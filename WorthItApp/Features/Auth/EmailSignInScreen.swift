import SwiftUI

struct EmailSignInScreen: View {
    let authRepository: AuthRepository
    let onAppleSignIn: () -> Void
    let onAuthenticated: (AuthSession) -> Void

    @Environment(\.i18n) private var i18n
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
                AuthFooterNote(text: i18n.t(.auth.email.footer))
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
            Text(i18n.t(.auth.email.title))
                .font(WorthItTypography.headline)
                .foregroundStyle(WorthItColor.textPrimary)

            Text(i18n.t(.auth.email.subtitle))
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(4)
        }
        .padding(.top, WorthItSpacing.xl)
    }

    private var formFields: some View {
        VStack(spacing: WorthItSpacing.l) {
            AuthTextField(
                label: i18n.t(.auth.fields.email.label),
                placeholder: i18n.t(.auth.fields.email.placeholder),
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .username
            )
            AuthTextField(
                label: i18n.t(.auth.fields.password.label),
                placeholder: i18n.t(.auth.fields.password.placeholder),
                text: $password,
                isSecure: true,
                textContentType: .password,
                submitLabel: .go
            )
        }
    }

    private var appleButton: some View {
        AuthActionButton(title: i18n.t(.auth.actions.continueWithApple), systemName: "apple.logo", style: .apple) {
            onAppleSignIn()
        }
        .padding(.top, WorthItSpacing.s)
    }

    private var emailDivider: some View {
        HStack(spacing: WorthItSpacing.m) {
            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)

            Text(i18n.t(.auth.email.divider.orUseEmail))
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .lineLimit(1)

            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)
        }
    }

    private var submitButton: some View {
        AuthActionButton(title: isSubmitting ? i18n.t(.auth.email.actions.signingIn) : i18n.t(.auth.email.actions.signIn), systemName: "arrow.right", style: .primary) {
            Task { await submit() }
        }
        .disabled(isSubmitting)
    }

    private var registrationLink: some View {
        NavigationLink(value: AuthRoute.registration) {
            Text(i18n.t(.auth.email.links.createAccount))
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
            errorMessage = i18n.t(.auth.email.errors.required)
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
            return i18n.t(.auth.email.errors.invalidCredentials)
        }

        return i18n.t(.auth.email.errors.signInFailed)
    }
}

#Preview {
    EmailSignInScreen(
        authRepository: AuthRepository(baseURL: APIEnvironment.development.baseURL),
        onAppleSignIn: {},
        onAuthenticated: { _ in }
    )
}
