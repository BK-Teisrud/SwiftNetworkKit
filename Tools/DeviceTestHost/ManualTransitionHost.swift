import Darwin
import Foundation
import Network
import NetworkKit
import SwiftUI
import os

private struct ManualEvent: Codable, Sendable {
    let kind: String
    let elapsed: Double
    let fields: [String: String]
}

private final class ManualDiagnostics: NetworkDiagnosticSink {
    private let events = OSAllocatedUnfairLock(initialState: [[String: String]]())
    func record(_ event: NetworkDiagnosticEvent) {
        let outcome: String
        switch event.outcome {
        case .success: outcome = "success"
        case .cancelled: outcome = "cancelled"
        case .timeout: outcome = "timeout"
        case .transport: outcome = "transport"
        case .httpStatus: outcome = "http-status"
        case .invalidRequest: outcome = "invalid-request"
        case .invalidResponse: outcome = "invalid-response"
        case .encoding: outcome = "encoding"
        case .decoding: outcome = "decoding"
        case .other: outcome = "other"
        }
        events.withLock {
            // Four intended calls; an overflow marker makes extra callbacks visible without unbounded storage.
            if $0.count < 16 {
                $0.append(["outcome": outcome, "duration": String(event.duration),
                           "status": event.status.map { String($0.code) } ?? "none"])
            } else if $0.count == 16 { $0.append(["overflow": "true"]) }
        }
    }
    func snapshot() -> [[String: String]] { events.withLock { $0 } }
}

@MainActor private final class ManualChecks: ObservableObject {
    @Published var running = false
    @Published var status = "No requests started."
    @Published var pathStatus = "unknown"
    @Published var completed: Set<String> = []
    @Published var finished = false
    @Published var reportFailed = false
    private let start = ContinuousClock.now
    private let monitor = NWPathMonitor()
    private let diagnostics = ManualDiagnostics()
    private let runID = UUID().uuidString
    private var events: [ManualEvent] = []
    private var truncated = false
    private var client: APIClient?
    private var task: Task<Void, Never>?
    private var current = "none"
    private var recoveryCompletion: ContinuousClock.Instant?
    private var reportURL: URL?

    init() {
        let commit = Bundle.main.object(forInfoDictionaryKey: "NetworkKitVerificationCommit") as? String
        let source = Bundle.main.object(forInfoDictionaryKey: "NetworkKitManualSourceSHA256") as? String
        let platform = Bundle.main.object(forInfoDictionaryKey: "NetworkKitManualPlatform") as? String
        guard commit?.count == 40, source?.count == 64,
              ["iOS", "macOS", "watchOS", "tvOS"].contains(platform ?? "") else {
            reportFailed = true
            status = "Missing verification metadata. Do not run checks."
            return
        }
        if let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let directory = cache.appendingPathComponent("NetworkKitManualChecks", isDirectory: true)
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                reportURL = directory.appendingPathComponent(runID + ".json")
            } catch { status = "Cannot create the test report. No requests will start." }
        }
        append("host-started", fields: ["rss": residentBytes()])
        monitor.pathUpdateHandler = { [weak self] path in
            let status: String
            switch path.status {
            case .satisfied: status = "satisfied"
            case .unsatisfied: status = "unsatisfied"
            case .requiresConnection: status = "requires-connection"
            @unknown default: status = "unknown"
            }
            let interfaces = [(NWInterface.InterfaceType.wifi, "wifi"), (.cellular, "cellular"),
                              (.wiredEthernet, "wired"), (.loopback, "loopback"), (.other, "other")]
                .filter { path.usesInterfaceType($0.0) }.map { $0.1 }.joined(separator: ",")
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.pathStatus = status
                self.append("path", fields: ["status": status, "interfaces": interfaces,
                                             "during-call": String(self.running), "check": self.current])
            }
        }
        monitor.start(queue: DispatchQueue(label: "NetworkKit.manual-path"))
    }

    func scene(_ phase: ScenePhase) {
        let value: String
        switch phase {
        case .active: value = "active"
        case .inactive: value = "inactive"
        case .background: value = "background"
        @unknown default: value = "unknown"
        }
        append("scene", fields: ["phase": value, "during-call": String(running), "check": current])
    }

    func run(_ kind: String) {
        guard reportURL != nil, !reportFailed, !running, !finished, !completed.contains(kind),
              ["background", "network-loss", "recovery"].contains(kind) else { return }
        running = true
        current = kind
        append("call-start", fields: ["check": kind, "path": pathStatus, "rss": residentBytes()])
        status = kind == "background" ? "Leave the app, then return after five seconds."
            : kind == "network-loss" ? "Interrupt connectivity now, then restore it and return."
            : "Checking recovery with an explicit new request."
        task = Task {
            do {
                guard let base = URL(string: "https://httpbingo.org") else { throw URLError(.badURL) }
                if client == nil { client = try APIClient(configuration: .init(baseURL: base, diagnostics: diagnostics)) }
                guard let client else { throw URLError(.unknown) }
                let url = kind == "recovery" ? base.appendingPathComponent("status").appendingPathComponent("204")
                    : base.appendingPathComponent("delay").appendingPathComponent("8")
                let count = kind == "recovery" ? 2 : 1
                let responses = try await withThrowingTaskGroup(of: (Int, Int).self) { group in
                    for _ in 0..<count {
                        group.addTask {
                            let response = try await client.send(URLRequest(url: url), response: .data)
                            return (response.status.code, response.value.count)
                        }
                    }
                    var values: [(Int, Int)] = []
                    for try await value in group { values.append(value) }
                    return values
                }
                append("call-terminal", fields: ["check": kind, "outcome": "success",
                    "statuses": responses.map { String($0.0) }.sorted().joined(separator: ","),
                    "calls": String(count), "bytes": String(responses.reduce(0) { $0 + $1.1 })])
            } catch is CancellationError {
                append("call-terminal", fields: ["check": kind, "outcome": "cancelled"])
            } catch NetworkError.transport(let failure) {
                append("call-terminal", fields: ["check": kind, "outcome": "transport",
                    "known-system-domain": String(failure.domain == NSURLErrorDomain), "code": String(failure.code)])
            } catch NetworkError.timeout(let reason) {
                append("call-terminal", fields: ["check": kind, "outcome": "timeout", "reason": reason.rawValue])
            } catch NetworkError.httpStatus(let code, _) {
                append("call-terminal", fields: ["check": kind, "outcome": "http-status", "status": String(code.code)])
            } catch {
                append("call-terminal", fields: ["check": kind, "outcome": "other"])
            }
            if kind == "recovery" {
                await client?.shutdown()
                client = nil
                append("shutdown-joined", fields: ["diagnostic-count": String(diagnostics.snapshot().count)])
                recoveryCompletion = .now
            }
            running = false
            completed.insert(kind)
            append("call-joined", fields: ["check": kind, "rss": residentBytes(),
                "diagnostic-count": String(diagnostics.snapshot().count)])
            task = nil
            status = kind == "recovery" ? "After 61 seconds from recovery completion, save the final sample."
                : "Check finished. Report records observations; acceptance requires review."
        }
    }

    func cancel() { append("caller-cancel"); task?.cancel() }

    func settle() {
        guard !running, completed.contains("recovery"), !finished, let recoveryCompletion else { return }
        guard seconds(recoveryCompletion.duration(to: .now)) >= 61 else {
            status = "Wait until 61 seconds after recovery completed, then save again."
            return
        }
        append("post-original-budget", fields: ["rss": residentBytes(),
            "seconds-after-recovery-completion": String(seconds(recoveryCompletion.duration(to: .now))),
            "diagnostic-count": String(diagnostics.snapshot().count)])
        monitor.cancel()
        finished = true
        status = "Report saved. Results still require review."
    }

    private func append(_ kind: String, fields: [String: String] = [:]) {
        if events.count < 128 { events.append(.init(kind: kind, elapsed: seconds(start.duration(to: .now)), fields: fields)) }
        else { truncated = true }
        guard let reportURL else { return }
        struct Report: Encodable {
            let schema: Int
            let runID: String
            let platform: String
            let runtime: String
            let sdkCommit: String
            let hostSourceSHA256: String
            let inactivitySeconds: Double
            let totalSeconds: Double
            let truncated: Bool
            let events: [ManualEvent]
            let diagnostics: [[String: String]]
        }
        let report = Report(schema: 1, runID: runID,
            platform: Bundle.main.object(forInfoDictionaryKey: "NetworkKitManualPlatform") as? String ?? "unknown",
            runtime: ProcessInfo.processInfo.operatingSystemVersionString,
            sdkCommit: Bundle.main.object(forInfoDictionaryKey: "NetworkKitVerificationCommit") as? String ?? "unknown",
            hostSourceSHA256: Bundle.main.object(forInfoDictionaryKey: "NetworkKitManualSourceSHA256") as? String ?? "unknown",
            inactivitySeconds: 30, totalSeconds: 60, truncated: truncated, events: events, diagnostics: diagnostics.snapshot())
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(report).write(to: reportURL, options: .atomic)
        } catch { reportFailed = true; status = "Test report write failed. Do not accept this run." }
    }

    private func seconds(_ duration: Duration) -> Double {
        let value = duration.components
        return Double(value.seconds) + Double(value.attoseconds) / 1e18
    }

    private func residentBytes() -> String {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        let capacity = Int(count)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? String(info.resident_size) : "unavailable"
    }
}

@main struct NetworkKitManualTransitionHost: App {
    @StateObject private var checks = ManualChecks()
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        WindowGroup {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("NetworkKit manual checks").font(.headline)
                    Text(checks.reportFailed ? "Report unavailable. Do not accept this run." : checks.status)
                    Text("Path: " + checks.pathStatus).font(.caption)
                    Button("1. Background check") { checks.run("background") }
                        .disabled(checks.running || checks.completed.contains("background") || checks.finished)
                    Button("2. Network loss check") { checks.run("network-loss") }
                        .disabled(checks.running || !checks.completed.contains("background") || checks.completed.contains("network-loss") || checks.finished)
                    Button("3. Recovery check") { checks.run("recovery") }
                        .disabled(checks.running || !checks.completed.contains("network-loss") || checks.completed.contains("recovery") || checks.finished)
                    Button("Cancel active check") { checks.cancel() }.disabled(!checks.running)
                    Button("Save final sample") { checks.settle() }
                        .disabled(checks.running || !checks.completed.contains("recovery") || checks.finished)
                }.padding()
            }.onChange(of: phase) { _, value in checks.scene(value) }
        }
    }
}
