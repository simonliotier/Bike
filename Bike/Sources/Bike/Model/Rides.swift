import Foundation

/// Generated automatically from API response.
public struct Rides: Codable, Sendable {
    public let filters: [String]?
    public let orderClauses: [OrderClauses]
    public let meta: Meta
    public let data: [Ride]

    enum CodingKeys: String, CodingKey {
        case filters
        case orderClauses = "order_clauses"
        case meta
        case data
    }

    public struct OrderClauses: Codable, Sendable {
        public let fieldname: String?
        public let order: String?
    }

    public struct Meta: Codable, Sendable {
        public let limit: Int?
        public let offset: Int?
        public let totalRecords: Int?
        public let availableFilterFieldnames: [String]?
        public let availableOrderFieldnames: [String]?

        enum CodingKeys: String, CodingKey {
            case limit
            case offset
            case totalRecords = "total_records"
            case availableFilterFieldnames = "available_filter_fieldnames"
            case availableOrderFieldnames = "available_order_fieldnames"
        }
    }
}
