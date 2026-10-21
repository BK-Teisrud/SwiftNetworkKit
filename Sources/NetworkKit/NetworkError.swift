import Foundation

/// Structured failures without raw payloads, URLs, or underlying error objects.
/// CancellationError remains separate; transport cancellation requires later
/// operation-context normalization rather than a category inferred here.
public enum NetworkError: Error, Sendable, Equatable, LocalizedError,
    CustomStringConvertible, CustomDebugStringConvertible {
    case invalidRequest(InvalidRequestReason)
    case transport(TransportFailure)
    case httpStatus(HTTPStatus, headers: HTTPHeaders)
    case invalidResponse(InvalidResponseReason)
    case encoding
    case decoding
    case timeout(TimeoutReason)

    public enum InvalidRequestReason: String, Sendable {
        case insecureTransport
        case unpermittedOrigin
        case credentialsOverHTTP
        case invalidURL
        case invalidMethod
        case invalidHeaderName
        case invalidHeaderValue
        case conflictingHeaders
        case invalidConfiguration
        case unsupportedRequest
        case clientClosed
    }

    public enum InvalidResponseReason: String, Sendable {
        case nonHTTPResponse
        case invalidStatusCode
        case invalidHeaders
        case unexpectedContentType
        case redirectLimitExceeded
    }

    public enum TimeoutReason: String, Sendable {
        case inactivity
        case totalBudget
        case system
    }

    /// Retains machine-readable error identity, never userInfo or localized text.
    /// Domain is an explicit diagnostic value and is omitted from descriptions.
    public struct TransportFailure: Sendable, Equatable,
        CustomStringConvertible, CustomDebugStringConvertible {
        public let domain: String
        public let code: Int

        public init(domain: String, code: Int) {
            self.domain = domain
            self.code = code
        }

        public init(_ error: URLError) {
            self.init(domain: NSURLErrorDomain, code: error.code.rawValue)
        }

        public var description: String { "TransportFailure(code: \(code))" }
        public var debugDescription: String { description }
    }

    public var description: String {
        switch self {
        case .invalidRequest(let reason):
            "NetworkKit invalid request (\(reason.rawValue))."
        case .transport(let failure):
            "NetworkKit transport failure (code: \(failure.code))."
        case .httpStatus(let status, _):
            "NetworkKit HTTP status failure (\(status.code))."
        case .invalidResponse(let reason):
            "NetworkKit invalid response (\(reason.rawValue))."
        case .encoding:
            "NetworkKit request encoding failed."
        case .decoding:
            "NetworkKit response decoding failed."
        case .timeout(let reason):
            "NetworkKit timeout (\(reason.rawValue))."
        }
    }

    public var debugDescription: String { description }
    public var errorDescription: String? { description }
}
