import Bike
import Foundation
import SwiftUI

/// Loads and displays a ride.
struct AsyncRideView: View {
    let bike: Bike
    let ride: Ride

    @Environment(Client.self) private var client

    init(bike: Bike, ride: Ride) {
        self.bike = bike
        self.ride = ride
    }

    var body: some View {
        AsyncContentView(asyncContent: Content(bike: bike, ride: ride, client: client)) { locations in
            RideView(ride: ride, locations: locations)
        }
        .navigationTitle(ride.formattedTitle)
    }
}

extension AsyncRideView {
    @Observable
    class Content: AsyncContent {
        let bike: Bike
        let ride: Ride
        let client: Client
        var state: AsyncContentState<[Location]> = .loading

        init(bike: Bike, ride: Ride, client: Client) {
            self.bike = bike
            self.ride = ride
            self.client = client
        }

        func load() async {
            do {
                let locations = try await client.getLocations(for: bike.id, from: ride.startDate, till: ride.endDate)
                state = .loaded(locations)
            } catch {
                state = .failed(error)
            }
        }
    }
}

private extension Ride {
    var formattedTitle: String {
        if !name.isEmpty {
            return name
        }

        return startDate.formatted(date: .long, time: .omitted).capitalizedSentence
    }
}

#Preview {
    NavigationStack {
        AsyncRideView(bike: .preview, ride: .previewMorning)
            .environment(Client.preview)
    }
}
