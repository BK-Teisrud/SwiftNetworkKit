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
/// Calls retry only when explicitly opted in; credentials are never refreshed. The inactivity timeout is
/// applied to each request; a monotonic total budget covers preparation through delivery.
public final class APIClient: NetworkClient {
    private let configuration: NetworkConfiguration
    private let transport: any NetworkTransport
    private let clock: any NetworkClock
    private let lifecycle = ClientLifecycle()
    private let retryTiming: RetryTiming

    /// Creates and reuses a private session with automatic stores disabled.
    public init(configuration: NetworkConfiguration) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        clock = ContinuousNetworkClock()
        retryTiming = RetryTiming()
        transport = try URLSessionTransport(
            ownedConfiguration: URLSessionTransport.configuration(timeouts: configuration.timeouts),
            securityPolicy: configuration.security, baseURL: configuration.baseURL)
    }

    /// Borrows a compatible foreground session. Strict disables automatic stores;
    /// appManaged explicitly permits app-owned HTTPS cookie/cache storage only.
    /// Delegates, global headers and credential stores remain unsupported. The app retains ownership
    /// and must not invalidate it while calls are running. Client cleanup never
    /// invalidates or clears stores on a borrowed session.
    public init(configuration: NetworkConfiguration, session: URLSession,
                storage: SessionStorageProfile = .strict) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        clock = ContinuousNetworkClock()
        retryTiming = RetryTiming()
        transport = try URLSessionTransport(session: session, storagePolicy: storage,
            securityPolicy: configuration.security, baseURL: configuration.baseURL)
    }

    /// Internal test boundary; consumers inject NetworkClient, not a transport plugin.
    internal init(configuration: NetworkConfiguration, transport: any NetworkTransport,
                  clock: any NetworkClock = ContinuousNetworkClock(), retryTiming: RetryTiming = RetryTiming()) throws {
        try Self.validate(configuration)
        self.configuration = configuration
        self.transport = transport
        self.clock = clock
        self.retryTiming = retryTiming
    }

    private static func validate(_ configuration: NetworkConfiguration) throws {
        _ = try URLInputValidation.components(configuration.baseURL, isBase: true)
        _ = try configuration.security.validateURL(configuration.baseURL)
    }

    public func send<E: Endpoint>(_ endpoint: E) async throws -> NetworkResponse<E.Response> {
        let start = clock.now()
        return try await observe(start: start) { diagnostic, registration in
            try Task.checkCancellation()
            let options = endpoint.options
            return try await NetworkOperation.run(clock: self.clock, start: start,
                total: options.totalTimeout ?? self.configuration.timeouts.total,
                registration: registration, diagnostic: diagnostic) { operation in
                var prepared = try RequestBuilder.prepare(endpoint, configuration: self.configuration, options: options)
                diagnostic.prepared(prepared.request)
                prepared = try await RequestAuthentication.apply(prepared, configuration: self.configuration,
                    policy: options.authentication, requestID: diagnostic.requestID,
                    checkpoint: { try operation.checkpoint() })
                try operation.checkpoint()
                return try await self.execute(prepared, response: endpoint.responseStrategy,
                    diagnostic: diagnostic, remaining: { operation.remainingBudget() },
                    checkpoint: { try operation.checkpoint() })
            }
        }
    }

    public func send<Value: Sendable>(_ request: URLRequest, response: ResponseStrategy<Value>,
                                      options: NetworkCallOptions) async throws -> NetworkResponse<Value> {
        let start = clock.now()
        return try await observe(start: start) { diagnostic, registration in
            try await NetworkOperation.run(clock: self.clock, start: start,
                total: options.totalTimeout ?? self.configuration.timeouts.total,
                registration: registration, diagnostic: diagnostic) { operation in
                var prepared = try RequestBuilder.prepare(request, configuration: self.configuration, options: options)
                diagnostic.prepared(prepared.request)
                prepared = try await RequestAuthentication.apply(prepared, configuration: self.configuration,
                    policy: options.authentication, requestID: diagnostic.requestID,
                    checkpoint: { try operation.checkpoint() })
                try operation.checkpoint()
                return try await self.execute(prepared, response: response, diagnostic: diagnostic,
                    remaining: { operation.remainingBudget() }, checkpoint: { try operation.checkpoint() })
            }
        }
    }

    private func observe<Value: Sendable>(start: ContinuousClock.Instant,
        body: @Sendable (DiagnosticObservation, ClientOperationRegistration) async throws -> NetworkResponse<Value>
    ) async throws -> NetworkResponse<Value> {
        let diagnostic = DiagnosticObservation(sink: configuration.diagnostics, clock: clock, start: start)
        var registration: ClientOperationRegistration?
        defer { if let registration { lifecycle.finish(registration) } }
        do {
            let admitted = try lifecycle.register()
            registration = admitted
            let result = try await body(diagnostic, admitted)
            diagnostic.complete()
            return result
        } catch {
            diagnostic.complete(error: error)
            throw error
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

    /// Contains only sanitized failure metadata, never a failed response payload.
    private struct AttemptFailure: Error {
        let failure: NetworkError
        var retryAfterFields: [String] = []
        let receipt: Date
    }

    private func execute<Value: Sendable>(_ prepared: PreparedRequest, response: ResponseStrategy<Value>,
        diagnostic: DiagnosticObservation, remaining: @Sendable () -> TimeInterval,
        checkpoint: @Sendable () throws -> Void) async throws -> NetworkResponse<Value> {
        var attempts = 0
        while true {
            try checkpoint()
            attempts += 1
            do {
                return try await attempt(prepared, response: response, diagnostic: diagnostic, checkpoint: checkpoint)
            } catch let candidate as AttemptFailure {
                try checkpoint()
                guard prepared.retry == .oneRetryForSafeReads, attempts == 1,
                      RetryDecision.isEligible(candidate.failure, accepted: prepared.acceptedStatuses),
                      let wait = RetryDecision.delay(policy: prepared.retry, attempts: attempts,
                    failure: candidate.failure, accepted: prepared.acceptedStatuses,
                    retryAfterFields: candidate.retryAfterFields, receipt: candidate.receipt,
                    jitter: retryTiming.jitter(), remaining: remaining()) else { throw candidate.failure }
                // The attempt's stack and buffered data have unwound before waiting.
                // This sleep is a joined child of the original admitted operation.
                try checkpoint()
                // Parsing/sampling can consume time after the earlier budget snapshot.
                guard wait < remaining() else { throw candidate.failure }
                do { try await clock.sleep(until: clock.now().advanced(by: .seconds(wait))) }
                catch {
                    try checkpoint()
                    if error is CancellationError { throw CancellationError() }
                    throw NetworkError.invalidRequest(.invalidConfiguration)
                }
                try checkpoint()
            }
        }
    }

    private func attempt<Value: Sendable>(_ prepared: PreparedRequest, response: ResponseStrategy<Value>,
        diagnostic: DiagnosticObservation, checkpoint: @Sendable () throws -> Void) async throws -> NetworkResponse<Value> {
        try checkpoint()
        diagnostic.attemptStarted()
        let received: TransportResponse
        do {
            received = try await transport.send(prepared.request)
        } catch {
            try checkpoint()
            if error is CancellationError { throw CancellationError() }
            let failure: NetworkError
            if let mapped = error as? NetworkError { failure = mapped }
            else {
                let underlying = error as NSError
                if underlying.domain == NSURLErrorDomain && underlying.code == URLError.timedOut.rawValue {
                    failure = .timeout(.system)
                } else { failure = .transport(.init(domain: underlying.domain, code: underlying.code)) }
            }
            throw AttemptFailure(failure: failure, receipt: retryTiming.wallNow())
        }
        let receipt = retryTiming.wallNow()
        diagnostic.received(received.response)
        try checkpoint()
        let metadata = try ResponseMetadata(received.response)
        guard prepared.acceptedStatuses.accepts(metadata.status) else {
            throw AttemptFailure(failure: .httpStatus(metadata.status, headers: metadata.headers),
                                 retryAfterFields: metadata.retryAfterFields, receipt: receipt)
        }
        return try response.decode(received.data, metadata: metadata, acceptedStatuses: prepared.acceptedStatuses)
    }
}
