import Foundation
import os

/// Per-call terminal arbitration. No lock is held across suspension or app code.
internal final class NetworkOperation<Value: Sendable>: Sendable {
    private struct State: Sendable {
        var result: Result<Value, any Error>?
    }
    private let state = OSAllocatedUnfairLock(initialState: State())
    private let clock: any NetworkClock
    private let start: ContinuousClock.Instant
    private let total: TimeInterval

    private init(clock: any NetworkClock, start: ContinuousClock.Instant, total: TimeInterval) {
        self.clock = clock
        self.start = start
        self.total = total
    }

    private func elapsed(at instant: ContinuousClock.Instant? = nil) -> Double {
        let components = start.duration(to: instant ?? clock.now()).components
        return Double(components.seconds) + Double(components.attoseconds) / 1e18
    }

    /// Called only under state synchronization. The internal clock must read time
    /// synchronously without invoking callbacks or acquiring this operation's lock.
    private func interruption() -> (any Error)? {
        if Task.isCancelled { return CancellationError() }
        if elapsed() >= total { return NetworkError.timeout(.totalBudget) }
        return nil
    }

    func checkpoint() throws {
        let error: (any Error)? = state.withLock { state in
            if case .failure(let error) = state.result { return error }
            guard state.result == nil, let error = interruption() else { return nil }
            state.result = .failure(error)
            return error
        }
        if let error { throw error }
    }

    private func finish(_ result: Result<Value, any Error>) {
        state.withLock { state in
            guard state.result == nil else { return }
            if let error = interruption() { state.result = .failure(error) }
            else { state.result = result }
        }
    }

    private func cancel() {
        state.withLock { state in
            if state.result == nil { state.result = .failure(CancellationError()) }
        }
    }

    private func watch() async {
        while !Task.isCancelled {
            let deadline: ContinuousClock.Instant? = state.withLock { state in
                guard state.result == nil else { return nil }
                let now = clock.now()
                let remaining = total - elapsed(at: now)
                if remaining <= 0 {
                    state.result = .failure(NetworkError.timeout(.totalBudget))
                    return nil
                }
                // Bound only the next sleep, not the selected total budget.
                let interval = min(max(remaining, 1e-9), 86_400)
                return now.advanced(by: .seconds(interval))
            }
            guard let deadline else { return }
            // No arbitrary finite Double is converted into an overflowing duration.
            // Tiny waits round up to a nanosecond; each wake rechecks elapsed time.
            do {
                try await clock.sleep(until: deadline)
            } catch is CancellationError {
                return // Group cleanup cancels this sleeper; it is not caller cancellation.
            } catch {
                finish(.failure(NetworkError.invalidRequest(.invalidConfiguration)))
                return
            }
        }
    }

    static func run(clock: any NetworkClock, start: ContinuousClock.Instant, total: TimeInterval,
                    body: @escaping @Sendable (NetworkOperation<Value>) async throws -> Value) async throws -> Value {
        guard total.isFinite, total > 0 else { throw NetworkError.invalidRequest(.invalidConfiguration) }
        let operation = NetworkOperation(clock: clock, start: start, total: total)
        return try await withTaskCancellationHandler {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        try operation.checkpoint()
                        let value = try await body(operation)
                        operation.finish(.success(value))
                    } catch { operation.finish(.failure(error)) }
                }
                group.addTask { await operation.watch() }
                _ = await group.next()
                group.cancelAll()
                // Join both children: never leave an operation or watchdog detached.
                while await group.next() != nil {}
            }
            return try operation.state.withLock { state in
                // The worker always records a result, even after a cancelled watchdog.
                guard let result = state.result else {
                    throw NetworkError.invalidRequest(.invalidConfiguration)
                }
                return try result.get()
            }
        } onCancel: { operation.cancel() }
    }
}
