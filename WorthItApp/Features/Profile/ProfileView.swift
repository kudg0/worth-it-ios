import SwiftUI

struct ProfileView: View {
    let user: AuthUser?
    let onLogout: () -> Void

    private let region = "Cyprus"
    private let currency = "EUR"
    private let distanceUnits = "Kilometers"

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            topBar
            identityHeader

            VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
                ProfileSection(title: "Identity") {
                    ProfileRow(title: "Name", value: displayName, systemIcon: "person")
                    ProfileRow(title: "Email", value: email, systemIcon: "envelope")
                }

                ProfileSection(title: "Localization") {
                    ProfileRow(title: "Region", value: region, systemIcon: "globe.europe.africa", isSelectable: true)
                    ProfileRow(title: "Currency", value: currency, systemIcon: "banknote", isSelectable: true)
                    ProfileRow(title: "Distance", value: distanceUnits, systemIcon: "ruler", isSelectable: true)
                }

                ProfileSection(title: "Security") {
                    ProfileRow(
                        title: "Sign-in Method",
                        value: "Email connected",
                        systemIcon: "shield.checkered",
                        valueColor: WorthItColor.primaryContainer,
                        isSelectable: true
                    )
                }
            }

            signOutButton
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var topBar: some View {
        HStack {
            Text("Worth It")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color(hex: 0xD8E2FF))
                .lineLimit(1)

            Spacer(minLength: WorthItSpacing.l)

            avatar
        }
        .frame(height: 48)
    }

    private var identityHeader: some View {
        VStack(spacing: WorthItSpacing.s) {
            Text(displayName)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(email)
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Button {} label: {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(hex: 0xD8E2FF))
                .padding(.horizontal, 34)
                .frame(height: 46)
                .background(WorthItColor.surfaceContainerLow, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, WorthItSpacing.l)
        }
        .frame(maxWidth: .infinity)
    }

    private var signOutButton: some View {
        Button(action: onLogout) {
            HStack(spacing: WorthItSpacing.s) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .semibold))

                Text("Sign Out")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color(hex: 0xFFB4AB))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(Color(hex: 0xFFB4AB).opacity(0.20), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
        .padding(.top, WorthItSpacing.s)
        .accessibilityLabel("Sign out")
    }

    private var avatar: some View {
        Text(initials)
            .font(.system(size: 15, weight: .heavy))
            .foregroundStyle(WorthItColor.primaryContainer)
            .frame(width: 48, height: 48)
            .background(WorthItColor.surfaceContainerHigh, in: Circle())
            .overlay {
                Circle()
                    .stroke(WorthItColor.outlineInput, lineWidth: 2)
            }
            .shadow(color: WorthItColor.primaryContainer.opacity(0.15), radius: 30)
    }

    private var displayName: String {
        let trimmedName = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedName.isEmpty ? "Worth It User" : trimmedName
    }

    private var email: String {
        user?.email ?? "Not connected"
    }

    private var initials: String {
        let parts = displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        let value = String(parts).uppercased()
        return value.isEmpty ? "WI" : value
    }
}

private struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)
                .padding(.horizontal, WorthItSpacing.s)

            VStack(spacing: 0) {
                content
            }
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
            .shadow(color: .black.opacity(0.20), radius: 24, y: 4)
        }
    }
}

private struct ProfileRow: View {
    let title: String
    let value: String
    let systemIcon: String
    var valueColor: Color = WorthItColor.textSecondary
    var isSelectable = false

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemIcon)
                .font(.system(size: 16, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(WorthItColor.textPrimary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textPrimary)

            Spacer(minLength: WorthItSpacing.m)

            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            if isSelectable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)
            }
        }
        .frame(minHeight: 52)
        .padding(.horizontal, WorthItSpacing.l)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: 0x313442).opacity(0.50))
                .frame(height: 1)
                .padding(.leading, 52)
        }
    }
}
