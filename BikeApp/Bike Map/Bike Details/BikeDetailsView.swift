import Alamofire
import Bike
import Contacts
import MapKit
import SwiftUI

/// View displayed as a popover when the bike is selected on the map.
struct BikeDetailsView: View {
    let bike: Bike
    let bikeDetails: BikeDetails
    let itineraryProvider: ItineraryProvider

    private let locationManager = CLLocationManager()

    @State private var presentedSheetScreen: Screen?
    @State private var pendingSheetScreen: Screen?
    @State private var isSheetPresented: Bool = false
    @State private var postalAddress: Address?
    @State private var itinerary: Itinerary?

    @Environment(\.openWindow) private var openWindow

    init(bike: Bike, bikeDetails: BikeDetails, itineraryProvider: (any ItineraryProvider)? = nil) {
        self.bike = bike
        self.bikeDetails = bikeDetails
        self.itineraryProvider = itineraryProvider ?? AppItineraryProvider(bike: bike)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            VStack(alignment: .leading, spacing: 16) {
                itineraryButton
                HStack(spacing: 16) {
                    ridesButton
                    statsButton
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled)
        #if os(iOS)
            // On iOS, we set an ideal width that will be used to size the popover on iPad, but will be ignored by the
            // sheet on iPhone.
            .frame(idealWidth: 400)
        #elseif os(macOS)
            // On macOS, we set an explicit width to prevent a layout issue occurring when using
            // `fixedSize(horizontal:vertical:)`.
            .frame(width: 400)
        #endif
        #if os(macOS)
        // On macOS, keep the popover displayed when other windows are opened.
        .interactiveDismissDisabled(true)
        #endif
        .fittedPresentationDetent()
        .task(loadItinerary)
        .sheet(item: $presentedSheetScreen) { screen in
            NavigationStack {
                switch screen {
                case .rides:
                    AsyncRideList(bike: bike)
                case .stats:
                    AsyncStatsView(bike: bike)
                }
            }
            .onIsPresentedChange(perform: onSheetIsPresentedChange)
        }
    }

    @ViewBuilder private var header: some View {
        VStack(alignment: .leading) {
            Text(bike.name)
                .font(.title2)
                .bold()

            VStack(alignment: .leading) {
                Text(formattedAddress)
                HStack(spacing: 4) {
                    Text(lastLocationDate)
                    Image(batteryPercentage: Double(bike.batteryPercentage) / 100.0)
                }
            }
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .textCase(nil)
        .listRowInsets(.init())
        .padding(.bottom)
    }

    @ViewBuilder private var itineraryButton: some View {
        Button {
            Task(operation: openDirection)
        } label: {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    .foregroundStyle(.accent)
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
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(CardBackgroundModifier())
        }
        .tint(.primary)
        .buttonStyle(.plain)
    }

    @ViewBuilder private var ridesButton: some View {
        Button {
            present(.rides)
        } label: {
            RidesCardView(rides: bikeDetails.lastRides)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var statsButton: some View {
        Button {
            present(.stats)
        } label: {
            StatsCardView(stats: bikeDetails.weekStats)
        }
        .buttonStyle(.plain)
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

    private var lastLocationDate: String {
        bike.lastLocation.date.formatted(.relative(presentation: .named)).capitalizedSentence
    }

    private func loadItinerary() async {
        requestLocationAuthorization()
        Task { postalAddress = try? await itineraryProvider.getAddress() }
        Task { itinerary = try? await itineraryProvider.getItinerary() }
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

        #if os(iOS)
            MKMapItem.openMaps(with: [bikeMapItem], launchOptions: launchOptions)
        #endif

        #if os(macOS)
            await MKMapItem.openMaps(with: [bikeMapItem], launchOptions: launchOptions)
        #endif
    }

    private func present(_ screen: Screen) {
        #if os(iOS)
            if isSheetPresented {
                pendingSheetScreen = screen
            } else {
                presentedSheetScreen = screen
            }

        #elseif os(macOS)
            openWindow(id: screen.rawValue, value: bike)
        #endif
    }

    private func onSheetIsPresentedChange(_ isPresented: Bool) {
        isSheetPresented = isPresented

        // When trying to present a new sheet before the previous one is completely dismissed, SwiftUI triggers
        // tasks cancellation on the new sheet. So we wait for the previous sheet to be completely dismissed
        // before presenting the new one.
        if !isPresented, let screen = pendingSheetScreen {
            present(screen)
            pendingSheetScreen = nil
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true

    Background {
        Map()
            .popover(isPresented: .constant(true), attachmentAnchor: .point(.center), arrowEdge: .trailing) {
                BikeDetailsView(bike: .preview,
                                bikeDetails: .init(lastRides: .previewLast3, weekStats: .previewWeek),
                                itineraryProvider: PreviewItineraryProvider())
                .environment(Client.preview)
            }
    }
}

struct OnIsPresentedChangeModifier: ViewModifier {
    var onIsPresentedChange: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                onIsPresentedChange(true)
            }
            .onDisappear {
                onIsPresentedChange(false)
            }
    }
}

extension View {
    /// Set the view detent so that it fits the view content.
    func onIsPresentedChange(perform action: @escaping (Bool) -> Void) -> some View {
        modifier(OnIsPresentedChangeModifier(onIsPresentedChange: action))
    }
}
