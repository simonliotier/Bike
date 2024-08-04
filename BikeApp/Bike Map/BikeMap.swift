import Bike
import MapKit
import SwiftUI

struct BikeMap: View {
    let bikes: [Bike]

    var body: some View {
        if let bike = bikes.first {
            Map(initialPosition: .region(.init(center: bike.lastLocationCoordinate,
                                               span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                Marker(bike.markerName, systemImage: "bicycle", coordinate: bike.lastLocationCoordinate)
                    .tag(bike)

                UserAnnotation()
            }
            .mapStyle(.standard)
        } else {
            EmptyView()
        }
    }
}

extension Bike {
    var lastLocationCoordinate: CLLocationCoordinate2D {
        .init(latitude: lastLocation.lat, longitude: lastLocation.lon)
    }

    var markerName: String {
        "\(name) - \(batteryPercentage.formatted(.percent))"
    }
}

#Preview {
    BikeMap(bikes: .preview)
}
