import SwiftUI

struct AchievementMapLane: View {
    let summary: AchievementCategorySummary
    let achievements: [AchievementProgress]
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    let onOpenAchievement: (AchievementProgress) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: WorthItSpacing.s), count: 3)
    private var isCategoryEarned: Bool {
        isLevelUnlocked && summary.total > 0 && summary.earned >= summary.total
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(spacing: WorthItSpacing.s) {
                Image(systemName: isCategoryEarned ? "checkmark.seal.fill" : summary.systemIcon)
                    .font(.system(size: isCategoryEarned ? 14 : 11, weight: .semibold))
                    .foregroundStyle(isCategoryEarned ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                    .frame(width: 24, height: 24)
                    .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(summary.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("\(summary.earned)")
                        .foregroundStyle(WorthItColor.accentGold)
                    Text("/\(summary.total)")
                        .foregroundStyle(WorthItColor.textSecondary)
                }
                .font(.system(size: 12, weight: .medium))
                .monospacedDigit()
                .padding(.horizontal, WorthItSpacing.s)
                .padding(.vertical, WorthItSpacing.xs)
                .background(WorthItColor.surfaceContainerLow, in: Capsule())
            }

            LazyVGrid(columns: columns, alignment: .center, spacing: WorthItSpacing.l) {
                ForEach(achievements) { achievement in
                    AchievementMapNode(
                        achievement: achievement,
                        selectedLevel: selectedLevel,
                        isLevelUnlocked: isLevelUnlocked,
                        onOpenAchievement: onOpenAchievement
                    )
                }
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }
}

private struct AchievementMapNode: View {
    let achievement: AchievementProgress
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    let onOpenAchievement: (AchievementProgress) -> Void

    private var isEarned: Bool {
        isLevelUnlocked && achievement.isTierEarned(in: selectedLevel)
    }

    private var isLocked: Bool {
        !isLevelUnlocked
    }

    private var badgeState: AchievementBadgeState {
        if isLocked { return .locked }
        return isEarned ? .earned : .inProgress
    }

    private var progress: Double {
        achievement.tierProgress(in: selectedLevel)
    }

    private var nodeFrameSize: CGFloat { 72 }
    private var earnedBadgeSize: CGFloat { 72 }
    private var progressBadgeSize: CGFloat { 58 }

    var body: some View {
        Button {
            onOpenAchievement(achievement)
        } label: {
            VStack(spacing: WorthItSpacing.s) {
                ZStack {
                    if isLocked {
                        Circle()
                            .fill(WorthItColor.surfaceContainerLow.opacity(0.50))
                            .overlay {
                                Circle().stroke(WorthItColor.outlineSelected, lineWidth: 1)
                            }
                            .frame(width: progressBadgeSize, height: progressBadgeSize)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(WorthItColor.textTertiary.opacity(0.55))
                    } else if !isEarned {
                        WIAchievementProgressRing(
                            progress: progress,
                            state: .inProgress,
                            lineWidth: 2.5,
                            trackColor: WorthItColor.primaryContainer.opacity(0.42),
                            progressColor: WorthItColor.primaryContainer,
                            showsPulse: true,
                            pulseSpeed: 1.75,
                            sweepLineScale: 0.26,
                            initialFillDelay: .zero
                        ) {
                            Image(AchievementGlyph.assetName(for: achievement.medalGlyph))
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(WorthItColor.primaryContainer)
                                .frame(width: 20, height: 20)
                        }
                        .frame(width: progressBadgeSize, height: progressBadgeSize)
                    } else {
                        AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: badgeState, size: earnedBadgeSize)
                    }
                }
                .frame(width: nodeFrameSize, height: nodeFrameSize)

                Text(achievement.title)
                    .font(.system(size: 10, weight: isEarned ? .semibold : .medium))
                    .foregroundStyle(isLocked ? WorthItColor.textTertiary.opacity(0.42) : WorthItColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30, alignment: .top)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .opacity(isLocked ? 0.72 : 1)
    }
}
