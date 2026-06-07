import SwiftUI

extension ScenarioOverviewView {
    var topBarTitle: String {
        switch selectedTab {
        case .addEntryChooser:
            "Add Entry"
        case .addComparableOption:
            "Comparable Editor"
        case .logExpense:
            editingCostEvent == nil ? "Log Expense" : "Edit Expense"
        case .scheduleService:
            editingScheduledService == nil ? "Schedule Service" : "Edit Service"
        case .expenseHistory:
            "Expense History"
        case .mileageHistory:
            "Mileage History"
        case .metricDetail:
            selectedDetailMetricSlide?.title ?? "Metric Detail"
        case .logMileage:
            editingUsageEvent == nil ? "Log Mileage" : "Edit Mileage"
        default:
            activeScenario.name
        }
    }

    var topBarTitleColor: Color {
        isEntryFlowScreen ? WorthItColor.primaryContainer : WorthItColor.textSecondary
    }

    var isEntryFlowScreen: Bool {
        selectedTab == .addEntryChooser || selectedTab == .addComparableOption || selectedTab == .logExpense || selectedTab == .scheduleService || selectedTab == .expenseHistory || selectedTab == .mileageHistory || selectedTab == .metricDetail || selectedTab == .logMileage
    }

    var showsScenarioNavigation: Bool {
        selectedTab != .addEntryChooser && selectedTab != .addComparableOption && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .expenseHistory && selectedTab != .mileageHistory && selectedTab != .metricDetail && selectedTab != .logMileage
    }

    var showsBottomNav: Bool {
        selectedTab != .addEntryChooser && selectedTab != .addComparableOption && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .metricDetail && selectedTab != .logMileage
    }

    var scrollBottomPadding: CGFloat {
        switch selectedTab {
        case .mileage, .logExpense, .scheduleService, .logMileage, .addComparableOption:
            224
        default:
            132
        }
    }

    var canGoBackInScenario: Bool {
        selectedTab != .overview && !scenarioTabPath.isEmpty
    }

    func navigateScenarioTab(_ tab: ScenarioTab) {
        guard selectedTab != tab else { return }

        withAnimation(.easeInOut(duration: 0.20)) {
            if tab == .overview {
                scenarioTabPath = []
            } else {
                pushScenarioTab(selectedTab == .profile ? .overview : selectedTab)
            }

            selectedTab = tab
        }
    }

    func pushScenarioTab(_ tab: ScenarioTab) {
        scenarioTabPath = ScenarioOverviewNavigationPath.pushed(scenarioTabPath, tab: tab)
    }

    func popScenarioTab() {
        let result = ScenarioOverviewNavigationPath.popped(scenarioTabPath)
        guard let previousTab = result.tab else { return }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = result.path
            if selectedTab == .logExpense {
                editingCostEvent = nil
            }
            if selectedTab == .logMileage {
                resetMileageForm()
            }
            selectedTab = previousTab
        }
    }

    func openAddEntryChooserFromOverview() {
        resetEntryEditingState()

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.overview]
            selectedTab = .addEntryChooser
        }
    }

    func openAddEntryChooserFromMaintenance() {
        resetEntryEditingState()

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.expenses]
            selectedTab = .addEntryChooser
        }
    }

    func openAddComparableOption() {
        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.compare]
            selectedTab = .addComparableOption
        }
    }

    func closeComparableEditor() {
        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = []
            selectedTab = .compare
        }
    }

    func openScenarioHome() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .overview
            scenarioTabPath = []
        }
    }

    func openProfile() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .profile
            scenarioTabPath = []
        }
    }

    func openMetricDetail(_ metric: OverviewMetric) {
        selectedDetailMetric = metric
        selectedMetricTrendDate = nil
        selectedMetricTrendRange = .oneYear

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.overview]
            selectedTab = .metricDetail
        }
    }

    func openExpenseHistory(focusedOn expenseId: UUID? = nil, monthStart: Date? = nil) {
        focusedExpenseId = expenseId
        focusedMileageId = nil
        expenseHistoryFilter = .all

        if let expenseId, let event = costEvents.first(where: { $0.id == expenseId }) {
            let monthStart = expenseHistoryMonthStart(for: event.date)
            focusedExpenseHistoryMonthStart = monthStart
            selectedExpenseHistoryBarLabel = expenseHistoryMonthIdentifier(for: monthStart)
        } else if let monthStart {
            focusedExpenseHistoryMonthStart = monthStart
            selectedExpenseHistoryBarLabel = expenseHistoryMonthIdentifier(for: monthStart)
        } else if expenseId == nil {
            focusedExpenseHistoryMonthStart = nil
            selectedExpenseHistoryBarLabel = nil
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .expenseHistory
        }
    }

    func openMileageHistory(focusedOn mileageId: UUID? = nil, monthStart: Date? = nil) {
        focusedMileageId = mileageId
        focusedExpenseId = nil

        if let mileageId, let item = mileageLogItems.first(where: { $0.id == mileageId }) {
            let monthStart = expenseHistoryMonthStart(for: item.date)
            focusedMileageHistoryMonthStart = monthStart
            selectedMileageHistoryBarLabel = expenseHistoryMonthIdentifier(for: monthStart)
        } else if let monthStart {
            focusedMileageHistoryMonthStart = monthStart
            selectedMileageHistoryBarLabel = expenseHistoryMonthIdentifier(for: monthStart)
        } else if mileageId == nil {
            focusedMileageHistoryMonthStart = nil
            selectedMileageHistoryBarLabel = nil
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .mileageHistory
        }
    }
}
