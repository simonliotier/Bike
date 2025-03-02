@preconcurrency import AppAuth
@preconcurrency import AppAuthCore
import Foundation
import KeychainSwift
import SwiftUI

/// Handle the authentication of the user through OAuth.
///
/// User can sign-in in the iOS and macOS apps. The auth state, containing the access and refresh tokens, is then
/// automatically shared with other apps and widgets using Keychain access group and iCloud synchronization.
@Observable @MainActor public final class AuthenticationController: NSObject, @unchecked Sendable {
    /// Indicates if the user is currently authenticated.
    public var isAuthenticated: Bool {
        return authState?.isAuthorized ?? false
    }

    /// Provide a valid access token, refreshing it first, if needed.
    public var accessToken: String {
        get async throws {
            // Another app or widget may have updated the auth state, reload it.
            loadAuthState()

            guard let authState else {
                throw AuthenticationError.missingAuthState
            }

            let (accessToken, _) = try await authState.performAction()

            return accessToken
        }
    }

    /// Current authentication state.
    private var authState: OIDAuthState?

    /// The in-flight external user-agent session. We must keep a reference on it during authentication.
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?

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

        loadAuthState()
    }

    /// Update the `authState` property with the value stored in the Keychain.
    ///
    /// The Keychain is the source of truth for the shared authentication state between all apps and widget. Each of
    /// them may update the auth state and save it in the Keychain.
    private func loadAuthState() {
        authState = readAuthStateFromKeychain()
        authState?.stateChangeDelegate = self
    }

    // MARK: - Sign In

    /// Sign in the user by presenting the sign in interface, in order to get an access token.
    @available(watchOS, unavailable)
    public func signIn() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.signIn { result in
                continuation.resume(with: result)
            }
        }
    }

    @available(watchOS, unavailable)
    private func signIn(completion: @escaping (Result<Void, Error>) -> Void) {
        let authorizationEndpoint = URL(string: "https://login.conneq.tech/v1/login")!
        let tokenEndpoint = URL(string: "https://api.ids.conneq.tech/oauth")!
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint,
                                                    tokenEndpoint: tokenEndpoint)
        let clientId = "5c0d36ce-7396-46f0-bcc0-3c6e16c0d2b6"
        let clientSecret = "_NU4.j2A!f!YawfpDFKdWBDQemuMtrYa"
        let scopes = ["openid", "profile"]
        let redirectURL = URL(string: "tech.conneq.decathlon://decathlon.app.ids.conneq.tech")!
        let codeVerifier = OIDAuthorizationRequest.generateCodeVerifier()
        let codeChallenge = OIDAuthorizationRequest.codeChallengeS256(forVerifier: codeVerifier)

        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientId,
                                              clientSecret: clientSecret,
                                              scope: OIDScopeUtilities.scopes(with: scopes),
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              state: OIDAuthorizationRequest.generateState(),
                                              nonce: nil, // Nonce must be explicitly null.
                                              codeVerifier: codeVerifier,
                                              codeChallenge: codeChallenge,
                                              codeChallengeMethod: OIDOAuthorizationRequestCodeChallengeMethodS256,
                                              additionalParameters: nil)

        guard let agent = platformExternalUserAgent() else {
            completion(.failure(AuthenticationError.externalUserAgentCreationFailed))
            return
        }

        currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request,
                                                          externalUserAgent: agent) { authState, error in
            if let error {
                print("Error during authorization: \(error)")
                completion(.failure(error))
                return
            }

            guard let authState else {
                print("Error during authorization: \(AuthenticationError.missingAuthState)")
                completion(.failure(AuthenticationError.missingAuthState))
                return
            }

            authState.stateChangeDelegate = self
            self.writeAuthStateToKeychain(authState)
            self.authState = authState
            completion(.success(()))
        }
    }

    @available(watchOS, unavailable)
    private func platformExternalUserAgent() -> OIDExternalUserAgent? {
        #if os(macOS)
        guard let window = NSApp.windows.first else {
            return nil
        }
        return OIDExternalUserAgentMac(presenting: window)
        #endif

        #if os(iOS)
        let scene = UIApplication.shared.connectedScenes.first
        let windowScene = scene as? UIWindowScene

        guard let rootViewController = windowScene?.windows.first?.rootViewController,
              let userAgent = OIDExternalUserAgentIOS(presenting: rootViewController) else {
            return nil
        }

        return userAgent
        #endif

        #if os(watchOS)
        fatalError()
        #endif
    }

    // MARK: - Sign Out

    /// Sign out the user by deleting the auth state.
    public func signOut() {
        authState = nil
        deleteAuthStateFromKeychain()
    }

    // MARK: - Keychain

    /// Save the give auth state to the Keychain.
    private func writeAuthStateToKeychain(_ state: OIDAuthState) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: state, requiringSecureCoding: true)
            keychain.set(data, forKey: .authState, withAccess: .accessibleAfterFirstUnlock)
        } catch {
            print("Error archiving OIDAuthState: \(error)")
        }
    }

    /// Return an auth state from the Keychain, if it exists.
    private func readAuthStateFromKeychain() -> OIDAuthState? {
        guard let data = keychain.getData(.authState) else {
            return nil
        }

        do {
            return try NSKeyedUnarchiver.unarchiveTopLevelObject(ofClass: OIDAuthState.self, from: data)
        } catch {
            print("Error unarchiving OIDAuthState: \(error)")
        }

        return nil
    }

    /// Delete the potential auth state saved in the Keychain.
    private func deleteAuthStateFromKeychain() {
        keychain.delete(.authState)
    }
}

public enum AuthenticationError: Error {
    case externalUserAgentCreationFailed
    case missingAuthState
    case missingToken
    case authStatedDecodingFailed
}

extension AuthenticationController: OIDAuthStateChangeDelegate {
    /// Called when the authorization auth state changes. We update the auth state stored in the Keychain.
    public nonisolated func didChange(_ state: OIDAuthState) {
        Task {
            await writeAuthStateToKeychain(state)
        }
    }
}

private extension String {
    static let authState = "bike.authState"
}

private extension NSKeyedUnarchiver {
    /// Unarchive an object of the given type.
    ///
    /// This implementation relies on the deprecated method `NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(_:)`
    /// because `OIDAuthState` does not work with `unarchivedObject(ofClass:from:)`. The `SilenceDeprecation` allows us
    /// to get rid of the deprecation warning.
    static func unarchiveTopLevelObject<DecodedObjectType>(
        ofClass cls: DecodedObjectType.Type,
        from data: Data
    ) throws -> DecodedObjectType where DecodedObjectType: NSObject, DecodedObjectType: NSCoding {
        guard let decodedObject = try (SilenceDeprecationImplementation() as SilenceDeprecation)
            .unarchiveTopLevelObjectWithData(data) as? DecodedObjectType else {
            throw AuthenticationError.authStatedDecodingFailed
        }

        return decodedObject
    }
}

private protocol SilenceDeprecation {
    func unarchiveTopLevelObjectWithData(_ data: Data) throws -> Any?
}

private final class SilenceDeprecationImplementation: SilenceDeprecation {
    @available(iOS, deprecated: 18)
    @available(macOS, deprecated: 10.15)
    @available(watchOS, deprecated: 11)
    func unarchiveTopLevelObjectWithData(_ data: Data) throws -> Any? {
        try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
    }
}

extension OIDAuthState {
    /// Async version of `OIDAuthState.performAction(freshTokens:)`.
    func performAction(additionalRefreshParameters: [String: String] = [:]) async throws -> (String, String) {
        try await withCheckedThrowingContinuation { continuation in
            self.performAction(freshTokens: { accessToken, idToken, error in
                                   if let error {
                                       continuation.resume(throwing: error)
                                       return
                                   }

                                   guard let accessToken, let idToken else {
                                       continuation.resume(throwing: AuthenticationError.missingToken)
                                       return
                                   }

                                   continuation.resume(returning: (accessToken, idToken))
                               },
                               additionalRefreshParameters: additionalRefreshParameters)
        }
    }
}
