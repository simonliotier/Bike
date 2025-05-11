import BikeCore
import SwiftUI

/// Basic sign in view.
struct SignInView: View {
    @State private var state: LoginViewState = .idle

    @Environment(Authenticator.self) private var authenticator

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
            #if !os(tvOS)
                .controlSize(.extraLarge)
            #endif
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
                try await authenticator.signIn()
            } catch {
                self.state = .error(error)
            }
        }
    }

    private func signOut() {
        authenticator.signOut()
        state = .idle
    }
}

#Preview {
    SignInView()
        .environment(Authenticator(PreviewAuthenticator(isAuthenticated: false)))
}
