import Bike
import SwiftUI
import WidgetKit

@main
struct BikeApp: App {
    @State private var authenticationController: AuthenticationController

    private let client: Client

    init() {
        let authenticationController = AuthenticationController()
        self.authenticationController = authenticationController
        client = Client(client: APIClient(authenticationController: authenticationController))
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        Group {
            WindowGroup {
                Group {
                    if authenticationController.isAuthenticated {
                        AsyncBikeMap()
                    } else {
                        SignInView()
                    }
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
        .environment(authenticationController)
        .environment(client)
        .onChange(of: scenePhase) { _, _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
