import Bike
import MapKit
import SwiftUI

/// A view displaying the user bike on a map.
///
/// The bike can be selected to display additional info in a bottom sheet or popover.
struct BikeMap: View {
    let bike: Bike

    @State private var position: MapCameraPosition
    @State private var selection: Bike?
    @State private var bikeButtonVisible: Bool = false
    @State private var isPopoverPresented = true

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    init(bike: Bike) {
        self.bike = bike
        position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
    }

    var body: some View {
        Background {
            Map(position: $position,
                selection: $selection) {
                    UserAnnotation()
                    Annotation(bike.name, coordinate: bike.lastLocationCoordinate) {
                        SelectablePinAnnotation(resource: .bike, isSelected: $isPopoverPresented)
                            .popover(isPresented: $isPopoverPresented, arrowEdge: .trailing) {
                                BikeDetailsView(bike: bike)
                                    .environment(\.isInPopover, horizontalSizeClass == .regular)
                                    .presentationDetents(presentationDetents)
                            }
                    }
                    .annotationTitles(isPopoverPresented ? .hidden : .visible)
                    .tag(bike)
                }
                .mapStyle(.standard)
                .mapControls {
                    MapUserLocationButton()
                    MapPitchToggle()
                    MapCompass()
                }
                .blurredStatusBarBackground()
                .onChange(of: selection, onSelectionChanged)
                .onChange(of: isPopoverPresented, onIsSheetPresentedChanged)
                .onMapCameraChange(onMapCameraChanged)
                .overlay(alignment: .bottomTrailing, content: bikeLocationButtonOverlay)
        }
    }

    /// When the bike is selected/unselected, update the sheet.
    private func onSelectionChanged(_ oldValue: Bike?, _ newValue: Bike?) {
        isPopoverPresented = (newValue == bike)
    }

    /// When the sheet is presented/dismissed, update the bike selection.
    private func onIsSheetPresentedChanged(_ oldValue: Bool, _ newValue: Bool) {
        if !newValue {
            withAnimation(.bouncy) {
                selection = nil
            }
        }
    }

    /// Button allowing the user to reset the map framing to the bike location.
    ///
    /// The button is only displayed if the bike annotation is not visible
    @ViewBuilder private func bikeLocationButtonOverlay() -> some View {
        if bikeButtonVisible {
            MapBikeLocationButton {
                withAnimation {
                    position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical)
        }
    }

    /// When the map camera changed, update the bike location button visibility.
    private func onMapCameraChanged(_ context: MapCameraUpdateContext) {
        withAnimation {
            bikeButtonVisible = !context.rect.contains(bike.lastLocationMapPoint)
        }
    }

    private var presentationDetents: Set<PresentationDetent> {
        return if horizontalSizeClass == .compact {
            [.fraction(1.0 / 3.0), .large]
        } else {
            [.large]
        }
    }
}

extension Bike {
    var lastLocationCoordinate: CLLocationCoordinate2D {
        .init(latitude: lastLocation.lat, longitude: lastLocation.lon)
    }

    var lastLocationMapPoint: MKMapPoint {
        .init(lastLocationCoordinate)
    }
}

#Preview {
    BikeMap(bike: .preview)
        .environment(\.client, PreviewClient())
}
