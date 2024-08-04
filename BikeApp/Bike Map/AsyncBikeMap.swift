import Bike
import Foundation
import SwiftUI

/// Basic view displaying the last bike location on a map.
@MainActor
struct AsyncBikeMap: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        AsyncContentView(asyncContent: viewModel) { bikes in
            BikeMap(bikes: bikes)
        }
    }
}

extension AsyncBikeMap {
    @Observable
    class ViewModel: AsyncContent {
        var state: AsyncContentState<[Bike]> = .loading

        private let client = Client()

        func load(isRefreshing: Bool) async {
            do {
                let bikes = try await client.getBikes()
                state = .loaded(bikes)
            } catch {
                state = .failed(error)
            }
        }
    }
}
