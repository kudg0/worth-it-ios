import SwiftUI

struct ScenarioOverviewView: View {
    typealias ChartRange = ScenarioOverviewChartRange
    typealias MetricTrendRange = ScenarioOverviewMetricTrendRange
    typealias CostPerKmTrendScope = ScenarioOverviewCostPerKmTrendScope
    typealias CompareMetric = ScenarioOverviewCompareMetric
    typealias MetricTrendSwipeDirection = ScenarioOverviewMetricTrendSwipeDirection
    typealias MetricTrendDeltaDisplay = ScenarioOverviewMetricTrendDeltaDisplay
    typealias ScenarioTab = ScenarioOverviewTab
    typealias EntryKind = ScenarioOverviewEntryKind
    typealias ScheduleTrigger = ScenarioOverviewScheduleTrigger
    typealias ServiceMileageInputMode = ScenarioOverviewServiceMileageInputMode
    typealias RecurringFrequency = ScenarioOverviewRecurringFrequency
    typealias LogExpensePicker = ScenarioOverviewLogExpensePicker
    typealias MileageMode = ScenarioOverviewMileageMode
    typealias MileagePicker = ScenarioOverviewMileagePicker
    typealias ExpenseCategory = ScenarioOverviewExpenseCategory
    typealias OverviewMetric = ScenarioOverviewMetric
    typealias ExpenseHistoryFilter = ScenarioOverviewExpenseHistoryFilter
    typealias MetricSlide = ScenarioMetricSlide
    typealias MetricTrend = ScenarioMetricTrend
    typealias ExpenseMonthGroup = ScenarioExpenseMonthGroup
    typealias ExpenseHistoryBar = ScenarioExpenseHistoryBar
    typealias MileageHistoryBar = ScenarioMileageHistoryBar
    typealias MetricTrendPoint = ScenarioMetricTrendPoint
    typealias CostPerKmBreakdownSource = ScenarioCostPerKmBreakdownSource
    typealias MileageLogItem = ScenarioMileageLogItem
    typealias MileageMonthGroup = ScenarioMileageMonthGroup
    typealias ScheduledServiceDisplayItem = ScenarioScheduledServiceDisplayItem

    let repository: ScenarioRepository
    let scenario: ScenarioListItem
    let onScenarioChanged: (ScenarioListItem) -> Void
    let onScenarioDeleted: () -> Void
    let onEditScenario: (ScenarioListItem) -> Void
    let onExitScenario: () -> Void

    @AppStorage("scenarioOverview.selectedMetric") var selectedMetricId = OverviewMetric.costPerKm.rawValue
    @AppStorage("scenarioOverview.enabledMetrics") var enabledMetricIds = ""
    @AppStorage("scenarioOverview.costPerKmIncludesFinancing") var costPerKmIncludesFinancing = false
    @AppStorage("scenarioOverview.includesVehicleResidualValue") var includesVehicleResidualValue = true
    @AppStorage("scenarioOverview.costPerKmBasis") var costPerKmBasisRawValue = ScenarioAnalyticsCostPerKmBasis.sincePurchase.rawValue
    @AppStorage("scenarioOverview.analyticsDeltaDisplay") var analyticsDeltaDisplayRawValue = ScenarioAnalyticsDeltaDisplay.absolute.rawValue
    @State var selectedTab: ScenarioTab = .overview
    @State var expenseHistoryFilter: ExpenseHistoryFilter = .all
    @State var selectedExpenseHistoryBarLabel: String?
    @State var focusedExpenseHistoryMonthStart: Date?
    @State var selectedMileageHistoryBarLabel: String?
    @State var focusedMileageHistoryMonthStart: Date?
    @State var focusedExpenseId: UUID?
    @State var focusedMileageId: UUID?
    @State var focusedComparableId: UUID?
    @State var selectedMileageDetailId: UUID?
    @State var selectedDetailMetric: OverviewMetric = .monthlyCost
    @State var selectedMetricTrendDate: Date?
    @State var selectedMetricTrendRange: MetricTrendRange = .oneYear
    @State var costPerKmTrendScope: CostPerKmTrendScope = .month
    @State var selectedEfficiencyChartDate: Date?
    @State var scenarioTabPath: [ScenarioTab] = []
    @State var selectedEntryKind: EntryKind = .expense
    @State var expenseAmount = ""
    @State var expenseDate = Date()
    @State var activeLogExpensePicker: LogExpensePicker?
    @State var activeMileagePicker: MileagePicker?
    @State var editingCostEvent: CostEvent?
    @State var editingUsageEvent: UsageEvent?
    @State var editingScheduledService: ScheduledService?
    @State var activeScheduledServiceActionId: UUID?
    @State var expenseNotes = ""
    @State var expenseCategory: ExpenseCategory = .fuel
    @State var isRecurringExpense = false
    @State var recurringFrequency: RecurringFrequency = .monthly
    @State var recurringStartDate: Date?
    @State var recurringEndDate: Date?
    @State var isExpenseServiceLinkExpanded = false
    @State var selectedExpenseScheduledServiceId: UUID?
    @State var shouldCompleteLinkedScheduledService = false
    @State var selectedServiceType = "Select a service..."
    @State var scheduleTrigger: ScheduleTrigger = .date
    @State var serviceBaselineDate: Date?
    @State var serviceBaselineOdometer = ""
    @State var isScheduleBasisExpanded = false
    @State var serviceDate: Date?
    @State var serviceMileage = ""
    @State var serviceMileageInputMode: ServiceMileageInputMode = .interval
    @State var isOptionalServiceDateEnabled = false
    @State var isOptionalServiceMileageEnabled = false
    @State var serviceDetails = ""
    @State var mileageMode: MileageMode = .odometer
    @State var mileageValue = ""
    @State var mileageDate = Date()
    @State var mileageNotes = ""
    @State var chartRange: ChartRange = .month
    @State var displayedScenario: ScenarioListItem?
    @State var currentSummary: ScenarioSummary?
    @State var currentComparison: ScenarioComparison?
    @State var previousMonthSummary: ScenarioSummary?
    @State var costEvents: [CostEvent] = []
    @State var usageEvents: [UsageEvent] = []
    @State var alternatives: [AlternativeOption] = []
    @State var comparisonVisibleAlternativeIds: Set<UUID> = []
    @State var analyticsDraftIncludesResidualValue = true
    @State var analyticsDraftDefaultMetric: ScenarioAnalyticsDefaultMetric = .perKm
    @State var analyticsDraftCostPerKmBasis: ScenarioAnalyticsCostPerKmBasis = .sincePurchase
    @State var analyticsDraftDeltaDisplay: ScenarioAnalyticsDeltaDisplay = .absolute
    @State var scheduledServices: [ScheduledService] = []
    @State var scheduledServiceDueItems: [ScheduledServiceDueItem] = []
    @State var summaryError: String?
    @State var costEventsError: String?
    @State var usageEventsError: String?
    @State var alternativesError: String?
    @State var scheduledServicesError: String?
    @State var isUpdatingFavorite = false
    @State var isDeleting = false
    @State var isSavingEntry = false
    @State var showsDeleteConfirmation = false
    @State var actionError: String?
    @State var compareMetric: CompareMetric = .perKm
    @State var editingAlternative: AlternativeOption?
    @State var comparableName = ""
    @State var comparablePricingModel: AlternativePricingMode = .distanceCurve
    @State var comparablePricePerKm = ""
    @State var comparablePricePerMinute = ""
    @State var comparableCurvePoints = Self.emptyComparableCurvePoints()
    @State var comparablePricePerMonth = ""
    @State var comparableManualTotal = ""
    @State var comparableNote = ""
    @State var comparableInheritedCostCategories: Set<String> = []
    @State var isComparableIncluded = true

    var body: some View {
        ZStack {
            WorthItColor.surfaceLowest.ignoresSafeArea()
            WITopSpotlight()
            ScenarioAtmosphericGlow()

            VStack(spacing: 0) {
                ScenarioTopBar(
                    title: topBarTitle,
                    titleColor: topBarTitleColor,
                    usesEntryTitleStyle: isEntryFlowScreen,
                    canGoBack: canGoBackInScenario,
                    selectedTab: selectedTab,
                    activeScenario: activeScenario,
                    isUpdatingFavorite: isUpdatingFavorite,
                    isDeleting: isDeleting,
                    onBack: popScenarioTab,
                    onToggleFavorite: { Task { await toggleFavorite() } },
                    onEditScenario: onEditScenario,
                    onDeleteScenario: { showsDeleteConfirmation = true },
                    onAddEntry: openAddEntryChooserFromMaintenance,
                    onAddMileage: { openMileageForm() },
                    onAddComparable: openAddComparableOption,
                    onRemoveComparable: { Task { await deleteEditingComparable() } },
                    onEditMileageDetail: editSelectedMileageDetail
                )

                if showsScenarioNavigation {
                    ScenarioTabsBar(selectedTab: selectedTab, onSelect: navigateScenarioTab)
                }

                ScrollView {
                    VStack(spacing: 40) {
                        tabContent
                    }
                    .padding(.horizontal, WorthItSpacing.xxl)
                    .padding(.top, WorthItSpacing.xxxxl + WorthItSpacing.xl)
                    .padding(.bottom, scrollBottomPadding)
                }
                .id(selectedTab)
                .scrollIndicators(.hidden)
            }

            if showsBottomNav {
                ScenarioBottomNav(
                    selectedTab: selectedTab,
                    onExit: onExitScenario,
                    onHome: openScenarioHome,
                    onSettings: openSettings
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .mileage {
                stickyEntryCTA(title: "Log Mileage", bottomPadding: 124) {
                    openMileageForm()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .logExpense {
                stickyEntryCTA(title: editingCostEvent == nil ? "Save Expense" : "Save Changes") {
                    Task { await saveExpense() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .scheduleService {
                stickyEntryCTA(title: editingScheduledService == nil ? "Save Schedule" : "Save Changes") {
                    Task { await saveScheduledService() }
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .logMileage {
                stickyEntryCTA(title: mileageSaveTitle) {
                    Task { await saveMileage() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .addComparableOption {
                AddComparableOptionFooter(
                    title: editingAlternative == nil ? "Save Comparable" : "Save Changes",
                    isLoading: isSavingEntry,
                    onSave: { Task { await saveComparable() } }
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .analyticsSettings {
                analyticsModelScreen
                    .footer
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .comparisonSettings {
                ScenarioComparisonVisibilityScreen(
                    alternatives: alternatives,
                    isSaving: isSavingEntry,
                    selectedIds: $comparisonVisibleAlternativeIds,
                    onSave: { selectedIds in Task { await saveComparisonVisibility(selectedIds: selectedIds) } }
                )
                .footer
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }

            if let serviceId = activeScheduledServiceActionId {
                ScheduledServiceActionOverlay(
                    onDismiss: closeScheduledServiceActions,
                    onEdit: {
                        activeScheduledServiceActionId = nil
                        beginEditingScheduledService(serviceId)
                    },
                    onCompleteWithExpense: {
                        activeScheduledServiceActionId = nil
                        beginCompletingScheduledService(serviceId)
                    }
                )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .confirmationDialog(
            "Delete scenario?",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Scenario", role: .destructive) {
                Task { await deleteScenario() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the scenario and all related entries.")
        }
        .alert("Scenario action failed", isPresented: hasActionError) {
            Button("OK", role: .cancel) {
                actionError = nil
            }
        } message: {
            Text(actionError ?? "Please try again.")
        }
        .sheet(item: $activeLogExpensePicker) { picker in
            logExpensePickerSheet(picker)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $activeMileagePicker) { picker in
            mileagePickerSheet(picker)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task(id: scenario.id) {
            displayedScenario = scenario
            selectedTab = .overview
            scenarioTabPath = []
            await loadSummary()
        }
    }


    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .overview:
            ScenarioOverviewScreen(
                metrics: availableMetrics,
                selectedMetric: selectedMetricBinding,
                selectedMetricId: currentSelectedMetricId,
                showsEfficiencyCard: hasEfficiencyChartData,
                efficiencyModel: overviewEfficiencyModel,
                onOpenMetric: openMetricDetail,
                onAddExpense: openAddEntryChooserFromOverview,
                onOpenUsage: { navigateScenarioTab(.mileage) },
                onOpenCompare: { navigateScenarioTab(.compare) }
            )
        case .expenses:
            ScenarioExpensesScreen(model: expensesScreenModel)
        case .mileage:
            ScenarioMileageScreen(
                currentOdometerValue: currentOdometerValue,
                mileageUnit: mileageDisplayUnit,
                heroDateText: mileageHeroDateText,
                lastUpdateText: mileageLastUpdateText,
                thisMonthText: mileageThisMonthText,
                averagePerDayText: mileageAveragePerDayText,
                usageEventsError: usageEventsError,
                logItems: mileageLogItems,
                currentMonthItems: currentMonthMileageLogItems,
                onOpenHistory: { openMileageHistory() },
                onOpenMileage: openMileageDetail,
                onEditMileage: beginEditingMileage
            )
        case .insights:
            ScenarioInsightsScreen()
        case .compare:
            ScenarioCompareScreen(
                selectedMetric: $compareMetric,
                currency: activeScenario.currency,
                summary: currentSummary,
                ownershipCostPerKm: analyticsCostPerKmValue,
                ownershipMonthlyCost: analyticsMonthlyCostValue,
                comparison: currentComparison,
                alternatives: alternatives,
                alternativesError: alternativesError,
                chartSeries: compareChartSeries,
                scenarioStartDate: activeScenario.startDate,
                focusedComparableId: focusedComparableId,
                onAddComparable: openAddComparableOption,
                onEditComparable: beginEditingComparable
            )
        case .addComparableOption:
            AddComparableOptionScreen(
                isEditing: editingAlternative != nil,
                name: $comparableName,
                pricingModel: $comparablePricingModel,
                pricePerKm: $comparablePricePerKm,
                pricePerMinute: $comparablePricePerMinute,
                curvePoints: $comparableCurvePoints,
                pricePerMonth: $comparablePricePerMonth,
                manualTotal: $comparableManualTotal,
                note: $comparableNote,
                inheritedCostCategories: $comparableInheritedCostCategories,
                currencyCode: activeScenario.currency,
                isIncluded: $isComparableIncluded,
                onRemove: { Task { await deleteEditingComparable() } }
            )
        case .comparisonSettings:
            ScenarioComparisonVisibilityScreen(
                alternatives: alternatives,
                isSaving: isSavingEntry,
                selectedIds: $comparisonVisibleAlternativeIds,
                onSave: { selectedIds in Task { await saveComparisonVisibility(selectedIds: selectedIds) } }
            )
        case .analyticsSettings:
            analyticsModelScreen
        case .addEntryChooser:
            AddEntryChooserScreen(
                selectedEntryKind: $selectedEntryKind,
                onContinue: continueAddEntryChooser
            )
        case .logExpense:
            LogExpenseScreen(model: logExpenseScreenModel)
        case .scheduleService:
            ScheduleServiceScreen(model: scheduleServiceScreenModel)
        case .expenseHistory:
            ExpenseHistoryScreen(model: expenseHistoryScreenModel)
        case .mileageHistory:
            MileageHistoryScreen(model: mileageHistoryScreenModel)
        case .mileageDetail:
            mileageDetailContent
        case .metricDetail:
            metricDetailContent
        case .logMileage:
            LogMileageScreen(
                mode: $mileageMode,
                value: $mileageValue,
                notes: $mileageNotes,
                isEditing: editingUsageEvent != nil,
                currentOdometerValue: currentOdometerValue,
                mileageUnit: mileageDisplayUnit,
                previousOdometerText: previousOdometerText,
                odometerDeltaText: mileageOdometerDeltaText,
                resultingOdometerText: resultingOdometerText,
                dateText: Self.shortDateFormatter.string(from: mileageDate),
                timeText: Self.timeFormatter.string(from: mileageDate),
                sanitizeValue: sanitizedDecimalInput,
                onModeChange: resetMileageValueForMode,
                onOpenDatePicker: { activeMileagePicker = .date },
                onOpenTimePicker: { activeMileagePicker = .time },
                onDelete: { Task { await deleteEditingMileage() } }
            )
        case .settings:
            ScenarioSettingsScreen(
                scenarioName: activeScenario.name,
                vehicleSummary: scenarioVehicleSummary,
                acquisitionSummary: scenarioAcquisitionSummary,
                resaleSummary: scenarioResaleSummary,
                analyticsSummary: scenarioAnalyticsSummary,
                comparisonSummary: scenarioComparisonSummary,
                preferencesSummary: scenarioPreferencesSummary,
                onEditScenario: { onEditScenario(activeScenario) },
                onOpenAnalytics: { openAnalyticsSettings() },
                onOpenComparison: { openComparisonSettings() },
                onOpenPreferences: {},
                onDeleteScenario: { showsDeleteConfirmation = true }
            )
        }
    }

    func continueAddEntryChooser() {
        if selectedEntryKind == .expense {
            navigateScenarioTab(.logExpense)
        } else {
            resetScheduledServiceForm()
            navigateScenarioTab(.scheduleService)
        }
    }

    var metricTrendPoints: [MetricTrendPoint] {
        if selectedDetailMetric == .costPerKm {
            return sortedTrendPoints(costPerKmMetricTrendPoints)
        }

        if selectedDetailMetric == .currentMonthCostPerKm {
            return sortedTrendPoints(activeCostPerKmTrendRange == .oneYear ? monthlyEfficiencyTrendPoints(maxMonths: 12) : monthlyEfficiencyTrendPoints(maxMonths: nil))
        }

        if selectedDetailMetric == .totalOwnership {
            return sortedTrendPoints(totalOwnershipTrendPoints(maxMonths: selectedMetricTrendRange == .oneYear ? 12 : nil))
        }

        let realPoints = realMetricTrendPoints
        if realPoints.count >= 2 {
            return sortedTrendPoints(realPoints)
        }

        let calendar = Calendar(identifier: .gregorian)
        let current = metricCurrentNumericValue
        let pointCount = selectedMetricTrendRange == .oneYear ? 7 : metricTrendAllPointCount

        let points = (0..<pointCount).compactMap { index in
            calendar.date(byAdding: .month, value: index - (pointCount - 1), to: currentMonthStart).map {
                MetricTrendPoint(date: $0, value: current)
            }
        }

        return sortedTrendPoints(points)
    }

    var solidMetricTrendPoints: [MetricTrendPoint] {
        sortedTrendPoints(metricTrendPoints.filter { !$0.isProjected })
    }

    var dashedMetricTrendPoints: [MetricTrendPoint] {
        let points = sortedTrendPoints(metricTrendPoints)
        guard let firstProjectedIndex = points.firstIndex(where: \.isProjected) else {
            return []
        }

        let anchor = firstProjectedIndex > 0 ? [points[firstProjectedIndex - 1]] : []
        return anchor + points[firstProjectedIndex...]
    }

    var costPerKmMetricTrendPoints: [MetricTrendPoint] {
        projectedCostPerKmTrendPoints(maxMonths: activeCostPerKmTrendRange == .oneYear ? 12 : nil)
    }

    func effectiveCostPerKmTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        return efficiencyMonthStarts(maxMonths: maxMonths).compactMap { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let asOf = min(monthEnd, Date())
            return effectiveCostPerDistanceValue(asOf: asOf).map {
                MetricTrendPoint(date: monthStart, value: $0)
            }
        }
    }

    func projectedCostPerKmTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let count = maxMonths ?? max(efficiencyMonthStarts(maxMonths: nil).count, 1)
        return projectedEfficiencySnapshotTrendPoints(period: .month, count: count)
    }

    var costPerKmMonthlyComparisonTrendPoints: [MetricTrendPoint] {
        effectiveCostPerKmTrendPoints(maxMonths: nil).suffix(2).map { $0 }
    }

    var currentMonthCostPerKmComparisonTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)

        return sortedTrendPoints([
            previousMonthStart.flatMap { start in
                previousMonthlyCostPerDistanceValue.map { MetricTrendPoint(date: start, value: $0) }
            },
            currentMonthlyCostPerDistanceValue.map { MetricTrendPoint(date: currentMonthStart, value: $0) }
        ].compactMap { $0 })
    }

    func sortedTrendPoints(_ points: [MetricTrendPoint]) -> [MetricTrendPoint] {
        points.sorted { lhs, rhs in
            if lhs.date == rhs.date {
                return !lhs.isProjected && rhs.isProjected
            }

            return lhs.date < rhs.date
        }
    }

    var costPerKmSelectedMonthTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = costPerKmSelectedMonthStart
        guard let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let now = Date()
        var realValues: [Double] = []

        return monthRange.compactMap { day -> MetricTrendPoint? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return nil }
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            let value = efficiencyPeriodValue(bucketStart: date, period: .day)

            if let value, dayEnd <= now {
                realValues.append(value)
                return MetricTrendPoint(date: date, value: value)
            }

            return MetricTrendPoint(
                date: date,
                value: projectedMetricTrendValue(from: realValues),
                isProjected: true
            )
        }
    }

    var costPerKmSelectedYearTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let yearStart = costPerKmSelectedYearStart
        let now = Date()
        var realValues: [Double] = []

        return (0..<12).compactMap { monthOffset -> MetricTrendPoint? in
            guard let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: yearStart) else { return nil }
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let value = efficiencyPeriodValue(bucketStart: monthStart, period: .month)

            if let value, monthEnd <= now {
                realValues.append(value)
                return MetricTrendPoint(date: monthStart, value: value)
            }

            return MetricTrendPoint(
                date: monthStart,
                value: projectedMetricTrendValue(from: realValues),
                isProjected: true
            )
        }
    }

    func projectedMetricTrendValue(from values: [Double]) -> Double {
        guard !values.isEmpty else {
            return currentCostPerDistanceValue ?? 0
        }

        let sampleCount = max(Int(ceil(Double(values.count) * 0.25)), 1)
        let sample = values.suffix(sampleCount)
        return sample.reduce(0, +) / Double(sample.count)
    }

    var realMetricTrendPoints: [MetricTrendPoint] {
        realMetricTrendPoints(for: selectedDetailMetric)
    }

    func realMetricTrendPoints(for metric: OverviewMetric) -> [MetricTrendPoint] {
        switch metric {
        case .monthlyCost:
            return twoPointTrend(previous: previousMonthlySpendValue, current: monthlySpendValue)
        case .costPerKm:
            return costPerKmMonthlyComparisonTrendPoints
        case .currentMonthCostPerKm:
            return currentMonthCostPerKmComparisonTrendPoints
        case .totalExpenses:
            return totalExpensesTrendPoints(maxMonths: nil)
        case .totalOwnership:
            return totalOwnershipTrendPoints(maxMonths: nil)
        case .projectedGain, .expectedResale, .loanInterest:
            return []
        }
    }

    func twoPointTrend(previous: Double?, current: Double?) -> [MetricTrendPoint] {
        [
            previous.map { MetricTrendPoint(date: expenseHistoryMonthStart(for: previousMonthAsOfDate), value: $0) },
            current.map { MetricTrendPoint(date: currentMonthStart, value: $0) }
        ]
        .compactMap { $0 }
        .sorted { $0.date < $1.date }
    }

    var metricTrendAllPointCount: Int {
        let calendar = Calendar(identifier: .gregorian)
        let start = expenseHistoryMonthStart(for: activeScenario.startDate)
        let components = calendar.dateComponents([.month], from: start, to: currentMonthStart)
        return max((components.month ?? 0) + 1, 2)
    }

    var usesScrollableMetricTrendChart: Bool {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            return activeCostPerKmTrendRange == .all && metricTrendPoints.count > metricTrendVisiblePointCount
        }

        return selectedMetricTrendRange == .all && metricTrendPoints.count > metricTrendVisiblePointCount
    }

    var metricTrendVisiblePointCount: Int {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            switch costPerKmTrendScope {
            case .day:
                return 30
            case .week:
                return 12
            case .month, .all:
                return 12
            }
        }

        return 12
    }

    var metricTrendVisibleDomainLength: TimeInterval {
        switch metricTrendCalendarComponent {
        case .day:
            TimeInterval(60 * 60 * 24 * max(metricTrendVisiblePointCount - 1, 1))
        case .weekOfYear:
            TimeInterval(60 * 60 * 24 * 7 * max(metricTrendVisiblePointCount - 1, 1))
        default:
            TimeInterval(60 * 60 * 24 * 31 * max(metricTrendVisiblePointCount - 1, 1))
        }
    }

    var metricTrendTitle: String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm:
            "\(costPerKmTrendScope.trendTitle) trend"
        case .totalOwnership:
            realMetricTrendPoints.count >= 2 ? "Cost inputs trend" : "Current cost inputs"
        case .monthlyCost, .totalExpenses:
            realMetricTrendPoints.count >= 2 ? "Monthly trend" : "Current baseline"
        case .projectedGain, .expectedResale, .loanInterest:
            "Current snapshot"
        }
    }

    var selectedMetricTrendDateBinding: Binding<Date?> {
        Binding {
            selectedMetricTrendDate ?? defaultMetricTrendPoint?.date
        } set: { newValue in
            guard let newValue else {
                return
            }

            selectedMetricTrendDate = nearestMetricTrendPoint(to: newValue)?.date
        }
    }

    var selectedMetricTrendPoint: MetricTrendPoint? {
        guard let selectedMetricTrendDate else {
            return defaultMetricTrendPoint
        }

        return nearestMetricTrendPoint(to: selectedMetricTrendDate)
    }

    var defaultMetricTrendPoint: MetricTrendPoint? {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            let calendar = Calendar(identifier: .gregorian)
            let currentBucketStart = calendar.dateInterval(of: metricTrendCalendarComponent, for: Date())?.start ?? Date()
            return nearestMetricTrendPoint(to: currentBucketStart) ?? metricTrendPoints.last
        }

        return metricTrendPoints.last(where: { !$0.isProjected }) ?? metricTrendPoints.last
    }

    func moveMetricTrendSelection(direction: MetricTrendSwipeDirection) {
        if selectedDetailMetric == .costPerKm {
            moveCostPerKmTrendPeriod(direction: direction)
            return
        }

        let points = metricTrendPoints.sorted { $0.date < $1.date }
        guard !points.isEmpty else { return }

        let currentDate = selectedMetricTrendPoint?.date ?? points.last?.date ?? Date()
        let currentIndex = points.enumerated().min { lhs, rhs in
            abs(lhs.element.date.timeIntervalSince(currentDate)) < abs(rhs.element.date.timeIntervalSince(currentDate))
        }?.offset ?? max(points.count - 1, 0)

        let nextIndex: Int
        switch direction {
        case .older:
            nextIndex = max(currentIndex - 1, 0)
        case .newer:
            nextIndex = min(currentIndex + 1, points.count - 1)
        }

        selectedMetricTrendDate = points[nextIndex].date
    }

    func moveCostPerKmTrendPeriod(direction: MetricTrendSwipeDirection) {
        let points = metricTrendPoints.sorted { $0.date < $1.date }
        guard !points.isEmpty else { return }

        let currentDate = selectedMetricTrendPoint?.date ?? defaultMetricTrendPoint?.date ?? points.last?.date ?? Date()
        let currentIndex = points.enumerated().min { lhs, rhs in
            abs(lhs.element.date.timeIntervalSince(currentDate)) < abs(rhs.element.date.timeIntervalSince(currentDate))
        }?.offset ?? max(points.count - 1, 0)

        let nextIndex: Int
        switch direction {
        case .older:
            nextIndex = max(currentIndex - 1, 0)
        case .newer:
            nextIndex = min(currentIndex + 1, points.count - 1)
        }

        selectedMetricTrendDate = points[nextIndex].date
    }

    func nearestMetricTrendPoint(to date: Date) -> MetricTrendPoint? {
        metricTrendPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    var metricTrendYAxisValues: [Double] {
        let values = metricTrendPoints.map(\.value)
        guard let minValue = values.min(), let maxValue = values.max() else { return [] }

        if minValue == maxValue {
            return [0, max(maxValue, 1)]
        }

        let paddedMin = max(0, minValue * 0.92)
        let paddedMax = maxValue * 1.08
        let middle = (paddedMin + paddedMax) / 2
        return [paddedMin, middle, paddedMax]
    }

    var metricTrendYAxisMax: Double {
        max((metricTrendPoints.map(\.value).max() ?? 0) * 1.08, 1)
    }

    func metricTrendYAxisLabel(_ value: Double) -> String {
        metricTrendPointValueLabel(MetricTrendPoint(date: Date(), value: value))
    }

    func metricTrendPointValueLabel(_ point: MetricTrendPoint) -> String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2))"
        default:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 0))"
        }
    }

    var metricCurrentNumericValue: Double {
        switch selectedDetailMetric {
        case .monthlyCost:
            monthlySpendValue ?? 0
        case .costPerKm:
            currentCostPerDistanceValue ?? 0
        case .currentMonthCostPerKm:
            currentMonthlyCostPerDistanceValue ?? 0
        case .totalExpenses:
            totalLoggedExpensesValue
        case .totalOwnership:
            totalOwnershipCost.map(doubleValue) ?? 0
        case .projectedGain:
            doubleValue(projectedGain)
        case .expectedResale:
            doubleValue(expectedResaleValue)
        case .loanInterest:
            doubleValue(loanInterestTotal)
        }
    }

    var metricTrendAxisDates: [Date] {
        guard let first = metricTrendPoints.first?.date, let last = metricTrendPoints.last?.date else {
            return []
        }

        let middleIndex = metricTrendPoints.count / 2
        return [first, metricTrendPoints[middleIndex].date, last]
    }

    func metricTrendAxisLabel(for date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)

        if (selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm),
           let currentBucketStart = calendar.dateInterval(of: metricTrendCalendarComponent, for: Date())?.start,
           calendar.isDate(date, equalTo: currentBucketStart, toGranularity: metricTrendCalendarComponent) {
            return "Present"
        }

        if selectedDetailMetric != .costPerKm && selectedDetailMetric != .currentMonthCostPerKm,
           calendar.isDate(date, equalTo: currentMonthStart, toGranularity: .month) {
            return "Present"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            switch costPerKmTrendScope {
            case .day, .week:
                formatter.dateFormat = "d MMM"
            case .month, .all:
                formatter.dateFormat = "MMM yyyy"
            }
        } else {
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: date)
    }

    var metricTrendCalendarComponent: Calendar.Component {
        if selectedDetailMetric == .costPerKm {
            return .month
        }

        if selectedDetailMetric == .currentMonthCostPerKm {
            return .month
        }

        switch costPerKmTrendScope {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month, .all:
            return .month
        }
    }

    var costPerKmSelectedMonthStart: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sourceDate = selectedMetricTrendDate ?? Date()
        return calendar.dateInterval(of: .month, for: sourceDate)?.start ?? currentMonthStart
    }

    var effectiveCostPerKmSelectedEnd: Date {
        let calendar = Calendar(identifier: .gregorian)
        let selectedMonthStart = selectedMetricTrendPoint?.date ?? currentMonthStart
        let selectedMonthEnd = calendar.date(byAdding: .month, value: 1, to: selectedMonthStart) ?? Date()
        return min(selectedMonthEnd, Date())
    }

    var costPerKmSelectedPeriodEnd: Date {
        let calendar = Calendar(identifier: .gregorian)
        guard let point = selectedMetricTrendPoint else {
            return Date()
        }

        if !point.isProjected {
            let periodEnd = calendar.date(byAdding: metricTrendCalendarComponent, value: 1, to: point.date) ?? Date()
            if periodEnd >= Date() {
                return Date()
            }

            return calendar.date(byAdding: .day, value: -1, to: periodEnd) ?? point.date
        }

        if calendar.isDate(point.date, inSameDayAs: currentYearEndDate(from: point.date, calendar: calendar)) {
            return point.date
        }

        let nextPeriod = calendar.date(byAdding: metricTrendCalendarComponent, value: 1, to: point.date) ?? point.date
        return calendar.date(byAdding: .day, value: -1, to: nextPeriod) ?? point.date
    }

    var costPerKmSelectedYearStart: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sourceDate = selectedMetricTrendDate ?? Date()
        return calendar.dateInterval(of: .year, for: sourceDate)?.start ?? sourceDate
    }

    var activeCostPerKmTrendRange: MetricTrendRange {
        showsCostPerKmYearRangeToggle ? selectedMetricTrendRange : .oneYear
    }

    var showsCostPerKmYearRangeToggle: Bool {
        let currentYearStart = Calendar(identifier: .gregorian).dateInterval(of: .year, for: Date())?.start ?? currentMonthStart
        if selectedDetailMetric == .currentMonthCostPerKm {
            return monthlyEfficiencyTrendPoints(maxMonths: nil).contains { $0.date < currentYearStart }
        }

        return effectiveCostPerKmTrendPoints(maxMonths: nil).contains { $0.date < currentYearStart }
    }

    var monthlySpend: String {
        if let monthlySpendValue {
            return "\(currencySymbol)\(formatDouble(monthlySpendValue, fractionDigits: 0))"
        }

        return "—"
    }

    var monthlySpendValue: Double? {
        let currentExpenses = doubleValue(currentMonthExpenseTotal)
        let loanInterest = currentMonthLoanInterest

        if loanInterest > 0 || currentExpenses > 0 {
            return loanInterest + currentExpenses
        }

        return monthlyCostValue(from: currentSummary)
    }

    var loanPaymentSubtitle: String? {
        guard
            activeScenario.acquisitionType == "loan",
            let loanTermMonths = activeScenario.loanTermMonths,
            loanTermMonths > 0,
            let loanEndDate = Calendar(identifier: .gregorian).date(
                byAdding: .month,
                value: loanTermMonths,
                to: activeScenario.startDate
            )
        else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"
        return "Until \(formatter.string(from: loanEndDate))"
    }

    var previousMonthlySpendValue: Double? {
        let previousExpenses = doubleValue(previousMonthExpenseTotal)
        let loanInterest = previousMonthLoanInterest

        if loanInterest > 0 || previousExpenses > 0 {
            return loanInterest + previousExpenses
        }

        return monthlyCostValue(from: previousMonthSummary)
    }

    func monthlyCostValue(from summary: ScenarioSummary?) -> Double? {
        guard
            let summary,
            summary.includedCostsTotal > 0,
            summary.ownershipWindow.monthsOwned > 0
        else {
            return nil
        }

        return summary.includedCostsTotal / summary.ownershipWindow.monthsOwned
    }

    var totalOwnershipCost: Decimal? {
        guard purchasePrice > 0 else { return nil }
        guard ownershipNetCost > 0 else { return nil }
        return ownershipNetCost
    }

    var totalOwnershipDisplay: String {
        guard let totalOwnershipCost else { return "—" }
        return "\(currencySymbol)\(formatDecimal(totalOwnershipCost, fractionDigits: 0))"
    }

    var expectedResaleDisplay: String {
        expectedResaleValue > 0 ? "\(currencySymbol)\(formatDecimal(expectedResaleValue, fractionDigits: 0))" : "—"
    }

    var projectedGain: Decimal {
        max(expectedResaleValue - purchasePrice - loanInterestTotal - nonDailyExpenseTotal, 0)
    }

    var ownershipNetCost: Decimal {
        if let currentSummary {
            return Decimal(currentSummary.netOwnershipCost)
        }

        return purchasePrice + loanInterestTotal - expectedResaleValue
    }

    var previousOwnershipNetCost: Double? {
        previousMonthSummary?.netOwnershipCost
    }

    var monthlySpendProgress: CGFloat {
        if let monthlySpendValue {
            return normalizedProgress(monthlySpendValue / max(doublePurchasePrice / 12, 1))
        }

        if let currentSummary, currentSummary.includedCostsTotal > 0, currentSummary.ownershipWindow.monthsOwned > 0 {
            let averageMonthlyCosts = currentSummary.includedCostsTotal / currentSummary.ownershipWindow.monthsOwned
            return normalizedProgress(averageMonthlyCosts / max(doublePurchasePrice / 12, 1))
        }

        return 0
    }

    var costPerKmProgress: CGFloat {
        guard let costPerKm = currentCostPerDistanceValue else { return 0 }
        return normalizedProgress(costPerKm / 1.0)
    }

    var currentMonthCostPerKmProgress: CGFloat {
        guard let costPerKm = currentMonthlyCostPerDistanceValue else { return 0 }
        return normalizedProgress(costPerKm / 1.0)
    }

    var totalOwnershipProgress: CGFloat {
        guard purchasePrice > 0, let totalOwnershipCost else { return 0 }
        return normalizedProgress(doubleValue(totalOwnershipCost) / doublePurchasePrice)
    }

    var projectedGainProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }
        return normalizedProgress(doubleValue(projectedGain) / doublePurchasePrice)
    }

    var loanInterestProgress: CGFloat {
        let principal = decimalValue(activeScenario.loanAmount)
        guard principal > 0 else { return 0 }
        return normalizedProgress(doubleValue(loanInterestTotal) / doubleValue(principal))
    }

    var expectedResaleProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }

        return normalizedProgress(doubleValue(expectedResaleValue) / doublePurchasePrice)
    }

    var expectedResaleColor: Color {
        expectedResaleValue >= purchasePrice ? Color(hex: 0x34D399) : WorthItColor.accentGold
    }

    var nonDailyExpenseTotal: Decimal {
        costEvents.reduce(Decimal(0)) { total, event in
            if Self.dailyExpenseCategories.contains(event.category) {
                return total
            }

            return total + decimalValue(event.amount)
        }
    }

    static let dailyExpenseCategories: Set<String> = ["fuel", "wash"]

    var monthlyCostTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .monthlyCost), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var costPerKmTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .costPerKm), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var currentMonthCostPerKmTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .currentMonthCostPerKm), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var totalOwnershipTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .totalOwnership), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var totalLoggedExpensesValue: Double {
        costEvents.reduce(0) { total, event in
            total + doubleValue(decimalValue(event.amount))
        }
    }

    var totalLoggedExpensesDisplay: String {
        "\(currencySymbol)\(formatDouble(totalLoggedExpensesValue, fractionDigits: 0))"
    }

    var totalLoggedExpensesProgress: CGFloat {
        normalizedProgress(totalLoggedExpensesValue / max(doublePurchasePrice, 1))
    }

    func totalExpensesTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        return efficiencyMonthStarts(maxMonths: maxMonths).map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let total = costEvents
                .filter { $0.date < monthEnd }
                .reduce(0) { $0 + doubleValue(decimalValue($1.amount)) }
            return MetricTrendPoint(date: monthStart, value: total)
        }
    }

    var compareChartSeries: [ScenarioCompareChartSeries] {
        if let backendSeries = backendCompareChartSeries, !backendSeries.isEmpty {
            return backendSeries
        }

        return []
    }

    var backendCompareChartSeries: [ScenarioCompareChartSeries]? {
        guard let series = currentComparison?.series else { return nil }

        var result: [ScenarioCompareChartSeries] = []
        let ownershipPoints = series.ownership.compactMap { point -> ScenarioCompareChartPoint? in
            guard let value = compareChartValue(point) else { return nil }
            return ScenarioCompareChartPoint(date: point.date, value: value)
        }

        if !ownershipPoints.isEmpty {
            result.append(
                ScenarioCompareChartSeries(
                    id: "ownership",
                    title: "Your car",
                    color: WorthItColor.primaryContainer,
                    points: ownershipPoints,
                    isBenchmark: false
                )
            )
        }

        let visibleAlternativeIds = Set(alternatives.filter(\.isIncluded).map(\.id))
        let colors = [
            Color(hex: 0x7DD3FC),
            Color(hex: 0xA7F3D0),
            Color(hex: 0xC4B5FD),
            Color(hex: 0xF9A8D4)
        ]

        result.append(
            contentsOf: series.alternatives
                .filter { visibleAlternativeIds.contains($0.id) }
                .enumerated()
                .compactMap { index, alternative -> ScenarioCompareChartSeries? in
                    let points = alternative.points.compactMap { point -> ScenarioCompareChartPoint? in
                        guard let value = compareChartValue(point) else { return nil }
                        return ScenarioCompareChartPoint(date: point.date, value: value)
                    }
                    guard !points.isEmpty else { return nil }

                    return ScenarioCompareChartSeries(
                        id: alternative.id.uuidString,
                        title: alternative.name,
                        color: colors[index % colors.count].opacity(0.86),
                        points: points,
                        isBenchmark: true
                    )
                }
        )

        return result
    }

    func compareChartValue(_ point: ScenarioComparison.Series.Point) -> Double? {
        switch compareMetric {
        case .perKm:
            return point.perKm
        case .perMonth:
            return point.perMonth
        case .totalCost:
            return point.total
        }
    }

    func averageMonthlyOwnershipCost(asOf date: Date) -> Double? {
        let calendar = Calendar(identifier: .gregorian)
        let start = expenseHistoryMonthStart(for: activeScenario.startDate)
        let end = min(max(date, start), Date())
        let monthCount = max((calendar.dateComponents([.month], from: start, to: end).month ?? 0) + 1, 1)
        return netOwnershipCost(to: end) / Double(monthCount)
    }

    var costPerKmBreakdownTrend: MetricTrend? {
        if selectedDetailMetric == .currentMonthCostPerKm {
            return costPerKmPeriodBreakdownTrend
        }

        let points = sortedTrendPoints(costPerKmMetricTrendPoints)
        guard let currentPoint = selectedMetricTrendPoint ?? points.last,
              let currentIndex = points.lastIndex(where: { $0.id == currentPoint.id }),
              currentIndex > 0
        else {
            return nil
        }

        return metricTrend(
            previousPoint: points[currentIndex - 1],
            currentPoint: currentPoint,
            lowerIsBetter: true,
            deltaDisplay: analyticsMetricTrendDeltaDisplay
        )
    }

    var costPerKmPeriodBreakdownTrend: MetricTrend? {
        guard costPerKmBreakdownDistance > 0 else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let component: Calendar.Component = activeCostPerKmTrendRange == .oneYear ? .month : metricTrendCalendarComponent
        guard let previousStart = calendar.date(byAdding: component, value: -1, to: costPerKmBreakdownStart),
              let previous = efficiencyPeriodValue(bucketStart: previousStart, period: component),
              previous > 0
        else {
            return nil
        }

        let current = costPerKmBreakdownCost / costPerKmBreakdownDistance
        return metricTrend(
            previousPoint: MetricTrendPoint(date: previousStart, value: previous),
            currentPoint: MetricTrendPoint(date: costPerKmBreakdownStart, value: current),
            lowerIsBetter: true,
            deltaDisplay: analyticsMetricTrendDeltaDisplay
        )
    }

    func metricTrend(
        points: [MetricTrendPoint],
        lowerIsBetter: Bool,
        deltaDisplay: MetricTrendDeltaDisplay = .percent
    ) -> MetricTrend {
        if summaryError != nil {
            return MetricTrend(label: "SUMMARY LOAD FAILED", iconName: "minus", color: WorthItColor.textTertiary)
        }

        guard let previousPoint = points.dropLast().last,
              let current = points.last?.value,
              previousPoint.value > 0
        else {
            return MetricTrend(label: "NO PREVIOUS MONTH DATA", iconName: "minus", color: WorthItColor.textTertiary)
        }

        return metricTrend(
            previousPoint: previousPoint,
            currentPoint: MetricTrendPoint(date: points.last?.date ?? Date(), value: current),
            lowerIsBetter: lowerIsBetter,
            deltaDisplay: deltaDisplay
        )
    }

    func metricTrend(
        previousPoint: MetricTrendPoint,
        currentPoint: MetricTrendPoint,
        lowerIsBetter: Bool,
        deltaDisplay: MetricTrendDeltaDisplay = .percent
    ) -> MetricTrend {
        let previous = previousPoint.value
        let delta = currentPoint.value - previous
        let deltaPercent = (delta / previous) * 100
        let neutralThreshold = 0.05
        let trend = trendPresentation(delta: deltaPercent, neutralThreshold: neutralThreshold, lowerIsBetter: lowerIsBetter)
        let previousMonth = monthName(for: previousPoint.date).uppercased()
        guard abs(deltaPercent) > neutralThreshold else {
            return MetricTrend(
                label: "NO CHANGE VS \(previousMonth)",
                iconName: trend.iconName,
                color: trend.color
            )
        }

        let sign = abs(deltaPercent) > neutralThreshold ? (deltaPercent > 0 ? "+" : "-") : ""
        let deltaLabel: String = switch deltaDisplay {
        case .percent:
            "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
        case .currency:
            "\(sign)\(currencySymbol)\(formatDouble(abs(delta), fractionDigits: 2))"
        }

        return MetricTrend(
            label: "\(deltaLabel) VS \(previousMonth)",
            iconName: trend.iconName,
            color: trend.color
        )
    }

    func trendPresentation(delta: Double, neutralThreshold: Double, lowerIsBetter: Bool) -> (iconName: String, color: Color) {
        guard abs(delta) > neutralThreshold else {
            return ("minus", WorthItColor.textTertiary)
        }

        let isImprovement = lowerIsBetter ? delta < 0 : delta > 0
        let iconName = delta < 0 ? "arrow.down.right" : "arrow.up.right"
        let color = isImprovement ? Color(hex: 0x34D399) : WorthItColor.danger

        return (iconName, color)
    }

    var previousMonthName: String {
        monthName(for: previousMonthAsOfDate)
    }

    func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    var previousMonthAsOfDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        return calendar.date(byAdding: .second, value: -1, to: startOfCurrentMonth) ?? now
    }

    var expenseDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }

    var purchasePrice: Decimal {
        Decimal(string: activeScenario.purchasePrice) ?? 0
    }

    var doublePurchasePrice: Double {
        NSDecimalNumber(decimal: purchasePrice).doubleValue
    }

    var monthlyMetricTitle: String {
        activeScenario.acquisitionType == "loan" ? "Monthly Cost" : "Monthly Spend"
    }

    var expectedResaleValue: Decimal {
        decimalValue(activeScenario.expectedResaleValue)
    }

    var loanMonthlyPayment: Decimal {
        guard activeScenario.acquisitionType == "loan" else { return 0 }

        let principal = decimalValue(activeScenario.loanAmount)
        let months = Decimal(activeScenario.loanTermMonths ?? 0)
        let annualRate = decimalValue(activeScenario.loanAnnualInterestRate) / 100

        guard principal > 0, months > 0 else { return 0 }
        guard annualRate > 0 else { return principal / months }

        let monthlyRate = doubleValue(annualRate / 12)
        let monthCount = doubleValue(months)
        let principalValue = doubleValue(principal)
        let denominator = 1 - pow(1 + monthlyRate, -monthCount)

        guard denominator > 0 else { return 0 }
        return Decimal(principalValue * monthlyRate / denominator)
    }

    var currentMonthLoanInterest: Double {
        let calendar = Calendar(identifier: .gregorian)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
        return loanInterestCost(from: currentMonthStart, to: monthEnd)
    }

    var previousMonthLoanInterest: Double {
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = expenseHistoryMonthStart(for: previousMonthAsOfDate)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        return loanInterestCost(from: monthStart, to: monthEnd)
    }

    func loanInterestCost(from start: Date, to end: Date) -> Double {
        guard activeScenario.acquisitionType == "loan",
              let loanTermMonths = activeScenario.loanTermMonths,
              loanTermMonths > 0
        else {
            return 0
        }

        let principal = doubleValue(decimalValue(activeScenario.loanAmount))
        let annualRate = doubleValue(decimalValue(activeScenario.loanAnnualInterestRate) / 100)
        let monthlyPayment = doubleValue(loanMonthlyPayment)
        guard principal > 0, annualRate > 0, monthlyPayment > 0 else { return 0 }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        guard let loanEnd = calendar.date(byAdding: .month, value: loanTermMonths, to: loanStart) else { return 0 }

        let intervalStart = max(start, loanStart)
        let intervalEnd = min(end, loanEnd)
        guard intervalStart < intervalEnd else { return 0 }

        let monthlyRate = annualRate / 12
        var cursor = expenseHistoryMonthStart(for: intervalStart)
        var total = 0.0

        while cursor < intervalEnd {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: cursor) else {
                break
            }

            let monthOffset = max(calendar.dateComponents([.month], from: loanStart, to: cursor).month ?? 0, 0)
            let balanceBeforeMonth = principal * pow(1 + monthlyRate, Double(monthOffset))
                - monthlyPayment * ((pow(1 + monthlyRate, Double(monthOffset)) - 1) / monthlyRate)
            let monthlyInterest = max(balanceBeforeMonth, 0) * monthlyRate
            let overlapStart = max(intervalStart, cursor)
            let overlapEnd = min(intervalEnd, nextMonth)

            if overlapStart < overlapEnd {
                total += monthlyInterest
            }

            cursor = nextMonth
        }

        return total
    }

    var loanInterestTotal: Decimal {
        guard activeScenario.acquisitionType == "loan" else { return 0 }

        let months = Decimal(activeScenario.loanTermMonths ?? 0)
        let principal = decimalValue(activeScenario.loanAmount)
        return max(loanMonthlyPayment * months - principal, 0)
    }

    var currencySymbol: String {
        switch activeScenario.currency {
        case "USD":
            "$"
        case "GBP":
            "£"
        default:
            "€"
        }
    }

    var activeScenario: ScenarioListItem {
        displayedScenario ?? scenario
    }

    var hasActionError: Binding<Bool> {
        Binding(
            get: { actionError != nil },
            set: { isPresented in
                if !isPresented {
                    actionError = nil
                }
            }
        )
    }

    var costPerKmFinancingBinding: Binding<Bool> {
        Binding(
            get: { costPerKmIncludesFinancing },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.18)) {
                    costPerKmIncludesFinancing = newValue
                    selectedEfficiencyChartDate = nil
                    selectedMetricTrendDate = nil
                }
            }
        )
    }

}

private struct ChartLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = [
            CGPoint(x: rect.minX, y: rect.maxY * 0.82),
            CGPoint(x: rect.width * 0.18, y: rect.maxY * 0.74),
            CGPoint(x: rect.width * 0.35, y: rect.maxY * 0.62),
            CGPoint(x: rect.width * 0.52, y: rect.maxY * 0.50),
            CGPoint(x: rect.width * 0.70, y: rect.maxY * 0.47),
            CGPoint(x: rect.width * 0.86, y: rect.maxY * 0.39),
            CGPoint(x: rect.maxX, y: rect.maxY * 0.30),
        ]

        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
