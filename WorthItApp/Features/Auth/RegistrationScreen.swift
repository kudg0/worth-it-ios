import SwiftUI

struct RegistrationScreen: View {
    let authRepository: AuthRepository
    let onAppleSignIn: () -> Void
    let onAuthenticated: (AuthSession) -> Void

    @Environment(\.i18n) private var i18n
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRegion = "Cyprus"
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()
            WITopSpotlight()

            ScrollView {
                VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                    header
                    titleBlock
                    if AuthCapabilities.isAppleSignInEnabled {
                        appleButton
                        emailDivider
                    }
                    formFields
                    RegionSelector(selection: $selectedRegion)
                    createButton
                    errorLabel
                    signInLink
                    AuthFooterNote(text: i18n.t(.auth.registration.footer))
                }
                .padding(.horizontal, WorthItSpacing.xl)
                .padding(.top, WorthItSpacing.m)
                .padding(.bottom, WorthItSpacing.xxxxl)
            }
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
            Text(i18n.t(.auth.registration.title))
                .font(WorthItTypography.headline)
                .foregroundStyle(WorthItColor.textPrimary)

            Text(i18n.t(.auth.registration.subtitle))
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(4)
        }
        .padding(.top, WorthItSpacing.xl)
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

    private var formFields: some View {
        VStack(spacing: WorthItSpacing.l) {
            AuthTextField(
                label: i18n.t(.auth.fields.name.label),
                placeholder: i18n.t(.auth.fields.name.placeholder),
                text: $name,
                textContentType: .name
            )
            AuthTextField(
                label: i18n.t(.auth.fields.email.label),
                placeholder: i18n.t(.auth.fields.email.placeholder),
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            AuthTextField(
                label: i18n.t(.auth.fields.password.label),
                placeholder: i18n.t(.auth.fields.password.createPlaceholder),
                text: $password,
                isSecure: true,
                textContentType: .newPassword,
                submitLabel: .go
            )
        }
    }

    private var createButton: some View {
        AuthActionButton(
            title: isSubmitting ? i18n.t(.auth.registration.actions.creating) : i18n.t(.auth.registration.actions.create),
            systemName: "person.badge.plus",
            style: .primary
        ) {
            Task { await submit() }
        }
        .disabled(isSubmitting)
        .padding(.top, WorthItSpacing.s)
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

    private var signInLink: some View {
        NavigationLink(value: AuthRoute.emailSignIn) {
            Text(i18n.t(.auth.registration.links.signIn))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
        }
    }

    private func submit() async {
        guard !isSubmitting else { return }
        errorMessage = nil

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = i18n.t(.auth.registration.errors.required)
            return
        }

        guard password.count >= 8 else {
            errorMessage = i18n.t(.auth.registration.errors.passwordTooShort)
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let session = try await authRepository.signUp(
                name: trimmedName,
                email: trimmedEmail,
                password: password,
                region: selectedRegion
            )
            onAuthenticated(session)
        } catch {
            errorMessage = authErrorText(error)
        }
    }

    private func authErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(let statusCode, let body) = error {
            let authError = AuthErrorBody.parse(body)

            if [400, 409, 422].contains(statusCode),
               authError.matches("already") || authError.matches("USER_ALREADY_EXISTS") {
                return i18n.t(.auth.registration.errors.accountExists)
            }

            if let message = authError.message, !message.isEmpty {
                return message
            }

            return "\(i18n.t(.auth.registration.errors.createFailedWithStatus)) (\(statusCode))"
        }

        return i18n.t(.auth.registration.errors.createFailedNetwork)
    }
}

private struct AuthErrorBody: Decodable {
    let message: String?
    let code: String?

    static func parse(_ body: String) -> AuthErrorBody {
        guard let data = body.data(using: .utf8),
              let parsed = try? JSONDecoder().decode(AuthErrorBody.self, from: data) else {
            return AuthErrorBody(message: body, code: nil)
        }

        return parsed
    }

    func matches(_ fragment: String) -> Bool {
        message?.localizedCaseInsensitiveContains(fragment) == true ||
            code?.localizedCaseInsensitiveContains(fragment) == true
    }
}

private struct RegionSelector: View {
    @Environment(\.i18n) private var i18n

    @Binding var selection: String

    private let regions = Locale.Region.isoRegions
        .filter { $0.identifier.count == 2 }
        .compactMap { Locale.current.localizedString(forRegionCode: $0.identifier) }
        .uniquedAndSorted()

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            WISelectField(label: i18n.t(.profile.view.rows.region), options: regions, selection: $selection)

            Text(i18n.t(.auth.registration.region.helpText))
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension Array where Element == String {
    func uniquedAndSorted() -> [String] {
        Array(Set(self)).sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }
}

#Preview {
    RegistrationScreen(
        authRepository: AuthRepository(baseURL: APIEnvironment.development.baseURL),
        onAppleSignIn: {},
        onAuthenticated: { _ in }
    )
}
