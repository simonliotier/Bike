import MapKit
import SwiftUI

/// A button that toggle the map style between standard and imagery.
///
/// It is inspired by the button displayed in the Apple Fitness app.
struct MapStyleButton: View {
    @Binding var mapStyle: MapStyle

    var body: some View {
        Button(mapStyle.title, systemImage: mapStyle.imageName) {
            switch mapStyle {
            case .standard:
                mapStyle = .imagery
            case .imagery:
                mapStyle = .standard
            }
        }
        .buttonStyle(.mapControl)
    }

    /// Custom map style enum with only the two styles between which the user can toggle.
    enum MapStyle {
        case standard
        case imagery

        var imageName: String {
            switch self {
            case .standard:
                return "map"
            case .imagery:
                return "globe.europe.africa"
            }
        }

        var title: LocalizedStringKey {
            switch self {
            case .standard:
                return "Show satellite map"
            case .imagery:
                return "Show standard map"
            }
        }
    }
}

extension MapStyle {
    init(_ mapStyle: MapStyleButton.MapStyle) {
        switch mapStyle {
        case .standard:
            self = .standard
        case .imagery:
            self = .imagery
        }
    }
}

#Preview {
    @Previewable @State var mapStyle: MapStyleButton.MapStyle = .standard

    MapStyleButton(mapStyle: $mapStyle)
}
