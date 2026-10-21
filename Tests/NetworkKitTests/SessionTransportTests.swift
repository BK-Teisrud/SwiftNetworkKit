import Foundation
import Testing
import os
@testable import NetworkKit

/// Foundation requires this inherited conformance to be restated. Instances contain no
/// mutable state; the only shared fixture registry is protected by OSAllocatedUnfairLock.
private final class SessionStubProtocol: URLProtocol, @unchecked Sendable {
    struct Fixture: Sendable {
        let data: Data
        let status: Int
        let headers: [String: String]
        var hold = false
        var onStart: (@Sendable () -> Void)? = nil
        var onRequest: (@Sendable (URLRequest) -> Void)? = nil
    }
    static let fixtures = OSAllocatedUnfairLock(initialState: [String: Fixture]())
    static func install(_ fixture: Fixture) -> URL {
        let url = URL(string: "https://example.invalid/" + UUID().uuidString)!
        fixtures.withLock { $0[url.absoluteString] = fixture }
        return url
    }
    static func remove(_ url: URL) { _ = fixtures.withLock { $0.removeValue(forKey: url.absoluteString) } }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url,
              let fixture = Self.fixtures.withLock({ $0[url.absoluteString] }) else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable)); return
        }
        fixture.onRequest?(request)
        fixture.onStart?()
        if fixture.hold { return }
        let response = HTTPURLResponse(url: url, statusCode: fixture.status, httpVersion: "HTTP/1.1", headerFields: fixture.headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: fixture.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

private final class UnsupportedSessionDelegate: NSObject, URLSessionDelegate {}

@Suite struct SessionTransportTests {
    private func configuration() -> URLSessionConfiguration {
        let config = URLSessionTransport.configuration()
        config.protocolClasses = [SessionStubProtocol.self]
        return config
    }
    private func fixture() -> URL {
        SessionStubProtocol.install(.init(data: Data("buffered".utf8), status: 201,
                                        headers: ["X-Result": "ok", "Set-Cookie": "secret=value"]))
    }

    @Test func strictConfigurationDisablesAutomaticStorage() {
        let config = URLSessionTransport.configuration()
        #expect(config.httpCookieStorage == nil)
        #expect(config.urlCredentialStorage == nil)
        #expect(config.urlCache == nil)
        #expect(!config.httpShouldSetCookies)
        #expect(config.httpCookieAcceptPolicy == .never)
        #expect(config.requestCachePolicy == .reloadIgnoringLocalCacheData)
        #expect(!config.waitsForConnectivity)
        #expect(config.timeoutIntervalForRequest == 30)
        #expect(config.timeoutIntervalForResource > 60)
    }

    @Test func ownedSessionIsReusedAndSnapshotsItsConfiguration() async throws {
        let config = configuration()
        let transport = try URLSessionTransport(ownedConfiguration: config)
        let session = await transport.session
        config.httpShouldSetCookies = true
        let url = fixture(); defer { SessionStubProtocol.remove(url) }
        for _ in 0..<2 {
            let result = try await transport.send(URLRequest(url: url))
            #expect(result.data == Data("buffered".utf8))
            #expect((result.response as? HTTPURLResponse)?.statusCode == 201)
            #expect((result.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "x-result") == "ok")
        }
        #expect(await transport.session === session)
        #expect(!session.configuration.httpShouldSetCookies)
        #expect(session.configuration.httpCookieStorage == nil)
        await transport.invalidateOwnedSession()
        await transport.invalidateOwnedSession()
        await #expect(throws: NetworkError.invalidRequest(.clientClosed)) {
            try await transport.send(URLRequest(url: url))
        }
    }

    @Test func injectedSessionSurvivesAdapterCleanupAndDeinit() async throws {
        let session = URLSession(configuration: configuration())
        defer { session.invalidateAndCancel() }
        let url = fixture(); defer { SessionStubProtocol.remove(url) }
        var adapter: URLSessionTransport? = try URLSessionTransport(session: session)
        #expect(await adapter!.session === session)
        #expect(await adapter!.ownsSession == false)
        _ = try await adapter!.send(URLRequest(url: url))
        await adapter!.invalidateOwnedSession()
        adapter = nil
        let (data, _) = try await session.data(for: URLRequest(url: url))
        #expect(data == Data("buffered".utf8))
    }

    @Test func defaultStoredSessionsRequireExplicitAppManagedPolicy() throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [SessionStubProtocol.self]
        let session = URLSession(configuration: config)
        defer { session.invalidateAndCancel() }
        #expect(throws: NetworkError.invalidRequest(.invalidConfiguration)) { try URLSessionTransport(session: session) }
        let borrowed = try URLSessionTransport(session: session, storagePolicy: .appManaged)
        _ = borrowed
        #expect(session.configuration.httpCookieStorage != nil)
        #expect(session.configuration.httpShouldSetCookies)
        #expect(session.configuration.urlCache != nil)
    }

    @Test func externalDelegateIsRejectedEvenWithAppManagedStorage() throws {
        let session = URLSession(configuration: configuration(), delegate: UnsupportedSessionDelegate(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        #expect(throws: NetworkError.invalidRequest(.unsupportedRequest)) {
            try URLSessionTransport(session: session, storagePolicy: .appManaged)
        }
    }

    @Test func strictInjectionRejectsEachIncompatibleSetting() throws {
        for index in 0..<6 {
            let config = configuration()
            switch index {
            case 0: config.httpCookieStorage = HTTPCookieStorage.shared
            case 1: config.httpShouldSetCookies = true
            case 2: config.httpCookieAcceptPolicy = .always
            case 3: config.urlCredentialStorage = URLCredentialStorage.shared
            case 4: config.urlCache = URLCache(memoryCapacity: 1024, diskCapacity: 0)
            default: config.requestCachePolicy = .returnCacheDataElseLoad
            }
            let session = URLSession(configuration: config)
            defer { session.invalidateAndCancel() }
            #expect(throws: NetworkError.invalidRequest(.invalidConfiguration)) { try URLSessionTransport(session: session) }
        }
    }

    @Test func concurrentCallsOnOneSessionRemainIndependent() async throws {
        let transport = try URLSessionTransport(ownedConfiguration: configuration())
        let url = fixture(); defer { SessionStubProtocol.remove(url) }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask { () async throws -> Void in
                    let result = try await transport.send(URLRequest(url: url))
                    #expect(result.data == Data("buffered".utf8))
                }
            }
            try await group.waitForAll()
        }
        await transport.invalidateOwnedSession()
    }

    @Test func streamsAreRejectedBeforeTransport() async throws {
        let transport = try URLSessionTransport(ownedConfiguration: configuration())
        var request = URLRequest(url: URL(string: "https://example.invalid")!)
        request.httpBodyStream = InputStream(data: Data())
        await #expect(throws: NetworkError.invalidRequest(.unsupportedRequest)) { try await transport.send(request) }
        await transport.invalidateOwnedSession()
    }

    @Test func cancellationAtEntryDoesNotStartRequest() async throws {
        try await Task {
            withUnsafeCurrentTask { $0?.cancel() }
            let transport = try URLSessionTransport(ownedConfiguration: configuration())
            await #expect(throws: CancellationError.self) {
                try await transport.send(URLRequest(url: URL(string: "https://example.invalid")!))
            }
            await transport.invalidateOwnedSession()
        }.value
    }

    @Test(.timeLimit(.minutes(1))) func externalInvalidationStopsAnActiveBorrowedOperation() async throws {
        let session = URLSession(configuration: configuration())
        let adapter = try URLSessionTransport(session: session)
        let signal = AsyncStream<Void>.makeStream()
        let url = SessionStubProtocol.install(.init(data: Data(), status: 200, headers: [:], hold: true,
                                                   onStart: { signal.continuation.yield(()) }))
        defer { SessionStubProtocol.remove(url); signal.continuation.finish() }
        let operation = Task { try await adapter.send(URLRequest(url: url)) }
        var iterator = signal.stream.makeAsyncIterator()
        _ = await iterator.next()
        session.invalidateAndCancel()
        do {
            _ = try await operation.value
            Issue.record("External invalidation must stop the active operation")
        } catch let error as URLError {
            #expect(error.code == .cancelled)
        }
        #expect(await adapter.session === session)
    }

    @Test func invalidResourceLimitsAndOwnedStoresAreRejected() throws {
        for index in 0..<3 {
            let config = configuration()
            if index == 0 { config.timeoutIntervalForResource = 0 }
            if index == 1 { config.timeoutIntervalForRequest = 0 }
            if index == 2 { config.urlCache = URLCache(memoryCapacity: 1024, diskCapacity: 0) }
            #expect(throws: NetworkError.invalidRequest(.invalidConfiguration)) {
                try URLSessionTransport(ownedConfiguration: config)
            }
        }
    }

    @Test func strictRequestCopyPreventsCookieAndCacheOverrides() async throws {
        let observed = OSAllocatedUnfairLock(initialState: [URLRequest]())
        let url = SessionStubProtocol.install(.init(data: Data(), status: 200, headers: [:],
            onRequest: { request in observed.withLock { $0.append(request) } }))
        defer { SessionStubProtocol.remove(url) }
        let adapter = try URLSessionTransport(ownedConfiguration: configuration())
        var input = URLRequest(url: url)
        input.httpShouldHandleCookies = true
        input.cachePolicy = .returnCacheDataDontLoad
        _ = try await adapter.send(input)
        let requests = observed.withLock { $0 }
        #expect(requests.count == 1)
        #expect(requests.first?.httpShouldHandleCookies == false)
        #expect(requests.first?.cachePolicy == .reloadIgnoringLocalCacheData)
        #expect(input.httpShouldHandleCookies)
        #expect(input.cachePolicy == .returnCacheDataDontLoad)
        await adapter.invalidateOwnedSession()
    }

    @Test func backgroundConfigurationRejectedWhereAvailable() throws {
        #if os(macOS) || os(iOS) || os(watchOS)
        let config = URLSessionConfiguration.background(withIdentifier: "NetworkKitTest-" + UUID().uuidString)
        #expect(throws: NetworkError.invalidRequest(.unsupportedRequest)) {
            try URLSessionTransport(ownedConfiguration: config)
        }
        #else
        // tvOS does not offer this constructor. Its owned profile is foreground-only.
        #expect(URLSessionTransport.configuration().identifier == nil)
        #endif
    }

    @Test func resourceLimitRemainsSeparateFromRequestedTotalBudget() throws {
        let config = URLSessionTransport.configuration(timeouts: try NetworkTimeouts(inactivity: 45, total: 120))
        #expect(config.timeoutIntervalForRequest == 45)
        #expect(config.timeoutIntervalForResource == URLSessionConfiguration.ephemeral.timeoutIntervalForResource)
    }
}
