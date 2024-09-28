import Bike
import Contacts
import MapKit
import SwiftUI

/// View displayed as a sheet when the bike is selected on the map.
struct BikeDetailsView: View {
    let bike: Bike

    let provider: Provider

    init(bike: Bike, provider: (any BikeDetailsView.Provider)? = nil) {
        self.bike = bike
        self.provider = provider ?? APIProvider(bike: bike)
    }

    @State private var postalAddress: Address?
    @State private var itinerary: Itinerary?

    @Environment(\.dismiss) private var dismiss

    private let locationManager = CLLocationManager()

    var body: some View {
        List {
            Section {
                itineraryButton
            } header: {
                header
            }
            .textCase(nil)
            .font(nil)
        }
        .scrollContentBackground(.hidden)
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled)
        .task(load)
    }

    var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(bike.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
                Text(formattedAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text(lastLocationDate)
                    Image(batteryPercentage: Double(bike.batteryPercentage) / 100.0)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Label("Close", systemImage: "xmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .foregroundStyle(.secondary)
        }
        .textCase(nil)
        .foregroundStyle(.primary)
        .listRowInsets(.init())
        .padding(.vertical)
    }

    var itineraryButton: some View {
        Button {
            Task(operation: openDirection)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Itinerary")
                        .font(.headline)
                    if let formattedItinerary {
                        Text(formattedItinerary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(.primary)
    }

    private var formattedAddress: String {
        guard let postalAddress else { return "" }
        return [postalAddress.street, postalAddress.city].joined(separator: ", ")
    }

    private var formattedItinerary: String? {
        guard let itinerary else { return nil }
        let formattedDistance = Measurement(value: itinerary.distance, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
        let formattedExpectedTravelTime = Duration.seconds(itinerary.expectedTravelTime)
            .formatted(.units(width: .narrow))
        return [formattedDistance, formattedExpectedTravelTime].joined(separator: " • ")
    }

    var lastLocationDate: String {
        bike.lastLocation.date.formatted(.relative(presentation: .named)).capitalizedSentence
    }

    private func load() async {
        requestLocationAuthorization()
        postalAddress = try? await provider.getAddress()
        itinerary = try? await provider.getItinerary()
    }

    private func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    /// Open Apple Maps to display direction to the bike.
    func openDirection() async throws {
        let bikeCLPlacemark = try await bike.getPlacemark()
        let bikeMKPlacemark = MKPlacemark(placemark: bikeCLPlacemark)
        let bikeMapItem = MKMapItem(placemark: bikeMKPlacemark)

        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]

        MKMapItem.openMaps(with: [bikeMapItem], launchOptions: launchOptions)
    }
}

extension BikeDetailsView {
    protocol Provider: Sendable {
        var bike: Bike { get }
        func getAddress() async throws -> Address
        func getItinerary() async throws -> Itinerary
    }

    struct Address {
        let street: String
        let city: String
    }

    struct Itinerary {
        let distance: CLLocationDistance
        let expectedTravelTime: TimeInterval
    }
}

extension BikeDetailsView {
    struct APIProvider: Provider {
        let bike: Bike

        func getAddress() async throws -> BikeDetailsView.Address {
            let placemark = try await bike.getPlacemark()
            guard let postalAddress = placemark.postalAddress else { fatalError() }
            return .init(street: postalAddress.street, city: postalAddress.city)
        }

        func getItinerary() async throws -> BikeDetailsView.Itinerary {
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
}

#Preview {
    @Previewable @State var isPresented = true

    Map()
        .sheet(isPresented: $isPresented) {
            BikeDetailsView(bike: .preview, provider: BikeDetailsView.PreviewProvider())
        }
}

extension BikeDetailsView {
    struct PreviewProvider: Provider {
        let bike: Bike = .preview

        func getAddress() async throws -> BikeDetailsView.Address {
            .preview
        }

        func getItinerary() async throws -> BikeDetailsView.Itinerary {
            .preview
        }
    }
}

extension BikeDetailsView.Address {
    static let preview = BikeDetailsView.Address(street: "7 rue de Valmy", city: "Nantes")
}

extension BikeDetailsView.Itinerary {
    static let preview = BikeDetailsView.Itinerary(distance: 1234, expectedTravelTime: 567)
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
