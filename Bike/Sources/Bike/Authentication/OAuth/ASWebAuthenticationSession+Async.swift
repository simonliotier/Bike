import AuthenticationServices

/// Async wrappers for `ASWebAuthenticationSession`.
extension ASWebAuthenticationSession {
    /// Create and start an `ASWebAuthenticationSession` instance to authenticate a user through a web service.
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @MainActor static func start(url: URL,
                                 presentationContextProvider: (any ASWebAuthenticationPresentationContextProviding)?,
                                 callback: ASWebAuthenticationSession.Callback) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = session(url: url, callback: callback, continuation: continuation)
            session.presentationContextProvider = presentationContextProvider
            session.start()
        }
    }

    /// Create and start an `ASWebAuthenticationSession` instance to authenticate a user through a web service.
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(visionOS, unavailable)
    @available(watchOS, unavailable)
    @MainActor static func start(url: URL,
                                 callback: ASWebAuthenticationSession.Callback) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = session(url: url, callback: callback, continuation: continuation)
            session.start()
        }
    }

    private static func session(
        url: URL,
        callback: ASWebAuthenticationSession.Callback,
        continuation: CheckedContinuation<URL, any Error>
    ) -> ASWebAuthenticationSession {
        ASWebAuthenticationSession(url: url, callback: callback) { url, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: ASWebAuthenticationSessionError.missingURL)
                }
            }
        }
    }
}

enum ASWebAuthenticationSessionError: Error {
    case missingURL
}
