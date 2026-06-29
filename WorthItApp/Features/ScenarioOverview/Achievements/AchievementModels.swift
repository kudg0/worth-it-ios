import Foundation

struct AchievementTier: Decodable, Hashable {
    let label: String
    let targetValue: Double
    let level: Int
    let isRequired: Bool
}

enum AchievementLevelStatus: String, Decodable, Hashable {
    case completed
    case current
    case locked
}

struct AchievementProgress: Decodable, Identifiable, Hashable {
    var id: String { achievementKey }

    let achievementKey: String
    let title: String
    let description: String
    let category: String
    let scope: String
    let medalGlyph: String
    let tiers: [AchievementTier]
    let level: Int
    let currentLevel: Int
    let levelStatus: AchievementLevelStatus
    let isLevelUnlocked: Bool
    let currentLevelEarned: Int
    let currentLevelTotal: Int
    let currentLevelProgress: Double
    let currentValue: Double
    let nextTargetValue: Double?
    let currentTierIndex: Int?
    let earnedTierIndex: Int?
    let earnedAt: Date?
    let progress: Double
    let gameCenterAchievementId: String?
    let gameCenterReportPercent: Double?
    let sourceScenarioId: UUID?
}

struct AchievementAward: Decodable, Identifiable, Hashable {
    let id: UUID
    let achievementKey: String
    let tierIndex: Int
    let tierLabel: String
    let sourceScenarioId: UUID?
    let gameCenterAchievementId: String?
    let gameCenterReportedAt: Date?
    let awardedAt: Date
}

struct AchievementCategorySummary: Identifiable, Hashable {
    let id: String
    let title: String
    let systemIcon: String
    let earned: Int
    let total: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(earned) / Double(total)
    }
}

struct AchievementLevelSummary: Identifiable, Hashable {
    let id: Int
    let earned: Int
    let total: Int
    let isUnlocked: Bool

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(earned) / Double(total)
    }
}

extension AchievementProgress {
    var isEarned: Bool {
        earnedTierIndex != nil
    }

    var isInProgress: Bool {
        !isEarned && currentValue > 0
    }

    var earnedCount: Int {
        guard let earnedTierIndex else { return 0 }
        return earnedTierIndex + 1
    }

    var totalTierCount: Int {
        tiers.count
    }

    var displayProgress: Double {
        min(max(progress, 0), 1)
    }

    var nextTierProgress: Double {
        guard let nextTargetValue, nextTargetValue > 0 else {
            return isEarned ? 1 : 0
        }

        return min(max(currentValue / nextTargetValue, 0), 1)
    }

    var nextTierLabel: String {
        guard let currentTierIndex, tiers.indices.contains(currentTierIndex) else {
            return tiers.last?.label ?? ""
        }

        return tiers[currentTierIndex].label
    }

    func tierIndex(in level: Int) -> Int? {
        tiers.firstIndex { $0.level == level }
    }

    func tierLabel(in level: Int) -> String {
        guard let index = tierIndex(in: level), tiers.indices.contains(index) else {
            return nextTierLabel
        }

        return tiers[index].label
    }

    func tierProgress(in level: Int) -> Double {
        guard let index = tierIndex(in: level), tiers.indices.contains(index) else {
            return nextTierProgress
        }

        let targetValue = tiers[index].targetValue
        guard targetValue > 0 else {
            return isTierEarned(in: level) ? 1 : 0
        }

        return min(max(currentValue / targetValue, 0), 1)
    }

    func hasRequiredTier(in level: Int) -> Bool {
        tiers.contains { $0.level == level && $0.isRequired }
    }

    func hasTier(in level: Int) -> Bool {
        tiers.contains { $0.level == level }
    }

    func isRequiredTierEarned(in level: Int) -> Bool {
        tiers.enumerated().contains { index, tier in
            tier.level == level && tier.isRequired && (earnedTierIndex ?? -1) >= index
        }
    }

    func isTierEarned(in level: Int) -> Bool {
        tiers.enumerated().contains { index, tier in
            tier.level == level && (earnedTierIndex ?? -1) >= index
        }
    }
}
