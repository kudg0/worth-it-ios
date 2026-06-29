enum AchievementNavigationRoute: Equatable {
    case hub
    case map(initialCategory: String?)
    case detail(achievementKey: String, title: String, returnCategory: String?)
}
