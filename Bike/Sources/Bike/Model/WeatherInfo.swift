import Foundation

/// Generated automatically from API response.
public struct WeatherInfo: Decodable {
    public let weatherType: String?
    public let temperature: String?
    public let temperatureApparent: String?
    public let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case weatherType = "weather_type"
        case temperature
        case temperatureApparent = "temperature_apparent"
        case iconUrl = "icon_url"
    }
}
