import Alamofire
import AuthenticationServices
import Foundation

/// An OAuth client, configured to authorize a Decathlon user.
@MainActor class OAuthClient: NSObject {
    override init() {}

    private let configuration = OAuthConfiguration()

    /// Perform OAuth authorization by presenting the Decathlon login page and requesting tokens.
    @available(watchOS, unavailable)
    func authorize() async throws -> Authorization {
        let (code, codeVerifier) = try await startAuthentication()
        return try await exchangeCodeForTokens(code: code, codeVerifier: codeVerifier)
    }

    /// Present the Decathlon login page to let the user sign in.
    /// - Returns: The response code and the code verifier, required for exchange.
    @available(watchOS, unavailable)
    private func startAuthentication() async throws -> (String, String) {
        let codeVerifier = PKCEHelper.generateCodeVerifier()
        let codeChallenge = PKCEHelper.generateCodeChallenge(from: codeVerifier)

        guard var components = URLComponents(string: configuration.authorizationEndpoint) else {
            throw OAuthError.invalidAuthorizationEndpoint
        }

        components.queryItems = [
            URLQueryItem(name: "redirect_uri", value: configuration.redirectUri),
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "scope", value: "openid profile"),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge)
        ]

        let url = try components.asURL()

        #if os(tvOS) || os(watchOS)
        let callbackURL = try await ASWebAuthenticationSession.start(url: url,
                                                                     callback: .customScheme(configuration.scheme))
        #else
        let callbackURL = try await ASWebAuthenticationSession.start(url: url,
                                                                     presentationContextProvider: self,
                                                                     callback: .customScheme(configuration.scheme))
        #endif

        // Extract the code from the callback URL.
        guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "code" })?
            .value else {
            throw OAuthError.missingCodeInCallbackURL
        }

        return (code, codeVerifier)
    }

    /// Exchange to code obtained during authorization with an access token and refresh token.
    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> Authorization {
        let parameters: Parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": configuration.redirectUri,
            "client_id": configuration.clientId,
            "code_verifier": codeVerifier
        ]

        // Headers must include the client ID and client secret as authorization.
        let httpHeaders: HTTPHeaders = [.authorization(username: configuration.clientId,
                                                       password: configuration.clientSecret)]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        return try await AF
            .request(configuration.tokenEndpoint,
                     method: .post,
                     parameters: parameters,
                     encoding: URLEncoding.httpBody,
                     headers: httpHeaders)
            .validate()
            .serializingDecodable(decoder: decoder)
            .value
    }

    /// Refresh the access token of the given authorization using the refresh token.
    func refresh(authorization: Authorization) async throws -> Authorization {
        let parameters: Parameters = [
            "grant_type": "refresh_token",
            "client_id": configuration.clientId,
            "client_secret": configuration.clientSecret,
            "refresh_token": authorization.refreshToken
        ]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        return try await AF
            .request(configuration.tokenEndpoint, method: .post, parameters: parameters)
            .validate()
            .serializingDecodable(decoder: decoder)
            .value
    }
}

#if !(os(tvOS) || os(watchOS))
extension OAuthClient: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS) || os(visionOS)
        let scene = UIApplication.shared.connectedScenes.first
        let windowScene = scene as? UIWindowScene

        guard let window = windowScene?.windows.first else {
            fatalError()
        }

        return window
        #endif

        #if os(macOS)
        guard let window = NSApp.windows.first else {
            fatalError()
        }
        return window
        #endif
    }
}
#endif

enum OAuthError: Error {
    case missingCodeInCallbackURL
    case invalidAuthorizationEndpoint
}
