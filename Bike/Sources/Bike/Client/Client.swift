import Alamofire
import Foundation

/// Perform requests to the Decathlon bike API.
public final class Client: Sendable {
    private let endPointURL = URL(string: "https://decathlon.api.bike.conneq.tech")!

    public init() {}

    /// Get user profile.
    public func getProfile() async throws -> User {
        try await fetch(path: "me")
    }

    /// Get user bikes.
    public func getBikes() async throws -> [Bike] {
        try await fetch(path: "bike")
    }

    /// Get bike rides.
    public func getRides(for bike: Int, limit: Int = 50, offset: Int = 0) async throws -> Rides {
        let path = "/v2/bike/\(bike)/ride"

        let parameters: Parameters = [
            "limit": limit,
            "offset": offset,
            "order[]": "start_date;desc"
        ]

        return try await fetch(path: path, parameters: parameters)
    }

    /// Perform a request to the Decathlon bike API.
    private func fetch<T: Decodable>(path: String, parameters: Parameters? = nil) async throws -> T {
        let url = endPointURL.appending(path: path)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // Ensure that we are authenticated, as advised on OAuth2 readme.
        // https://github.com/p2/OAuth2?tab=readme-ov-file#8-re-authorize
        try await AuthenticationController.shared.authenticate()

        let oauth2 = AuthenticationController.shared.oauth2

        return try await AF.request(url,
                                    method: .get,
                                    parameters: parameters,
                                    interceptor: AuthenticationRequestInterceptor(oauth2: oauth2))
            .serializingDecodable(T.self, decoder: decoder)
            .value
    }
}
