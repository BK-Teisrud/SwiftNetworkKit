import Foundation
import Network
import Testing
import NetworkKit
import os
import Darwin

private enum NativeFixtureFailure: Error { case startup, malformed, measurement }
private struct NativeReply: Decodable, Sendable { let value: String }
private struct NativeEndpoint<Value: Sendable>: Endpoint {
    let path: EndpointPath
    let responseStrategy: ResponseStrategy<Value>
    let options: NetworkCallOptions
}

/// Test-only, credential-free SDK traffic. Required local endpoint prevents LAN exposure.
private final class NativeLoopbackFixture: Sendable {
    private struct State {
        var ready = false
        var failed = false
        var stopped = false
        var connections: [UUID: NWConnection] = [:]
        var counts: [String: Int] = [:]
        var cookies = 0
        var credentials = 0
        var redirect: String?
    }
    private let state = OSAllocatedUnfairLock(initialState: State())
    private let listener: NWListener
    private let queue = DispatchQueue(label: "NetworkKit.synthetic.loopback")

    private init() throws {
        let parameters = NWParameters.tcp
        parameters.requiredLocalEndpoint = .hostPort(host: "127.0.0.1", port: .any)
        listener = try NWListener(using: parameters)
    }

    static func start() async throws -> NativeLoopbackFixture {
        let fixture = try NativeLoopbackFixture()
        fixture.listener.stateUpdateHandler = { [weak fixture] value in
            guard let fixture else { return }
            fixture.state.withLock { state in
                switch value {
                case .ready: state.ready = true
                case .failed: state.failed = true
                case .cancelled: state.stopped = true
                default: break
                }
            }
        }
        fixture.listener.newConnectionHandler = { [weak fixture] connection in
            guard let fixture else { connection.cancel(); return }
            let id = UUID()
            fixture.state.withLock { $0.connections[id] = connection }
            connection.stateUpdateHandler = { [weak fixture] value in
                if case .cancelled = value { fixture?.state.withLock { $0.connections[id] = nil } }
                if case .failed = value { fixture?.state.withLock { $0.connections[id] = nil } }
            }
            connection.start(queue: fixture.queue)
            fixture.read(connection, id: id, previous: Data())
        }
        fixture.listener.start(queue: fixture.queue)
        do {
            for _ in 0..<200 {
                if fixture.state.withLock({ $0.ready }) && fixture.listener.port != nil { return fixture }
                if fixture.state.withLock({ $0.failed }) { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            throw NativeFixtureFailure.startup
        } catch {
            _ = await fixture.stop()
            throw error
        }
    }

    var base: URL {
        get throws {
            guard let port = listener.port,
                  let url = URL(string: "http://127.0.0.1:\(port.rawValue)") else { throw NativeFixtureFailure.startup }
            return url
        }
    }
    func redirect(to url: URL) { state.withLock { $0.redirect = url.absoluteString } }
    func count(_ path: String) -> Int { state.withLock { $0.counts[path, default: 0] } }
    var receivedCookies: Int { state.withLock { $0.cookies } }
    var receivedCredentials: Int { state.withLock { $0.credentials } }
    func contacted(_ path: String, after count: Int) async throws -> Bool {
        for _ in 0..<200 {
            if self.count(path) > count { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return false
    }
    func stop() async -> Bool {
        listener.cancel()
        for connection in state.withLock({ Array($0.connections.values) }) { connection.cancel() }
        // Joined cleanup must remain observable even when the test task was cancelled.
        return await Task.detached { [self] in
            for _ in 0..<200 {
                if state.withLock({ $0.stopped && $0.connections.isEmpty }) { return true }
                try? await Task.sleep(for: .milliseconds(10))
            }
            return false
        }.value
    }

    private func read(_ connection: NWConnection, id: UUID, previous: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] data, _, complete, error in
            guard let self else { connection.cancel(); return }
            let buffer = previous + (data ?? Data())
            if buffer.count > 16384 { connection.cancel(); return }
            if let end = buffer.range(of: Data("\r\n\r\n".utf8)),
               let headers = String(data: buffer[..<end.upperBound], encoding: .utf8),
               let line = headers.components(separatedBy: "\r\n").first {
                let parts = line.split(separator: " ")
                guard parts.count >= 2 else { connection.cancel(); return }
                self.respond(connection, path: String(parts[1]), headers: headers.lowercased())
            } else if complete || error != nil { connection.cancel() }
            else { self.read(connection, id: id, previous: buffer) }
        }
    }

    private func respond(_ connection: NWConnection, path: String, headers: String) {
        state.withLock {
            $0.counts[path, default: 0] += 1
            if headers.contains("\r\ncookie:") { $0.cookies += 1 }
            if headers.contains("\r\nauthorization:") { $0.credentials += 1 }
        }
        if path == "/hold" {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1) { _, _, _, _ in connection.cancel() }
            return
        }
        var status = 200
        var extra = "Cache-Control: no-store\r\n"
        var body = Data(#"{"value":"synthetic"}"#.utf8)
        switch path {
        case "/empty": status = 204; body = Data()
        case "/status": status = 503; body = Data("invalid-json".utf8)
        case "/bad-json": body = Data("invalid-json".utf8)
        case "/payload": body = Data(repeating: 120, count: 65536)
        case "/large": body = Data(repeating: 120, count: 1048576)
        case "/redirect": status = 302; extra += "Location: /json\r\n"; body = Data()
        case "/cross": status = 302; extra += "Location: \(state.withLock { $0.redirect } ?? "/json")\r\n"; body = Data()
        case "/loop-a": status = 302; extra += "Location: /loop-b\r\n"; body = Data()
        case "/loop-b": status = 302; extra += "Location: /loop-a\r\n"; body = Data()
        case "/cookie": extra += "Set-Cookie: snk_fixture=synthetic; Path=/; Max-Age=3600\r\n"
        case "/cache": extra = "Cache-Control: public, max-age=3600\r\nETag: \"synthetic\"\r\n"
        case "/challenge":
            if !headers.contains("authorization: basic zml4dhvyztpzew50agv0awm=") {
                status = 401; extra += "WWW-Authenticate: Basic realm=\"NetworkKit-synthetic\"\r\n"
            }
        default: break
        }
        let date = DateFormatter()
        date.locale = Locale(identifier: "en_US_POSIX"); date.timeZone = TimeZone(secondsFromGMT: 0)
        date.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
        var bytes = Data("HTTP/1.1 \(status) Fixture\r\nDate: \(date.string(from: Date()))\r\nContent-Type: application/json\r\n\(extra)Content-Length: \(body.count)\r\nConnection: close\r\n\r\n".utf8)
        bytes.append(body)
        connection.send(content: bytes, completion: .contentProcessed { _ in connection.cancel() })
    }
}

private func nativeFixture(_ body: (NativeLoopbackFixture, URL) async throws -> Void) async throws {
    let fixture = try await NativeLoopbackFixture.start()
    do {
        try await body(fixture, fixture.base)
        #expect(await fixture.stop(), "Native fixture failed bounded listener/connection cleanup")
    } catch {
        #expect(await fixture.stop(), "Native fixture failed cleanup after error")
        throw error
    }
}

private func nativeClient(_ base: URL, session: URLSession? = nil, diagnostics: (any NetworkDiagnosticSink)? = nil) throws -> APIClient {
    let config = NetworkConfiguration(baseURL: base, timeouts: try .init(inactivity: 2, total: 4),
                                      security: .init(allowInsecureLoopback: true), diagnostics: diagnostics)
    if let session { return try APIClient(configuration: config, session: session) }
    return try APIClient(configuration: config)
}

private func nativeSend<Value: Sendable>(_ input: Input, client: APIClient, base: URL, path: String,
    response: ResponseStrategy<Value>, options: NetworkCallOptions = .default) async throws -> NetworkResponse<Value> {
    if input == .typed {
        return try await client.send(NativeEndpoint(path: .init(segments: [path]), responseStrategy: response, options: options))
    }
    return try await client.send(URLRequest(url: base.appendingPathComponent(path)), response: response, options: options)
}

/// Same serialized opt-in suite as HTTPS checks; no automatic root/CI execution.
extension PublicHTTPSTests {
    @Test(arguments: Input.allCases)
    func nativeLoopbackResponseParity(input: Input) async throws {
        try await nativeFixture { fixture, base in
            let client = try nativeClient(base)
            do {
                let json = try await nativeSend(input, client: client, base: base, path: "json", response: .json(NativeReply.self))
                #expect(json.value.value == "synthetic" && json.status.code == 200)
                let data = try await nativeSend(input, client: client, base: base, path: "payload", response: .data)
                #expect(data.value.count == 65536 && data.value.allSatisfy { $0 == 120 })
                #expect(try await nativeSend(input, client: client, base: base, path: "empty", response: .empty).status.code == 204)
                do {
                    _ = try await nativeSend(input, client: client, base: base, path: "status", response: .json(NativeReply.self))
                    Issue.record("Expected native HTTP failure before decoding")
                } catch NetworkError.httpStatus(let status, _) { #expect(status.code == 503) }
                #expect(fixture.count("/json") == 1 && fixture.count("/payload") == 1)
                await client.shutdown()
            } catch { await client.shutdown(); throw error }
            print("NativeLoopback response \(input.rawValue): passed")
        }
    }

    @Test(arguments: Input.allCases)
    func nativeLoopbackRedirectCounters(input: Input) async throws {
        try await nativeFixture { fixture, base in
            try await nativeFixture { destination, other in
                fixture.redirect(to: other.appendingPathComponent("json"))
                let client = try nativeClient(base)
                do {
                    let response = try await nativeSend(input, client: client, base: base, path: "redirect", response: .json(NativeReply.self))
                    #expect(response.value.value == "synthetic" && fixture.count("/json") == 1)
                    let denied = try await nativeSend(input, client: client, base: base, path: "cross", response: .data,
                        options: .init(acceptedStatuses: .init(codes: [302])))
                    #expect(denied.status.code == 302 && destination.count("/json") == 0)
                    let control = URLSession(configuration: .ephemeral)
                    defer { control.invalidateAndCancel() }
                    let (_, followed) = try await control.data(from: base.appendingPathComponent("cross"))
                    #expect((followed as? HTTPURLResponse)?.statusCode == 200 && destination.count("/json") == 1)
                    do {
                        _ = try await nativeSend(input, client: client, base: base, path: "loop-a", response: .data)
                        Issue.record("Expected native redirect loop failure")
                    } catch NetworkError.invalidResponse(let reason) { #expect(reason == .redirectLimitExceeded) }
                    #expect(fixture.count("/loop-a") == 1 && fixture.count("/loop-b") == 1)
                    await client.shutdown()
                } catch { await client.shutdown(); throw error }
            }
            print("NativeLoopback redirects \(input.rawValue): counters passed")
        }
    }

    @Test(arguments: Input.allCases, Ownership.allCases)
    func nativeLoopbackStrictStorage(input: Input, ownership: Ownership) async throws {
        try await nativeFixture { fixture, base in
            let settings = URLSessionConfiguration.ephemeral
            settings.httpCookieStorage = nil; settings.httpShouldSetCookies = false
            settings.urlCredentialStorage = nil; settings.urlCache = nil
            settings.httpCookieAcceptPolicy = .never
            settings.requestCachePolicy = .reloadIgnoringLocalCacheData
            settings.timeoutIntervalForRequest = 2; settings.timeoutIntervalForResource = 4
            let session = ownership == .borrowed ? URLSession(configuration: settings) : nil
            defer { session?.invalidateAndCancel() }
            let client = try nativeClient(base, session: session)
            do {
                for _ in 0..<2 {
                    _ = try await nativeSend(input, client: client, base: base, path: "cookie", response: .data)
                    _ = try await nativeSend(input, client: client, base: base, path: "cache", response: .data)
                }
                #expect(fixture.count("/cookie") == 2 && fixture.count("/cache") == 2)
                #expect(fixture.receivedCookies == 0 && fixture.receivedCredentials == 0)
                do {
                    _ = try await nativeSend(input, client: client, base: base, path: "forbidden", response: .data,
                        options: .init(headers: .init(["Authorization": "Basic synthetic"])))
                    Issue.record("Expected credentials-over-HTTP rejection before contact")
                } catch NetworkError.invalidRequest(let reason) { #expect(reason == .credentialsOverHTTP) }
                #expect(fixture.count("/forbidden") == 0)
                let contactControl = URLSession(configuration: settings)
                defer { contactControl.invalidateAndCancel() }
                _ = try await contactControl.data(from: base.appendingPathComponent("forbidden"))
                #expect(fixture.count("/forbidden") == 1 && fixture.receivedCredentials == 0)
                do {
                    let response = try await nativeSend(input, client: client, base: base, path: "challenge", response: .data,
                        options: .init(acceptedStatuses: .init(codes: [401])))
                    #expect(response.status.code == 401)
                } catch let error as NetworkError {
                    let failure = try #require(error.transportFailure)
                    #expect(failure.domain == NSURLErrorDomain)
                    #expect([URLError.userCancelledAuthentication.rawValue, URLError.cancelled.rawValue].contains(failure.code))
                }
                #expect(fixture.count("/challenge") >= 1 && fixture.receivedCredentials == 0)
                await client.shutdown()
                if let session {
                    let (_, response) = try await session.data(from: base.appendingPathComponent("empty"))
                    #expect((response as? HTTPURLResponse)?.statusCode == 204)
                }
            } catch { await client.shutdown(); throw error }
            print("NativeLoopback storage \(input.rawValue) \(ownership.rawValue): counters passed")
        }
    }

    @Test(arguments: Input.allCases)
    func nativeLoopbackObservedCancellationAndShutdown(input: Input) async throws {
        try await nativeFixture { fixture, base in
            for shutdown in [false, true] {
                let client = try nativeClient(base)
                let before = fixture.count("/hold")
                let task = Task { try await nativeSend(input, client: client, base: base, path: "hold", response: .data) }
                do {
                let contacted = try await fixture.contacted("/hold", after: before)
                try #require(contacted)
                if shutdown { await client.shutdown() } else { task.cancel() }
                do { _ = try await task.value; Issue.record("Expected cancellation after actual fixture contact") }
                catch is CancellationError { }
                if !shutdown {
                    #expect(try await nativeSend(input, client: client, base: base, path: "empty", response: .empty).status.code == 204)
                    await client.shutdown()
                } else {
                    do {
                        _ = try await nativeSend(input, client: client, base: base, path: "empty", response: .empty)
                        Issue.record("Expected closed-client admission failure")
                    } catch NetworkError.invalidRequest(let reason) { #expect(reason == .clientClosed) }
                }
                } catch {
                    task.cancel()
                    _ = await task.result
                    await client.shutdown()
                    throw error
                }
            }
            print("NativeLoopback lifecycle \(input.rawValue): contacted, cancelled, joined")
        }
    }

    @Test(arguments: Input.allCases)
    func nativeLoopbackNativeBudgets(input: Input) async throws {
        try await nativeFixture { fixture, base in
            for total in [false, true] {
                let client = try nativeClient(base)
                do {
                    let options = try NetworkCallOptions(inactivityTimeout: total ? 2 : 0.25, totalTimeout: total ? 0.15 : 3)
                    _ = try await nativeSend(input, client: client, base: base, path: "hold", response: .data, options: options)
                    Issue.record("Expected native budget expiration")
                } catch NetworkError.timeout(let reason) { #expect(reason == (total ? .totalBudget : .system)) }
                catch { await client.shutdown(); throw error }
                await client.shutdown()
            }
            #expect(fixture.count("/hold") == 2)
            print("NativeLoopback budgets \(input.rawValue): Foundation request timeout and library total")
        }
    }
}

private final class NativeDiagnosticCounter: NetworkDiagnosticSink {
    private let state = OSAllocatedUnfairLock(initialState: (count: 0, invalid: 0))
    func record(_ event: NetworkDiagnosticEvent) {
        let valid = event.method == .get && event.status?.code == 200 && event.outcome == .success
        state.withLock { $0.count += 1; if !valid { $0.invalid += 1 } }
    }
    var count: Int { state.withLock { $0.count } }
    var invalid: Int { state.withLock { $0.invalid } }
}

private func nativeResidentBytes() throws -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    guard result == KERN_SUCCESS else { throw NativeFixtureFailure.measurement }
    return UInt64(info.resident_size)
}

extension PublicHTTPSTests {
    @Test
    func nativeLoopbackPrivateAppStoreControls() async throws {
        try await nativeFixture { fixture, base in
            let settings = URLSessionConfiguration.ephemeral
            settings.httpCookieAcceptPolicy = .always
            let cookies = try #require(settings.httpCookieStorage)
            let credentials = try #require(settings.urlCredentialStorage)
            try #require(cookies !== HTTPCookieStorage.shared && credentials !== URLCredentialStorage.shared)
            let cache = URLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 0, diskPath: nil)
            settings.urlCache = cache
            let protection = URLProtectionSpace(host: "127.0.0.1", port: try #require(base.port), protocol: "http",
                realm: "NetworkKit-synthetic", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
            let credential = URLCredential(user: "fixture", password: "synthetic", persistence: .forSession)
            credentials.setDefaultCredential(credential, for: protection)
            let session = URLSession(configuration: settings)
            defer {
                session.invalidateAndCancel()
                for cookie in cookies.cookies ?? [] { cookies.deleteCookie(cookie) }
                credentials.remove(credential, for: protection)
                cache.removeAllCachedResponses()
            }
            _ = try await session.data(from: base.appendingPathComponent("cookie"))
            _ = try await session.data(from: base.appendingPathComponent("cookie"))
            #expect(fixture.receivedCookies > 0 && cookies.cookies?.isEmpty == false)
            let request = URLRequest(url: base.appendingPathComponent("cache"))
            _ = try await session.data(for: request)
            for _ in 0..<200 {
                if cache.cachedResponse(for: request) != nil { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            try #require(cache.cachedResponse(for: request) != nil)
            _ = try await session.data(for: request)
            #expect(fixture.count("/cache") == 1)
            let (_, response) = try await session.data(from: base.appendingPathComponent("challenge"))
            #expect((response as? HTTPURLResponse)?.statusCode == 200 && fixture.receivedCredentials > 0)
            for cookie in cookies.cookies ?? [] { cookies.deleteCookie(cookie) }
            credentials.remove(credential, for: protection)
            cache.removeAllCachedResponses()
            #expect(cookies.cookies?.isEmpty != false)
            #expect(credentials.defaultCredential(for: protection) == nil && cache.cachedResponse(for: request) == nil)
            print("NativeLoopback app controls: cookie/cache/credential positive and explicit private deletion")
        }
    }

    @Test
    func nativeLoopbackConcurrentResourceObservations() async throws {
        try await nativeFixture { fixture, base in
            for (path, bytes, concurrency, calls) in [("payload", 65536, 4, 64), ("large", 1048576, 8, 32)] {
                for direct in (bytes == 65536 ? [false, true] : [true, false]) {
                    let diagnostics = NativeDiagnosticCounter()
                    let client = try nativeClient(base, diagnostics: diagnostics)
                    let settings = URLSessionConfiguration.ephemeral
                    settings.httpCookieStorage = nil; settings.httpShouldSetCookies = false
                    settings.urlCredentialStorage = nil; settings.urlCache = nil
                    settings.timeoutIntervalForRequest = 2; settings.timeoutIntervalForResource = 4
                    let session = URLSession(configuration: settings)
                    let before = fixture.count("/" + path)
                    let initial = try nativeResidentBytes()
                    do {
                        func perform(_ index: Int) async throws {
                            let value: Data
                            if direct { value = try await session.data(from: base.appendingPathComponent(path)).0 }
                            else {
                                value = try await nativeSend(index.isMultiple(of: 2) ? .typed : .raw,
                                    client: client, base: base, path: path, response: .data).value
                            }
                            try #require(value.count == bytes && value.allSatisfy { $0 == 120 })
                        }
                        try await perform(0)
                        let warm = try nativeResidentBytes()
                        for offset in stride(from: 0, to: calls, by: concurrency) {
                            try await withThrowingTaskGroup(of: Void.self) { group in
                                for index in offset..<min(offset + concurrency, calls) { group.addTask { try await perform(index) } }
                                try await group.waitForAll()
                            }
                        }
                        let completed = try nativeResidentBytes()
                        await client.shutdown()
                        session.invalidateAndCancel()
                        try await Task.sleep(for: .seconds(6))
                        let settled = try nativeResidentBytes()
                        #expect(fixture.count("/" + path) - before == calls + 1)
                        #expect(diagnostics.count == (direct ? 0 : calls + 1) && diagnostics.invalid == 0)
                        print("NativeLoopback resource mode=\(direct ? "foundation" : "networkkit") bytes=\(bytes) concurrency=\(concurrency) calls=\(calls + 1) rssInitial=\(initial) rssWarm=\(warm) rssCompleted=\(completed) rssAfterOriginalBudget=\(settled) settleSeconds=6")
                    } catch { await client.shutdown(); session.invalidateAndCancel(); throw error }
                }
            }
        }
    }
}
