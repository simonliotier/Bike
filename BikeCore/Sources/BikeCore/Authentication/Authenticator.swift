import Foundation

/// An object handling the authentication.
///
/// This is a concrete type wrapping the `AuthenticatorProtocol` protocol to be used in `@Environment`.
@Observable @MainActor public class Authenticator: AuthenticatorProtocol {
    let wrapped: any AuthenticatorProtocol

    public init(_ wrapped: any AuthenticatorProtocol = AppAuthenticator()) {
        self.wrapped = wrapped
    }

    public var isAuthenticated: Bool {
        wrapped.isAuthenticated
    }

    public var accessToken: String {
        get async throws {
            try await wrapped.accessToken
        }
    }

    #if !os(watchOS)
    public func signIn() async throws {
        try await wrapped.signIn()
    }
    #endif

    public func signOut() {
        wrapped.signOut()
    }
}

/// Protocol defining the interface for authentication related tasks.
@MainActor public protocol AuthenticatorProtocol {
    var isAuthenticated: Bool { get }
    var accessToken: String { get async throws }
    #if !os(watchOS)
    func signIn() async throws
    #endif
    func signOut()
}
