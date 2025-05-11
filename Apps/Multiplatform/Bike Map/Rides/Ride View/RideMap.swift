import BikeCore
import MapKit
import SwiftUI

/// Displays a ride route on a map.
struct RideMap: View {
    let locations: [Location]

    private var sortedLocation: [Location] {
        locations
            .sorted(using: KeyPathComparator(\.date, order: .forward))
    }

    var route: [CLLocationCoordinate2D] {
        sortedLocation
            .map { location in
                location.coordinate2D
            }
    }

    var body: some View {
        Map {
            MapPolyline(coordinates: route)
                .stroke(.outerRidePath, lineWidth: 6)
            MapPolyline(coordinates: route)
                .stroke(.innerRidePath, lineWidth: 4)
            if let start = sortedLocation.first {
                Annotation(LocalizedStringKey("Start"), coordinate: start.coordinate2D) {
                    endPoint
                }
            }
            if let end = sortedLocation.last {
                Annotation(LocalizedStringKey("End"), coordinate: end.coordinate2D) {
                    endPoint
                }
            }
        }
    }

    @ViewBuilder private var endPoint: some View {
        ZStack {
            Circle()
                .fill(.outerRidePath)
                .frame(width: 14, height: 14)

            Circle()
                .fill(.innerRidePath)
                .frame(width: 11, height: 11)

            Circle()
                .fill(.outerRidePath)
                .frame(width: 5, height: 5)
        }
    }
}

#Preview {
    RideMap(locations: .preview)
}

private extension ShapeStyle where Self == Color {
    static var innerRidePath: Color {
        let mixColor = Color(light: Color.white, dark: Color.black)
        return .accent.mix(with: mixColor, by: 0.1)
    }

    static var outerRidePath: Color {
        let mixColor = Color(light: Color.black, dark: Color.white)
        return .accent.mix(with: mixColor, by: 0.1)
    }
}

extension Location {
    var coordinate2D: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
}
