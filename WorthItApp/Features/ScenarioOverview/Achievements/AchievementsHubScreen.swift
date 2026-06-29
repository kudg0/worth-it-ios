import SwiftUI

struct AchievementsHubScreen: View {
    @Environment(\.i18n) private var i18n

    let repository: ScenarioRepository
    let scenario: ScenarioListItem
    @Binding var route: AchievementNavigationRoute

    @State private var achievements: [AchievementProgress] = []
    @State private var selectedLevel = 1
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var currentLevel: Int {
        achievements.first?.currentLevel ?? 1
    }

    private var levelSummaries: [AchievementLevelSummary] {
        let levels = Set(achievements.flatMap { achievement in
            achievement.tiers.filter(\.isRequired).map(\.level)
        })

        return levels.sorted().map { level in
            let milestones = achievements.flatMap { achievement in
                achievement.tiers.enumerated()
                    .filter { _, tier in tier.level == level && tier.isRequired }
                    .map { index, _ in (achievement: achievement, tierIndex: index) }
            }
            let earned = milestones.filter { milestone in
                (milestone.achievement.earnedTierIndex ?? -1) >= milestone.tierIndex
            }.count

            return AchievementLevelSummary(
                id: level,
                earned: earned,
                total: milestones.count,
                isUnlocked: level <= currentLevel
            )
        }
    }

    private var selectedLevelSummary: AchievementLevelSummary {
        levelSummaries.first { $0.id == selectedLevel } ?? AchievementLevelSummary(
            id: selectedLevel,
            earned: 0,
            total: 0,
            isUnlocked: selectedLevel <= currentLevel
        )
    }

    private var selectedLevelAchievements: [AchievementProgress] {
        achievements.filter { $0.hasTier(in: selectedLevel) }
    }

    private var isSelectedLevelUnlocked: Bool {
        selectedLevelSummary.isUnlocked
    }

    private var nextUnlock: AchievementProgress? {
        guard isSelectedLevelUnlocked else { return nil }

        return selectedLevelAchievements
            .filter { $0.hasRequiredTier(in: selectedLevel) }
            .filter { !$0.isRequiredTierEarned(in: selectedLevel) }
            .sorted { $0.tierProgress(in: selectedLevel) > $1.tierProgress(in: selectedLevel) }
            .first
    }

    private var categorySummaries: [AchievementCategorySummary] {
        let groups = Dictionary(grouping: selectedLevelAchievements, by: \.category)
        let preferredOrder = ["costs", "economics", "usage", "tracking", "lifecycle", "comparison", "value", "evidence"]
        return groups.keys.sorted { lhs, rhs in
            let lhsIndex = preferredOrder.firstIndex(of: lhs) ?? preferredOrder.count
            let rhsIndex = preferredOrder.firstIndex(of: rhs) ?? preferredOrder.count
            return lhsIndex == rhsIndex ? lhs < rhs : lhsIndex < rhsIndex
        }
        .map { categorySummary(id: $0, items: groups[$0] ?? []) }
    }

    private var hubContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            AchievementHeroRing(
                levels: levelSummaries,
                selectedLevel: $selectedLevel,
                onOpenLevel: { route = .map(initialCategory: nil) }
            )

            if let nextUnlock {
                AchievementNextUnlockCard(
                    achievement: nextUnlock,
                    selectedLevel: selectedLevel,
                    onOpenAchievement: openAchievementDetail
                )
            }

            AchievementCategoryDashboard(
                summaries: categorySummaries,
                achievements: selectedLevelAchievements,
                selectedLevel: selectedLevel,
                isLevelUnlocked: isSelectedLevelUnlocked,
                onOpenCategory: { route = .map(initialCategory: $0) },
                onOpenAchievement: openAchievementDetail
            )

            if let errorMessage {
                ScenarioLoadErrorCard(
                    title: i18n.t("Achievements unavailable"),
                    message: errorMessage,
                    onRetry: { Task { await loadAchievements() } }
                )
            }
        }
    }

    var body: some View {
        Group {
            switch route {
            case .hub:
                ScrollView {
                    hubContent
                        .padding(.horizontal, WorthItSpacing.xxl)
                        .padding(.top, WorthItSpacing.xxxxl + WorthItSpacing.xl)
                        .padding(.bottom, 132)
                }
                .scrollIndicators(.hidden)
            case .map(let initialCategory):
                AchievementMapScreen(
                    scenario: scenario,
                    levels: levelSummaries,
                    selectedLevel: $selectedLevel,
                    categorySummaries: categorySummaries,
                    achievements: selectedLevelAchievements,
                    isLevelUnlocked: isSelectedLevelUnlocked,
                    initialCategory: initialCategory,
                    showsLocalHeader: false,
                    onClose: { route = .hub },
                    onOpenAchievement: { achievement in
                        route = .detail(
                            achievementKey: achievement.achievementKey,
                            title: achievement.title,
                            returnCategory: achievement.category
                        )
                    }
                )
            case .detail(let achievementKey, _, let returnCategory):
                if let achievement = achievements.first(where: { $0.achievementKey == achievementKey }) {
                    AchievementDetailScreen(
                        achievement: achievement,
                        selectedLevel: selectedLevel,
                        isLevelUnlocked: isSelectedLevelUnlocked,
                        showsLocalHeader: false,
                        onClose: {
                            if let returnCategory {
                                route = .map(initialCategory: returnCategory)
                            } else {
                                route = .hub
                            }
                        }
                    )
                } else {
                    ScenarioLoadErrorCard(
                        title: i18n.t("Achievement unavailable"),
                        message: i18n.t("Open achievements again to refresh this milestone."),
                        onRetry: { route = .map(initialCategory: returnCategory) }
                    )
                    .padding(.horizontal, WorthItSpacing.xxl)
                    .padding(.top, WorthItSpacing.xxxxl + WorthItSpacing.xl)
                }
            }
        }
        .overlay {
            if isLoading && achievements.isEmpty {
                ProgressView()
                    .tint(WorthItColor.primaryContainer)
            }
        }
        .task {
            await loadAchievements()
        }
        .onChange(of: currentLevel) { _, newValue in
            guard selectedLevel == 1 || !levelSummaries.contains(where: { $0.id == selectedLevel }) else {
                return
            }
            selectedLevel = newValue
        }
    }

    private func categorySummary(id: String, items: [AchievementProgress]) -> AchievementCategorySummary {
        return AchievementCategorySummary(
            id: id,
            title: categoryTitle(id),
            systemIcon: categoryIcon(id),
            earned: isSelectedLevelUnlocked ? items.filter { $0.isTierEarned(in: selectedLevel) }.count : 0,
            total: items.count
        )
    }

    private func categoryTitle(_ category: String) -> String {
        switch category {
        case "costs", "economics": i18n.t("Economics")
        case "usage": i18n.t("Usage")
        case "tracking": i18n.t("Consistency")
        case "lifecycle": i18n.t("Lifecycle")
        case "comparison": i18n.t("Alternatives")
        case "value": i18n.t("Value")
        case "evidence": i18n.t("Evidence")
        default: i18n.t("\(category.capitalized)")
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "costs", "economics": "chart.line.downtrend.xyaxis"
        case "usage": "gauge.with.dots.needle.33percent"
        case "tracking": "waveform.path.ecg"
        case "lifecycle": "key.fill"
        case "comparison": "arrow.triangle.branch"
        case "value": "chart.line.uptrend.xyaxis"
        case "evidence": "doc.viewfinder.fill"
        default: "seal.fill"
        }
    }

    private func openAchievementDetail(_ achievement: AchievementProgress) {
        route = .detail(
            achievementKey: achievement.achievementKey,
            title: achievement.title,
            returnCategory: nil
        )
    }

    private func loadAchievements() async {
        isLoading = true
        errorMessage = nil

        do {
            achievements = try await repository.listAchievements()
            selectedLevel = achievements.first?.currentLevel ?? 1
        } catch {
            errorMessage = i18n.t("Open achievements again to refresh ownership milestones.")
        }

        isLoading = false
    }
}
