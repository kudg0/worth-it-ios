import SwiftUI

struct AchievementDetailScreen: View {
    @Environment(\.i18n) private var i18n
    let achievement: AchievementProgress
    let selectedLevel: Int
    let isLevelUnlocked: Bool
    var showsLocalHeader = true
    let onClose: () -> Void
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

    var body: some View {
        ScrollView {
            VStack(spacing: WorthItSpacing.xxxxl) {
                if showsLocalHeader {
                    header
                }
                hero
                titleBlock
                tierRail
                requirementCard
                detailGrid
            }
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, showsLocalHeader ? WorthItSpacing.xxxxl + WorthItSpacing.xl : WorthItSpacing.xl)
            .padding(.bottom, 132)
        }
        .scrollIndicators(.hidden)
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
            lineWidth: 8,
            trackColor: isLevelUnlocked ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.56),
            progressColor: isLevelUnlocked ? WorthItColor.accentGoldBright : WorthItColor.textTertiary.opacity(0.56),
            showsPulse: isLevelUnlocked && !isEarned
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
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(isLevelUnlocked ? WorthItColor.accentGold : WorthItColor.textTertiary)
                    .monospacedDigit()
                Text(progressPillText)
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(WorthItColor.textPrimary)
                    .padding(.horizontal, WorthItSpacing.m)
                    .padding(.vertical, WorthItSpacing.s)
                    .background(WorthItColor.surfaceContainerHigh.opacity(0.80), in: Capsule())
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

    private var tierRail: some View {
        HStack(spacing: WorthItSpacing.s) {
            ForEach(achievement.tiers.indices, id: \.self) { index in
                Capsule()
                    .fill(tierColor(index))
                    .frame(height: 4)
            }
        }
        .opacity(0.72)
    }

    private var requirementCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: isEarned ? "checkmark.seal.fill" : "lock.open.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isEarned ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                    .frame(width: 32, height: 32)
                    .background((isEarned ? WorthItColor.accentGold : WorthItColor.primaryContainer).opacity(0.10), in: Circle())
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

    private var detailGrid: some View {
        AchievementDetailValueGrid(
            currentTitle: i18n.t("Current"),
            neededTitle: i18n.t("Needed"),
            leftTitle: i18n.t("Left"),
            current: achievement.currentValue,
            target: targetValue,
            remaining: remainingValue
        )
    }

    private var progressPillText: String {
        if isEarned { return i18n.t("Achievement earned") }
        return i18n.t("\(AchievementValueFormatter.text(achievement.currentValue)) of \(AchievementValueFormatter.text(targetValue))")
    }

    private var requirementTitle: String {
        if isEarned { return i18n.t("Achievement reached") }
        return i18n.t("Reach \(achievement.tierLabel(in: selectedLevel))")
    }

    private var requirementBody: String {
        if !isLevelUnlocked {
            return i18n.t("Unlock this level first, then this achievement can start progressing.")
        }
        if isEarned {
            return i18n.t("You have reached \(achievement.tierLabel(in: selectedLevel)) for this achievement.")
        }
        return i18n.t("Current progress is \(AchievementValueFormatter.text(achievement.currentValue)). Reach \(AchievementValueFormatter.text(targetValue)) to earn this achievement. \(AchievementValueFormatter.text(remainingValue)) left.")
    }

    private func tierColor(_ index: Int) -> Color {
        guard achievement.tiers.indices.contains(index) else { return WorthItColor.surfaceContainerHigh }
        if (achievement.earnedTierIndex ?? -1) >= index { return WorthItColor.accentGold }
        if achievement.tiers[index].level == selectedLevel { return WorthItColor.primaryContainer }
        return WorthItColor.surfaceContainerHigh
    }
}
