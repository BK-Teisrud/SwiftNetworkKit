import Foundation

/// Injectable boundary shared by typed endpoints and explicitly constructed requests.
public protocol NetworkClient: Sendable {
    func send<E: Endpoint>(_ endpoint: E) async throws -> NetworkResponse<E.Response>
    func send<Value: Sendable>(_ request: URLRequest, response: ResponseStrategy<Value>,
                               options: NetworkCallOptions) async throws -> NetworkResponse<Value>
}

extension NetworkClient {
    /// Uses the standard status policy and client timeout/header defaults.
    public func send<Value: Sendable>(_ request: URLRequest,
                                      response: ResponseStrategy<Value>) async throws -> NetworkResponse<Value> {
        try await send(request, response: response, options: .default)
    }
}

/// Buffered foreground HTTP client with one immutable configuration and shared pipeline.
///
/// Calls do not retry or refresh credentials. The configured inactivity timeout is
/// applied to each request; the monotonic total-budget watchdog is not implemented yet.
public final class APIClient: NetworkClient {
    private let configuration: NetworkConfiguration
    private let transport: any NetworkTransport

    /// Creates and reuses a private session with automatic stores disabled.
    public init(configuration: NetworkConfiguration) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        transport = try URLSessionTransport(
            ownedConfiguration: URLSessionTransport.configuration(timeouts: configuration.timeouts),
            securityPolicy: configuration.security, baseURL: configuration.baseURL)
    }

    /// Borrows an active foreground session without a delegate, additional headers,
    /// or automatic cookie, credential, or cache stores. The app retains ownership
    /// and must not invalidate it while calls are running. Client cleanup never
    /// invalidates a borrowed session. App-managed storage profiles remain internal.
    public init(configuration: NetworkConfiguration, session: URLSession) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        transport = try URLSessionTransport(session: session,
            securityPolicy: configuration.security, baseURL: configuration.baseURL)
    }

    /// Internal test boundary; consumers inject NetworkClient, not a transport plugin.
    internal init(configuration: NetworkConfiguration, transport: any NetworkTransport) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        self.transport = transport
    }

    private static func validate(_ configuration: NetworkConfiguration) throws {
        _ = try URLInputValidation.components(configuration.baseURL, isBase: true)
        _ = try configuration.security.validateURL(configuration.baseURL)
    }

    public func send<E: Endpoint>(_ endpoint: E) async throws -> NetworkResponse<E.Response> {
        let prepared = try RequestBuilder.prepare(endpoint, configuration: configuration)
        return try await execute(prepared, response: endpoint.responseStrategy)
    }

    public func send<Value: Sendable>(_ request: URLRequest, response: ResponseStrategy<Value>,
                                      options: NetworkCallOptions) async throws -> NetworkResponse<Value> {
        let prepared = try RequestBuilder.prepare(request, configuration: configuration, options: options)
        return try await execute(prepared, response: response)
    }

    private func execute<Value: Sendable>(_ prepared: PreparedRequest,
                                          response: ResponseStrategy<Value>) async throws -> NetworkResponse<Value> {
        try Task.checkCancellation()
        let received: TransportResponse
        do {
            received = try await transport.send(prepared.request)
        } catch {
            // Actual task cancellation wins over a system cancellation signal.
            // An unexplained URLError.cancelled is an ordinary transport failure.
            try Task.checkCancellation()
            if error is CancellationError { throw CancellationError() }
            if let failure = error as? NetworkError { throw failure }
            let underlying = error as NSError
            if underlying.domain == NSURLErrorDomain && underlying.code == URLError.timedOut.rawValue {
                throw NetworkError.timeout(.system)
            }
            throw NetworkError.transport(.init(domain: underlying.domain, code: underlying.code))
        }
        try Task.checkCancellation()
        return try response.decode(received.data, response: received.response,
                                   acceptedStatuses: prepared.acceptedStatuses)
    }
}
