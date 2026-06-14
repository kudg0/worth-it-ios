import SwiftUI

struct AuthFlowView: View {
    let authRepository: AuthRepository
    @ObservedObject var authSessionStore: AuthSessionStore
    @StateObject private var appleSignIn = AppleSignInProvider()
    @State private var authNotice: String?

    var body: some View {
        NavigationStack {
            AuthEntryScreen(
                onAppleSignIn: {
                    appleSignIn.request()
                },
                onEmailSignIn: {},
                onCreateAccount: {}
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .emailSignIn:
                    EmailSignInScreen(
                        authRepository: authRepository,
                        onAppleSignIn: {
                            appleSignIn.request()
                        },
                        onAuthenticated: authenticate
                    )
                case .registration:
                    RegistrationScreen(
                        authRepository: authRepository,
                        onAppleSignIn: {
                            appleSignIn.request()
                        },
                        onAuthenticated: authenticate
                    )
                }
            }
        }
        .tint(WorthItColor.primaryContainer)
        .onAppear {
            appleSignIn.onCredential = { credential in
                Task { await authenticateWithApple(credential) }
            }
            appleSignIn.onFailure = { message in
                authNotice = message
            }
        }
        .alert("Authorization", isPresented: Binding(
            get: { authNotice != nil },
            set: { if !$0 { authNotice = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authNotice ?? "")
        }
    }

    private func authenticate(_ session: AuthSession) {
        withAnimation(.easeInOut(duration: 0.22)) {
            authSessionStore.replace(with: session)
        }
    }

    private func authenticateWithApple(_ credential: AppleSignInCredential) async {
        do {
            let session = try await authRepository.signInWithApple(credential)
            authenticate(session)
        } catch {
            authNotice = appleAuthErrorText(error)
        }
    }

    private func appleAuthErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(_, let body) = error,
           body.contains("PROVIDER_NOT_FOUND") {
            return "Apple Sign In is not enabled on the backend yet."
        }

        return "Could not sign in with Apple. Check setup and try again."
    }
}

enum AuthRoute: Hashable {
    case emailSignIn
    case registration
}
