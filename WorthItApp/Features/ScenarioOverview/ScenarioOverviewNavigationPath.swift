struct ScenarioOverviewNavigationPath {
    static func pushed<T: Equatable>(_ path: [T], tab: T) -> [T] {
        guard path.last != tab else { return path }
        return path + [tab]
    }

    static func popped<T>(_ path: [T]) -> (tab: T?, path: [T]) {
        var nextPath = path
        return (nextPath.popLast(), nextPath)
    }
}
