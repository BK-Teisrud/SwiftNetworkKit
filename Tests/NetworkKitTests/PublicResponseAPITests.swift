import Foundation
import Testing
import NetworkKit

@Suite struct PublicResponseAPITests {
    @Test func externalConsumerCanShutdownThroughClientBoundary() async throws {
        struct Call: Endpoint {
            typealias Response = EmptyResponse
            let path = try! EndpointPath(segments: [])
        }
        let url = URL(string: "https://example.invalid")!
        let client: any NetworkClient = try APIClient(configuration: NetworkConfiguration(baseURL: url))
        await client.shutdown()
        await client.shutdown()
        await #expect(throws: NetworkError.invalidRequest(.clientClosed)) { try await client.send(Call()) }
        await #expect(throws: NetworkError.invalidRequest(.clientClosed)) {
            try await client.send(URLRequest(url: url), response: .empty)
        }
    }

    @Test func systemTimeoutRetainsOnlySafeTransportIdentity() {
        #expect(NetworkError.timeout(.system).transportFailure == .init(URLError(.timedOut)))
        #expect(NetworkError.transport(.init(URLError(.cancelled))).transportFailure == .init(URLError(.cancelled)))
        #expect(NetworkError.timeout(.totalBudget).transportFailure == nil)
        #expect(NetworkError.decoding.transportFailure == nil)
    }
    @Test func externalConsumerCanInjectAndExecuteClientBoundary() async throws {
        struct Mock: NetworkClient {
            func shutdown() async {}
            func send<E: Endpoint>(_ endpoint: E) async throws -> NetworkResponse<E.Response> {
                throw NetworkError.invalidRequest(.unsupportedRequest)
            }
            func send<Value: Sendable>(_ request: URLRequest, response: ResponseStrategy<Value>,
                                      options: NetworkCallOptions) async throws -> NetworkResponse<Value> {
                let http = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
                return try response.decode(Data("mock".utf8), response: http, acceptedStatuses: options.acceptedStatuses)
            }
        }
        let client: any NetworkClient = Mock()
        #expect(try await client.send(URLRequest(url: URL(string: "https://example.invalid")!), response: .text).value == "mock")
        let configuration = NetworkConfiguration(baseURL: URL(string: "https://example.invalid")!)
        let owned: any NetworkClient = try APIClient(configuration: configuration)
        await owned.shutdown()
        await client.shutdown()
    }

    @Test func externalConsumerCanBorrowCompatibleSession() async throws {
        let settings = URLSessionConfiguration.ephemeral
        settings.httpCookieStorage = nil
        settings.httpShouldSetCookies = false
        settings.httpCookieAcceptPolicy = .never
        settings.urlCredentialStorage = nil
        settings.urlCache = nil
        settings.requestCachePolicy = .reloadIgnoringLocalCacheData
        #if !os(watchOS)
        settings.protocolClasses = [SessionStubProtocol.self]
        #endif
        let session = URLSession(configuration: settings)
        defer { session.invalidateAndCancel() }
        let client = try APIClient(configuration: NetworkConfiguration(baseURL: URL(string: "https://example.invalid")!),
                                   session: session)
        #if !os(watchOS)
        let url = SessionStubProtocol.install(.init(data: Data("public".utf8), status: 200, headers: [:]))
        defer { SessionStubProtocol.remove(url) }
        #expect(try await client.send(URLRequest(url: url), response: .text).value == "public")
        #else
        // URLProtocol interception is unsupported on watchOS; construction is still checked.
        _ = client
        #endif
    }
    @Test func externalConsumerCanSelectTypedAndRawStrategies() throws {
        struct Model: Decodable, Sendable { let name: String }
        struct Call: Endpoint {
            let path: EndpointPath
            let responseStrategy: ResponseStrategy<Model> = .json()
            let options = NetworkCallOptions.default
        }
        let local = URL(string: "http://localhost:8080")!
        let security = NetworkSecurityPolicy(allowInsecureLoopback: true, additionalRawOrigins: [try NetworkOrigin(local)])
        #expect(try NetworkOrigin(local).port == 8080)
        #expect(try Call(path: EndpointPath(segments: [])).request(configuration:
            NetworkConfiguration(baseURL: local, security: security)).url == local)
        let response = HTTPURLResponse(url: URL(string: "https://example.invalid")!, statusCode: 200,
                                       httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
        let call = Call(path: try EndpointPath(segments: ["items"]))
        #expect(try call.decodeResponse(Data(#"{"name":"ok"}"#.utf8), response: response).value.name == "ok")
        #expect(try ResponseStrategy<String>.text.decode(Data("hello".utf8), response: response).value == "hello")
        #expect(try ResponseStrategy<Data>.data.decode(Data([0,255]), response: response).value == Data([0,255]))
        #expect(try ResponseStrategy<EmptyResponse>.empty.decode(Data(), response: response).value == EmptyResponse())
    }
}
