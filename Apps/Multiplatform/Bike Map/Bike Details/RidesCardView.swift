import BikeCore
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
        HStack(spacing: rideRowSpacing) {
            AsyncRideThumbnail(ride: ride)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 4, height: 4)))
                .frame(width: rideThumbnailWidth)
            VStack(alignment: .leading) {
                Text(ride.formattedDate)
                    .font(.callout)
                    .fontDesign(.rounded)
                    .lineLimit(1)
                Text(ride.formattedDetails)
                    .font(.footnote)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rideThumbnailWidth: CGFloat {
        #if os(tvOS)
        return 80
        #else
        return 40
        #endif
    }

    private var rideRowSpacing: CGFloat? {
        #if os(tvOS)
        return 16
        #else
        return nil
        #endif
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
        .fixedSize(horizontal: true, vertical: true)
        .environment(Client.preview)
}
