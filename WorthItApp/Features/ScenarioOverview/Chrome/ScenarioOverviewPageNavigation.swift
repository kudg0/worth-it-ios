import SwiftUI

extension ScenarioOverviewView {
    func openExpensesPage() {
        contentTransitionDirection = tabTransitionDirection(from: selectedTab, to: .expenses)
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .expenses
            scenarioTabPath = []
        }
    }

    func openMileagePage() {
        contentTransitionDirection = tabTransitionDirection(from: selectedTab, to: .mileage)
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .mileage
            scenarioTabPath = []
        }
    }
}
