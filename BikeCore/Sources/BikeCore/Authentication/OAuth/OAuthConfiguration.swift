import Foundation

/// Wrap the OAuth configuration, loaded from the OAuthConfiguration.plist file.
struct OAuthConfiguration {
    let clientId: String
    let clientSecret: String
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let redirectUri: String
    let scheme: String

    init() {
        guard let plistPath = Bundle.module.path(forResource: "OAuthConfiguration", ofType: "plist") else {
            fatalError("Could not find OAuthConfiguration.plist.")
        }

        guard let plistData = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
            fatalError("Could not read data from OAuthConfiguration.plist.")
        }

        guard let clientId = plistData["CLIENT_ID"] as? String,
              let clientSecret = plistData["CLIENT_SECRET"] as? String,
              let authorizationEndpoint = plistData["AUTHORIZATION_ENDPOINT"] as? String,
              let tokenEndpoint = plistData["TOKEN_ENDPOINT"] as? String,
              let redirectUri = plistData["REDIRECT_URI"] as? String,
              let scheme = plistData["SCHEME"] as? String else {
            fatalError("Missing required keys in OAuthConfiguration.plist.")
        }

        self.clientId = clientId
        self.clientSecret = clientSecret
        self.authorizationEndpoint = authorizationEndpoint
        self.tokenEndpoint = tokenEndpoint
        self.redirectUri = redirectUri
        self.scheme = scheme
    }
}
