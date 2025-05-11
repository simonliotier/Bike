import Foundation

public struct Stat: Codable, Sendable {
    public let from: Date
    public let till: Date
    public let c02: Int
    public let calories: Int
    public let avgSpeed: Int
    public let distanceTraveled: Int
    public let avgPowerDistribution: Int
    public let shiftAdvice: Int
    public let topSpeed: Int
    public let elevationUp: Int
    public let elevationDown: Int

    enum CodingKeys: String, CodingKey {
        case from
        case till
        case c02
        case calories
        case avgSpeed = "avg_speed"
        case distanceTraveled = "distance_traveled"
        case avgPowerDistribution = "avg_power_distribution"
        case shiftAdvice = "shift_advice"
        case topSpeed = "top_speed"
        case elevationUp = "elevation_up"
        case elevationDown = "elevation_down"
    }
}
