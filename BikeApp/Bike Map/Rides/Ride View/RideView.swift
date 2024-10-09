import Bike
import MapKit
import SwiftUI

/// Displays a ride.
struct RideView: View {
    let ride: Ride
    let locations: [Location]

    var body: some View {
        NavigationStack {
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
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(content: toolbarContent)
        }
    }

    @ToolbarContentBuilder private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            VStack {
                Text(ride.formattedTitle)
                    .font(.headline)
                    .bold()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            DismissButton()
        }
    }
}

private extension Ride {
    var formattedTitle: String {
        if !name.isEmpty {
            return name
        }

        return startDate.formatted(date: .complete, time: .omitted).capitalizedSentence
    }

    var formattedTimeRange: String {
        let range = startDate..<endDate
        return range.formatted(.interval.hour().minute())
    }
}

#Preview {
    SheetPreview {
        RideView(ride: .previewMorning, locations: .preview)
    }
}
