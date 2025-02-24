import Foundation

// Provide instances to be used in SwiftUI Previews.
import SwiftUI

public extension Image {
    static var myImage: Image {
        Image("myImage", bundle: .module)
    }
}

extension Decodable {
    static func previewAsset<T: Decodable>(named: String) -> T {
        do {
            return try Bundle.module.decodeAsset(named: named, dateDecodingStrategy: .iso8601)
        } catch {
            fatalError("Error decoding asset \(named): \(error)")
        }
    }
}

public extension User {
    static let preview: Self = .previewAsset(named: "user")
}

public extension Ride {
    static let previewMorning: Self = .previewAsset(named: "ride_morning")
    static let previewAfternoon: Self = .previewAsset(named: "ride_afternoon")
}

public extension [CGPoint] {
    static let rideThumbnailPoints: Self = .previewAsset(named: "ride_thumbnail_points")
}

public extension [Ride] {
    static let preview: [Ride] = Rides.preview.data
    static let previewLast3: [Ride] = Rides.previewLast3.data
}

public extension Rides {
    static let preview: Self = .previewAsset(named: "rides")
    static let previewLast3: Self = .previewAsset(named: "rides_last_3")
}

public extension [Bike] {
    static let preview: Self = .previewAsset(named: "bike")
}

public extension Bike {
    static let preview: Self = [Bike].preview.first!
}

public extension Geofence {
    static let preview: Self = .previewAsset(named: "geofence")
}

public extension [Geofence] {
    static let preview: Self = .previewAsset(named: "geofences")
}

public extension [Location] {
    static let preview: Self = .previewAsset(named: "locations")
}

public extension [Stat] {
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
