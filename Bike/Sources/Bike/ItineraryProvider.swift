import Foundation
import MapKit

public protocol ItineraryProvider: Sendable {
    var bike: Bike { get }
    func getAddress() async throws -> Address

    #if os(iOS) || os(macOS)
    func getItinerary() async throws -> Itinerary
    #endif
}

public struct AppItineraryProvider: ItineraryProvider {
    public let bike: Bike

    public init(bike: Bike) {
        self.bike = bike
    }

    public func getAddress() async throws -> Address {
        let placemark = try await bike.getPlacemark()
        guard let postalAddress = placemark.postalAddress else { fatalError() }
        return .init(street: postalAddress.street, city: postalAddress.city)
    }

    #if os(iOS) || os(macOS)
    public func getItinerary() async throws -> Itinerary {
        let currentLocationMapItem = MKMapItem.forCurrentLocation()
        let bikePlacemark = try await bike.getPlacemark()
        let bikeMapItem = MKMapItem(placemark: MKPlacemark(placemark: bikePlacemark))

        let directionRequest = MKDirections.Request()
        directionRequest.source = currentLocationMapItem
        directionRequest.destination = bikeMapItem
        directionRequest.transportType = .walking

        let directions = MKDirections(request: directionRequest)

        let eta = try await directions.calculateETA()

        return .init(distance: eta.distance, expectedTravelTime: eta.expectedTravelTime)
    }
    #endif
}

public struct PreviewItineraryProvider: ItineraryProvider {
    public let bike: Bike = .preview

    public init() {}

    public func getAddress() async throws -> Address {
        .preview
    }

    public func getItinerary() async throws -> Itinerary {
        .preview
    }
}

public struct Address: Sendable {
    public let street: String
    public let city: String
}

public struct Itinerary: Sendable {
    public let distance: CLLocationDistance
    public let expectedTravelTime: TimeInterval
}

public extension Address {
    static let preview = Address(street: "7 rue de Valmy", city: "Nantes")
}

public extension Itinerary {
    static let preview = Itinerary(distance: 1234, expectedTravelTime: 567)
}

public extension Bike {
    func getPlacemark() async throws -> CLPlacemark {
        guard let placemark = try await CLGeocoder().reverseGeocodeLocation(lastCLLocation).first else {
            throw Error.noPlacemarkFound
        }

        return placemark
    }

    var lastCLLocation: CLLocation {
        .init(latitude: lastLocation.lat, longitude: lastLocation.lon)
    }

    enum Error: Swift.Error {
        case noPlacemarkFound
    }
}
