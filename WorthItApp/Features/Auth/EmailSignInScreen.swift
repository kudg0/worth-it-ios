import SwiftUI

struct EmailSignInScreen: View {
    let authRepository: AuthRepository
    let onAppleSignIn: () -> Void
    let onAuthenticated: (AuthSession) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()
            WITopSpotlight()

            VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                header
                titleBlock
                if AuthCapabilities.isAppleSignInEnabled {
                    appleButton
                    emailDivider
                }
                formFields
                submitButton
                errorLabel
                Spacer(minLength: 0)
                registrationLink
                AuthFooterNote(text: "Use the account tied to your ownership scenarios.")
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .padding(.top, WorthItSpacing.m)
            .padding(.bottom, WorthItSpacing.xl)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var header: some View {
        ZStack {
            AuthWordmark()

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(WorthItColor.surfaceContainerHigh, in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text("Sign in with email.")
                .font(WorthItTypography.headline)
                .foregroundStyle(WorthItColor.textPrimary)

            Text("Open your scenarios, metrics, and history from this account.")
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(4)
        }
        .padding(.top, WorthItSpacing.xl)
    }

    private var formFields: some View {
        VStack(spacing: WorthItSpacing.l) {
            AuthTextField(
                label: i18n.t("Email"),
                placeholder: i18n.t("you@example.com"),
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .username
            )
            AuthTextField(
                label: i18n.t("Password"),
                placeholder: i18n.t("Password"),
                text: $password,
                isSecure: true,
                textContentType: .password,
                submitLabel: .go
            )
        }
    }

    private var appleButton: some View {
        AuthActionButton(title: i18n.t("Continue with Apple"), systemName: "apple.logo", style: .apple) {
            onAppleSignIn()
        }
        .padding(.top, WorthItSpacing.s)
    }

    private var emailDivider: some View {
        HStack(spacing: WorthItSpacing.m) {
            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)

            Text("or use email")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .lineLimit(1)

            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)
        }
    }

    private var submitButton: some View {
        AuthActionButton(title: isSubmitting ? "Signing in..." : "Sign in", systemName: "arrow.right", style: .primary) {
            Task { await submit() }
        }
        .disabled(isSubmitting)
    }

    private var registrationLink: some View {
        NavigationLink(value: AuthRoute.registration) {
            Text("No account yet? Create account")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
        }
    }

    @ViewBuilder
    private var errorLabel: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.danger)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func submit() async {
        guard !isSubmitting else { return }
        errorMessage = nil

        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let session = try await authRepository.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            onAuthenticated(session)
        } catch {
            errorMessage = authErrorText(error)
        }
    }

    private func authErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(let statusCode, _) = error, statusCode == 401 || statusCode == 403 {
            return "Email or password is incorrect."
        }

        return "Could not sign in. Check connection and try again."
    }
}

#Preview {
    EmailSignInScreen(
        authRepository: AuthRepository(baseURL: APIEnvironment.development.baseURL),
        onAppleSignIn: {},
        onAuthenticated: { _ in }
    )
}
