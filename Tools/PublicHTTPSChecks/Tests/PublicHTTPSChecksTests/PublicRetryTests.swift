import Foundation
import Testing
import NetworkKit
import os

private enum RetryOwnership: String, CaseIterable, Sendable { case owned, borrowedStrict, borrowedAppManaged }
private struct HTTPSRetryCall: Endpoint {
    let path = try! EndpointPath(segments: ["status", "503"])
    let responseStrategy: ResponseStrategy<EmptyResponse> = .empty
    let options: NetworkCallOptions
}
private struct RetryCookies: Decodable { let cookies: [String: String] }
private final class HTTPSRetrySink: NetworkDiagnosticSink {
    private let lock = OSAllocatedUnfairLock(initialState: [NetworkDiagnosticEvent]())
    var events: [NetworkDiagnosticEvent] { lock.withLock { $0 } }
    func record(_ event: NetworkDiagnosticEvent) { lock.withLock { $0.append(event) } }
}

/// Explicit opt-in only, fixed public fixture with synthetic ephemeral cookie state.
/// SDK invocation counts are not external wire counters.
@Suite(.serialized, .timeLimit(.minutes(1))) struct PublicRetryTests {
    @Test(arguments: RetryOwnership.allCases, Input.allCases)
    private func publicRetryWithActiveHTTPSStorage(profile: RetryOwnership, input: Input) async throws {
        let base = URL(string: "https://httpbingo.org")!, sink = HTTPSRetrySink()
        let settings = URLSessionConfiguration.ephemeral
        settings.urlCredentialStorage = nil
        settings.timeoutIntervalForRequest = 5; settings.timeoutIntervalForResource = 10
        settings.requestCachePolicy = .reloadIgnoringLocalCacheData
        let cookieName = "snk_retry_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let store: HTTPCookieStorage?
        if profile == .borrowedAppManaged {
            let isolatedStore = try #require(settings.httpCookieStorage)
            try #require(isolatedStore !== HTTPCookieStorage.shared)
            store = isolatedStore
            settings.urlCache = URLCache(memoryCapacity: 131072, diskCapacity: 0)
            let cookie = try #require(HTTPCookie(properties: [.domain: "httpbingo.org", .path: "/",
                .name: cookieName, .value: "synthetic-memory-only", .secure: "TRUE",
                .expires: Date().addingTimeInterval(120)]))
            store?.setCookie(cookie)
        } else {
            store = nil
            settings.httpCookieStorage = nil; settings.httpShouldSetCookies = false
            settings.httpCookieAcceptPolicy = .never; settings.urlCache = nil
        }
        defer { for cookie in store?.cookies ?? [] { store?.deleteCookie(cookie) } }
        let session = profile == .owned ? nil : URLSession(configuration: settings)
        defer { session?.invalidateAndCancel() }
        let config = NetworkConfiguration(baseURL: base, timeouts: try NetworkTimeouts(inactivity: 5, total: 10), diagnostics: sink)
        let client: APIClient
        if let session { client = try APIClient(configuration: config, session: session,
            storage: profile == .borrowedAppManaged ? .appManaged : .strict) }
        else { client = try APIClient(configuration: config) }
        do {
            for enabled in [false, true] {
                let options = try NetworkCallOptions(retry: enabled ? .oneRetryForSafeReads : .disabled)
                do {
                    if input == .raw {
                        _ = try await client.send(URLRequest(url: base.appendingPathComponent("status/503")), response: .empty, options: options)
                    } else { _ = try await client.send(HTTPSRetryCall(options: options)) }
                    Issue.record("Expected fixed public HTTP 503")
                } catch let failure as NetworkError {
                    guard case .httpStatus(let status, _) = failure else { throw failure }
                    #expect(status.code == 503)
                }
            }
            #expect(sink.events.count == 2)
            #expect(sink.events.map(\.attemptCount) == [1, 2])
            #expect(sink.events.allSatisfy { $0.status?.code == 503 && $0.outcome == .httpStatus })
            await client.shutdown()
            if let session {
                if profile == .borrowedAppManaged {
                    // Owner's active store and session survive client shutdown.
                    let (data, response) = try await session.data(from: base.appendingPathComponent("cookies"))
                    #expect((response as? HTTPURLResponse)?.statusCode == 200)
                    let echoed = try JSONDecoder().decode(RetryCookies.self, from: data)
                    #expect(echoed.cookies[cookieName] == "synthetic-memory-only")
                    #expect(store?.cookies?.contains { $0.name == cookieName } == true)
                } else {
                    let (_, response) = try await session.data(from: base.appendingPathComponent("status/204"))
                    #expect((response as? HTTPURLResponse)?.statusCode == 204)
                }
            }
            for cookie in store?.cookies ?? [] { store?.deleteCookie(cookie) }
            #expect(store?.cookies?.contains { $0.name == cookieName } != true)
            print("PublicRetry \(profile.rawValue) \(input.rawValue): disabled=1 enabled=2 status=503")
        } catch {
            await client.shutdown()
            throw error
        }
    }
}
