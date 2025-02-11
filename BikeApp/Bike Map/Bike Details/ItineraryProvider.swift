import Bike
import Foundation
import MapKit

protocol ItineraryProvider: Sendable {
    var bike: Bike { get }
    func getAddress() async throws -> Address
    func getItinerary() async throws -> Itinerary
}

struct AppItineraryProvider: ItineraryProvider {
    let bike: Bike

    func getAddress() async throws -> Address {
        let placemark = try await bike.getPlacemark()
        guard let postalAddress = placemark.postalAddress else { fatalError() }
        return .init(street: postalAddress.street, city: postalAddress.city)
    }

    func getItinerary() async throws -> Itinerary {
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
}

struct PreviewItineraryProvider: ItineraryProvider {
    let bike: Bike = .preview

    func getAddress() async throws -> Address {
        .preview
    }

    func getItinerary() async throws -> Itinerary {
        .preview
    }
}

struct Address {
    let street: String
    let city: String
}

struct Itinerary {
    let distance: CLLocationDistance
    let expectedTravelTime: TimeInterval
}

extension Address {
    static let preview = Address(street: "7 rue de Valmy", city: "Nantes")
}

extension Itinerary {
    static let preview = Itinerary(distance: 1234, expectedTravelTime: 567)
}

extension Bike {
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
