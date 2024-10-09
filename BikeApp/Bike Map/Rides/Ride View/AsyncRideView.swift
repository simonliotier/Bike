import Bike
import Foundation
import SwiftUI

/// Loads and displays a ride.
struct AsyncRideView: View {
    let bike: Bike
    let ride: Ride

    @State private var asyncContent: Content

    init(bike: Bike, ride: Ride) {
        self.bike = bike
        self.ride = ride
        _asyncContent = State(initialValue: Content(bike: bike, ride: ride))
    }

    var body: some View {
        AsyncContentView(asyncContent: asyncContent) { locations in
            RideView(ride: ride, locations: locations)
        }
    }
}

extension AsyncRideView {
    @Observable
    class Content: AsyncContent {
        let bike: Bike
        let ride: Ride

        init(bike: Bike, ride: Ride) {
            self.bike = bike
            self.ride = ride
        }

        var state: AsyncContentState<[Location]> = .loading

        private let client = Client()

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
