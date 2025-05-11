import BikeCore
import Foundation
import SwiftUI

/// Loads and displays the bike information.
struct AsyncBikeView: View {
    @Environment(Client.self) private var client

    var body: some View {
        AsyncContentView(asyncContent: Content(client: client)) { bike in
            NavigationStack {
                BikeView(bike: bike)
            }
        }
    }
}

extension AsyncBikeView {
    @Observable
    class Content: AsyncContent {
        let client: Client
        var state: AsyncContentState<Bike> = .loading

        init(client: Client) {
            self.client = client
        }

        func load() async {
            do {
                let bikes = try await client.getBikes()

                guard let bike = bikes.first else {
                    throw Error.noBike
                }

                state = .loaded(bike)
            } catch {
                state = .failed(error)
            }
        }
    }
}

extension AsyncBikeView {
    enum Error: Swift.Error {
        case noBike
    }
}

#Preview {
    AsyncBikeView()
        .environment(Client.preview)
}
