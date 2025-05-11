import BikeCore
import SwiftUI

@main
struct BikeWatchApp: App {
    private let authenticator = Authenticator()

    var body: some Scene {
        WindowGroup {
            if authenticator.isAuthenticated {
                AsyncBikeView()
            } else {
                Text("Not authenticated")
            }
        }
        .environment(authenticator)
        .environmentObject(Client(AppClient(authenticator: authenticator)))
    }
}
