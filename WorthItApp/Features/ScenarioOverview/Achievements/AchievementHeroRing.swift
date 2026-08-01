import SwiftUI

struct AchievementHeroRing: View {
    let levels: [AchievementLevelSummary]
    @Binding var selectedLevel: Int
    var onOpenLevel: () -> Void = {}

    private enum Layout {
        static let ringSize: CGFloat = 256
        static let glowSafeSize: CGFloat = 316
    }

    var body: some View {
        VStack(spacing: WorthItSpacing.l) {
            TabView(selection: $selectedLevel) {
                ForEach(levels) { level in
                    Button(action: onOpenLevel) {
                        AchievementHeroRingPage(level: level, ringSize: Layout.ringSize, glowSafeSize: Layout.glowSafeSize)
                    }
                    .buttonStyle(.plain)
                    .tag(level.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: Layout.glowSafeSize)

            HStack(spacing: WorthItSpacing.s) {
                ForEach(levels) { level in
                    Capsule()
                        .fill(level.id == selectedLevel ? WorthItColor.primaryContainer : WorthItColor.surfaceContainerHigh)
                        .frame(width: level.id == selectedLevel ? 18 : 6, height: 6)
                        .animation(.smooth(duration: 0.2), value: selectedLevel)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, WorthItSpacing.xxxl)
    }
}

private struct AchievementHeroRingPage: View {
    @Environment(\.i18n) private var i18n

    let level: AchievementLevelSummary
    let ringSize: CGFloat
    let glowSafeSize: CGFloat

    private var progress: Double {
        level.isUnlocked ? level.progress : 0
    }

    private var isAchieved: Bool {
        level.isUnlocked && level.total > 0 && level.earned >= level.total
    }

    private var ringState: WIAchievementRingState {
        if !level.isUnlocked { return .locked }
        return isAchieved ? .earned : .inProgress
    }

    var body: some View {
        WIAchievementProgressRing(
            progress: progress,
            state: ringState,
            lineWidth: 14,
            trackColor: level.isUnlocked ? WorthItColor.primaryContainer.opacity(0.58) : WorthItColor.textTertiary.opacity(0.62),
            progressColor: isAchieved ? WorthItColor.accentGoldBright : WorthItColor.primaryContainer,
            showsPulse: level.isUnlocked && !isAchieved,
            pulseSpeed: 1.55,
            sweepLineScale: 0.30
        ) {
            VStack(spacing: WorthItSpacing.s) {
                Text(i18n.t(.achievements.levelRing.labelFormat, level.id))
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(level.isUnlocked ? WorthItColor.primaryContainer : WorthItColor.textTertiary)

                if level.isUnlocked {
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(level.earned)")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(isAchieved ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                            .monospacedDigit()

                        Text("/\(max(level.total, 0))")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .monospacedDigit()
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .frame(height: 58)
                }

                Text(statusText)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1)
                    .foregroundStyle(level.isUnlocked ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
            }
        }
        .frame(width: ringSize, height: ringSize)
        .frame(width: glowSafeSize, height: glowSafeSize)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if isAchieved {
            return i18n.t(.achievements.levelRing.accessibility.achievedFormat, level.id, level.earned, level.total)
        }

        if level.isUnlocked {
            return i18n.t(.achievements.levelRing.accessibility.progressFormat, level.id, level.earned, level.total)
        }

        return i18n.t(.achievements.levelRing.accessibility.lockedFormat, level.id)
    }

    private var statusText: String {
        if !level.isUnlocked { return i18n.t(.achievements.levelRing.status.locked) }
        return isAchieved ? i18n.t(.achievements.levelRing.status.achieved) : i18n.t(.achievements.levelRing.status.inProgress)
    }
}
