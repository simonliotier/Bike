import SwiftUI

@main
struct BikeApp: App {
    @State private var authenticated: Bool = false

    var body: some Scene {
        WindowGroup {
            if authenticated {
                AsyncBikeMap()
            } else {
                LoginView(authenticated: $authenticated)
            }
        }
    }
}
