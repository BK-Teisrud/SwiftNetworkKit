import Foundation
import Testing
import NetworkKit
import Security
import os

enum Input: String, CaseIterable, Sendable { case typed, raw }

private struct PublicEndpoint<Value: Sendable>: Endpoint {
    let path: EndpointPath
    let responseStrategy: ResponseStrategy<Value>
    let options: NetworkCallOptions
}

private struct SlideShow: Decodable, Sendable {
    struct Contents: Decodable, Sendable { let title: String }
    let slideshow: Contents
}

/// Corroboration only: ordinary ephemeral URLSession, system default trust handling.
/// Never returns a credential or accepts a failed trust decision.
private final class TrustObservation: NSObject, URLSessionTaskDelegate {
    private struct State: Sendable { var challengeSeen = false; var trustError: Int?; var knownDomain = false }
    private let state = OSAllocatedUnfairLock(initialState: State())

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            var error: CFError?
            _ = SecTrustEvaluateWithError(trust, &error)
            let code = error.map { CFErrorGetCode($0) }
            let known = error.map { CFEqual(CFErrorGetDomain($0), kCFErrorDomainOSStatus) } ?? false
            state.withLock { $0.challengeSeen = true; $0.trustError = code; $0.knownDomain = known }
        }
        completionHandler(.performDefaultHandling, nil)
    }

    func corroborate(base: URL, name: String, input: Input, expectedTrustError: Int) async -> Bool {
        let settings = URLSessionConfiguration.ephemeral
        settings.httpCookieStorage = nil; settings.urlCredentialStorage = nil; settings.urlCache = nil
        settings.timeoutIntervalForRequest = 5; settings.timeoutIntervalForResource = 10
        let session = URLSession(configuration: settings)
        defer { session.invalidateAndCancel() }
        var code: Int?
        var knownTransportDomain = false
        do { _ = try await session.data(for: URLRequest(url: base), delegate: self) }
        catch { let error = error as NSError; code = error.code; knownTransportDomain = error.domain == NSURLErrorDomain }
        let observation = state.withLock { $0 }
        print("PublicHTTPS corroboration \(name) \(input.rawValue): challenge=\(observation.challengeSeen) trust-code=\(observation.trustError.map(String.init) ?? "none") transport-code=\(code.map(String.init) ?? "none")")
        return observation.challengeSeen && observation.knownDomain && observation.trustError == expectedTrustError
            && knownTransportDomain && code == URLError.secureConnectionFailed.rawValue
    }
}

/// Only this separate, manually invoked package contacts public services.
/// No credentials, arbitrary URL, trust delegate, TLS override or library retry.
@Suite(.serialized, .timeLimit(.minutes(1)))
struct PublicHTTPSTests {
    private func run(base: String = "https://httpbingo.org",
                     body: (APIClient, URL) async throws -> Void) async throws {
        let url = try #require(URL(string: base))
        let client = try APIClient(configuration: .init(baseURL: url,
            timeouts: .init(inactivity: 5, total: 10)))
        do {
            try await body(client, url)
            await client.shutdown()
        } catch {
            await client.shutdown()
            throw error
        }
    }

    private func send<Value: Sendable>(_ input: Input, client: APIClient, base: URL,
        path: [String], response: ResponseStrategy<Value>,
        options: NetworkCallOptions = .default) async throws -> NetworkResponse<Value> {
        switch input {
        case .typed:
            return try await client.send(PublicEndpoint(path: .init(segments: path),
                responseStrategy: response, options: options))
        case .raw:
            let url = path.reduce(base) { $0.appendingPathComponent($1) }
            return try await client.send(URLRequest(url: url), response: response, options: options)
        }
    }

    @Test(arguments: Input.allCases)
    func trustedJSON(input: Input) async throws {
        try await run { client, base in
            let response = try await send(input, client: client, base: base, path: ["json"],
                response: .json(SlideShow.self))
            try #require(response.status.code == 200)
            let valid = !response.value.slideshow.title.isEmpty
            try #require(valid)
            print("PublicHTTPS json \(input.rawValue): status=200")
        }
    }

    @Test(arguments: Input.allCases)
    func explicitEmptyResponse(input: Input) async throws {
        try await run { client, base in
            let response = try await send(input, client: client, base: base, path: ["status", "204"], response: .empty)
            try #require(response.status.code == 204)
            print("PublicHTTPS empty \(input.rawValue): status=204")
        }
    }

    @Test(arguments: Input.allCases)
    func HTTPFailurePrecedesDecode(input: Input) async throws {
        try await run { client, base in
            do {
                _ = try await send(input, client: client, base: base, path: ["status", "503"],
                    response: .json(SlideShow.self))
                Issue.record("Expected an HTTP status failure")
            } catch NetworkError.httpStatus(let status, _) {
                try #require(status.code == 503)
                print("PublicHTTPS status \(input.rawValue): status=503")
            }
        }
    }

    @Test(arguments: Input.allCases)
    func sameOriginRedirect(input: Input) async throws {
        try await run { client, base in
            let response = try await send(input, client: client, base: base,
                path: ["relative-redirect", "1"], response: .data)
            try #require(response.status.code == 200)
            // The echo contains client/network metadata: inspect locally, never print/save it.
            let object = (try? JSONSerialization.jsonObject(with: response.value)) as? [String: Any]
            let finalURL = (object?["url"] as? String).flatMap(URL.init(string:))
            let valid = finalURL?.scheme == "https" && finalURL?.host == "httpbingo.org" && finalURL?.path == "/get"
            try #require(valid)
            print("PublicHTTPS redirect \(input.rawValue): status=200")
        }
    }

    @Test(arguments: Input.allCases)
    func validBadsslControl(input: Input) async throws {
        try await run(base: "https://sha256.badssl.com") { client, base in
            let response = try await send(input, client: client, base: base, path: [], response: .data)
            try #require(response.status.code == 200)
            let valid = !response.value.isEmpty
            try #require(valid)
            print("PublicHTTPS valid-certificate \(input.rawValue): status=200")
        }
    }

    @Test(arguments: Input.allCases)
    func untrustedCertificate(input: Input) async throws {
        try await rejection(input, base: "https://self-signed.badssl.com", name: "self-signed", expectedTrustError: Int(errSecNotTrusted))
    }

    @Test(arguments: Input.allCases)
    func operatorDesignatedHostnameMismatch(input: Input) async throws {
        try await rejection(input, base: "https://wrong.host.badssl.com", name: "wrong-host", expectedTrustError: Int(errSecHostNameMismatch))
    }

    private func rejection(_ input: Input, base: String, name: String, expectedTrustError: Int) async throws {
        try await run(base: base) { client, base in
            do {
                _ = try await send(input, client: client, base: base, path: [], response: .data)
                Issue.record("Invalid public certificate was accepted")
            } catch NetworkError.transport(let failure) {
                var certificateRejected = failure.domain == NSURLErrorDomain &&
                    [URLError.serverCertificateUntrusted.rawValue, URLError.serverCertificateHasUnknownRoot.rawValue].contains(failure.code)
                if !certificateRejected && failure.domain == NSURLErrorDomain && failure.code == URLError.secureConnectionFailed.rawValue {
                    print("PublicHTTPS certificate-observation \(name) \(input.rawValue): known-domain=\(failure.domain == NSURLErrorDomain) code=\(failure.code)")
                    certificateRejected = await TrustObservation().corroborate(base: base, name: name, input: input, expectedTrustError: expectedTrustError)
                }
                try #require(certificateRejected)
                print("PublicHTTPS \(name) \(input.rawValue): certificate-rejected=\(failure.code)")
            }
        }
    }

    @Test(arguments: Input.allCases)
    func totalBudget(input: Input) async throws {
        try await run { client, base in
            do {
                _ = try await send(input, client: client, base: base, path: ["delay", "3"],
                    response: .data, options: .init(totalTimeout: 0.25))
                Issue.record("Delayed public response escaped the total budget")
            } catch NetworkError.timeout(.totalBudget) {
                print("PublicHTTPS total-budget \(input.rawValue): totalBudget")
            }
        }
    }
}
