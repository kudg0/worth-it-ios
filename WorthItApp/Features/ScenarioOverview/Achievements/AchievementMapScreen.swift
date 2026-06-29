import SwiftUI

struct AchievementMapScreen: View {
    @Environment(\.i18n) private var i18n

    let scenario: ScenarioListItem
    let levels: [AchievementLevelSummary]
    @Binding var selectedLevel: Int
    let categorySummaries: [AchievementCategorySummary]
    let achievements: [AchievementProgress]
    let isLevelUnlocked: Bool
    let initialCategory: String?
    var showsLocalHeader = true
    let onClose: () -> Void
    let onOpenAchievement: (AchievementProgress) -> Void

    private var selectedLevelSummary: AchievementLevelSummary {
        levels.first { $0.id == selectedLevel } ?? AchievementLevelSummary(
            id: selectedLevel,
            earned: 0,
            total: 0,
            isUnlocked: selectedLevel <= (levels.first { $0.isUnlocked }?.id ?? 1)
        )
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
                    if showsLocalHeader {
                        header
                    }
                    summaryCard
                    levelTabs
                    lanes
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.top, showsLocalHeader ? WorthItSpacing.xxxxl + WorthItSpacing.xl : WorthItSpacing.xl)
                .padding(.bottom, 132)
            }
            .scrollIndicators(.hidden)
            .task(id: initialCategory) {
                guard let initialCategory else { return }
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.smooth(duration: 0.35)) {
                    proxy.scrollTo(initialCategory, anchor: .top)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: WorthItSpacing.m) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceContainerLow, in: Circle())
            }
            .buttonStyle(.plain)

            VStack(spacing: WorthItSpacing.xs) {
                Text(i18n.t("Achievement Map"))
                    .font(.system(size: 14, weight: .bold))
                    .tracking(0.7)
                    .textCase(.uppercase)
                    .foregroundStyle(WorthItColor.primaryContainer)
            }
            .frame(maxWidth: .infinity)

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

    private var summaryCard: some View {
        HStack(spacing: WorthItSpacing.m) {
            WIAchievementProgressRing(
                progress: selectedLevelSummary.isUnlocked ? selectedLevelSummary.progress : 0,
                lineWidth: 4,
                trackColor: selectedLevelSummary.isUnlocked ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.56),
                progressColor: selectedLevelSummary.isUnlocked ? WorthItColor.accentGoldBright : WorthItColor.textTertiary.opacity(0.56),
                showsPulse: false,
                initialFillDelay: .zero
            ) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text("\(selectedLevelSummary.earned)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WorthItColor.accentGold)
                    Text("/\(selectedLevelSummary.total)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                }
                .monospacedDigit()
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(i18n.t("Total Progress"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                Text(i18n.t("Mastery Level \(selectedLevel)"))
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(WorthItColor.primaryContainer)
            }

            Spacer()

            Image(systemName: "info.circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 32, height: 32)
                .background(WorthItColor.surfaceLowest, in: Circle())
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private var levelTabs: some View {
        WISegmentedControl(
            items: levels.map { (title: i18n.t("Level \($0.id)"), value: $0.id) },
            selection: $selectedLevel,
            layout: .scroll
        )
    }

    private var lanes: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            ForEach(categorySummaries) { summary in
                AchievementMapLane(
                    summary: summary,
                    achievements: categoryItems(for: summary.id),
                    selectedLevel: selectedLevel,
                    isLevelUnlocked: isLevelUnlocked,
                    onOpenAchievement: onOpenAchievement
                )
                .id(summary.id)
            }
        }
    }

    private func categoryItems(for category: String) -> [AchievementProgress] {
        achievements
            .filter { $0.category == category }
            .sorted { $0.tierProgress(in: selectedLevel) > $1.tierProgress(in: selectedLevel) }
    }
}
