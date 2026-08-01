import SwiftUI

struct AchievementDetailScreen: View {
    @Environment(\.i18n) private var i18n
    let achievement: AchievementProgress
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    var similarAchievements: [AchievementProgress] = []
    var showsLocalHeader = true
    let onClose: () -> Void
    var onOpenSimilarAchievement: (AchievementProgress) -> Void = { _ in }
    private var isEarned: Bool {
        isLevelUnlocked && achievement.isTierEarned(in: selectedLevel)
    }
    private var progress: Double {
        isLevelUnlocked ? achievement.tierProgress(in: selectedLevel) : 0
    }
    private var targetValue: Double {
        guard let index = achievement.tierIndex(in: selectedLevel),
              achievement.tiers.indices.contains(index)
        else {
            return achievement.nextTargetValue ?? 0
        }

        return achievement.tiers[index].targetValue
    }
    private var remainingValue: Double {
        max(0, targetValue - achievement.currentValue)
    }

    private var ringState: WIAchievementRingState {
        if !isLevelUnlocked { return .locked }
        return isEarned ? .earned : .inProgress
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: WorthItSpacing.xxxxl) {
                    Color.clear
                        .frame(height: 0)
                        .id(ScrollAnchor.top)

                    if showsLocalHeader {
                        header
                    }
                    hero
                    titleBlock
                    requirementCard
                    progressDetails
                    similarAchievementsSection
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.top, showsLocalHeader ? WorthItSpacing.xxxxl + WorthItSpacing.xl : WorthItSpacing.xl)
                .padding(.bottom, 132)
            }
            .scrollIndicators(.hidden)
            .onChange(of: achievement.achievementKey) {
                withAnimation(.easeInOut(duration: 0.28)) {
                    proxy.scrollTo(ScrollAnchor.top, anchor: .top)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceContainerLow, in: Circle())
            }
            .buttonStyle(.plain)
            Spacer()
            Button {} label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceContainerLow, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var hero: some View {
        WIAchievementProgressRing(
            progress: progress,
            state: ringState,
            lineWidth: 8,
            trackColor: isLevelUnlocked ? WorthItColor.primaryContainer.opacity(0.58) : WorthItColor.textTertiary.opacity(0.56),
            progressColor: isEarned ? WorthItColor.accentGoldBright : WorthItColor.primaryContainer,
            showsPulse: isLevelUnlocked && !isEarned,
            pulseSpeed: 1.48,
            sweepLineScale: 0.34
        ) {
            VStack(spacing: WorthItSpacing.s) {
                Text(achievement.title)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, WorthItSpacing.xl)

                if isLevelUnlocked {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(isEarned ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                        .monospacedDigit()
                    Text(progressPillText)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(WorthItColor.textPrimary)
                        .padding(.horizontal, WorthItSpacing.m)
                        .padding(.vertical, WorthItSpacing.s)
                        .background(WorthItColor.surfaceContainerHigh.opacity(0.80), in: Capsule())
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.88))
                        .frame(width: 64, height: 64)
                        .background(WorthItColor.surfaceContainerHigh.opacity(0.72), in: Circle())

                    Text(i18n.t(.achievements.detail.status.levelLockedFormat, selectedLevel))
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .padding(.horizontal, WorthItSpacing.m)
                        .padding(.vertical, WorthItSpacing.s)
                        .background(WorthItColor.surfaceContainerHigh.opacity(0.80), in: Capsule())
                }
            }
        }
        .frame(width: 280, height: 280)
        .frame(maxWidth: .infinity)
    }

    private var titleBlock: some View {
        VStack(spacing: WorthItSpacing.m) {
            Text(achievement.title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(achievement.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, WorthItSpacing.xl)
    }

    private var requirementCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(spacing: WorthItSpacing.m) {
                AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: badgeState, size: 36)

                Text(requirementTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WorthItColor.textPrimary)
            }
            Divider().overlay(WorthItColor.surfaceContainerHigh)
            Text(requirementBody)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(3)
        }
        .padding(WorthItSpacing.xl)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSelected, lineWidth: 1)
        }
    }

    private var similarAchievementsSection: some View {
        Group {
            if !similarAchievements.isEmpty {
                VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                    Text(i18n.t(.achievements.detail.similar.title))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    VStack(spacing: WorthItSpacing.s) {
                        ForEach(similarAchievements.prefix(3)) { item in
                            AchievementDetailSimilarRow(
                                achievement: item,
                                selectedLevel: selectedLevel,
                                isLevelUnlocked: isLevelUnlocked,
                                onOpen: onOpenSimilarAchievement
                            )
                        }
                    }
                }
                .padding(WorthItSpacing.xl)
                .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            }
        }
    }

    private var progressDetails: some View {
        Group {
            if isLevelUnlocked {
                AchievementDetailValueGrid(
                    currentTitle: i18n.t(.achievements.detail.stats.current),
                    neededTitle: i18n.t(.achievements.detail.stats.needed),
                    leftTitle: i18n.t(.achievements.detail.stats.left),
                    current: achievement.currentValue,
                    target: targetValue,
                    remaining: remainingValue
                )
            } else {
                AchievementLockedLevelNotice(level: selectedLevel)
            }
        }
    }

    private var progressPillText: String {
        if isEarned { return i18n.t(.achievements.detail.progressPill.earned) }
        return i18n.t(
            .achievements.detail.progressPill.valueFormat,
            AchievementValueFormatter.text(achievement.currentValue),
            AchievementValueFormatter.text(targetValue)
        )
    }

    private var badgeState: AchievementBadgeState {
        if !isLevelUnlocked { return .locked }
        return isEarned ? .earned : .inProgress
    }

    private var requirementTitle: String {
        if !isLevelUnlocked { return i18n.t(.achievements.detail.requirement.unlockLevelFormat, selectedLevel) }
        if isEarned { return i18n.t(.achievements.detail.requirement.achievementReached) }
        return i18n.t(.achievements.detail.requirement.reachFormat, achievement.tierLabel(in: selectedLevel))
    }

    private var requirementBody: String {
        if !isLevelUnlocked {
            return i18n.t(.achievements.detail.body.unlockLevelFirstFormat, selectedLevel)
        }
        if isEarned {
            return i18n.t(.achievements.detail.body.earnedFormat, achievement.tierLabel(in: selectedLevel))
        }
        return i18n.t(
            .achievements.detail.body.progressFormat,
            AchievementValueFormatter.text(achievement.currentValue),
            AchievementValueFormatter.text(targetValue),
            AchievementValueFormatter.text(remainingValue)
        )
    }
}

private enum ScrollAnchor {
    case top
}

private struct AchievementLockedLevelNotice: View {
    @Environment(\.i18n) private var i18n

    let level: Int

    var body: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 32, height: 32)
                .background(WorthItColor.surfaceContainerHigh.opacity(0.72), in: Circle())

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(i18n.t(.achievements.detail.notice.levelRequiredFormat, level))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(i18n.t(.achievements.detail.body.unlockLevelFirstFormat, level))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}

private struct AchievementDetailSimilarRow: View {
    @Environment(\.i18n) private var i18n

    let achievement: AchievementProgress
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    let onOpen: (AchievementProgress) -> Void

    private var isEarnedOnCurrentLevel: Bool {
        isLevelUnlocked && achievement.isTierEarned(in: selectedLevel)
    }

    var body: some View {
        Button {
            onOpen(achievement)
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                AchievementBadgeImage(medalGlyph: achievement.medalGlyph, state: badgeState, size: 36)

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(achievement.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(statusText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WorthItColor.textTertiary)
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
}
