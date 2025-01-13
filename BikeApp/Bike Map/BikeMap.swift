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
    @State private var mapStyle: MapStyleButton.MapStyle = .standard
    @State private var bikeButtonVisible: Bool = false
    @State private var isPopoverPresented = true
    @State private var sheetHeight: CGFloat = 0

    @Namespace private var mapScope

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    init(bike: Bike) {
        self.bike = bike
        position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
    }

    var body: some View {
        Background {
            Map(position: $position,
                selection: $selection,
                scope: mapScope) {
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
                .mapStyle(.init(mapStyle))
                .mapControls(mapControls)
                .customMapControls(customMapControls)
                .mapScope(mapScope)
                .blurredStatusBarBackground()
                .onChange(of: selection, onSelectionChanged)
                .onChange(of: isPopoverPresented, onIsSheetPresentedChanged)
                .onMapCameraChange(onMapCameraChanged)
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

    /// When the map camera changed, update the bike location button visibility.
    private func onMapCameraChanged(_ context: MapCameraUpdateContext) {
        withAnimation {
            bikeButtonVisible = context.rect.contains(bike.lastLocationMapPoint)
        }
    }

    private func onMapBikeLocationButtonTap() {
        withAnimation {
            position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
        }
    }

    private var presentationDetents: Set<PresentationDetent> {
        return if horizontalSizeClass == .compact {
            [.fraction(1.0 / 3.0), .large]
        } else {
            [.large]
        }
    }

    // MARK: - Map Controls

    @ViewBuilder private func mapControls() -> some View {
        // We need to explicitly hide the default Map compass since we already display it in our custom map controls.
        MapCompass().mapControlVisibility(.hidden)
    }

    @ViewBuilder private func customMapControls() -> some View {
        // Order the controls so they do not shift when one of them appear/disappear.
        #if os(iOS)
            mapUserLocationButton
            mapStyleButton
            mapPitchToggle
            mapBikeLocationButton
            mapCompass
        #endif

        #if os(macOS)
            mapCompass
            mapBikeLocationButton
            mapUserLocationButton
            mapStyleButton
            mapPitchToggle
        #endif
    }

    private var mapCompass: some View {
        MapCompass(scope: mapScope)
    }

    private var mapUserLocationButton: some View {
        MapUserLocationButton(scope: mapScope)
            // Set same appearance as our other map controls.
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var mapStyleButton: some View {
        MapStyleButton(mapStyle: $mapStyle)
    }

    private var mapPitchToggle: some View {
        MapPitchToggle(scope: mapScope)
            // Set same appearance as our other map controls.
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            // The background will stay visible even if the map hides the toggle so we keep it visible.
            .mapControlVisibility(.visible)
    }

    @ViewBuilder private var mapBikeLocationButton: some View {
        if !bikeButtonVisible {
            MapBikeLocationButton(action: onMapBikeLocationButtonTap)
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
