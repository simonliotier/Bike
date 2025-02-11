import Bike
import SwiftUI
import WidgetKit

@main
struct BikeApp: App {
    @State private var authenticated: Bool = false

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if authenticated {
                    AsyncBikeMap()
                } else {
                    LoginView(authenticated: $authenticated)
                }
            }
            .onChange(of: scenePhase) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif

        #if os(macOS)
            WindowGroup(id: Screen.stats.rawValue, for: Bike.self) { $bike in
                Screen.stats.view(for: bike)
            }

            WindowGroup(id: Screen.rides.rawValue, for: Bike.self) { $bike in
                Screen.rides.view(for: bike)
            }
        #endif
    }
}
