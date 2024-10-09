import Bike
import Foundation
import SwiftUI

/// Loads and displays the last bike location on a map.
struct AsyncBikeMap: View {
    @State private var asyncContent = Content()

    var body: some View {
        AsyncContentView(asyncContent: asyncContent) { bikes in
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
        var state: AsyncContentState<[Bike]> = .loading

        private let client = Client()

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
