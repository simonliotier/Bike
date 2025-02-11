import Foundation

/// Generated automatically from API response.
public struct WeatherInfo: Codable, Sendable, Hashable, Equatable {
    public let weatherType: WeatherType?
    public let temperature: String?
    public let temperatureApparent: String?
    public let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case weatherType = "weather_type"
        case temperature
        case temperatureApparent = "temperature_apparent"
        case iconUrl = "icon_url"
    }

    /// This list is probably incomplete. In practice, the API always returns a `cloudy` weather type. We found the
    /// other types by testing various terms and checking if there was an associate icon. Example:
    /// https://cb4e5bc7a3dc43969015c331117f69c1.objectstore.eu/cnt/static/weather/fog.png
    public enum WeatherType: String, Codable, Sendable {
        case cloudy
        case rain
        case wind
        case fog
        case hail
    }
}
