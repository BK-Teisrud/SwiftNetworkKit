import Foundation

/// Internal seam only. URLSessionTransport supplies the foreground owned/borrowed adapter.
internal protocol NetworkTransport: Sendable {
    func send(_ request: URLRequest) async throws -> TransportResponse
}

internal struct TransportResponse: Sendable {
    let data: Data
    let response: URLResponse
}

/// Monotonic instants, shared by the production clock and deterministic test clocks.
/// No wall-clock dates or public scheduler/plugin API are involved.
internal protocol NetworkClock: Sendable {
    func now() -> ContinuousClock.Instant
    func sleep(until deadline: ContinuousClock.Instant) async throws
}

internal struct ContinuousNetworkClock: NetworkClock {
    private let clock = ContinuousClock()

    func now() -> ContinuousClock.Instant { clock.now }

    func sleep(until deadline: ContinuousClock.Instant) async throws {
        try await clock.sleep(until: deadline)
    }
}
