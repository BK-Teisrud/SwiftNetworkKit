import Foundation

/// Internal transport only; the public client and complete security policy follow later.
internal actor URLSessionTransport: NetworkTransport {
    enum StoragePolicy: Sendable { case strict, appManaged }

    let session: URLSession
    let ownsSession: Bool
    private let storagePolicy: StoragePolicy
    private var invalidated = false

    /// Starts from ephemeral, then explicitly disables even in-memory automatic stores.
    static func configuration(timeouts: NetworkTimeouts = .default) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.httpCookieStorage = nil
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never
        config.urlCredentialStorage = nil
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = timeouts.inactivity
        // Keep the platform resource limit; a 60-second cap would contradict longer calls.
        // The monotonic per-operation total budget is implemented separately in I12.
        return config
    }

    /// Custom protocolClasses are an internal test seam, never a public plugin system.
    init(ownedConfiguration: URLSessionConfiguration = URLSessionTransport.configuration()) throws {
        guard let copy = ownedConfiguration.copy() as? URLSessionConfiguration else {
            throw NetworkError.invalidRequest(.invalidConfiguration)
        }
        try Self.validate(copy, storagePolicy: .strict)
        session = URLSession(configuration: copy)
        ownsSession = true
        storagePolicy = .strict
    }

    init(session: URLSession, storagePolicy: StoragePolicy = .strict) throws {
        guard session.delegate == nil else { throw NetworkError.invalidRequest(.unsupportedRequest) }
        try Self.validate(session.configuration, storagePolicy: storagePolicy)
        self.session = session
        ownsSession = false
        self.storagePolicy = storagePolicy
    }

    private static func validate(_ configuration: URLSessionConfiguration, storagePolicy: StoragePolicy) throws {
        guard configuration.identifier == nil else { throw NetworkError.invalidRequest(.unsupportedRequest) }
        guard configuration.timeoutIntervalForRequest.isFinite, configuration.timeoutIntervalForRequest > 0,
              configuration.timeoutIntervalForResource.isFinite, configuration.timeoutIntervalForResource > 0 else {
            throw NetworkError.invalidRequest(.invalidConfiguration)
        }
        if storagePolicy == .strict {
            guard configuration.httpCookieStorage == nil, !configuration.httpShouldSetCookies,
                  configuration.httpCookieAcceptPolicy == .never, configuration.urlCredentialStorage == nil,
                  configuration.urlCache == nil, configuration.requestCachePolicy == .reloadIgnoringLocalCacheData else {
                throw NetworkError.invalidRequest(.invalidConfiguration)
            }
        }
    }

    func send(_ input: URLRequest) async throws -> TransportResponse {
        try Task.checkCancellation()
        guard !invalidated else { throw NetworkError.invalidRequest(.clientClosed) }
        guard input.httpBodyStream == nil else { throw NetworkError.invalidRequest(.unsupportedRequest) }
        var request = input
        if storagePolicy == .strict {
            request.httpShouldHandleCookies = false
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        let (data, response) = try await session.data(for: request)
        try Task.checkCancellation()
        return TransportResponse(data: data, response: response)
    }

    /// Ownership primitive, not the client shutdown/operation registry planned in I13.
    /// Borrowed sessions and every task belonging to their other consumers are untouched.
    func invalidateOwnedSession() {
        guard ownsSession, !invalidated else { return }
        invalidated = true
        session.invalidateAndCancel()
    }

    deinit {
        if ownsSession { session.invalidateAndCancel() }
    }
}
