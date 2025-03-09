import Foundation
import KeychainSwift
import SwiftUI

/// Handle the authentication of the user through OAuth.
///
/// User can sign-in in the iOS and macOS apps. The authorization, containing the access and refresh tokens, is then
/// automatically shared with other apps and widgets using Keychain access group and iCloud synchronization.
@Observable @MainActor public final class AuthenticationController: NSObject, @unchecked Sendable {
    /// Indicates if the user is currently authenticated.
    public var isAuthenticated: Bool {
        authorization != nil
    }

    /// Returns a valid access token.
    public var accessToken: String {
        get async throws {
            try await getAccessTokenWithConcurrentAccessControl()
        }
    }

    /// Current authorization.
    private var authorization: Authorization?

    private let oAuthClient = OAuthClient()

    /// Keychain used to persist the auth state.
    private let keychain: KeychainSwift = {
        let keychain = KeychainSwift()

        // Use access group to share auth state between app and widgets.
        keychain.accessGroup = "5PPY38J7P4.tech.conneq.decathlon.shared"

        // Synchronization is activated to share the auth state with other devices.
        keychain.synchronizable = true

        return keychain
    }()

    // MARK: - Initialization

    override public init() {
        super.init()

        loadAuthorization()
    }

    /// Update the `authorization` property with the value stored in the Keychain.
    ///
    /// The Keychain is the source of truth for the shared authorization between all apps and widget. Each of them may
    /// update the authorization and save it in the Keychain.
    private func loadAuthorization() {
        authorization = readAuthorizationFromKeychain()
    }

    // MARK: - Sign In

    /// Sign in the user by presenting the sign in interface, in order to get an access token.
    @available(watchOS, unavailable)
    public func signIn() async throws {
        let authorization = try await oAuthClient.authorize()
        writeAuthorizationToKeychain(authorization)
        self.authorization = authorization
    }

    // MARK: - Sign Out

    /// Sign out the user by deleting the authorization.
    public func signOut() {
        authorization = nil
        deleteAuthorizationFromKeychain()
    }

    // MARK: - Access Token

    /// Task executed when fetching an access token.
    private var accessTokenTask: Task<String, Error>?

    /// Returns a valid access token, either from the Keychain, or by fetching a new one, while ensuring the request is
    /// only performed once.
    private func getAccessTokenWithConcurrentAccessControl() async throws -> String {
        if let accessTokenTask {
            // An access token request is already in progress, wait for for its completion.
            return try await accessTokenTask.value
        }

        // Create a new access token request task.
        let task = Task { () throws -> String in
            defer { accessTokenTask = nil }

            return try await getAccessToken()
        }

        accessTokenTask = task

        return try await task.value
    }

    /// Returns a valid access token, either from the Keychain, or by fetching a new one.
    private func getAccessToken() async throws -> String {
        loadAuthorization()

        guard let authorization else {
            throw AuthenticationError.userNotAuthenticated
        }

        if authorization.hasValidAccessToken {
            return authorization.accessToken
        } else {
            let newAuthorization = try await oAuthClient.refresh(authorization: authorization)
            writeAuthorizationToKeychain(newAuthorization)
            return newAuthorization.accessToken
        }
    }

    // MARK: - Keychain

    /// Saves the given authorization to the Keychain.
    private func writeAuthorizationToKeychain(_ authorization: Authorization) {
        do {
            let data = try JSONEncoder().encode(authorization)
            keychain.set(data, forKey: .authorization, withAccess: .accessibleAfterFirstUnlock)
        } catch {
            print("Error encoding authorization: \(error)")
        }
    }

    /// Returns an authorization from the Keychain, if it exists.
    private func readAuthorizationFromKeychain() -> Authorization? {
        guard let data = keychain.getData(.authorization) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(Authorization.self, from: data)
        } catch {
            print("Error decoding authorization: \(error)")
        }

        return nil
    }

    /// Delete the potential authorization saved in the Keychain.
    private func deleteAuthorizationFromKeychain() {
        keychain.delete(.authorization)
    }
}

public enum AuthenticationError: Error {
    case userNotAuthenticated
}

private extension String {
    /// Key used to store the authorization in the Keychain.
    static let authorization = "bike.authorization"
}
