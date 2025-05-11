import BikeCore
import SwiftUI

/// Loads and displays the full list of rides.
struct AsyncRideList: View {
    let bike: Bike

    @Environment(Client.self) private var client

    var body: some View {
        AsyncContentView(asyncContent: Content(bike: bike, client: client)) { rides in
            RideList(bike: bike, rides: rides)
        }
        .navigationTitle("Rides")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                DismissButton()
            }
            #endif
        }
    }
}

extension AsyncRideList {
    @Observable
    class Content: AsyncContent {
        let bike: Bike
        let client: Client
        var state: AsyncContentState<[Ride]> = .loading

        init(bike: Bike, client: Client) {
            self.bike = bike
            self.client = client
        }

        func load() async {
            do {
                let rides = try await client.getRides(for: bike.id, limit: 100, offset: 0)
                state = .loaded(rides.data)
            } catch {
                state = .failed(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AsyncRideList(bike: .preview)
    }
    .environment(Client.preview)
}
