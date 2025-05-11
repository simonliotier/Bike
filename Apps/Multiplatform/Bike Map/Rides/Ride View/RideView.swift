import BikeCore
import MapKit
import SwiftUI

/// Displays a ride.
struct RideView: View {
    let ride: Ride
    let locations: [Location]

    var body: some View {
        List {
            Section {
                RideMap(locations: locations)
                    .frame(idealHeight: 300)
            } header: {
                Text(ride.formattedTimeRange)
            }
            .listRowInsets(.init())
            Section {
                RideDetailsView(ride: ride)
            } header: {
                Text("Details")
            }
        }
    }
}

private extension Ride {
    var formattedTimeRange: String {
        let range = startDate..<endDate
        return range.formatted(.interval.hour().minute())
    }
}

#Preview {
    RideView(ride: .previewMorning, locations: .preview)
}
