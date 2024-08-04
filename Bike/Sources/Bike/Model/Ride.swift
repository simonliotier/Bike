import Foundation

/// Generated automatically from API response.
public struct Ride: Decodable, Identifiable {
    public let id: Int
    public let startDate: Date
    public let endDate: Date
    public let calories: Int
    public let avgSpeed: Int
    public let distanceTraveled: Int
    public let co2: Int
    public let avgPowerDistribution: Int
    public let shiftAdvice: Int
    public let elevationUp: Int
    public let elevationDown: Int
    public let bikeId: Int
    public let userId: Int
    public let user: User
    public let name: String
    public let creationDate: String
    public let activeState: Int
    public let weatherInfo: WeatherInfo
    public let rideType: String
    public let activeTime: Int
    public let rating: Int?
    public let timezone: String
    public let errorMask: Int

    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case endDate = "end_date"
        case calories
        case avgSpeed = "avg_speed"
        case distanceTraveled = "distance_traveled"
        case co2
        case avgPowerDistribution = "avg_power_distribution"
        case shiftAdvice = "shift_advice"
        case elevationUp = "elevation_up"
        case elevationDown = "elevation_down"
        case bikeId = "bike_id"
        case userId = "user_id"
        case user
        case name
        case creationDate = "creation_date"
        case activeState = "active_state"
        case weatherInfo = "weather_info"
        case rideType = "ride_type"
        case activeTime = "active_time"
        case rating
        case timezone
        case errorMask = "error_mask"
    }
}
