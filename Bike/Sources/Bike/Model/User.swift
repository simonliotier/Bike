import Foundation

/// Generated automatically from API response.
public struct User: Codable, Hashable, Sendable {
    public let id: Int?
    public let username: String?
    public let name: String?
    public let displayName: String?
    public let firstName: String?
    public let lastName: String?
    public let initials: String?
    public let avatarURL: String?
    public let address: String?
    public let city: String?
    public let country: String?
    public let postalCode: String?
    public let houseNumber: String?
    public let houseNumberAddition: String?
    public let phoneNumber: String?
    public let phoneNumberFormatted: String?
    public let gender: String?
    public let isEmailVerified: Bool?
    public let creationDate: String?
    public let timezone: String?
    public let location: Location?
    public let registeredOnPlatform: String?
    public let privacyStatementAcceptedOn: String?
    public let email: String?
    public let conneqtechID: String?
    public let isDemoAccount: Bool?
    public let permissions: [String]?

    public struct Location: Codable, Hashable, Sendable {
        public let lat: Double?
        public let lon: Double?
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case initials
        case avatarURL = "avatar_url"
        case address
        case city
        case country
        case postalCode = "postal_code"
        case houseNumber = "house_number"
        case houseNumberAddition = "house_number_addition"
        case phoneNumber = "phone_number"
        case phoneNumberFormatted = "phone_number_formatted"
        case gender
        case isEmailVerified = "is_email_verified"
        case creationDate = "creation_date"
        case timezone
        case location
        case registeredOnPlatform = "registered_on_platform"
        case privacyStatementAcceptedOn = "privacy_statement_accepted_on"
        case email
        case conneqtechID = "conneqtech_id"
        case isDemoAccount = "is_demo_account"
        case permissions
    }
}
