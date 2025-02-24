import Bike
import SwiftUI

@main
struct BikeWatch_Watch_AppApp: App {
    private let authenticationController = AuthenticationController()

    var body: some Scene {
        WindowGroup {
            if authenticationController.isAuthenticated {
                AsyncBikeView()
            } else {
                Text("Not authenticated")
            }
        }
        .environment(authenticationController)
        .environmentObject(Client.api(authenticationController))
    }
}
