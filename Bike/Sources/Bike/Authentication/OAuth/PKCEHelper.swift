import CryptoKit
import Foundation

/// Provides helpers methods used during OAuth PKCE.
struct PKCEHelper {
    /// Generates a code verifier, a random string with 43–128 characters (per the PKCE spec).
    static func generateCodeVerifier(length: Int = 50) -> String {
        // Generate random data
        var data = Data(count: length)
        _ = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!) }

        // Convert to a URL-safe Base64 encoded string.
        let codeVerifier = data
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        return codeVerifier
    }

    /// Generates the code challenge by hashing the verifier with SHA-256, then Base64URL-encoding.
    static func generateCodeChallenge(from verifier: String) -> String {
        let verifierData = Data(verifier.utf8)
        let hashed = SHA256.hash(data: verifierData)

        // Convert the hashed bytes to a URL-safe Base64 encoded string.
        let challenge = Data(hashed)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        return challenge
    }
}
