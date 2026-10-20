import Foundation

/// Immutable, validated limits in seconds. A shorter total budget is valid.
public struct NetworkTimeouts: Sendable, Equatable {
    public let inactivity: TimeInterval
    public let total: TimeInterval

    public init(inactivity: TimeInterval = 30, total: TimeInterval = 60) throws {
        guard inactivity.isFinite, inactivity > 0, total.isFinite, total > 0 else {
            throw NetworkError.invalidRequest(.invalidConfiguration)
        }
        self.inactivity = inactivity
        self.total = total
    }

    public static let `default` = NetworkTimeouts()

    private init() {
        inactivity = 30
        total = 60
    }
}

/// Immutable client settings. URL/security validation belongs to request construction.
public struct NetworkConfiguration: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let baseURL: URL
    public let headers: HTTPHeaders
    public let timeouts: NetworkTimeouts

    public init(baseURL: URL, headers: HTTPHeaders = HTTPHeaders(),
                timeouts: NetworkTimeouts = .default) {
        self.baseURL = baseURL
        self.headers = headers
        self.timeouts = timeouts
    }

    public var description: String { "NetworkConfiguration(headerCount: \(headers.count))" }
    public var debugDescription: String { description }
}

/// Explicit call overrides. Nil inherits the corresponding client limit.
public struct NetworkCallOptions: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let headers: HTTPHeaders
    public let inactivityTimeout: TimeInterval?
    public let totalTimeout: TimeInterval?

    public init(headers: HTTPHeaders = HTTPHeaders(), inactivityTimeout: TimeInterval? = nil,
                totalTimeout: TimeInterval? = nil) throws {
        for limit in [inactivityTimeout, totalTimeout].compactMap({ $0 }) {
            guard limit.isFinite, limit > 0 else {
                throw NetworkError.invalidRequest(.invalidConfiguration)
            }
        }
        self.headers = headers
        self.inactivityTimeout = inactivityTimeout
        self.totalTimeout = totalTimeout
    }

    public var description: String { "NetworkCallOptions(headerCount: \(headers.count))" }
    public var debugDescription: String { description }
}

/// A new value for every operation; no shared mutable encoder/session state.
internal struct ConfigurationSnapshot: Sendable {
    let baseURL: URL
    let headers: HTTPHeaders
    let timeouts: NetworkTimeouts

    init(configuration: NetworkConfiguration, options: NetworkCallOptions) throws {
        baseURL = configuration.baseURL
        headers = try HTTPHeaders(configuration.headers.fields.merging(options.headers.fields) { _, call in call })
        timeouts = try NetworkTimeouts(
            inactivity: options.inactivityTimeout ?? configuration.timeouts.inactivity,
            total: options.totalTimeout ?? configuration.timeouts.total)
    }
}
