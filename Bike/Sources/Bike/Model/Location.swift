import Foundation

/// Generated automatically from API response.
public struct Location: Decodable, Hashable, Identifiable, Sendable {
    public let id: String
    public let lat: Double
    public let lon: Double
    public let date: Date
    public let speed: Int
    public let batteryPercentage: Int
    public let bikeId: Int
    public let isMoving: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case lat
        case lon
        case date
        case speed
        case batteryPercentage = "battery_percentage"
        case bikeId = "bike_id"
        case isMoving = "is_moving"
    }
}
