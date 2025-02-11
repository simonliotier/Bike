import Bike
import Foundation

// Provide instances to be used in SwiftUI Previews.

extension Decodable {
    static func previewAsset<T: Decodable>(named: String) -> T {
        do {
            return try Bundle.main.decodeAsset(named: named, dateDecodingStrategy: .iso8601)
        } catch {
            fatalError("Error decoding asset \(named): \(error)")
        }
    }
}

extension User {
    static let preview: Self = .previewAsset(named: "user")
}

extension Ride {
    static let previewMorning: Self = .previewAsset(named: "ride_morning")
    static let previewAfternoon: Self = .previewAsset(named: "ride_afternoon")
}

extension [CGPoint] {
    static let rideThumbnailPoints: Self = .previewAsset(named: "ride_thumbnail_points")
}

extension [Ride] {
    static let preview: [Ride] = Rides.preview.data
    static let previewLast3: [Ride] = Rides.previewLast3.data
}

extension Rides {
    static let preview: Self = .previewAsset(named: "rides")
    static let previewLast3: Self = .previewAsset(named: "rides_last_3")
}

extension [Bike] {
    static let preview: Self = .previewAsset(named: "bike")
}

extension Bike {
    static let preview: Self = [Bike].preview.first!
}

extension Geofence {
    static let preview: Self = .previewAsset(named: "geofence")
}

extension [Geofence] {
    static let preview: Self = .previewAsset(named: "geofences")
}

extension [Location] {
    static let preview: Self = .previewAsset(named: "locations")
}

extension [Stat] {
    static let previewDay: Self = .previewAsset(named: "stats_day")
    static let previewWeek: Self = .previewAsset(named: "stats_week")
    static let previewMonth: Self = .previewAsset(named: "stats_month")

    static func preview(for periodType: StatsPeriodType) -> Self {
        switch periodType {
        case .day:
            .previewDay
        case .week:
            .previewWeek
        case .month:
            .previewMonth
        }
    }
}
