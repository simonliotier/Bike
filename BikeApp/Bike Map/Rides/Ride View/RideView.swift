import Bike
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
                    .aspectRatio(contentMode: .fit)
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
    Color.clear
        .popover(isPresented: .constant(true), attachmentAnchor: .point(.center), arrowEdge: .trailing) {
            NavigationStack {
                RideView(ride: .previewMorning, locations: .preview)
            }
        }
}
