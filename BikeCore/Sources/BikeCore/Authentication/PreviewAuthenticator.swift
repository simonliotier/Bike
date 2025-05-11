import Foundation

/// Implementation of the `AuthenticatorProtocol` protocol that is used in previews.
@Observable @MainActor public class PreviewAuthenticator: AuthenticatorProtocol {
    public private(set) var isAuthenticated: Bool = false

    public init(isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }

    public let accessToken: String = ""

    public func signIn() async throws {
        isAuthenticated = true
    }

    public func signOut() {
        isAuthenticated = false
    }
}
