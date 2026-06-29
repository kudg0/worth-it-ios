import SwiftUI

extension ScenarioOverviewView {
    var topBarTitle: String {
        switch selectedTab {
        case .addEntryChooser:
            "Add Entry"
        case .addComparableOption:
            "Comparable Editor"
        case .chooseComparableOption:
            "Choose Alternative"
        case .analyticsSettings:
            "Analytics Model"
        case .comparisonSettings:
            "Comparison Options"
        case .preferencesSettings:
            "Preferences"
        case .logExpense:
            editingCostEvent == nil ? "Log Expense" : "Edit Expense"
        case .scheduleService:
            editingScheduledService == nil ? "Schedule Service" : "Edit Service"
        case .scheduledServices:
            "Scheduled Services"
        case .scheduledServiceDetail:
            "Service Detail"
        case .expenseDetail:
            "Expense Detail"
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
        case .achievements:
            switch achievementRoute {
            case .hub:
                "Achievements"
            case .map:
                "Achievement Map"
            case .detail(_, let title, _):
                title
            }
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
        selectedTab == .addEntryChooser || selectedTab == .chooseComparableOption || selectedTab == .addComparableOption || selectedTab == .analyticsSettings || selectedTab == .comparisonSettings || selectedTab == .preferencesSettings || selectedTab == .logExpense || selectedTab == .scheduleService || selectedTab == .scheduledServices || selectedTab == .scheduledServiceDetail || selectedTab == .expenseDetail || selectedTab == .expenseHistory || selectedTab == .mileageHistory || selectedTab == .mileageDetail || selectedTab == .metricDetail || selectedTab == .logMileage || isAchievementPushedScreen
    }

    var showsScenarioNavigation: Bool {
        selectedTab != .addEntryChooser && selectedTab != .chooseComparableOption && selectedTab != .addComparableOption && selectedTab != .analyticsSettings && selectedTab != .comparisonSettings && selectedTab != .preferencesSettings && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .scheduledServices && selectedTab != .scheduledServiceDetail && selectedTab != .expenseDetail && selectedTab != .expenseHistory && selectedTab != .mileageHistory && selectedTab != .mileageDetail && selectedTab != .metricDetail && selectedTab != .logMileage
            && selectedTab != .settings && !isAchievementPushedScreen
    }

    var showsBottomNav: Bool {
        selectedTab != .addEntryChooser && selectedTab != .chooseComparableOption && selectedTab != .addComparableOption && selectedTab != .analyticsSettings && selectedTab != .comparisonSettings && selectedTab != .preferencesSettings && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .scheduledServiceDetail && selectedTab != .expenseDetail && selectedTab != .mileageDetail && selectedTab != .metricDetail && selectedTab != .logMileage
            && !isAchievementPushedScreen
    }

    var scrollBottomPadding: CGFloat {
        switch selectedTab {
        case .mileage, .logExpense, .scheduleService, .logMileage, .chooseComparableOption, .addComparableOption, .analyticsSettings, .comparisonSettings, .preferencesSettings:
            224
        default:
            132
        }
    }

    var scenarioContentTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: contentTransitionDirection.insertionEdge).combined(with: .opacity),
            removal: .move(edge: contentTransitionDirection.removalEdge).combined(with: .opacity)
        )
    }

    var comparableFooterTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }

    var canGoBackInScenario: Bool {
        isAchievementPushedScreen || (selectedTab != .overview && !scenarioTabPath.isEmpty)
    }

    var isAchievementPushedScreen: Bool {
        selectedTab == .achievements && achievementRoute != .hub
    }

    func tabTransitionDirection(from currentTab: ScenarioTab, to nextTab: ScenarioTab) -> ScenarioOverviewContentTransitionDirection {
        guard let currentIndex = currentTab.topLevelNavigationIndex,
              let nextIndex = nextTab.topLevelNavigationIndex
        else {
            return .forward
        }

        return nextIndex < currentIndex ? .backward : .forward
    }

    func navigateScenarioTab(_ tab: ScenarioTab) {
        guard selectedTab != tab else { return }

        contentTransitionDirection = tabTransitionDirection(from: selectedTab, to: tab)
        withAnimation(.easeInOut(duration: 0.20)) {
            if tab == .overview {
                scenarioTabPath = []
                achievementRoute = .hub
            } else if tab == .achievements {
                scenarioTabPath = []
                achievementRoute = .hub
            } else {
                pushScenarioTab(selectedTab == .settings ? .overview : selectedTab)
                achievementRoute = .hub
            }

            selectedTab = tab
        }
    }

    func pushScenarioTab(_ tab: ScenarioTab) {
        scenarioTabPath = ScenarioOverviewNavigationPath.pushed(scenarioTabPath, tab: tab)
    }

    func popScenarioTab() {
        if selectedTab == .achievements {
            switch achievementRoute {
            case .hub:
                break
            case .map:
                withAnimation(.smooth(duration: 0.30)) {
                    achievementRoute = .hub
                }
                return
            case .detail(_, _, let returnCategory):
                withAnimation(.smooth(duration: 0.30)) {
                    if let returnCategory {
                        achievementRoute = .map(initialCategory: returnCategory)
                    } else {
                        achievementRoute = .hub
                    }
                }
                return
            }
        }

        let result = ScenarioOverviewNavigationPath.popped(scenarioTabPath)
        guard let previousTab = result.tab else { return }

        contentTransitionDirection = .backward
        withAnimation(.smooth(duration: 0.30)) {
            scenarioTabPath = result.path
            if selectedTab == .logExpense {
                editingCostEvent = nil
            }
            if selectedTab == .logMileage {
                resetMileageForm()
            }
            if selectedTab == .scheduleService {
                resetScheduledServiceForm()
            }
            if selectedTab == .mileageDetail {
                selectedMileageDetailId = nil
            }
            if selectedTab == .scheduledServiceDetail {
                selectedScheduledServiceDetailId = nil
            }
            if selectedTab == .expenseDetail {
                selectedExpenseDetailId = nil
                activeExpenseActionId = nil
                activeExpenseDaySelection = nil
                displayedExpenseDetailWeekStart = nil
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

    func openScheduledServices() {
        displayedScheduledServiceMonth = scheduledServicesInitialMonth
        selectedScheduledServiceDate = nil

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .scheduledServices
        }
    }

    func openScheduledServiceDetail(_ serviceId: UUID) {
        guard upcomingServiceItems.contains(where: { $0.id == serviceId }) else { return }
        selectedScheduledServiceDetailId = serviceId

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .scheduledServiceDetail
        }
    }

    func openExpenseDetail(_ expenseId: UUID) {
        guard let event = costEvents.first(where: { $0.id == expenseId }) else { return }
        selectedExpenseDetailId = expenseId
        displayedExpenseDetailWeekStart = expenseDetailWeekStart(for: event.date)

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .expenseDetail
        }
    }

    func openAddComparableOption() {
        resetComparableForm()
        applyComparableCategory(.taxi)
        contentTransitionDirection = .forward
        withAnimation(.smooth(duration: 0.30)) {
            scenarioTabPath = [.compare]
            selectedTab = .chooseComparableOption
        }
    }

    func openComparableEditorFromChoice() {
        contentTransitionDirection = .forward
        withAnimation(.smooth(duration: 0.30)) {
            pushScenarioTab(.chooseComparableOption)
            selectedTab = .addComparableOption
        }
    }

    func closeComparableEditor() {
        contentTransitionDirection = .backward
        withAnimation(.smooth(duration: 0.30)) {
            scenarioTabPath = []
            selectedTab = .compare
        }
    }

    func beginEditingComparable(_ alternativeId: UUID) {
        guard let alternative = alternatives.first(where: { $0.id == alternativeId }) else { return }
        editingAlternative = alternative
        comparableCategory = alternative.category
        comparablePresetKey = alternative.presetKey
        comparableName = alternative.name
        comparablePricingModel = editablePricingMode(for: alternative)
        comparablePricePerKm = alternative.paramsJson.pricePerKm.map(formatEditableNumber) ?? ""
        comparablePricePerMinute = alternative.paramsJson.pricePerMinute.map(formatEditableNumber) ?? ""
        comparableAverageSpeedKmh = alternative.paramsJson.averageSpeedKmh.map(formatEditableNumber) ?? defaultAverageSpeedKmh(for: alternative.category)
        comparableCurvePoints = curvePoints(for: alternative)
        comparablePricePerMonth = alternative.paramsJson.pricePerMonth.map(formatEditableNumber) ?? ""
        comparableManualTotal = alternative.paramsJson.value.map(formatEditableNumber) ?? ""
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
        comparableCategory = .taxi
        comparablePresetKey = nil
        comparableName = ""
        comparablePricingModel = .distanceCurve
        comparablePricePerKm = ""
        comparablePricePerMinute = ""
        comparableAverageSpeedKmh = ""
        comparableCurvePoints = Self.emptyComparableCurvePoints()
        comparablePricePerMonth = ""
        comparableManualTotal = ""
        comparableInheritedCostCategories = []
        isComparableIncluded = true
    }

    func applyComparableCategory(_ category: AlternativeCategory) {
        comparableCategory = category
        comparablePresetKey = nil
        comparableName = category.defaultComparableName
        comparablePricingModel = category.defaultPricingMode
        comparablePricePerKm = category.defaultPricePerKm
        comparablePricePerMinute = category.defaultPricePerMinute
        comparableAverageSpeedKmh = defaultAverageSpeedKmh(for: category)
        comparableCurvePoints = category.defaultCurvePoints
        comparablePricePerMonth = category.defaultPricePerMonth
        comparableManualTotal = category.defaultManualTotal
        comparableInheritedCostCategories = category.defaultInheritedCostCategories
    }

    func editablePricingMode(for alternative: AlternativeOption) -> AlternativePricingMode {
        switch alternative.pricingMode {
        case .perDistance, .distanceCurve, .perPeriod, .perTime, .mixed, .manualEquivalent:
            alternative.pricingMode
        }
    }

    func defaultAverageSpeedKmh(for category: AlternativeCategory) -> String {
        switch category {
        case .taxi, .carSharing, .rentalCar:
            "70"
        case .publicTransport:
            "30"
        case .bicycle, .electricScooter:
            "18"
        case .motorcycle:
            "70"
        case .custom:
            "50"
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
        contentTransitionDirection = tabTransitionDirection(from: selectedTab, to: .overview)
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .overview
            scenarioTabPath = []
            achievementRoute = .hub
        }
    }

    func openSettings() {
        contentTransitionDirection = .forward
        withAnimation(.easeInOut(duration: 0.20)) {
            selectedTab = .settings
            scenarioTabPath = []
            achievementRoute = .hub
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
        syncMetricDetailSelection(for: metric)
        selectedDetailMetric = metric
        selectedDetailMetricPayload = nil
        metricDetailError = nil
        selectedMetricTrendDate = nil
        selectedEfficiencyChartDate = nil
        selectedMetricTrendRange = .oneYear

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.overview]
            selectedTab = .metricDetail
        }

        Task { await loadSelectedMetricDetail() }
    }

    func syncMetricDetailSelection(for metric: OverviewMetric) {
        guard metric == .paybackDistance,
              let payload = analyticsOverview?.metrics.first(where: { $0.metricId.overviewMetric == metric }),
              let entityRef = payload.card?.entityRef,
              entityRef.type == "alternative",
              let alternativeId = UUID(uuidString: entityRef.id)
        else {
            return
        }

        selectedBreakEvenAlternativeId = alternativeId
        UserDefaults.standard.set(alternativeId.uuidString, forKey: selectedBreakEvenStorageKey(for: activeScenario.id))
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
