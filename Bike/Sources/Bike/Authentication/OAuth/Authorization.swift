import Foundation

/// Authorization info provided by OAuth.
struct Authorization: Codable {
    let accessToken: String
    let expiresAt: Date
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresAt = "expires_at"
        case refreshToken = "refresh_token"
    }
}

extension Authorization {
    /// Indicates if the access token is valid.
    var hasValidAccessToken: Bool {
        .now < expiresAt
    }
}
