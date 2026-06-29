import SwiftUI

struct AchievementRecentUnlocks: View {
    @Environment(\.i18n) private var i18n

    let awards: [AchievementAward]
    let achievements: [AchievementProgress]
    let titleForAward: (AchievementAward) -> String
    let dateText: (Date) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(i18n.t("Recent Unlocks"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .padding(.horizontal, WorthItSpacing.xs)

            VStack(spacing: WorthItSpacing.m) {
                if awards.isEmpty {
                    emptyState
                } else {
                    ForEach(awards) { award in
                        AchievementUnlockRow(
                            title: titleForAward(award),
                            subtitle: dateText(award.awardedAt),
                            medalGlyph: achievements.first { $0.achievementKey == award.achievementKey }?.medalGlyph
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)

            Text(i18n.t("No earned milestones yet. Keep logging ownership data."))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}

private struct AchievementUnlockRow: View {
    let title: String
    let subtitle: String
    let medalGlyph: String?

    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            AchievementBadgeImage(medalGlyph: medalGlyph ?? "", state: .earned, size: 44)

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
