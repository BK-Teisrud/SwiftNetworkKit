import Foundation
import Testing
import os
@testable import NetworkKit

#if os(macOS)
/// Two ephemeral listeners, both bound only to 127.0.0.1. No public networking.
private final class LocalRedirectServer {
    let process: Process
    let base: URL
    let destination: URL
    init() throws {
        process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["python3", "-u", "-c", #"""
import http.server, threading
count = 0
class Destination(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        global count
        count += 1
        self.send_response(200); self.send_header('Content-Length', '0'); self.end_headers()
    def log_message(self, *args): pass
other = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Destination)
class Original(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = b'done'
        if self.path == '/count':
            body = str(count).encode()
        elif self.path.startswith('/chain/') or self.path.startswith('/excess/'):
            kind, number = self.path.strip('/').split('/')
            limit = 5 if kind == 'chain' else 6
            if int(number) < limit:
                self.send_response(302)
                self.send_header('Location', 'http://127.0.0.1:%d/%s/%d' % (self.server.server_port, kind, int(number)+1))
                self.send_header('Content-Length', '0'); self.end_headers(); return
        elif self.path == '/loop':
            self.send_response(302)
            self.send_header('Location', 'http://127.0.0.1:%d/loop' % self.server.server_port)
            self.send_header('Content-Length', '0'); self.end_headers(); return
        else:
            self.send_response(302)
            self.send_header('Location', 'http://127.0.0.1:%d/denied' % other.server_port)
            self.send_header('Content-Length', '0'); self.end_headers(); return
        self.send_response(200); self.send_header('Content-Length', str(len(body))); self.end_headers()
        if self.command != 'HEAD': self.wfile.write(body)
    do_HEAD = do_GET
    def log_message(self, *args): pass
original = http.server.ThreadingHTTPServer(('127.0.0.1', 0), Original)
threading.Thread(target=other.serve_forever, daemon=True).start()
print('%d %d' % (original.server_port, other.server_port), flush=True)
original.serve_forever()
"""#]
        process.standardOutput = output
        process.standardError = Pipe()
        try process.run()
        var bytes = Data()
        while let next = try output.fileHandleForReading.read(upToCount: 1), !next.isEmpty {
            if next == Data([10]) { break }
            bytes.append(next)
        }
        let ports = String(decoding: bytes, as: UTF8.self).split(separator: " ").compactMap { Int($0) }
        guard ports.count == 2 else { process.terminate(); throw URLError(.cannotConnectToHost) }
        base = URL(string: "http://127.0.0.1:\(ports[0])")!
        destination = URL(string: "http://127.0.0.1:\(ports[1])/denied")!
    }
    func stop() { if process.isRunning { process.terminate(); process.waitUntilExit() } }
    deinit { if process.isRunning { process.terminate() } }
}
#endif

@Suite struct RedirectIntegrationTests {
    @Test(.timeLimit(.minutes(1)), arguments: [false, true])
    func deniedRedirectDestinationIsNotContacted(typed: Bool) async throws {
        #if os(macOS)
        let server = try LocalRedirectServer(); defer { server.stop() }
        let base = server.base
        let destination = server.destination
        let policy = NetworkSecurityPolicy(allowInsecureLoopback: true, additionalRawOrigins: [try NetworkOrigin(destination)])
        let operation = URLSessionTransport.systemDataOperation
        #else
        // Native local-server integration runs on macOS. Other platforms exercise the
        // actual delegate callback with scripted I/O, not a URLProtocol redirect.
        let base = URL(string: "https://example.invalid")!
        let destination = URL(string: "https://evil.invalid/denied")!
        let policy = NetworkSecurityPolicy(additionalRawOrigins: [try NetworkOrigin(destination)])
        let contacted = OSAllocatedUnfairLock(initialState: [URL]())
        let operation: URLSessionTransport.DataOperation = { session, request, delegate in
            contacted.withLock { $0.append(request.url!) }
            var next = request; next.url = destination
            let response = HTTPURLResponse(url: request.url!, statusCode: 302, httpVersion: nil,
                                           headerFields: ["Location": destination.absoluteString])!
            let task = session.dataTask(with: request) // Never resumed.
            let result = OSAllocatedUnfairLock<URLRequest?>(initialState: nil)
            delegate.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: next,
                                completionHandler: { next in result.withLock { $0 = next } })
            task.cancel()
            if let next = result.withLock({ $0 }) { contacted.withLock { $0.append(next.url!) } }
            return TransportResponse(data: Data(), response: response)
        }
        #endif
        let configuration = NetworkConfiguration(baseURL: base, timeouts: try NetworkTimeouts(inactivity: 3), security: policy)
        let acceptedRedirect = try NetworkCallOptions(acceptedStatuses: HTTPStatusPolicy(codes: [302]))
        let transport = try URLSessionTransport(dataOperation: operation, securityPolicy: policy, baseURL: base)
        #if os(macOS)
        // Exercise the public owned-session assembly and real native redirect callbacks.
        let client = try APIClient(configuration: configuration)
        #else
        let client = try APIClient(configuration: configuration, transport: transport)
        #endif
        let response: NetworkResponse<EmptyResponse>
        if typed {
            struct RedirectCall: Endpoint {
                typealias Response = EmptyResponse
                let path: EndpointPath
                let options: NetworkCallOptions
            }
            response = try await client.send(RedirectCall(path: EndpointPath(segments: ["start"]), options: acceptedRedirect))
        } else {
            response = try await client.send(URLRequest(url: base.appendingPathComponent("start")),
                                             response: .empty, options: acceptedRedirect)
        }
        #expect(response.status.code == 302)
        #if os(macOS)
        let count = try await client.send(URLRequest(url: base.appendingPathComponent("count")), response: .text)
        #expect(count.value == "0")
        #else
        #expect(contacted.withLock { $0 } == [base.appendingPathComponent("start")])
        #endif
        await transport.invalidateOwnedSession()
    }
    @Test(.timeLimit(.minutes(1)), arguments: ["GET", "HEAD", "limit", "loop"])
    func sameOriginRedirectsHaveABoundedLifetime(_ scenario: String) async throws {
        let method = scenario == "HEAD" ? "HEAD" : "GET"
        let path = scenario == "loop" ? "loop" : (scenario == "limit" ? "excess/0" : "chain/0")
        #if os(macOS)
        let server = try LocalRedirectServer(); defer { server.stop() }
        let base = server.base
        let policy = NetworkSecurityPolicy(allowInsecureLoopback: true)
        let operation = URLSessionTransport.systemDataOperation
        #else
        let base = URL(string: "https://example.invalid")!
        let policy = NetworkSecurityPolicy.default
        let operation: URLSessionTransport.DataOperation = { _, request, delegate in
            var current = request
            let hops = scenario == "loop" ? 1 : (scenario == "limit" ? 6 : 5)
            for i in 1...hops {
                var next = current
                next.url = scenario == "loop" ? request.url! : base.appendingPathComponent("step\(i)")
                let response = HTTPURLResponse(url: current.url!, statusCode: 302, httpVersion: nil, headerFields: nil)!
                guard let approved = delegate.redirectedRequest(response: response, proposed: next) else {
                    return TransportResponse(data: Data(), response: response)
                }
                current = approved
            }
            return TransportResponse(data: Data(), response: HTTPURLResponse(url: current.url!, statusCode: 200,
                                                                            httpVersion: nil, headerFields: nil)!)
        }
        #endif
        let transport = try URLSessionTransport(dataOperation: operation, securityPolicy: policy, baseURL: base)
        var request = URLRequest(url: base.appendingPathComponent(path)); request.httpMethod = method; request.timeoutInterval = 3
        if scenario == "limit" || scenario == "loop" {
            await #expect(throws: NetworkError.invalidResponse(.redirectLimitExceeded)) { try await transport.send(request) }
        } else {
            let result = try await transport.send(request)
            #expect((result.response as? HTTPURLResponse)?.statusCode == 200)
        }
        await transport.invalidateOwnedSession()
    }

}
