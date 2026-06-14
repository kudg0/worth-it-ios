import SwiftUI

struct EditProfileDraft {
    let name: String
    let email: String
    let image: String?
}

struct EditProfileScreen: View {
    let user: AuthUser?
    let onSave: (EditProfileDraft) async throws -> AuthUser
    let onDiscard: () -> Void

    @State private var fullName: String
    @State private var email: String
    @State private var errorText: String?
    @State private var isSaving = false

    init(
        user: AuthUser?,
        onSave: @escaping (EditProfileDraft) async throws -> AuthUser,
        onDiscard: @escaping () -> Void
    ) {
        self.user = user
        self.onSave = onSave
        self.onDiscard = onDiscard
        _fullName = State(initialValue: Self.displayName(for: user))
        _email = State(initialValue: user?.email ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
                    identityCard
                    securitySection
                    if let errorText {
                        WITipInfo(title: i18n.t("Profile not saved"), bodyText: errorText, size: .small, tone: .info)
                    }
                    actionStack
                }
                .padding(.horizontal, WorthItSpacing.xl)
                .padding(.top, WorthItSpacing.xxxl)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack(alignment: .top) {
                WorthItColor.surfaceLowest.ignoresSafeArea()
                Circle()
                    .fill(WorthItColor.surfaceContainerHigh.opacity(0.34))
                    .frame(width: 180, height: 180)
                    .blur(radius: 80)
                    .offset(y: -120)
            }
        }
    }

    private var topBar: some View {
        ZStack {
            Text("Edit Profile")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            HStack {
                Button(action: onDiscard) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.m)
        .background(WorthItColor.surfaceLowest.opacity(0.92))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(WorthItColor.outlineInput)
                .frame(height: 1)
        }
    }

    private var identityCard: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            editableAvatar

            VStack(spacing: WorthItSpacing.xl) {
                AccountProfileField(
                    label: i18n.t("FULL NAME"),
                    text: $fullName,
                    systemName: "person"
                )

                AccountProfileField(
                    label: i18n.t("EMAIL ADDRESS"),
                    text: $email,
                    systemName: "envelope",
                    keyboardType: .emailAddress
                )
            }
        }
        .padding(.horizontal, WorthItSpacing.xxl)
        .padding(.top, WorthItSpacing.xxl)
        .padding(.bottom, WorthItSpacing.xxl)
        .frame(maxWidth: .infinity)
        .background {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .fill(WorthItColor.surfaceIsland)

                Circle()
                    .fill(Color(hex: 0xD8E2FF).opacity(0.10))
                    .frame(width: 192, height: 192)
                    .blur(radius: 32)
                    .offset(x: 96, y: -96)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineInput, lineWidth: 1)
        }
        .shadow(color: Color(hex: 0xD8E2FF).opacity(0.05), radius: 40)
    }

    private var editableAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(initials)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 112, height: 112)
                .background(WorthItColor.surfaceContainerHigh, in: Circle())
                .overlay {
                    Circle()
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.18), radius: 24, y: 12)

            Button {} label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: 0x122F5F))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: 0xD8E2FF), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(WorthItColor.surfaceContainerLow, lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.20), radius: 12, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change profile photo")
        }
    }

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text("SECURITY & LINKED ACCOUNTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.80))
                .tracking(1.2)
                .padding(.horizontal, WorthItSpacing.l)

            VStack(spacing: 0) {
                AccountInfoRow(
                    title: i18n.t("Account Status"),
                    value: "Verified",
                    systemName: "shield.checkered",
                    valueColor: WorthItColor.accentGold
                )

                Divider()
                    .overlay(WorthItColor.outlineInput)
                    .padding(.leading, 72)

                AccountInfoRow(
                    title: i18n.t("Linked Identity"),
                    value: linkedIdentity,
                    systemName: "link"
                )
            }
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.16), radius: 18, y: 4)
        }
    }

    private var actionStack: some View {
        VStack(spacing: WorthItSpacing.m) {
            WIButton(title: i18n.t("SAVE CHANGES"), height: 56) {
                save()
            }
            .opacity(isSaving ? 0.62 : 1)
            .allowsHitTesting(!isSaving)

            WIButton(title: i18n.t("DISCARD"), style: .outline, height: 56, action: onDiscard)
        }
        .padding(.top, WorthItSpacing.xxxl)
    }

    private var initials: String {
        let parts = fullName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        let value = String(parts).uppercased()
        return value.isEmpty ? "WI" : value
    }

    private var linkedIdentity: String {
        email.isEmpty ? "Apple ID" : "Email"
    }

    private func save() {
        guard user != nil else { return }

        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorText = "Name cannot be empty."
            return
        }

        guard trimmedEmail.contains("@") else {
            errorText = "Enter a valid email address."
            return
        }

        isSaving = true
        errorText = nil

        Task {
            do {
                _ = try await onSave(EditProfileDraft(
                    name: trimmedName,
                    email: trimmedEmail,
                    image: user?.image
                ))
            } catch {
                errorText = profileSaveErrorText(error)
            }

            isSaving = false
        }
    }

    private func profileSaveErrorText(_ error: Error) -> String {
        if case APIError.requestFailed(let statusCode, let body) = error {
            if statusCode == 409 || body.contains("EMAIL_ALREADY_IN_USE") {
                return "This email is already used by another account."
            }

            return "Backend rejected the profile update. Status \(statusCode)."
        }

        return "Could not reach backend. Check connection and try again."
    }

    private static func displayName(for user: AuthUser?) -> String {
        let trimmedName = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedName.isEmpty ? "Worth It User" : trimmedName
    }
}

private struct AccountProfileField: View {
    let label: String
    @Binding var text: String
    let systemName: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            fieldLabel(label)
                .tracking(0.6)
                .textCase(.uppercase)
                .padding(.horizontal, WorthItSpacing.xs)

            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .frame(width: 18)

                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .textContentType(keyboardType == .emailAddress ? .emailAddress : .name)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 54)
            .background(WorthItColor.surfaceLowest.opacity(0.50), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}

private struct AccountInfoRow: View {
    let title: String
    let value: String
    let systemName: String
    var valueColor: Color = WorthItColor.textSecondary

    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 40, height: 40)
                .background(WorthItColor.surfaceContainer.opacity(0.52), in: Circle())

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(WorthItColor.textPrimary)

            Spacer(minLength: WorthItSpacing.m)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(minHeight: 72)
        .padding(.horizontal, WorthItSpacing.l)
    }
}

#Preview {
    EditProfileScreen(
        user: AuthUser(id: UUID(), name: "Ilya Brusenko", email: "ilya@example.com", image: nil),
        onSave: { _ in AuthUser(id: UUID(), name: "Ilya Brusenko", email: "ilya@example.com", image: nil) },
        onDiscard: {}
    )
}
