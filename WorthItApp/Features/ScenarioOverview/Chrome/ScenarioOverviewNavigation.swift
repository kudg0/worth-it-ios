import SwiftUI

extension ScenarioOverviewView {
    var topBarTitle: String {
        switch selectedTab {
        case .addEntryChooser:
            "Add Entry"
        case .addComparableOption:
            "Comparable Editor"
        case .analyticsSettings:
            "Analytics Model"
        case .comparisonSettings:
            "Comparison Options"
        case .logExpense:
            editingCostEvent == nil ? "Log Expense" : "Edit Expense"
        case .scheduleService:
            editingScheduledService == nil ? "Schedule Service" : "Edit Service"
        case .expenseHistory:
            "Expense History"
        case .mileageHistory:
            "Mileage History"
        case .mileageDetail:
            "Trip Detail"
        case .metricDetail:
            selectedDetailMetricSlide?.title ?? "Metric Detail"
        case .logMileage:
            editingUsageEvent == nil ? "Log Mileage" : "Edit Mileage"
        case .settings:
            "Scenario Settings"
        default:
            activeScenario.name
        }
    }

    var topBarTitleColor: Color {
        isEntryFlowScreen ? WorthItColor.primaryContainer : WorthItColor.textSecondary
    }

    var isEntryFlowScreen: Bool {
        selectedTab == .addEntryChooser || selectedTab == .addComparableOption || selectedTab == .analyticsSettings || selectedTab == .comparisonSettings || selectedTab == .logExpense || selectedTab == .scheduleService || selectedTab == .expenseHistory || selectedTab == .mileageHistory || selectedTab == .mileageDetail || selectedTab == .metricDetail || selectedTab == .logMileage
    }

    var showsScenarioNavigation: Bool {
        selectedTab != .addEntryChooser && selectedTab != .addComparableOption && selectedTab != .analyticsSettings && selectedTab != .comparisonSettings && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .expenseHistory && selectedTab != .mileageHistory && selectedTab != .mileageDetail && selectedTab != .metricDetail && selectedTab != .logMileage
            && selectedTab != .settings
    }

    var showsBottomNav: Bool {
        selectedTab != .addEntryChooser && selectedTab != .addComparableOption && selectedTab != .analyticsSettings && selectedTab != .comparisonSettings && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .mileageDetail && selectedTab != .metricDetail && selectedTab != .logMileage
    }

    var scrollBottomPadding: CGFloat {
        switch selectedTab {
        case .mileage, .logExpense, .scheduleService, .logMileage, .addComparableOption, .analyticsSettings, .comparisonSettings:
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
                pushScenarioTab(selectedTab == .settings ? .overview : selectedTab)
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
            if selectedTab == .mileageDetail {
                selectedMileageDetailId = nil
            }
            selectedTab = previousTab
        }
    }

    func openMileageDetail(_ usageEventId: UUID) {
        guard let item = mileageLogItems.first(where: { $0.id == usageEventId }) else { return }
        guard item.kind == .trip else {
            beginEditingMileage(usageEventId)
            return
        }

        selectedMileageDetailId = usageEventId

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .mileageDetail
        }
    }

    func editSelectedMileageDetail() {
        guard let selectedMileageDetailId else { return }
        beginEditingMileage(selectedMileageDetailId)
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
        resetComparableForm()
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

    func beginEditingComparable(_ alternativeId: UUID) {
        guard let alternative = alternatives.first(where: { $0.id == alternativeId }) else { return }
        editingAlternative = alternative
        comparableName = alternative.name
        comparablePricingModel = editablePricingMode(for: alternative)
        comparablePricePerKm = alternative.paramsJson.pricePerKm.map(formatEditableNumber) ?? ""
        comparablePricePerMinute = alternative.paramsJson.pricePerMinute.map(formatEditableNumber) ?? ""
        comparableCurvePoints = curvePoints(for: alternative)
        comparablePricePerMonth = alternative.paramsJson.pricePerMonth.map(formatEditableNumber) ?? ""
        comparableManualTotal = alternative.paramsJson.value.map(formatEditableNumber) ?? ""
        comparableNote = alternative.note ?? ""
        comparableInheritedCostCategories = Set(alternative.paramsJson.includedCostCategories ?? [])
        isComparableIncluded = alternative.isIncluded

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.compare]
            selectedTab = .addComparableOption
        }
    }

    func openComparableInCompare(_ alternativeId: UUID) {
        guard alternatives.contains(where: { $0.id == alternativeId }) else { return }

        withAnimation(.easeInOut(duration: 0.20)) {
            focusedComparableId = alternativeId
            selectedMileageDetailId = nil
            scenarioTabPath = []
            selectedTab = .compare
        }
    }

    func resetComparableForm() {
        editingAlternative = nil
        comparableName = ""
        comparablePricingModel = .distanceCurve
        comparablePricePerKm = ""
        comparablePricePerMinute = ""
        comparableCurvePoints = Self.emptyComparableCurvePoints()
        comparablePricePerMonth = ""
        comparableManualTotal = ""
        comparableNote = ""
        comparableInheritedCostCategories = []
        isComparableIncluded = true
    }

    func editablePricingMode(for alternative: AlternativeOption) -> AlternativePricingMode {
        switch alternative.pricingMode {
        case .perDistance, .distanceCurve, .perPeriod, .mixed, .manualEquivalent:
            alternative.pricingMode
        case .perTime:
            .manualEquivalent
        }
    }

    func curvePoints(for alternative: AlternativeOption) -> [ComparableCurveInputPoint] {
        let points = (alternative.paramsJson.pricePoints ?? [])
            .sorted { $0.distanceKm < $1.distanceKm }
            .map {
                ComparableCurveInputPoint(
                    distanceKm: formatEditableNumber($0.distanceKm),
                    totalPrice: formatEditableNumber($0.totalPrice)
                )
            }

        return points.isEmpty ? Self.emptyComparableCurvePoints() : points
    }

    static func emptyComparableCurvePoints() -> [ComparableCurveInputPoint] {
        [
            ComparableCurveInputPoint(),
            ComparableCurveInputPoint()
        ]
    }

    func openScenarioHome() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .overview
            scenarioTabPath = []
        }
    }

    func openSettings() {
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .settings
            scenarioTabPath = []
        }
    }

    func openComparisonSettings() {
        comparisonVisibleAlternativeIds = Set(alternatives.filter(\.isIncluded).map(\.id))

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .comparisonSettings
        }
    }

    func openMetricDetail(_ metric: OverviewMetric) {
        if metric == .totalExpenses {
            openExpenseHistory()
            return
        }

        if metric == .monthlyCost {
            openExpenseHistory(monthStart: currentMonthStart)
            return
        }

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
