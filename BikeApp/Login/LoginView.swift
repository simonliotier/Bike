import Bike
import SwiftUI

struct LoginView: View {
    @Binding var authenticated: Bool

    var body: some View {
        ProgressView()
            .task {
                // QUICKFIX: wait for the window scene to be in foreground active state after app launch.
                try? await Task.sleep(for: .seconds(1))

                await authenticate()
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
                print(error)
            }
        }
    }
}

#Preview {
    LoginView(authenticated: .constant(false))
}
