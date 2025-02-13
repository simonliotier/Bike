import Foundation
import SwiftUI

/// Protocol defining the interface for fetching user-related data.
public protocol Client: Sendable {
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

public extension EnvironmentValues {
    /// Environment value for the `Client` used to fetch user data.
    @Entry var client: Client = APIClient()
}
