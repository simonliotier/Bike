import Bike
import Foundation

/// Implementation of the `Client` that return mock data, to be used in previews.
@Observable
final class PreviewClient: ClientProtocol {
    init() {}

    func getProfile() async throws -> User {
        .preview
    }

    func getBikes() async throws -> [Bike] {
        .preview
    }

    func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides {
        limit == 3 ? .previewLast3 : .preview
    }

    func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location] {
        .preview
    }

    func getStats(for bike: Int, from: Date, till: Date, granularity: StatsGranularity) async throws -> [Stat] {
        let days = Calendar.current.dateComponents([.day], from: from, to: till).day ?? 0

        let periodType: StatsPeriodType = switch days {
        case 0..<1:
            .day
        case 1..<7:
            .week
        default:
            .month
        }

        return .preview(for: periodType)
    }
}
