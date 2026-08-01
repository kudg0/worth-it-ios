import SwiftUI

struct AchievementCategoryDashboard: View {
    let summaries: [AchievementCategorySummary]
    let achievements: [AchievementProgress]
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    var onOpenCategory: (String) -> Void = { _ in }
    var onOpenAchievement: (AchievementProgress) -> Void = { _ in }

    var body: some View {
        VStack(spacing: WorthItSpacing.xxl) {
            ForEach(summaries) { summary in
                AchievementCategoryDashboardCard(
                    summary: summary,
                    items: categoryItems(for: summary.id),
                    selectedLevel: selectedLevel,
                    isLevelUnlocked: isLevelUnlocked,
                    onOpenCategory: onOpenCategory,
                    onOpenAchievement: onOpenAchievement
                )
            }
        }
    }

    private func categoryItems(for category: String) -> [AchievementProgress] {
        Array(
            achievements
                .filter { $0.category == category }
                .sorted { $0.tierProgress(in: selectedLevel) > $1.tierProgress(in: selectedLevel) }
                .prefix(3)
        )
    }
}

private struct AchievementCategoryDashboardCard: View {
    @Environment(\.i18n) private var i18n

    let summary: AchievementCategorySummary
    let items: [AchievementProgress]
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    let onOpenCategory: (String) -> Void
    let onOpenAchievement: (AchievementProgress) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            Button {
                onOpenCategory(summary.id)
            } label: {
                VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                    HStack(alignment: .lastTextBaseline) {
                        Text(summary.title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Spacer()

                        Text(i18n.t(.achievements.categoryDashboard.earnedCountFormat, summary.earned, summary.total))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WorthItColor.textTertiary)
                    }

                    ProgressView(value: summary.progress)
                        .tint(summary.isEarned ? WorthItColor.accentGoldBright : WorthItColor.primaryContainer)
                        .background(WorthItColor.surfaceContainerHigh, in: Capsule())
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: WorthItSpacing.s) {
                ForEach(items) { item in
                    AchievementCategoryAchievementCard(
                        achievement: item,
                        selectedLevel: selectedLevel,
                        isLevelUnlocked: isLevelUnlocked,
                        onOpenAchievement: onOpenAchievement
                    )
                }
            }

            Button {
                onOpenCategory(summary.id)
            } label: {
                HStack(spacing: WorthItSpacing.s) {
                    Text(i18n.t(.achievements.common.actions.viewAll))
                        .font(.system(size: 14, weight: .semibold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            }
            .buttonStyle(.plain)
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}

private extension AchievementCategorySummary {
    var isEarned: Bool {
        total > 0 && earned >= total
    }
}

private struct AchievementCategoryAchievementCard: View {
    @Environment(\.i18n) private var i18n

    let achievement: AchievementProgress
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    let onOpenAchievement: (AchievementProgress) -> Void

    private var isEarnedOnCurrentLevel: Bool {
        isLevelUnlocked && achievement.isTierEarned(in: selectedLevel)
    }

    var body: some View {
        Button {
            onOpenAchievement(achievement)
        } label: {
            HStack(spacing: WorthItSpacing.s) {
                AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: badgeState, size: 36)

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(achievement.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(statusText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                Spacer()

                Image(systemName: trailingIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isEarnedOnCurrentLevel ? WorthItColor.accentGold : WorthItColor.textTertiary)
            }
            .padding(.horizontal, WorthItSpacing.m)
            .frame(height: 56)
            .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .opacity(isLevelUnlocked ? 1 : 0.62)
        }
        .buttonStyle(.plain)
    }

    private var statusText: String {
        if !isLevelUnlocked { return i18n.t(.achievements.common.status.locked) }
        return isEarnedOnCurrentLevel
            ? i18n.t(.achievements.common.status.earned)
            : i18n.t(
                .achievements.common.status.percentCompleteFormat,
                AchievementPercentFormatter.percentText(achievement.tierProgress(in: selectedLevel))
            )
    }

    private var badgeState: AchievementBadgeState {
        if !isLevelUnlocked { return .locked }
        return isEarnedOnCurrentLevel ? .earned : .inProgress
    }

    private var trailingIcon: String {
        if !isLevelUnlocked { return "lock.fill" }
        return isEarnedOnCurrentLevel ? "checkmark.seal.fill" : "chevron.right"
    }
}
