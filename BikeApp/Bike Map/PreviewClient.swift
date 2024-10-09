import Bike
import Foundation

/// Implementation of the `Client` that return mock data, to be used in previews.
final class PreviewClient: Client {
    init() {}

    func getProfile() async throws -> User {
        .preview
    }

    func getBikes() async throws -> [Bike] {
        .preview
    }

    func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides {
        .preview
    }

    func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location] {
        .preview
    }
}
