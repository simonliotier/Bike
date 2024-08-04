import Foundation

/// Generated automatically from API response.
public struct User: Decodable, Hashable {
    public let id: Int?
    public let username: String?
    public let name: String?
    public let display_name: String?
    public let first_name: String?
    public let last_name: String?
    public let initials: String?
    public let avatar_url: String?
    public let address: String?
    public let city: String?
    public let country: String?
    public let postal_code: String?
    public let house_number: String?
    public let house_number_addition: String?
    public let phone_number: String?
    public let phone_number_formatted: String?
    public let gender: String?
    public let is_email_verified: Bool?
    public let creation_date: String?
    public let timezone: String?
    public let location: Location?
    public let registered_on_platform: String?
    public let privacy_statement_accepted_on: String?
    public let email: String?
    public let conneqtech_id: String?
    public let is_demo_account: Bool?
    public let permissions: [String]?

    public struct Location: Decodable, Hashable {
        public let lat: Double?
        public let lon: Double?
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case display_name
        case first_name
        case last_name
        case initials
        case avatar_url
        case address
        case city
        case country
        case postal_code
        case house_number
        case house_number_addition
        case phone_number
        case phone_number_formatted
        case gender
        case is_email_verified
        case creation_date
        case timezone
        case location
        case registered_on_platform
        case privacy_statement_accepted_on
        case email
        case conneqtech_id
        case is_demo_account
        case permissions
    }
}
