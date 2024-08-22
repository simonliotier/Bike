import Bike
import SwiftUI

/// Basic login view.
struct LoginView: View {
    @Binding var authenticated: Bool

    @State private var error: Error?

    var body: some View {
        if let error {
            VStack {
                Text(error.localizedDescription)
                Button("Logout") {
                    AuthenticationController.shared.logout()
                }
            }
        } else {
            ProgressView()
                .task {
                    // QUICKFIX: wait for the window scene to be in foreground active state after app launch.
                    try? await Task.sleep(for: .seconds(1))

                    await authenticate()
                }
        }
    }

    private func authenticate() async {
        if AuthenticationController.shared.isAuthenticated {
            authenticated = true
        } else {
            do {
                try await AuthenticationController.shared.authenticate()
                authenticated = true
            } catch {
                self.error = error
            }
        }
    }
}

#Preview {
    LoginView(authenticated: .constant(false))
}
