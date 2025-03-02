import Bike
import Foundation
import SwiftUI

/// Describes a screen accessible from the main view.
///
/// The screens are presented as sheets on iOS and as windows on macOS.
enum Screen: String, Identifiable, CaseIterable {
    case rides
    case stats

    var id: Self {
        self
    }

    @MainActor @ViewBuilder func view(for bike: Bike?) -> some View {
        if let bike {
            NavigationStack {
                switch self {
                case .rides:
                    AsyncRideList(bike: bike)
                case .stats:
                    AsyncStatsView(bike: bike)
                }
            }
        } else {
            ContentUnavailableView("No bike selected", systemImage: "bicycle")
        }
    }
}
