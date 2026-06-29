import SwiftUI

struct AchievementNextUnlockCard: View {
    @Environment(\.i18n) private var i18n

    let achievement: AchievementProgress
    let selectedLevel: Int
    let onOpenAchievement: (AchievementProgress) -> Void

    private var levelProgress: Double {
        achievement.tierProgress(in: selectedLevel)
    }

    var body: some View {
        Button {
            onOpenAchievement(achievement)
        } label: {
            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                HStack(spacing: WorthItSpacing.m) {
                    icon

                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text(achievement.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text(i18n.t("Next Milestone Unlock"))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                    }

                    Spacer()

                    Text("\(Int(levelProgress * 100))%")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .monospacedDigit()
                }

                ProgressView(value: levelProgress)
                    .tint(WorthItColor.primaryContainer)
                    .background(WorthItColor.surfaceContainerHigh, in: Capsule())

                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)

                    Text(helperText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                }
                .padding(.horizontal, WorthItSpacing.m)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            }
            .padding(WorthItSpacing.xl)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private var icon: some View {
        AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: .inProgress, size: 44)
    }

    private var helperText: String {
        guard let tierIndex = achievement.tierIndex(in: selectedLevel),
              achievement.tiers.indices.contains(tierIndex) else {
            return i18n.t("This achievement family is complete.")
        }

        let nextTargetValue = achievement.tiers[tierIndex].targetValue
        let remaining = max(0, nextTargetValue - achievement.currentValue)
        return i18n.t("Add \(Int(ceil(remaining))) more toward \(achievement.tierLabel(in: selectedLevel)) to unlock.")
    }
}
