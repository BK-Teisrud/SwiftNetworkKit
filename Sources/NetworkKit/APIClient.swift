import Foundation

/// Injectable boundary shared by typed endpoints and explicitly constructed requests.
public protocol NetworkClient: Sendable {
    /// Closes admission, cancels this client's work and awaits shared cleanup.
    func shutdown() async
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
/// applied to each request; a monotonic total budget covers preparation through delivery.
public final class APIClient: NetworkClient {
    private let configuration: NetworkConfiguration
    private let transport: any NetworkTransport
    private let clock: any NetworkClock
    private let lifecycle = ClientLifecycle()

    /// Creates and reuses a private session with automatic stores disabled.
    public init(configuration: NetworkConfiguration) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        clock = ContinuousNetworkClock()
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
        clock = ContinuousNetworkClock()
        transport = try URLSessionTransport(session: session,
            securityPolicy: configuration.security, baseURL: configuration.baseURL)
    }

    /// Internal test boundary; consumers inject NetworkClient, not a transport plugin.
    internal init(configuration: NetworkConfiguration, transport: any NetworkTransport,
                  clock: any NetworkClock = ContinuousNetworkClock()) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        self.transport = transport
        self.clock = clock
    }

    private static func validate(_ configuration: NetworkConfiguration) throws {
        _ = try URLInputValidation.components(configuration.baseURL, isBase: true)
        _ = try configuration.security.validateURL(configuration.baseURL)
    }

    public func send<E: Endpoint>(_ endpoint: E) async throws -> NetworkResponse<E.Response> {
        let start = clock.now()
        let registration = try lifecycle.register()
        defer { lifecycle.finish(registration) }
        try Task.checkCancellation()
        let options = endpoint.options
        return try await NetworkOperation.run(clock: clock, start: start,
            total: options.totalTimeout ?? configuration.timeouts.total, registration: registration) { operation in
            var prepared = try RequestBuilder.prepare(endpoint, configuration: self.configuration, options: options)
            prepared = try await RequestAuthentication.apply(prepared, configuration: self.configuration,
                policy: options.authentication, checkpoint: { try operation.checkpoint() })
            try operation.checkpoint()
            return try await self.execute(prepared, response: endpoint.responseStrategy,
                                          checkpoint: { try operation.checkpoint() })
        }
    }

    public func send<Value: Sendable>(_ request: URLRequest, response: ResponseStrategy<Value>,
                                      options: NetworkCallOptions) async throws -> NetworkResponse<Value> {
        let start = clock.now()
        let registration = try lifecycle.register()
        defer { lifecycle.finish(registration) }
        return try await NetworkOperation.run(clock: clock, start: start,
            total: options.totalTimeout ?? configuration.timeouts.total, registration: registration) { operation in
            var prepared = try RequestBuilder.prepare(request, configuration: self.configuration, options: options)
            prepared = try await RequestAuthentication.apply(prepared, configuration: self.configuration,
                policy: options.authentication, checkpoint: { try operation.checkpoint() })
            try operation.checkpoint()
            return try await self.execute(prepared, response: response, checkpoint: { try operation.checkpoint() })
        }
    }

    /// Idempotent immediate-cancel shutdown. All callers await the same cleanup,
    /// including cancelled shutdown waiters. Borrowed sessions are never invalidated.
    public func shutdown() async {
        if let registrations = lifecycle.beginShutdown() {
            for registration in registrations { registration.cancel() }
            await lifecycle.waitUntilDrained()
            await transport.shutdown()
            lifecycle.completeShutdown()
        } else {
            await lifecycle.waitUntilClosed()
        }
    }

    private func execute<Value: Sendable>(_ prepared: PreparedRequest, response: ResponseStrategy<Value>,
                                          checkpoint: @Sendable () throws -> Void) async throws -> NetworkResponse<Value> {
        try checkpoint()
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
        try checkpoint()
        return try response.decode(received.data, response: received.response,
                                   acceptedStatuses: prepared.acceptedStatuses)
    }
}
