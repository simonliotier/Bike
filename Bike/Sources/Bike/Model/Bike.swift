import Foundation

/// Generated automatically from API response.
public struct Bike: Decodable, Identifiable, Hashable {
    public let id: Int
    public let userId: Int
    public let userName: String
    public let activeState: Int
    public let imei: String
    public let name: String
    public let isRequestingUserOwner: Bool
    public let lastLocation: Location
    public let batteryPercentage: Int
    public let owningUser: User
    public let geofences: [Geofence]
    public let linkedUsers: [User]
    public let activationCode: String
    public let frameNumber: String
    public let deliveryDate: Date
    public let fabricationDate: Date
    public let odometer: Int
    // let keyNumber: NSNull
    public let manufacturer: String
    // let type: NSNull
    public let articleNumber: String
    // let colorHex: NSNull
    public let bikeImageURL: String
    public let apiVersion: Int
    // public let cntApiBikeId: Int
    public let creationDate: Date
    public let isStolen: Bool
    public let blepass: String
    public let blename: String
    // let dealerID: NSNull
    public let rideInProgress: Bool
    // let currentRideUserID: NSNull
    public let displacement: Bool
    public let drop: Bool
    public let highspeed: Bool
    public let ischarging: Bool
    public let lowbattery: Bool
    public let noconnection: Bool
    public let notcharging: Bool
    public let powercut: Bool
    public let service: Bool
    public let motion: Bool
    public let moving: Bool
    public let freefall: Bool
    public let sos: Bool
    public let batterywarning: Bool
    public let batterydegraded: Bool
    public let vibration: Bool
    // let inviteCode: NSNull
    // let inviteCodeURI: NSNull

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case activeState = "active_state"
        case imei
        case name
        case isRequestingUserOwner = "is_requesting_user_owner"
        case lastLocation = "last_location"
        case batteryPercentage = "battery_percentage"
        case owningUser = "owning_user"
        case geofences
        case linkedUsers = "linked_users"
        case activationCode = "activation_code"
        case frameNumber = "frame_number"
        case deliveryDate = "delivery_date"
        case fabricationDate = "fabrication_date"
        case odometer
        // case keyNumber = "key_number"
        case manufacturer
        // case type
        case articleNumber = "article_number"
        // case colorHex = "color_hex"
        case bikeImageURL = "bike_image_url"
        case apiVersion = "api_version"
        // case cntApiBikeId = "cnt_api_bike_id"
        case creationDate = "creation_date"
        case isStolen = "is_stolen"
        case blepass
        case blename
        // case dealerId = "dealer_id"
        case rideInProgress = "ride_in_progress"
        // case currentRideUserId = "current_ride_user_id"
        case displacement
        case drop
        case highspeed
        case ischarging
        case lowbattery
        case noconnection
        case notcharging
        case powercut
        case service
        case motion
        case moving
        case freefall
        case sos
        case batterywarning
        case batterydegraded
        case vibration
        // case inviteCode = "invite_code"
        // case inviteCodeUri = "invite_code_uri"
    }
}
