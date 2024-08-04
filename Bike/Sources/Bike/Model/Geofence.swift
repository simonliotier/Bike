import Foundation

/// Generated automatically from API response.
public struct Geofence: Decodable, Hashable, Identifiable {
    public let id: Int
    public let bikeId: Int
    public let userId: Int
    public let name: String
    public let center: Location
    public let radius: Int
    public let activeState: Int
    public let creationDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case bikeId = "bike_id"
        case userId = "user_id"
        case name
        case center
        case radius
        case activeState = "active_state"
        case creationDate = "creation_date"
    }

    public struct Location: Decodable, Hashable {
        let lat: Double?
        let lon: Double?
    }
}
