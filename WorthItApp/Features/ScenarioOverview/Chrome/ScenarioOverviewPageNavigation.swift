import SwiftUI

extension ScenarioOverviewView {
    func openExpensesPage() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .expenses
            scenarioTabPath = []
        }
    }

    func openMileagePage() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .mileage
            scenarioTabPath = []
        }
    }
}
