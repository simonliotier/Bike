import Foundation

/// Implementation of the `Client` that return mock data, to be used in previews.
@Observable
public final class PreviewClient: ClientProtocol {
    public init() {}

    public func getProfile() async throws -> User {
        .preview
    }

    public func getBikes() async throws -> [Bike] {
        .preview
    }

    public func getRides(for bike: Int, limit: Int, offset: Int) async throws -> Rides {
        limit == 3 ? .previewLast3 : .preview
    }

    public func getLocations(for bike: Int, from: Date, till: Date) async throws -> [Location] {
        .preview
    }

    public func getStats(for bike: Int, from: Date, till: Date, granularity: StatsGranularity) async throws -> [Stat] {
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

public extension Client {
    static var preview: Client {
        Client(client: PreviewClient())
    }
}
