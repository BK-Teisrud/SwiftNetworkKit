import Foundation

// Non-shipping I28 experiment, compiled alongside unchanged SDK sources.
// This is not APIClient.download or evidence of its unimplemented race handling.
private struct CheckFailure: Error { let label: String }
private func require(_ value: Bool, _ label: String) throws {
    if !value { throw CheckFailure(label: label) }
}
private struct Observation: Codable {
    let mode: String
    let scenario: String
    let outcome: String
}

@main struct DownloadFeasibilityProbe {
    static func main() async throws {
        let args = CommandLine.arguments
        guard args.count == 5, let base = URL(string: args[1]),
              let tls = URL(string: args[2]) else { throw CheckFailure(label: "arguments") }
        let root = URL(fileURLWithPath: args[3], isDirectory: true)
        let fm = FileManager.default
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }
        var observations: [Observation] = []
        for owned in [true, false] {
            let mode = owned ? "owned" : "borrowed"
            let external = URLSession(configuration: URLSessionTransport.configuration())
            defer { external.invalidateAndCancel() }
            let transport = try owned
                ? URLSessionTransport(securityPolicy: .init(allowInsecureLoopback: true))
                : URLSessionTransport(session: external, securityPolicy: .init(allowInsecureLoopback: true))
            let session = transport.session
            func record(_ label: String) { observations.append(.init(mode: mode, scenario: label, outcome: "passed")) }
            func download(_ path: String) async throws -> (URL, URLResponse) {
                let request = URLRequest(url: base.appendingPathComponent(path))
                let delegate = try NetworkTaskDelegate(request: request,
                    policy: .init(allowInsecureLoopback: true), disableAutomaticStorage: true)
                let result = try await session.download(for: request, delegate: delegate)
                if let failure = delegate.failure {
                    try fm.removeItem(at: result.0)
                    throw failure
                }
                return result
            }
            // Final-file inspection and unique move, not a strict live disk cap.
            for (path, expected) in [("normal", 4096), ("empty", 0), ("unknown", 4096), ("encoded", 4096)] {
                let (url, response) = try await download(path)
                try require((response as? HTTPURLResponse)?.statusCode == 200, "status")
                // Verify the async URL survives a suspension before immediate preservation.
                try await Task.sleep(for: .milliseconds(20))
                let data = try Data(contentsOf: url) // Bounded fixture oracle only; not production transfer.
                try require(data == Data(repeating: 65, count: expected), "file contents")
                let moved = root.appendingPathComponent(UUID().uuidString)
                try fm.moveItem(at: url, to: moved)
                try require(!fm.fileExists(atPath: url.path), "move source removed")
                try require(fm.fileExists(atPath: moved.path), "preserved")
                try fm.removeItem(at: moved)
                record(path + "-async-lifetime-preserve-remove")
            }
            let (large, _) = try await download("oversized")
            let size = try fm.attributesOfItem(atPath: large.path)[.size] as? NSNumber
            try require(size?.intValue == 8192 && size!.intValue > 4096, "oversize oracle")
            try fm.removeItem(at: large)
            try require(!fm.fileExists(atPath: large.path), "oversize cleanup")
            record("oversized-final-file-rejected-and-removed")
            for path in ["partial", "status"] {
                let (url, response) = try await download(path)
                try require((response as? HTTPURLResponse)?.statusCode == (path == "partial" ? 206 : 503), "rejected status")
                try fm.removeItem(at: url)
                record(path + "-file-removed")
            }
            let (redirected, response) = try await download("redirect")
            try require((response as? HTTPURLResponse)?.statusCode == 200, "same-origin redirect")
            try fm.removeItem(at: redirected)
            record("same-origin-redirect")
            let (denied, deniedResponse) = try await download("denied")
            try require((deniedResponse as? HTTPURLResponse)?.statusCode == 302, "cross-origin denied")
            try fm.removeItem(at: denied)
            record("cross-origin-redirect-not-followed")
            do {
                let (url, _) = try await download("interrupted")
                try fm.removeItem(at: url)
                throw CheckFailure(label: "interruption unexpectedly succeeded")
            } catch is CheckFailure { throw CheckFailure(label: "interruption oracle") }
              catch { record("interrupted-no-successful-file") }
            let request = URLRequest(url: tls)
            let delegate = try NetworkTaskDelegate(request: request, policy: .default, disableAutomaticStorage: true)
            do {
                let (url, _) = try await session.download(for: request, delegate: delegate)
                try fm.removeItem(at: url)
                throw CheckFailure(label: "untrusted TLS unexpectedly succeeded")
            } catch is CheckFailure { throw CheckFailure(label: "TLS oracle") }
              catch {
                let e = error as NSError
                try require(e.domain == NSURLErrorDomain && [-1200, -1202, -1203].contains(e.code), "TLS error identity")
                record("system-trust-rejects-local-self-signed")
            }
            // Cancellation mechanism only; APIClient cancellation/error mapping is not implemented here.
            let slowRequest = URLRequest(url: base.appendingPathComponent("slow"))
            let slowDelegate = try NetworkTaskDelegate(request: slowRequest,
                policy: .init(allowInsecureLoopback: true), disableAutomaticStorage: true)
            let pending = Task { try await session.download(for: slowRequest, delegate: slowDelegate) }
            try await Task.sleep(for: .milliseconds(100))
            pending.cancel()
            do {
                let (url, _) = try await pending.value
                try fm.removeItem(at: url)
                throw CheckFailure(label: "cancel unexpectedly returned file")
            } catch is CheckFailure { throw CheckFailure(label: "cancel oracle") }
              catch {
                let e = error as NSError
                try require(error is CancellationError || (e.domain == NSURLErrorDomain && e.code == -999), "cancel category")
                record("cancel-joined-no-successful-file")
            }
            let (handedOff, _) = try await download("normal")
            let retained = root.appendingPathComponent(UUID().uuidString)
            try fm.moveItem(at: handedOff, to: retained)
            if owned {
                let active = Task { try await session.download(for: slowRequest, delegate: slowDelegate) }
                try await Task.sleep(for: .milliseconds(100))
                await transport.invalidateOwnedSession()
                do {
                    let (url, _) = try await active.value
                    try fm.removeItem(at: url)
                    throw CheckFailure(label: "owned invalidation unexpectedly succeeded")
                } catch is CheckFailure { throw CheckFailure(label: "owned invalidation oracle") }
                  catch {
                    let e = error as NSError
                    try require(e.domain == NSURLErrorDomain && e.code == -999, "owned invalidation cancellation")
                    record("owned-invalidation-joins-active-download")
                }
            } else {
                await transport.invalidateOwnedSession()
            }
            try require(fm.fileExists(atPath: retained.path), "handoff survives shutdown")
            try fm.removeItem(at: retained)
            record("handed-off-file-survives-invalidate")
            if !owned {
                let (url, _) = try await download("normal")
                try fm.removeItem(at: url)
                record("borrowed-session-remains-usable")
            }
        }
        let output = URL(fileURLWithPath: args[4])
        let data = try JSONEncoder().encode(observations)
        try data.write(to: output, options: .atomic)
        print("Passed \(observations.count) bounded native observations")
    }
}
