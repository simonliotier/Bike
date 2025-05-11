import BikeCore
import MapKit
import SwiftUI

/// Displays the bike information.
struct BikeView: View {
    let bike: Bike

    @State private var postalAddress: Address?

    private let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)

    let itineraryProvider: ItineraryProvider

    init(bike: Bike, itineraryProvider: (any ItineraryProvider)? = nil) {
        self.bike = bike
        self.itineraryProvider = itineraryProvider ?? AppItineraryProvider(bike: bike)
    }

    var body: some View {
        List {
            header
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            Button("Itinerary", systemImage: "arrow.triangle.turn.up.right.circle") {
                Task { try? await openDirection() }
            }
        }
        .listStyle(.elliptical)
        .navigationTitle(bike.name)
        .task {
            self.postalAddress = try? await itineraryProvider.getAddress()
        }
    }

    @ViewBuilder private var header: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text(formattedLastLocationDate)
                    Spacer()
                    Image(batteryPercentage: Double(bike.batteryPercentage) / 100.0)
                }
                .foregroundStyle(.secondary)
                .font(.caption2)
            }
            .padding(.horizontal)

            Map(initialPosition: .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan)),
                interactionModes: []) {
                    Annotation("", coordinate: bike.lastLocationCoordinate) {
                        ZStack {
                            Circle()
                                .frame(width: 18, height: 18)
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.accent)
                        }
                        .shadow(radius: 4)
                    }
                }

                .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
                .frame(height: 100)

            Text(formattedAddress)
                .font(.caption2)
                .padding(.horizontal)
        }
    }

    private var formattedAddress: String {
        guard let postalAddress else { return "" }
        return [postalAddress.street, postalAddress.city].joined(separator: ", ")
    }

    private var formattedLastLocationDate: String {
        bike.lastLocation.date.formatted(.relative(presentation: .named)).capitalizedSentence
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

#Preview {
    NavigationStack {
        BikeView(bike: .preview, itineraryProvider: PreviewItineraryProvider())
    }
}
