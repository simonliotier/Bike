import Bike
import MapKit
import SwiftUI

/// A view displaying the user bike on a map.
///
/// The bike can be selected to display additional info in a bottom sheet or popover.
struct BikeMap: View {
    let bike: Bike

    let bikeDetails: BikeDetails

    @State private var position: MapCameraPosition
    @State private var selection: Bike?
    @State private var mapStyle: MapStyleButton.MapStyle = .standard
    @State private var bikeButtonVisible: Bool = false
    @State private var isPopoverPresented = false
    @State private var isPinSelected = false
    @State private var detailsViewHeight: CGFloat = 0

    @Namespace private var mapScope

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    init(bike: Bike, content: BikeDetails) {
        self.bike = bike
        bikeDetails = content
        position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
    }

    var body: some View {
        Background {
            Map(position: $position,
                selection: $selection,
                scope: mapScope,
                content: mapContent)
                .modifier(AnimatableSafeAreaPadding(padding: bottomSafeAreaPadding))
                .mapStyle(.init(mapStyle))
                .mapControls(mapControls)
                .customMapControls(customMapControls)
                .mapScope(mapScope)
                .blurredStatusBarBackground()
                .onChange(of: selection, onChangeOfSelection)
                .onChange(of: isPopoverPresented, onChangedOfIsPopoverPresented)
                .onMapCameraChange(onMapCameraChanged)
                .animation(.default, value: bottomSafeAreaPadding)
                .onAppear {
                    selection = bike
                }
        }
    }

    @MapContentBuilder private func mapContent() -> some MapContent {
        UserAnnotation()
        Annotation(bike.name, coordinate: bike.lastLocationCoordinate) {
            SelectablePinAnnotation(resource: .bike,
                                    pinTransformationEnabled: horizontalSizeClass == .compact,
                                    isSelected: $isPinSelected)
                .popover(isPresented: $isPopoverPresented, arrowEdge: .trailing) {
                    BikeDetailsView(bike: bike, bikeDetails: bikeDetails)
                        .onHeightChange(onChangeOfBikeDetailsViewHeight)
                }
        }
        .annotationTitles(isPopoverPresented ? .hidden : .visible)
        .tag(bike)
    }

    /// Returns the safe area padding added at the bottom of the map to take in account the sheet.
    private var bottomSafeAreaPadding: CGFloat {
        guard horizontalSizeClass == .compact else {
            // In regular size class, a popover is displayed instead of a sheet so no padding is required.
            return 0
        }

        guard isPopoverPresented else {
            // When the sheet is dismissed, no padding is required.
            return 0
        }

        // When the detail sheet is displayed, add a bottom padding equals to its height.
        return detailsViewHeight
    }

    /// When the bike is selected/unselected, update the popover, the pin and the map position.
    private func onChangeOfSelection(_: Bike?, _ newValue: Bike?) {
        withAnimation {
            let isBikeSelected = newValue == bike

            isPopoverPresented = isBikeSelected
            isPinSelected = isBikeSelected

            if isBikeSelected {
                position = .region(.init(center: bike.lastLocationCoordinate, span: defaultSpan))
            }
        }
    }

    /// When the bike details popover is presented/dismissed, update the bike selection.
    private func onChangedOfIsPopoverPresented(_: Bool, _ newValue: Bool) {
        withAnimation {
            selection = newValue ? bike : nil
            isPinSelected = newValue
        }
    }

    /// Keep track of the bike details view height so we can update the safe area padding.
    private func onChangeOfBikeDetailsViewHeight(_ newValue: Double) {
        withAnimation {
            detailsViewHeight = newValue
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

#Preview {
    BikeMap(bike: .preview, content: .init(lastRides: .previewLast3, weekStats: .previewWeek))
        .environment(\.client, PreviewClient())
}
