import Bike
import MapKit
import SwiftUI

/// Row displaying a single ride.
struct RideRow: View {
    let ride: Ride

    var body: some View {
        HStack {
            AsyncRideThumbnail(ride: ride)
            VStack(alignment: .leading) {
                Text(ride.formattedTitle)
                    .font(.headline)
                Text(ride.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension Ride {
    var formattedTitle: String {
        let distance = Measurement(value: Double(distanceTraveled), unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))

        let duration = Duration.seconds(activeTime)
            .formatted(.units(allowed: [.hours, .minutes]))

        return [distance, duration].compactMap { $0 }.joined(separator: " • ")
    }

    var formattedDate: String {
        startDate.formatted(.relative(presentation: .named, unitsStyle: .wide))
            .capitalizedSentence
    }
}

#Preview {
    NavigationStack {
        List {
            RideRow(ride: .previewMorning)
        }
    }
}
