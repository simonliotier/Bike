import Bike
import SwiftUI

/// Loads and displays the full list of rides.
struct AsyncRideList: View {
    let bike: Bike

    @State private var asyncContent: Content

    init(bike: Bike) {
        self.bike = bike
        _asyncContent = State(initialValue: .init(bike: bike))
    }

    var body: some View {
        AsyncContentView(asyncContent: asyncContent) { rides in
            RideList(bike: bike, rides: rides)
        }
    }
}

extension AsyncRideList {
    @Observable
    class Content: AsyncContent {
        let bike: Bike

        init(bike: Bike) {
            self.bike = bike
        }

        var state: AsyncContentState<[Ride]> = .loading

        private let client = Client()

        func load() async {
            do {
                let rides = try await client.getRides(for: bike.id)
                state = .loaded(rides.data)
            } catch {
                state = .failed(error)
            }
        }
    }
}

#Preview {
    AsyncRideList(bike: .preview)
}
