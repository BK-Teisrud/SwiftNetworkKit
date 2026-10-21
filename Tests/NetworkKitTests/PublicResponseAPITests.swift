import Foundation
import Testing
import NetworkKit

@Suite struct PublicResponseAPITests {
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
