import Bike
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
struct BikeApp: App {
    private let authenticator: Authenticator
    private let client: Client

    init() {
        authenticator = .init()
        client = .init(AppClient(authenticator: authenticator))
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        Group {
            WindowGroup {
                Group {
                    if authenticator.isAuthenticated {
                        AsyncBikeMap()
                    } else {
                        SignInView()
                    }
                }
            }
            #if os(macOS)
            .windowStyle(.hiddenTitleBar)
            #endif

            #if os(macOS) || os(visionOS)
            WindowGroup(id: Screen.stats.rawValue, for: Bike.self) { $bike in
                Screen.stats.view(for: bike)
            }

            WindowGroup(id: Screen.rides.rawValue, for: Bike.self) { $bike in
                Screen.rides.view(for: bike)
            }
            #endif
        }
        .environment(authenticator)
        .environment(client)
        .onChange(of: scenePhase, onChangeOfScenePhase)
    }

    private func onChangeOfScenePhase(_ oldValue: ScenePhase, _ newValue: ScenePhase) {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
