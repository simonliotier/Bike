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

extension Ride {
    static let previewMorning: Self = .previewAsset(named: "ride_morning")
    static let previewAfternoon: Self = .previewAsset(named: "ride_afternoon")
}

extension Rides {
    static let preview: Self = .previewAsset(named: "rides")
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
