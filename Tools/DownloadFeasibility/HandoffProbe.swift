import Foundation
import os

// I28 only. Uses the existing terminal arbiter; does not implement a shipping API.
private enum ProbeError: Error { case assertion, injectedPreserve, injectedInspect, injectedRemove }
private func expect(_ value: Bool) throws { if !value { throw ProbeError.assertion } }
private final class DeadlineClock: NetworkClock {
    private let base = ContinuousClock().now
    private let offset = OSAllocatedUnfairLock(initialState: 0.0)
    func now() -> ContinuousClock.Instant { base.advanced(by: .seconds(offset.withLock { $0 })) }
    func expire() { offset.withLock { $0 = 2 } }
    func sleep(until deadline: ContinuousClock.Instant) async throws {
        // This clock tests finish-time arbitration only, never a real sleep threshold.
        // Every operation body terminates; run() cancels/joins this sleeper.
        try await Task.sleep(for: .seconds(3600))
    }
}
private actor Gate {
    private var opened = false
    private var waiters: [CheckedContinuation<Void, Never>] = []
    func wait() async {
        if opened { return }
        await withCheckedContinuation { waiters.append($0) }
    }
    func open() {
        opened = true
        let pending = waiters; waiters.removeAll()
        for waiter in pending { waiter.resume() }
    }
}
private final class FileOwner: Sendable {
    // Only release after NetworkOperation.run returns success; cleanup after it joins.
    // No concurrent filesystem mutation is allowed by this experimental protocol.
    private let candidate: OSAllocatedUnfairLock<URL?>
    init(_ url: URL) { candidate = OSAllocatedUnfairLock(initialState: url) }
    func handoff() throws -> URL {
        try candidate.withLock { value in
            guard let url = value else { throw ProbeError.assertion }
            value = nil
            return url
        }
    }
    func cleanup(injectFailure: Bool = false) throws {
        guard let url = candidate.withLock({ $0 }) else { return }
        if injectFailure { throw ProbeError.injectedRemove }
        try FileManager.default.removeItem(at: url)
        candidate.withLock { $0 = nil }
    }
}
@main struct HandoffFeasibilityProbe {
    static func main() async throws {
        guard CommandLine.arguments.count == 3 else { throw ProbeError.assertion }
        let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let fm = FileManager.default
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }
        var passed: [String] = []
        func file() throws -> URL {
            let url = root.appendingPathComponent(UUID().uuidString)
            try Data(repeating: 65, count: 64).write(to: url, options: .withoutOverwriting)
            return url
        }
        // Reproduce discarded URL ownership with the unchanged operation arbiter.
        do {
            let url = try file(), clock = DeadlineClock()
            do {
                _ = try await NetworkOperation<URL>.run(clock: clock, start: clock.now(), total: 1) { _ in
                    clock.expire()
                    return url
                }
                throw ProbeError.assertion
            } catch NetworkError.timeout(.totalBudget) {}
            try expect(fm.fileExists(atPath: url.path))
            try fm.removeItem(at: url)
            passed.append("finish-deadline-discards-value-but-does-not-own-file")
        }
        // Keep an outer operation-scoped owner until arbitration succeeds.
        do {
            let url = try file(), owner = FileOwner(url), clock = DeadlineClock()
            do {
                _ = try await NetworkOperation<URL>.run(clock: clock, start: clock.now(), total: 1) { _ in
                    clock.expire()
                    return url
                }
                throw ProbeError.assertion
            } catch NetworkError.timeout(.totalBudget) { try owner.cleanup() }
            try expect(!fm.fileExists(atPath: url.path))
            passed.append("outer-owner-removes-discarded-deadline-file")
        }
        do {
            let url = try file(), owner = FileOwner(url), clock = DeadlineClock()
            let ready = Gate(), release = Gate()
            let task = Task {
                try await NetworkOperation<URL>.run(clock: clock, start: clock.now(), total: 1) { _ in
                    await ready.open()
                    await release.wait() // Release is explicit; cancellation cannot strand this probe.
                    return url
                }
            }
            await ready.wait()
            task.cancel()
            await release.open()
            do { _ = try await task.value; throw ProbeError.assertion }
            catch is CancellationError { try owner.cleanup() }
            try expect(!fm.fileExists(atPath: url.path))
            passed.append("outer-owner-removes-discarded-cancelled-file-after-join")
        }
        do {
            let url = try file(), owner = FileOwner(url), clock = DeadlineClock()
            let result = try await NetworkOperation<URL>.run(clock: clock, start: clock.now(), total: 1) { _ in url }
            let handedOff = try owner.handoff()
            try expect(handedOff == result)
            try owner.cleanup() // Must not remove an app-owned result.
            try expect(fm.fileExists(atPath: handedOff.path))
            try fm.removeItem(at: handedOff)
            passed.append("success-handoff-survives-owner-cleanup")
        }
        // Bounded failure injection proves observability, not actual disk exhaustion.
        do {
            let url = try file(), owner = FileOwner(url)
            do { try owner.cleanup(injectFailure: true); throw ProbeError.assertion }
            catch ProbeError.injectedRemove {}
            try expect(fm.fileExists(atPath: url.path))
            try owner.cleanup()
            try expect(!fm.fileExists(atPath: url.path))
            passed.append("injected-removal-failure-retains-known-owner-for-explicit-cleanup")
        }
        for fault in [ProbeError.injectedPreserve, .injectedInspect] {
            let url = try file(), owner = FileOwner(url)
            do { throw fault }
            catch ProbeError.injectedPreserve { try owner.cleanup() }
            catch ProbeError.injectedInspect { try owner.cleanup() }
            try expect(!fm.fileExists(atPath: url.path))
            passed.append(fault == .injectedPreserve ? "preserve-failure-cleans-source" : "inspect-failure-cleans-candidate")
        }
        let remaining = try fm.contentsOfDirectory(atPath: root.path)
        try expect(remaining.isEmpty)
        try JSONEncoder().encode(passed).write(to: URL(fileURLWithPath: CommandLine.arguments[2]), options: .atomic)
        print("Passed \(passed.count) handoff observations")
    }
}
