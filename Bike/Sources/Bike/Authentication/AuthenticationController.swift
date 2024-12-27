import Foundation
@preconcurrency import OAuth2

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit)
    import AppKit
#endif

/// Handle the authentication of the user through OAuth2.
public final class AuthenticationController: Sendable {
    /// Shared instance.
    public static let shared = AuthenticationController()

    let oauth2: OAuth2CodeGrant

    init() {
        let settings: OAuth2JSON = [
            "client_id": "5c0d36ce-7396-46f0-bcc0-3c6e16c0d2b6",
            "client_secret": "_NU4.j2A!f!YawfpDFKdWBDQemuMtrYa",
            "authorize_uri": "https://login.conneq.tech/v1/login",
            "token_uri": "https://api.ids.conneq.tech/oauth",
            "redirect_uris": ["tech.conneq.decathlon://decathlon.app.ids.conneq.tech"],
            "scope": "openid profile",
            "use_pkce": true,
            "secret_in_body": true
        ]

        oauth2 = OAuth2CodeGrant(settings: settings)
        oauth2.logger = OAuth2DebugLogger(.trace)
    }

    public var isAuthenticated: Bool {
        oauth2.accessToken != nil
    }

    @MainActor
    public func authenticate() async throws {
        print("Authenticating...")

        #if os(iOS)
            let scene = UIApplication.shared.connectedScenes.first
            let windowScene = scene as? UIWindowScene
            let authorizeContext = windowScene?.windows.first?.rootViewController
        #endif

        #if os(macOS)
            let authorizeContext: NSWindow? = NSApp?.windows.first
        #endif

        oauth2.authConfig.authorizeEmbedded = true
        oauth2.authConfig.authorizeContext = authorizeContext
        oauth2.authConfig.ui.prefersEphemeralWebBrowserSession = true

        return try await withCheckedThrowingContinuation { continuation in
            oauth2.authorize { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    public func logout() {
        oauth2.forgetTokens()
    }
}
