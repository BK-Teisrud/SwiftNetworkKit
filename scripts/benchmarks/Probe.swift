// Test-only public consumer, built in release mode by run.py. Never part of NetworkKit.
import Darwin
import Foundation
import NetworkKit

struct Call: Endpoint {
    let path: EndpointPath
    let query: [HTTPQueryItem]
    let responseStrategy: ResponseStrategy<Data> = .data
    let options: NetworkCallOptions
    init(bytes: Int, slow: Bool = false, retry: Bool = false) throws {
        path = try EndpointPath(segments: [retry ? (slow ? "retry-wait" : "retry") : (slow ? "slow" : "payload")])
        query = [try HTTPQueryItem(name: "bytes", value: String(bytes)),
                 try HTTPQueryItem(name: "call", value: UUID().uuidString)]
        options = try NetworkCallOptions(retry: retry ? .oneRetryForSafeReads : .disabled)
    }
}

func payloadRequest(base: URL, bytes: Int, retry: Bool = false) -> URLRequest {
    var url = URLComponents(url: base.appendingPathComponent(retry ? "retry" : "payload"), resolvingAgainstBaseURL: false)!
    url.queryItems = [URLQueryItem(name: "bytes", value: String(bytes)), URLQueryItem(name: "call", value: UUID().uuidString)]
    return URLRequest(url: url.url!)
}

func seconds(_ duration: Duration) -> Double {
    let c = duration.components
    return Double(c.seconds) + Double(c.attoseconds) / 1e18
}
func residentBytes() throws -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }
    guard result == KERN_SUCCESS else { throw ProbeFailure.measurement }
    return UInt64(info.resident_size)
}
func liveMalloc() -> [String: UInt64] {
    var stats = malloc_statistics_t()
    malloc_zone_statistics(nil, &stats)
    return ["blocks": UInt64(stats.blocks_in_use), "bytes": UInt64(stats.size_in_use)]
}
enum ProbeFailure: Error { case measurement, invalidResult, noNativeRequest, unexpectedSuccess }

@main struct Probe {
    static func main() async throws {
        let args = CommandLine.arguments
        let base = URL(string: args[1])!
        let mode = args[2], concurrency = Int(args[3])!, bytes = Int(args[4])!, calls = Int(args[5])!, cycles = Int(args[6])!
        let configuration = NetworkConfiguration(baseURL: base,
            timeouts: try NetworkTimeouts(inactivity: 3, total: 10),
            security: NetworkSecurityPolicy(allowInsecureLoopback: true))
        let initialRSS = try residentBytes()
        let client = try APIClient(configuration: configuration)
        let clock = ContinuousClock()
        let direct: URLSession?
        if mode == "direct" {
            let config = URLSessionConfiguration.ephemeral
            config.httpCookieStorage = nil; config.httpShouldSetCookies = false
            config.urlCredentialStorage = nil; config.urlCache = nil
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.timeoutIntervalForRequest = 3; config.timeoutIntervalForResource = 10
            direct = URLSession(configuration: config)
        } else { direct = nil }
        defer { direct?.invalidateAndCancel() }
        // Warm URLSession/URL loading before measuring workloads, still counted by the fixture.
        if let direct {
            guard try await direct.data(for: payloadRequest(base: base, bytes: bytes)).0.count == bytes else { throw ProbeFailure.invalidResult }
        } else {
            guard try await client.send(Call(bytes: bytes)).value.count == bytes else { throw ProbeFailure.invalidResult }
        }
        let warmRSS = try residentBytes()
        let warmMalloc = liveMalloc()
        var cycleRSS: [UInt64] = [], cycleSeconds: [Double] = [], latency: [Double] = []
        var cancelled = 0, cancellationSeconds = 0.0
        if mode == "cancel" || mode == "retry-cancel" {
            let tasks = (0..<concurrency).map { _ in Task {
                do {
                    _ = try await client.send(Call(bytes: bytes, slow: true, retry: mode == "retry-cancel"))
                    throw ProbeFailure.unexpectedSuccess
                } catch is CancellationError { return 1 }
            } }
            // Confirm native server contact; sleeping alone is not cancellation-during-I/O evidence.
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 1; config.timeoutIntervalForResource = 3
            let control = URLSession(configuration: config)
            defer { control.invalidateAndCancel() }
            let deadline = clock.now.advanced(by: .seconds(3))
            var contacted = false
            while clock.now < deadline {
                let (data, _) = try await control.data(from: base.appendingPathComponent("stats"))
                let stats = try JSONDecoder().decode([String: Int].self, from: data)
                if mode == "retry-cancel" {
                    if (stats["retry_replied"] ?? 0) == concurrency { contacted = true; break }
                } else if (stats["slow_started"] ?? 0) > 0 { contacted = true; break }
                try await Task.sleep(for: .milliseconds(10))
            }
            let start = clock.now
            for task in tasks { task.cancel() }
            for task in tasks { cancelled += try await task.value }
            cancellationSeconds = seconds(start.duration(to: clock.now))
            guard contacted, cancelled == concurrency else { throw ProbeFailure.noNativeRequest }
            cycleRSS.append(try residentBytes())
        } else {
            for _ in 0..<cycles {
                let cycleStart = clock.now
                for offset in stride(from: 0, to: calls, by: concurrency) {
                    let timings = try await withThrowingTaskGroup(of: Double.self) { group in
                        for index in offset..<min(offset + concurrency, calls) {
                            group.addTask {
                                let chosen = mode == "fresh" ? try APIClient(configuration: configuration) : client
                                let start = clock.now
                                do {
                                    let value: Data
                                    if let direct { value = try await direct.data(for: payloadRequest(base: base, bytes: bytes)).0 }
                                    else if index.isMultiple(of: 2) { value = try await chosen.send(Call(bytes: bytes, retry: mode == "retry")).value }
                                    else {
                                        value = try await chosen.send(payloadRequest(base: base, bytes: bytes, retry: mode == "retry"), response: .data,
                                            options: NetworkCallOptions(retry: mode == "retry" ? .oneRetryForSafeReads : .disabled)).value
                                    }
                                    guard value.count == bytes, value.allSatisfy({ $0 == 120 }) else { throw ProbeFailure.invalidResult }
                                    if mode == "fresh" { await chosen.shutdown() }
                                    return seconds(start.duration(to: clock.now))
                                } catch {
                                    if mode == "fresh" { await chosen.shutdown() }
                                    throw error
                                }
                            }
                        }
                        var result: [Double] = []
                        for try await timing in group { result.append(timing) }
                        return result
                    }
                    latency += timings
                }
                cycleSeconds.append(seconds(cycleStart.duration(to: clock.now)))
                cycleRSS.append(try residentBytes())
            }
        }
        let shutdownStart = clock.now
        await client.shutdown()
        direct?.invalidateAndCancel()
        let shutdownSeconds = seconds(shutdownStart.duration(to: clock.now))
        let shutdownRSS = try residentBytes()
        let shutdownMalloc = liveMalloc()
        // Optional attribution sample after every configured ten-second deadline.
        if args.count > 7 && args[7] == "post-budget" { try await Task.sleep(for: .seconds(12)) }
        else { try await Task.sleep(for: .milliseconds(100)) }
        let settledRSS = try residentBytes()
        let settledMalloc = liveMalloc()
        latency.sort()
        func percentile(_ value: Double) -> Double {
            latency.isEmpty ? 0 : latency[min(latency.count - 1, Int(ceil(Double(latency.count) * value)) - 1)]
        }
        let output: [String: Any] = ["mode": mode, "concurrency": concurrency, "payload_bytes": bytes,
            "calls_per_cycle": calls, "cycles": cycleSeconds.count, "cycle_seconds": cycleSeconds,
            "call_p50_seconds": percentile(0.5), "call_p95_seconds": percentile(0.95),
            "rss_initial_bytes": initialRSS, "rss_warm_bytes": warmRSS, "rss_cycle_bytes": cycleRSS,
            "rss_shutdown_bytes": shutdownRSS, "rss_settled_bytes": settledRSS,
            "malloc_warm": warmMalloc, "malloc_shutdown": shutdownMalloc, "malloc_settled": settledMalloc,
            "shutdown_seconds": shutdownSeconds, "cancelled_calls": cancelled,
            "cancellation_join_seconds": cancellationSeconds]
        print(String(decoding: try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys]), as: UTF8.self))
    }
}
