import Bike
import SwiftUI

struct RidesCardView: View {
    let rides: [Ride]

    var body: some View {
        CardView {
            Label("Rides", systemImage: "mappin.and.ellipse")
        } content: {
            VStack(alignment: .leading) {
                ForEach(rides) { ride in
                    rideRow(ride)
                }
            }
        }
    }

    @ViewBuilder private func rideRow(_ ride: Ride) -> some View {
        HStack {
            AsyncRideThumbnail(ride: ride)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 4, height: 4)))
                .frame(width: 40)
            VStack(alignment: .leading) {
                Text(ride.formattedDate)
                    .font(.callout)
                    .fontDesign(.rounded)
                Text(ride.formattedDetails)
                    .font(.footnote)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Ride {
    var formattedDate: String {
        startDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)).capitalizedSentence
    }

    var formattedDetails: String {
        [formattedDistance, formattedDuration].joined(separator: " • ")
    }

    var formattedDistance: String {
        Measurement(value: Double(distanceTraveled), unit: UnitLength.meters)
            .formatted(.measurement(width: .narrow, usage: .road))
    }

    var formattedDuration: String {
        Duration.seconds(activeTime).formatted(.units(allowed: [.minutes], width: .narrow))
    }
}

import MapKit

#Preview {
    RidesCardView(rides: .previewLast3)
        .fixedSize(horizontal: false, vertical: true)
        .padding()
}
