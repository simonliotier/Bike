import BikeCore
import MapKit
import SwiftUI

/// Row displaying a single ride.
struct RideRow: View {
    let ride: Ride

    var body: some View {
        HStack {
            AsyncRideThumbnail(ride: ride)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            VStack(alignment: .leading) {
                Text(ride.formattedDate)
                Text(ride.formattedTitle)
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
        startDate.formatted(.dateTime.month(.wide).weekday(.wide).day().hour().minute())
            .capitalizedSentence
    }
}

#Preview {
    NavigationStack {
        List {
            RideRow(ride: .previewMorning)
        }
    }
    .environment(Client.preview)
}
