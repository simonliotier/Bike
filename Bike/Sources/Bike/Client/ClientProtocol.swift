import Foundation
import SwiftUI

/// Protocol defining the interface for fetching user-related data.
public protocol ClientProtocol: Sendable, ObservableObject {
    /// Get user profile.
    func getProfile() async throws -> User

    /// Get user bikes.
    func getBikes() async throws -> [Bike]

    /// Get bike rides.
    func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides

    /// Get bike locations between two dates.
    func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location]

    /// Get bike stats between two dates, for the given granularity.
    func getStats(for bike: Int, from: Date, till: Date, granularity: StatsGranularity) async throws -> [Stat]
}

/// Granularity specified when requesting stats.
public enum StatsGranularity: String, Codable, Sendable {
    case hourly
    case daily
}

/// Concrete type wrapper for the `ClientProtocol`. A concrete type is needed to use with `@Environment`.
@Observable
final public class Client: ClientProtocol {
    private let client: any ClientProtocol

    public init(client: any ClientProtocol) {
        self.client = client
    }

    public func getProfile() async throws -> User {
        try await client.getProfile()
    }

    public func getBikes() async throws -> [Bike] {
        try await client.getBikes()
    }

    public func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides {
        try await client.getRides(for: bike, limit: limit, offset: offset)
    }

    public func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location] {
        try await client.getLocations(for: bike, from: from, till: till)
    }

    public func getStats(for bike: Int, from: Date, till: Date, granularity: StatsGranularity) async throws -> [Stat] {
        try await client.getStats(for: bike, from: from, till: till, granularity: granularity)
    }
}
