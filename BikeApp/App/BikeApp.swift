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
    }
}
