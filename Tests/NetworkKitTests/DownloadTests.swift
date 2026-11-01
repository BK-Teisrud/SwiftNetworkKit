import Foundation
import Testing
import os
@testable import NetworkKit

private actor FileTestTransport: NetworkTransport {
    private(set) var calls = 0
    let work: @Sendable (URLRequest, DownloadFileOwner) async throws -> URLResponse
    init(_ work: @escaping @Sendable (URLRequest, DownloadFileOwner) async throws -> URLResponse) { self.work = work }
    func send(_ request: URLRequest) async throws -> TransportResponse { throw NetworkError.decoding }
    func download(_ request: URLRequest, owner: DownloadFileOwner) async throws -> URLResponse {
        calls += 1
        return try await work(request, owner)
    }
}
private final class FileSink: NetworkDiagnosticSink {
    private let state = OSAllocatedUnfairLock(initialState: [NetworkDiagnosticEvent]())
    var events: [NetworkDiagnosticEvent] { state.withLock { $0 } }
    func record(_ event: NetworkDiagnosticEvent) { state.withLock { $0.append(event) } }
}
private actor FileProvider: AuthenticationHeaderProvider {
    private(set) var calls = 0
    func headers(for context: AuthenticationContext) async throws -> HTTPHeaders {
        calls += 1
        return try HTTPHeaders(["Authorization": "synthetic-file-secret"])
    }
}
private struct FileFixture: Sendable {
    let root: URL
    let source: URL
    let destination: URL
    init(bytes: Int = 8) throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false,
                                               attributes: [.posixPermissions: 0o700])
        source = root.appendingPathComponent("native")
        destination = root.appendingPathComponent("preserved")
        try Data(repeating: 65, count: bytes).write(to: source)
    }
    var files: DownloadFileOperations {
        var value = DownloadFileOperations()
        let destination = destination
        value.destination = { destination }
        return value
    }
    func remove() { try? FileManager.default.removeItem(at: root) }
    var sourceExists: Bool { FileManager.default.fileExists(atPath: source.path) }
    var destinationExists: Bool { FileManager.default.fileExists(atPath: destination.path) }
}
private func fileResponse(_ request: URLRequest, status: Int = 200) -> HTTPURLResponse {
    HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: ["X-File": "synthetic"])!
}

@Suite(.timeLimit(.minutes(1))) struct DownloadTests {
    private let base = URL(string: "https://example.invalid")!

    @Test(arguments: [0, 8]) func successfulFileIsAppOwnedAndNeverDeletedByShutdown(bytes: Int) async throws {
        let fixture = try FileFixture(bytes: bytes); defer { fixture.remove() }
        let sink = FileSink(), provider = FileProvider()
        let transport = FileTestTransport { request, owner in
            #expect(request.value(forHTTPHeaderField: "Authorization") == "synthetic-file-secret")
            owner.adopt(fixture.source)
            return fileResponse(request)
        }
        let configuration = NetworkConfiguration(baseURL: base, authentication: .init(provider: provider), diagnostics: sink)
        let client = try APIClient(configuration: configuration, transport: transport, downloadFiles: fixture.files)
        let result = try await client.download(URLRequest(url: base), maximumBytes: 8)
        #expect(result.value.byteCount == Int64(bytes))
        #expect(result.status.code == 200 && result.headers["x-file"] == "synthetic")
        #expect(try Data(contentsOf: result.value.url) == Data(repeating: 65, count: bytes))
        #expect(!fixture.sourceExists && fixture.destinationExists)
        #expect(await provider.calls == 1)
        #expect(await transport.calls == 1)
        await client.shutdown()
        #expect(fixture.destinationExists)
        #expect(sink.events.count == 1 && sink.events.first?.attemptCount == 1)
        #expect(sink.events.first?.outcome == .success)
        #expect(!String(describing: result.value).contains(fixture.root.path))
    }

    @Test(arguments: [0, -1]) func invalidLimitStopsBeforeProviderAndTransport(limit: Int64) async throws {
        let provider = FileProvider(), sink = FileSink()
        let transport = FileTestTransport { request, _ in fileResponse(request) }
        let client = try APIClient(configuration: .init(baseURL: base, authentication: .init(provider: provider), diagnostics: sink), transport: transport)
        await #expect(throws: NetworkError.invalidRequest(.invalidConfiguration)) {
            try await client.download(URLRequest(url: base), maximumBytes: limit)
        }
        #expect(await provider.calls == 0)
        #expect(await transport.calls == 0)
        #expect(sink.events.first?.attemptCount == 0)
    }

    @Test(arguments: ["method", "body", "range", "if-range", "default-range", "call-range"])
    func unsupportedRequestsStopBeforeProviderAndTransport(kind: String) async throws {
        let provider = FileProvider()
        let transport = FileTestTransport { request, _ in fileResponse(request) }
        var request = URLRequest(url: base)
        if kind == "method" { request.httpMethod = "POST" }
        if kind == "body" { request.httpBody = Data() }
        if kind == "range" || kind == "if-range" { request.setValue("synthetic", forHTTPHeaderField: kind) }
        let headers = kind == "default-range" ? try HTTPHeaders(["Range": "bytes=0-1"]) : HTTPHeaders()
        let options = try DownloadOptions(headers: kind == "call-range" ? HTTPHeaders(["If-Range": "synthetic"]) : HTTPHeaders())
        let client = try APIClient(configuration: .init(baseURL: base, headers: headers, authentication: .init(provider: provider)), transport: transport)
        await #expect(throws: NetworkError.invalidRequest(.unsupportedRequest)) {
            try await client.download(request, maximumBytes: 8, options: options)
        }
        #expect(await provider.calls == 0)
        #expect(await transport.calls == 0)
    }

    @Test(arguments: [206, 204, 503]) func rejectedStatusRemovesNativeFileWithoutRetry(status: Int) async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        let transport = FileTestTransport { request, owner in owner.adopt(fixture.source); return fileResponse(request, status: status) }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, downloadFiles: fixture.files)
        do {
            _ = try await client.download(URLRequest(url: base), maximumBytes: 8)
            Issue.record("Rejected status returned a file")
        } catch NetworkError.httpStatus(let received, _) { #expect(received.code == status) }
        #expect(!fixture.sourceExists && !fixture.destinationExists)
        #expect(await transport.calls == 1)
    }

    @Test func actualSizeLimitRemovesPreservedFileAndUsesOtherDiagnosticOutcome() async throws {
        let fixture = try FileFixture(bytes: 9); defer { fixture.remove() }
        let sink = FileSink()
        let transport = FileTestTransport { request, owner in owner.adopt(fixture.source); return fileResponse(request) }
        let client = try APIClient(configuration: .init(baseURL: base, diagnostics: sink), transport: transport, downloadFiles: fixture.files)
        await #expect(throws: DownloadError.sizeLimitExceeded) { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        #expect(!fixture.sourceExists && !fixture.destinationExists)
        #expect(sink.events.first?.outcome == .other && sink.events.first?.status?.code == 200)
        #expect(sink.events.first?.attemptCount == 1)
    }

    @Test(arguments: ["preserve", "inspect", "remove"]) func fileFailureMappingAndCleanup(stage: String) async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        var operations = fixture.files
        if stage == "preserve" { operations.preserve = { _, _ in throw CocoaError(.fileWriteNoPermission) } }
        if stage == "inspect" { operations.inspect = { _ in throw CocoaError(.fileReadNoPermission) } }
        if stage == "remove" { operations.remove = { _ in throw CocoaError(.fileWriteNoPermission) } }
        let transport = FileTestTransport { request, owner in owner.adopt(fixture.source); return fileResponse(request, status: stage == "remove" ? 503 : 200) }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, downloadFiles: operations)
        let expected: DownloadError = stage == "remove" ? .cleanupFailed(primary: .httpStatus) : .fileSystem(stage == "preserve" ? .preserve : .inspect)
        await #expect(throws: expected) { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        if stage == "remove" { #expect(fixture.sourceExists) }
        else { #expect(!fixture.sourceExists && !fixture.destinationExists) }
        #expect(!expected.localizedDescription.contains(fixture.root.path))
    }

    @Test func deadlineAfterCandidateCreationRemovesDiscardedResult() async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        let clock = BudgetTestClock()
        var operations = fixture.files
        let inspect = operations.inspect
        operations.inspect = { url in let count = try inspect(url); clock.advance(2); return count }
        let transport = FileTestTransport { request, owner in owner.adopt(fixture.source); return fileResponse(request) }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, clock: clock, downloadFiles: operations)
        await #expect(throws: NetworkError.timeout(.totalBudget)) {
            try await client.download(URLRequest(url: base), maximumBytes: 8, options: DownloadOptions(totalTimeout: 1))
        }
        #expect(!fixture.sourceExists && !fixture.destinationExists)
        #expect(clock.pending == 0)
    }

    @Test(arguments: [false, true]) func cancellationJoinsCleanupAndPreservesCancellationError(cleanupFails: Bool) async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        let started = BudgetLatch(), release = BudgetLatch(), clock = BudgetTestClock()
        var operations = fixture.files
        if cleanupFails { operations.remove = { _ in throw CocoaError(.fileWriteNoPermission) } }
        let transport = FileTestTransport { request, owner in
            owner.adopt(fixture.source)
            await started.open(); await release.wait()
            return fileResponse(request)
        }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, clock: clock, downloadFiles: operations)
        let call = Task { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        await started.wait(); call.cancel(); await release.open()
        await #expect(throws: CancellationError.self) { try await call.value }
        #expect(fixture.sourceExists == cleanupFails)
        #expect(!fixture.destinationExists && clock.pending == 0)
    }

    @Test func exclusivePreservationDoesNotOverwriteOrDeleteCollisionTarget() async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        try Data("unrelated".utf8).write(to: fixture.destination)
        let transport = FileTestTransport { request, owner in owner.adopt(fixture.source); return fileResponse(request) }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, downloadFiles: fixture.files)
        await #expect(throws: DownloadError.fileSystem(.preserve)) { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        #expect(!fixture.sourceExists)
        #expect(try Data(contentsOf: fixture.destination) == Data("unrelated".utf8))
    }
    @Test(arguments: [false, true]) func nativeReturnAdoptsBeforeCancellationCheck(borrowed: Bool) async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        let started = BudgetLatch(), release = BudgetLatch()
        let external = URLSession(configuration: URLSessionTransport.configuration())
        defer { external.invalidateAndCancel() }
        let work: URLSessionTransport.DownloadOperation = { _, request, _ in
            await started.open(); await release.wait()
            return (fixture.source, fileResponse(request))
        }
        let transport = try borrowed
            ? URLSessionTransport(session: external, downloadOperation: work)
            : URLSessionTransport(downloadOperation: work)
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, downloadFiles: fixture.files)
        let call = Task { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        await started.wait(); call.cancel(); await release.open()
        await #expect(throws: CancellationError.self) { try await call.value }
        #expect(!fixture.sourceExists && !fixture.destinationExists)
        await client.shutdown()
    }

    @Test func shutdownJoinsFileChildAndCleanupBeforeClosingAdmission() async throws {
        let fixture = try FileFixture(); defer { fixture.remove() }
        let started = BudgetLatch(), cancelled = BudgetLatch(), release = BudgetLatch()
        let clock = BudgetTestClock()
        let transport = FileTestTransport { _, owner in
            owner.adopt(fixture.source)
            await started.open()
            do { try await clock.sleep(until: clock.now().advanced(by: .seconds(7200))) }
            catch { await cancelled.open(); await release.wait(); throw error }
            throw NetworkError.invalidResponse(.nonHTTPResponse)
        }
        let client = try APIClient(configuration: .init(baseURL: base), transport: transport, clock: clock, downloadFiles: fixture.files)
        let call = Task { try await client.download(URLRequest(url: base), maximumBytes: 8) }
        await started.wait()
        let shutdown = Task { await client.shutdown() }
        await cancelled.wait()
        #expect(fixture.sourceExists)
        await release.open()
        await #expect(throws: CancellationError.self) { try await call.value }
        await shutdown.value
        #expect(!fixture.sourceExists && !fixture.destinationExists && clock.pending == 0)
        await #expect(throws: NetworkError.invalidRequest(.clientClosed)) {
            try await client.download(URLRequest(url: base), maximumBytes: 8)
        }
    }

}
