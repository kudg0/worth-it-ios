import SwiftUI

struct ProfileView: View {
    var defaultCurrency = "EUR"

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            sectionTitle("Profile")

            VStack(spacing: WorthItSpacing.m) {
                profileRow(label: "Account", value: "Development mock")
                profileRow(label: "Auth", value: "Not connected")
                profileRow(label: "Region", value: "Cyprus")
                profileRow(label: "Distance", value: "Kilometers")
                profileRow(label: "Currency", value: defaultCurrency)
            }

            wideAction(
                title: "Authorization",
                subtitle: "Mock state for now. This will become the account, session, and sign-in settings area.",
                systemName: "person.badge.key.fill"
            )
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(WorthItColor.textPrimary)
            .tracking(-0.75)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(1)
                .textCase(.uppercase)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func wideAction(title: String, subtitle: String, systemName: String) -> some View {
        Button {} label: {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
