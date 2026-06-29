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

                        Text(i18n.t("\(summary.earned) of \(summary.total) earned"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WorthItColor.textTertiary)
                    }

                    ProgressView(value: summary.progress)
                        .tint(summary.isEarned ? WorthItColor.accentGoldBright : WorthItColor.primaryContainer)
                        .background(WorthItColor.surfaceContainerHigh, in: Capsule())
                }
            }
            .buttonStyle(.plain)

            if let lead = items.first {
                AchievementCategoryLeadRow(
                    achievement: lead,
                    selectedLevel: selectedLevel,
                    isLevelUnlocked: isLevelUnlocked,
                    onOpenAchievement: onOpenAchievement
                )
            }

            VStack(spacing: WorthItSpacing.s) {
                ForEach(items.dropFirst()) { item in
                    AchievementCategorySubRow(
                        achievement: item,
                        selectedLevel: selectedLevel,
                        isLevelUnlocked: isLevelUnlocked,
                        onOpenAchievement: onOpenAchievement
                    )
                }
            }
            .padding(.leading, WorthItSpacing.l)
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

private struct AchievementCategoryLeadRow: View {
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
            HStack(spacing: WorthItSpacing.m) {
                AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: badgeState, size: 44)

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(achievement.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(statusText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                Spacer()

                Image(systemName: trailingIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isEarnedOnCurrentLevel ? WorthItColor.accentGold : WorthItColor.textTertiary)
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 70)
            .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .opacity(isLevelUnlocked ? 1 : 0.62)
        }
        .buttonStyle(.plain)
    }

    private var statusText: String {
        if !isLevelUnlocked { return i18n.t("Locked") }
        return isEarnedOnCurrentLevel ? i18n.t("Earned") : i18n.t("\(Int(achievement.tierProgress(in: selectedLevel) * 100))% complete")
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

private struct AchievementCategorySubRow: View {
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
                Image(systemName: rowIcon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isEarnedOnCurrentLevel ? WorthItColor.accentGold : WorthItColor.textTertiary)
                    .frame(width: 16)

                Text(achievement.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)

                Spacer()

                Text(statusText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .monospacedDigit()
            }
            .frame(height: 32)
            .contentShape(Rectangle())
            .opacity(isLevelUnlocked ? 1 : 0.62)
        }
        .buttonStyle(.plain)
    }

    private var rowIcon: String {
        if !isLevelUnlocked { return "lock.fill" }
        return isEarnedOnCurrentLevel ? "checkmark" : "lock"
    }

    private var statusText: String {
        if !isLevelUnlocked { return i18n.t("Locked") }
        return isEarnedOnCurrentLevel ? i18n.t("Earned") : "\(Int(achievement.tierProgress(in: selectedLevel) * 100))%"
    }
}
