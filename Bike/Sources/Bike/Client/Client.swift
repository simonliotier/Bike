import Foundation

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
}
