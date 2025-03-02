import Bike
import SwiftUI

/// Basic sign in view.
struct SignInView: View {
    @State private var state: LoginViewState = .idle

    @Environment(AuthenticationController.self) private var authenticationController

    private enum LoginViewState {
        case idle
        case loading
        case error(Error)
    }

    var body: some View {
        switch state {
        case .idle:
            Button("Sign in", action: signIn)
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
        case .loading:
            ProgressView()
        case .error(let error):
            VStack {
                Text(error.localizedDescription)
                Button("Sign out", action: signOut)
            }
        }
    }

    private func signIn() {
        Task {
            state = .loading

            do {
                try await authenticationController.signIn()
            } catch {
                self.state = .error(error)
            }
        }
    }

    private func signOut() {
        authenticationController.signOut()
        state = .idle
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationController())
}
