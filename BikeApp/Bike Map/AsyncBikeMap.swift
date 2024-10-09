import Bike
import Foundation
import SwiftUI

/// Loads and displays the last bike location on a map.
struct AsyncBikeMap: View {
    @Environment(\.client) var client: Client

    var body: some View {
        AsyncContentView(asyncContent: Content(client: client)) { bikes in
            if let bike = bikes.first {
                BikeMap(bike: bike)
            } else {
                Text("No bike found.")
            }
        }
    }
}

extension AsyncBikeMap {
    @Observable
    class Content: AsyncContent {
        let client: Client
        var state: AsyncContentState<[Bike]> = .loading

        init(client: Client) {
            self.client = client
        }

        func load() async {
            do {
                let bikes = try await client.getBikes()
                state = .loaded(bikes)
            } catch {
                state = .failed(error)
            }
        }
    }
}

#Preview {
    AsyncBikeMap()
        .environment(\.client, PreviewClient())
}
