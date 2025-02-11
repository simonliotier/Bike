import Bike
import Foundation
import SwiftUI

/// Loads and displays the last bike location on a map.
struct AsyncBikeMap: View {
    @Environment(\.client) var client: Client

    var body: some View {
        AsyncContentView(asyncContent: Content(client: client)) { bike, content in
            BikeMap(bike: bike, content: content)
        }
    }
}

extension AsyncBikeMap {
    @Observable
    class Content: AsyncContent {
        let client: Client
        var state: AsyncContentState<(Bike, BikeDetails)> = .loading

        init(client: Client) {
            self.client = client
        }

        func load() async {
            do {
                let bikes = try await client.getBikes()

                guard let bike = bikes.first else {
                    throw Error.noBike
                }

                async let lastRides = client.getRides(for: bike.id, limit: 3, offset: 0).data

                let from = Calendar.current.startOfCurrentWeek
                let till = Calendar.current.endOfCurrentWeek
                async let weekStats = client.getStats(for: bike.id, from: from, till: till, granularity: .daily)

                state = try await .loaded((bike, .init(lastRides: lastRides, weekStats: weekStats)))
            } catch {
                state = .failed(error)
            }
        }
    }
}

extension AsyncBikeMap {
    enum Error: Swift.Error {
        case noBike
    }
}

#Preview {
    AsyncBikeMap()
        .environment(\.client, PreviewClient())
}
