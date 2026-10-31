import Darwin
import Foundation
import NetworkKit
import Security
import os

// Explicit verification executable, never part of the shipped SDK or ordinary tests.
private struct ProbeEndpoint<Value: Sendable>: Endpoint {
    let path: EndpointPath
    let responseStrategy: ResponseStrategy<Value>
    let options: NetworkCallOptions
    let query: [HTTPQueryItem] = []
}
private struct SlideShow: Decodable, Sendable {
    struct Contents: Decodable, Sendable { let title: String }
    let slideshow: Contents
}
private struct ProbeFailure: Error { let phase: String }

private final class TrustControl: NSObject, URLSessionTaskDelegate {
    private struct State: Sendable { var challenge = false; var knownDomain = false; var code: Int? }
    private let state = OSAllocatedUnfairLock(initialState: State())

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            var error: CFError?
            _ = SecTrustEvaluateWithError(trust, &error)
            let knownDomain = error.map { CFEqual(CFErrorGetDomain($0), kCFErrorDomainOSStatus) } ?? false
            let code = error.map { CFErrorGetCode($0) }
            state.withLock {
                $0.challenge = true
                $0.knownDomain = knownDomain
                $0.code = code
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }

    func verify(_ url: URL, expected: Int) async -> Bool {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCredentialStorage = nil
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = NetworkTimeouts.default.inactivity
        configuration.timeoutIntervalForResource = NetworkTimeouts.default.total
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        do { _ = try await session.data(for: URLRequest(url: url), delegate: self); return false }
        catch {
            let failure = error as NSError
            let observed = state.withLock { $0 }
            return observed.challenge && observed.knownDomain && observed.code == expected
                && failure.domain == NSURLErrorDomain
                && [-1200, -1202, -1203].contains(failure.code)
        }
    }
}

@main struct NativeHTTPSProbe {
    private static func perform<Value: Sendable>(_ typed: Bool, base: URL, path: [String],
                                                 response: ResponseStrategy<Value>) async throws -> NetworkResponse<Value> {
        let client = try APIClient(configuration: .init(baseURL: base))
        do {
            let result: NetworkResponse<Value>
            if typed {
                result = try await client.send(ProbeEndpoint(path: .init(segments: path),
                    responseStrategy: response, options: .init()))
            } else {
                let url = path.reduce(base) { $0.appendingPathComponent($1) }
                result = try await client.send(URLRequest(url: url), response: response)
            }
            await client.shutdown()
            return result
        } catch { await client.shutdown(); throw error }
    }

    private static func url(_ value: String) throws -> URL {
        guard let url = URL(string: value) else { throw ProbeFailure(phase: "fixed-url") }
        return url
    }

    private static func rejection(_ typed: Bool, base: URL, expected: Int) async throws -> Int {
        do {
            _ = try await perform(typed, base: base, path: [], response: .data)
            throw ProbeFailure(phase: "invalid-certificate-accepted")
        } catch NetworkError.transport(let failure) {
            guard failure.domain == NSURLErrorDomain, [-1200, -1202, -1203].contains(failure.code),
                  await TrustControl().verify(base, expected: expected)
            else { throw ProbeFailure(phase: "certificate-evidence-inconclusive") }
            return failure.code
        }
    }

    static func main() async {
        guard CommandLine.arguments.count == 2, CommandLine.arguments[1] == "--public-https" else {
            print("Explicit --public-https selection required; no requests started.")
            exit(2)
        }
        var phase = "setup"
        var results: [[String: String]] = []
        do {
            for typed in [true, false] {
                let mode = typed ? "typed" : "raw"
                let bingo = try url("https://httpbingo.org")
                phase = mode + "-json"
                let json = try await perform(typed, base: bingo, path: ["json"], response: .json(SlideShow.self))
                guard json.status.code == 200, !json.value.slideshow.title.isEmpty else { throw ProbeFailure(phase: phase) }
                results.append(["case": phase, "result": "passed"])
                phase = mode + "-empty"
                let empty = try await perform(typed, base: bingo, path: ["status", "204"], response: .empty)
                guard empty.status.code == 204 else { throw ProbeFailure(phase: phase) }
                results.append(["case": phase, "result": "passed"])
                phase = mode + "-valid-certificate"
                let valid = try await perform(typed, base: url("https://sha256.badssl.com"), path: [], response: .data)
                guard valid.status.code == 200, !valid.value.isEmpty else { throw ProbeFailure(phase: phase) }
                results.append(["case": phase, "result": "passed"])
                for (name, address, expected) in [
                    ("self-signed", "https://self-signed.badssl.com", Int(errSecNotTrusted)),
                    ("wrong-host", "https://wrong.host.badssl.com", Int(errSecHostNameMismatch))
                ] {
                    phase = mode + "-" + name
                    let code = try await rejection(typed, base: url(address), expected: expected)
                    results.append(["case": phase, "result": "passed", "transport_code": String(code),
                                    "foundation_exact_trust_code": String(expected)])
                }
            }
            let data = try JSONSerialization.data(withJSONObject: ["result": "passed", "cases": results], options: [.sortedKeys])
            guard let output = String(data: data, encoding: .utf8) else { throw ProbeFailure(phase: "safe-output") }
            print(output)
        } catch {
            // Fixed labels only: never print an echo body, arbitrary decoder error or URLSession error description.
            let failed = (error as? ProbeFailure)?.phase ?? phase
            let data = try? JSONSerialization.data(withJSONObject: ["result": "failed", "phase": failed], options: [.sortedKeys])
            if let data, let output = String(data: data, encoding: .utf8) { print(output) }
            exit(1)
        }
    }
}
