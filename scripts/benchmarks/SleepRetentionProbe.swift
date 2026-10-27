// Opt-in runtime control only: no NetworkKit import, networking, or product code.
import Foundation

enum RetentionFailure: Error { case cancellation, handshake }

@main struct SleepRetentionProbe {
    static func main() async throws {
        let mode = CommandLine.arguments[1]
        let clock = ContinuousClock()
        var cancellations = 0
        for _ in 0..<6_400 {
            let sleeper = Task {
                do {
                    if mode == "clock" { try await clock.sleep(until: clock.now.advanced(by: .seconds(10))) }
                    else { try await Task.sleep(nanoseconds: 10_000_000_000) }
                    return false
                } catch is CancellationError { return true }
                catch { return false }
            }
            // Give registration an opportunity; actual outstanding allocations are measured,
            // not inferred from a yield/delay or an assumed executor ordering.
            try await Task.sleep(nanoseconds: 100_000)
            sleeper.cancel()
            if await sleeper.value { cancellations += 1 }
        }
        guard cancellations == 6_400 else { throw RetentionFailure.cancellation }
        func emit(_ phase: String) throws {
            let data = try JSONSerialization.data(withJSONObject: ["phase": phase, "cancellations": cancellations])
            FileHandle.standardOutput.write(data + Data([10]))
        }
        try emit("joined")
        // Every original ten-second deadline is now in the past.
        try await Task.sleep(nanoseconds: 12_000_000_000)
        try emit("expired")
        // The bounded Python controller snapshots this phase before allowing exit.
        guard readLine() == "exit" else { throw RetentionFailure.handshake }
    }
}
