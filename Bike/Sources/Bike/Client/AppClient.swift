import Alamofire
import Foundation
import SwiftUI

/// Implementation of the `ClientProtocol` protocol that performs requests to the Decathlon bike API.
public final class AppClient: ClientProtocol, Sendable {
    let authenticator: Authenticator

    private let endPointURL = URL(string: "https://decathlon.api.bike.conneq.tech")!

    public init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }

    public func getProfile() async throws -> User {
        try await fetch(path: "me")
    }

    public func getBikes() async throws -> [Bike] {
        try await fetch(path: "bike")
    }

    public func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides {
        let path = "/v2/bike/\(bike)/ride"

        struct Parameters: Encodable {
            let limit: Int
            let offset: Int
            let order: String = "start_date;desc"
        }

        return try await fetch(path: path, parameters: Parameters(limit: limit, offset: offset))
    }

    public func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location] {
        let path = "bike/\(bike)/location"

        let parameters: Encodable & Sendable = [
            "from": from,
            "till": till
        ]

        return try await fetch(path: path, parameters: parameters)
    }

    public func getStats(for bike: Int, from: Date, till: Date, granularity: StatsGranularity) async throws -> [Stat] {
        let path = "bike/\(bike)/stats"

        struct Parameters: Encodable {
            let from: Date
            let till: Date
            let type: StatsGranularity
            let tz: String = TimeZone.current.identifier // swiftlint:disable:this identifier_name
        }

        return try await fetch(path: path, parameters: Parameters(from: from, till: till, type: granularity))
    }

    /// Perform a request to the Decathlon bike API.
    private func fetch<Value: Decodable & Sendable>(
        path: String,
        parameters: (any Encodable & Sendable)? = nil
    ) async throws -> Value {
        let url = endPointURL.appending(path: path)

        let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(dateEncoding: .iso8601))

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let interceptor = AuthenticationRequestInterceptor(authenticator: authenticator)

        let request: DataRequest = {
            if let parameters {
                return AF.request(url,
                                  method: .get,
                                  parameters: parameters,
                                  encoder: encoder,
                                  interceptor: interceptor)
            } else {
                return AF.request(url,
                                  method: .get,
                                  interceptor: interceptor)
            }
        }()

        return try await request
            .serializingDecodable(Value.self, automaticallyCancelling: true, decoder: decoder)
            .value
    }
}
