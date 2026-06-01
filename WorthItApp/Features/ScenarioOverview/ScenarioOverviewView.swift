import Charts
import SwiftUI

struct ScenarioOverviewView: View {
    enum ChartRange: Hashable {
        case day
        case week
        case month
    }

    enum MetricTrendRange: Hashable {
        case oneYear
        case all
    }

    enum ScenarioTab: Hashable {
        case overview
        case expenses
        case mileage
        case insights
        case compare
        case addEntryChooser
        case logExpense
        case scheduleService
        case expenseHistory
        case metricDetail
        case logMileage
        case profile
    }

    enum EntryKind: Hashable {
        case expense
        case service
    }

    enum ScheduleTrigger: Hashable {
        case date
        case mileage

        var apiValue: String {
            switch self {
            case .date: "date"
            case .mileage: "mileage"
            }
        }
    }

    enum RecurringFrequency: String, CaseIterable, Identifiable {
        case weekly
        case monthly
        case yearly

        var id: String { rawValue }

        var title: String {
            switch self {
            case .weekly: "Weekly"
            case .monthly: "Monthly"
            case .yearly: "Yearly"
            }
        }
    }

    enum LogExpensePicker: String, Identifiable {
        case date
        case time

        var id: String { rawValue }
    }

    enum MileageMode: String, Hashable {
        case odometer
        case trip

        var eventType: String {
            switch self {
            case .odometer: "odometer_update"
            case .trip: "trip"
            }
        }
    }

    enum MileagePicker: String, Identifiable {
        case date
        case time

        var id: String { rawValue }
    }

    enum ExpenseCategory: String, CaseIterable, Identifiable {
        case fuel
        case repair
        case tires
        case wash
        case insurance

        var id: String { rawValue }

        var title: String {
            switch self {
            case .fuel: "Fuel"
            case .repair: "Repair"
            case .tires: "Tires"
            case .wash: "Wash"
            case .insurance: "Insurance"
            }
        }

        var systemName: String {
            switch self {
            case .fuel: "fuelpump"
            case .repair: "wrench"
            case .tires: "gearshape.2"
            case .wash: "shower"
            case .insurance: "shield"
            }
        }

        var costCategory: String {
            switch self {
            case .fuel: "fuel"
            case .repair: "repair"
            case .tires: "tires"
            case .wash: "wash"
            case .insurance: "insurance"
            }
        }
    }

    enum OverviewMetric: String, CaseIterable, Identifiable {
        case monthlyCost
        case costPerKm
        case totalOwnership
        case projectedGain
        case expectedResale
        case loanInterest

        var id: String { rawValue }
    }

    enum ExpenseHistoryFilter: String, CaseIterable, Identifiable {
        case all
        case fuel
        case service
        case insurance

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: "All"
            case .fuel: "Fuel"
            case .service: "Service"
            case .insurance: "Insurance"
            }
        }

        func contains(_ event: CostEvent) -> Bool {
            switch self {
            case .all:
                true
            case .fuel:
                event.category == "fuel"
            case .service:
                ["maintenance", "repair", "tires", "wash"].contains(event.category)
            case .insurance:
                event.category == "insurance"
            }
        }
    }

    struct MetricSlide: Identifiable {
        let id: OverviewMetric
        let title: String
        let value: String
        let subtitle: String?
        let footer: String?
        let footerIcon: String
        let footerColor: Color
        let progress: CGFloat
        let accentColor: Color
    }

    struct MetricTrend {
        let label: String
        let iconName: String
        let color: Color
    }

    struct ExpenseMonthGroup: Identifiable {
        let monthStart: Date
        let events: [CostEvent]

        var id: Date { monthStart }
    }

    struct ExpenseHistoryBar: Identifiable {
        let monthStart: Date
        let selectionId: String
        let label: String
        let total: Double
        let previousTotal: Double?
        let count: Int
        let isCurrentMonth: Bool

        var id: String { selectionId }
    }

    struct MetricTrendPoint: Identifiable {
        let date: Date
        let value: Double

        var id: Date { date }
    }

    struct MileageLogItem: Identifiable {
        enum Kind {
            case odometer
            case trip
        }

        let id: UUID
        let kind: Kind
        let title: String
        let subtitle: String
        let previousOdometer: Int?
        let currentOdometer: Int?
        let distance: Double?
        let unit: String
        let date: Date
    }

    let repository: ScenarioRepository
    let scenario: ScenarioListItem
    let onScenarioChanged: (ScenarioListItem) -> Void
    let onScenarioDeleted: () -> Void
    let onEditScenario: (ScenarioListItem) -> Void
    let onExitScenario: () -> Void

    @AppStorage("scenarioOverview.selectedMetric") private var selectedMetricId = OverviewMetric.monthlyCost.rawValue
    @AppStorage("scenarioOverview.enabledMetrics") private var enabledMetricIds = ""
    @State private var selectedTab: ScenarioTab = .overview
    @State private var expenseHistoryFilter: ExpenseHistoryFilter = .all
    @State private var selectedExpenseHistoryBarLabel: String?
    @State private var focusedExpenseHistoryMonthStart: Date?
    @State private var selectedDetailMetric: OverviewMetric = .monthlyCost
    @State private var selectedMetricTrendDate: Date?
    @State private var selectedMetricTrendRange: MetricTrendRange = .oneYear
    @State private var selectedEfficiencyChartDate: Date?
    @State private var scenarioTabPath: [ScenarioTab] = []
    @State private var selectedEntryKind: EntryKind = .expense
    @State private var expenseAmount = ""
    @State private var expenseDate = Date()
    @State private var activeLogExpensePicker: LogExpensePicker?
    @State private var activeMileagePicker: MileagePicker?
    @State private var editingCostEvent: CostEvent?
    @State private var editingUsageEvent: UsageEvent?
    @State private var expenseNotes = ""
    @State private var expenseCategory: ExpenseCategory = .fuel
    @State private var isRecurringExpense = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var recurringStartDate: Date?
    @State private var recurringEndDate: Date?
    @State private var selectedServiceType = "Select a service..."
    @State private var scheduleTrigger: ScheduleTrigger = .date
    @State private var serviceDate: Date?
    @State private var serviceMileage = ""
    @State private var isOptionalServiceDateEnabled = false
    @State private var isOptionalServiceMileageEnabled = false
    @State private var serviceDetails = ""
    @State private var mileageMode: MileageMode = .odometer
    @State private var mileageValue = ""
    @State private var mileageDate = Date()
    @State private var mileageNotes = ""
    @State private var chartRange: ChartRange = .month
    @State private var displayedScenario: ScenarioListItem?
    @State private var currentSummary: ScenarioSummary?
    @State private var previousMonthSummary: ScenarioSummary?
    @State private var costEvents: [CostEvent] = []
    @State private var usageEvents: [UsageEvent] = []
    @State private var summaryError: String?
    @State private var costEventsError: String?
    @State private var usageEventsError: String?
    @State private var isUpdatingFavorite = false
    @State private var isDeleting = false
    @State private var isSavingEntry = false
    @State private var showsDeleteConfirmation = false
    @State private var actionError: String?

    var body: some View {
        ZStack {
            WorthItColor.surfaceLowest.ignoresSafeArea()
            WITopSpotlight()
            atmosphericGlow

            VStack(spacing: 0) {
                topBar

                if showsScenarioNavigation {
                    scenarioNavigation
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
                bottomNav
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }

            if selectedTab == .expenses {
                stickyEntryCTA(title: costEvents.isEmpty ? "Add first expense" : "Add Entry", bottomPadding: 124) {
                    openAddEntryChooserFromMaintenance()
                }
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
                stickyEntryCTA(title: "Save Schedule") {
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

    private var topBar: some View {
        HStack(spacing: WorthItSpacing.m) {
            if canGoBackInScenario {
                Button {
                    popScenarioTab()
                } label: {
                    HStack(spacing: WorthItSpacing.m) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(WorthItColor.primaryContainer)
                            .frame(width: 28, height: 40)

                        topBarTitleText
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back from \(topBarTitle)")
            } else {
                topBarTitleText
            }

            Spacer()

            topBarTrailingAction
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground.opacity(0.70))
        .shadow(color: WorthItColor.primaryContainer.opacity(0.08), radius: 8)
    }

    private var topBarTitleText: some View {
        Text(topBarTitle)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(topBarTitleColor)
            .tracking(isEntryFlowScreen ? -0.4 : 1.2)
            .textCase(isEntryFlowScreen ? nil : .uppercase)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    private var topBarTitle: String {
        switch selectedTab {
        case .addEntryChooser:
            "Add Entry"
        case .logExpense:
            editingCostEvent == nil ? "Log Expense" : "Edit Expense"
        case .scheduleService:
            "Schedule Service"
        case .expenseHistory:
            "Expense History"
        case .metricDetail:
            selectedDetailMetricSlide?.title ?? "Metric Detail"
        case .logMileage:
            editingUsageEvent == nil ? "Log Mileage" : "Edit Mileage"
        default:
            activeScenario.name
        }
    }

    private var topBarTitleColor: Color {
        isEntryFlowScreen ? WorthItColor.primaryContainer : WorthItColor.textSecondary
    }

    private var isEntryFlowScreen: Bool {
        selectedTab == .addEntryChooser || selectedTab == .logExpense || selectedTab == .scheduleService || selectedTab == .expenseHistory || selectedTab == .metricDetail || selectedTab == .logMileage
    }

    private var showsScenarioNavigation: Bool {
        selectedTab != .addEntryChooser && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .expenseHistory && selectedTab != .metricDetail && selectedTab != .logMileage
    }

    private var showsBottomNav: Bool {
        selectedTab != .addEntryChooser && selectedTab != .logExpense && selectedTab != .scheduleService && selectedTab != .metricDetail && selectedTab != .logMileage
    }

    private var scrollBottomPadding: CGFloat {
        selectedTab == .expenses || selectedTab == .mileage ? 224 : 132
    }

    @ViewBuilder
    private var topBarTrailingAction: some View {
        if isEntryFlowScreen {
            Color.clear.frame(width: 28, height: 40)
        } else {
            switch selectedTab {
            case .overview:
                scenarioMenu
            case .expenses:
                topBarIconButton(systemName: "plus", accessibilityLabel: "Add entry") {
                    openAddEntryChooserFromMaintenance()
                }
            case .mileage:
                topBarIconButton(systemName: "plus", accessibilityLabel: "Add mileage history") {
                    openMileageForm()
                }
            case .insights:
                Color.clear.frame(width: 28, height: 40)
            case .compare:
                topBarIconButton(systemName: "plus", accessibilityLabel: "Add comparable option") {
                    actionError = "Comparable option editor is coming next."
                }
            case .profile:
                Color.clear.frame(width: 28, height: 40)
            default:
                Color.clear.frame(width: 28, height: 40)
            }
        }
    }

    private func topBarIconButton(systemName: String, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 28, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var scenarioMenu: some View {
        Menu {
            Button {
                Task { await toggleFavorite() }
            } label: {
                Label(
                    activeScenario.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                    systemImage: activeScenario.isFavorite ? "star.slash.fill" : "star.fill"
                )
            }
            .disabled(isUpdatingFavorite || isDeleting)

            Button {
                onEditScenario(activeScenario)
            } label: {
                Label("Edit Scenario", systemImage: "pencil.circle.fill")
            }
            .disabled(isDeleting)

            Divider()

            Button(role: .destructive) {
                showsDeleteConfirmation = true
            } label: {
                Label("Delete Scenario", systemImage: "trash.fill")
            }
            .disabled(isDeleting)
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .frame(width: 28, height: 40)
        }
        .tint(Color(hex: 0x26324A))
        .accessibilityLabel("More")
    }

    private var scenarioNavigation: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    scenarioChip("Overview", tab: .overview)
                    scenarioChip("Maintenance", tab: .expenses)
                    scenarioChip("Mileage", tab: .mileage)
                    scenarioChip("Insights", tab: .insights)
                    scenarioChip("Compare", tab: .compare)
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.vertical, WorthItSpacing.l)
            }
            .scrollIndicators(.hidden)
            .background(WorthItColor.pageBackground.opacity(0.46))
            .onChange(of: selectedTab) { _, tab in
                guard tab != .profile else { return }

                withAnimation(.easeInOut(duration: 0.20)) {
                    proxy.scrollTo(tab, anchor: .center)
                }
            }
        }
    }

    private func scenarioChip(_ title: String, tab: ScenarioTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            navigateScenarioTab(tab)
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
                .padding(.horizontal, WorthItSpacing.xl)
                .frame(height: 36)
                .background(isSelected ? WorthItColor.primaryContainer : Color(hex: 0x3A4666), in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(hex: 0x44474F), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .id(tab)
    }

    private var canGoBackInScenario: Bool {
        selectedTab != .overview && !scenarioTabPath.isEmpty
    }

    private func navigateScenarioTab(_ tab: ScenarioTab) {
        guard selectedTab != tab else { return }

        withAnimation(.easeInOut(duration: 0.20)) {
            if tab == .overview {
                scenarioTabPath = []
            } else {
                let previousTab = selectedTab == .profile ? ScenarioTab.overview : selectedTab
                scenarioTabPath.append(previousTab)
            }

            selectedTab = tab
        }
    }

    private func popScenarioTab() {
        guard let previousTab = scenarioTabPath.popLast() else { return }

        withAnimation(.easeInOut(duration: 0.20)) {
            if selectedTab == .logExpense {
                editingCostEvent = nil
            }
            if selectedTab == .logMileage {
                resetMileageForm()
            }
            selectedTab = previousTab
        }
    }

    private func openAddEntryChooserFromOverview() {
        resetEntryEditingState()

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.overview]
            selectedTab = .addEntryChooser
        }
    }

    private func openAddEntryChooserFromMaintenance() {
        resetEntryEditingState()

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.expenses]
            selectedTab = .addEntryChooser
        }
    }

    private func openMetricDetail(_ metric: OverviewMetric) {
        selectedDetailMetric = metric
        selectedMetricTrendDate = nil
        selectedMetricTrendRange = .oneYear

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.overview]
            selectedTab = .metricDetail
        }
    }

    private var mainKPI: some View {
        VStack(spacing: 0) {
            if availableMetrics.isEmpty {
                metricSlide(
                    MetricSlide(
                        id: .monthlyCost,
                        title: "Summary",
                        value: "—",
                        subtitle: nil,
                        footer: "ADD USAGE OR COST DATA",
                        footerIcon: "plus",
                        footerColor: WorthItColor.textTertiary,
                        progress: 0,
                        accentColor: WorthItColor.textTertiary
                    )
                )
            } else {
                TabView(selection: selectedMetricBinding) {
                    ForEach(availableMetrics) { metric in
                        metricSlide(metric)
                            .tag(metric.id.rawValue)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .frame(height: 210)

                metricPageDots
                    .padding(.top, WorthItSpacing.m)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WorthItSpacing.xxxxl)
        .background {
            GeometryReader { proxy in
                ZStack {
                    Ellipse()
                        .fill(WorthItColor.primaryContainer.opacity(0.16))
                        .frame(width: proxy.size.width * 0.78, height: 190)
                        .blur(radius: 54)
                        .offset(x: -18, y: -16)

                    Ellipse()
                        .fill(Color(hex: 0x2DD4BF).opacity(0.11))
                        .frame(width: proxy.size.width * 0.58, height: 168)
                        .blur(radius: 50)
                        .offset(x: proxy.size.width * 0.18, y: -30)
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
        }
    }

    private func metricSlide(_ metric: MetricSlide) -> some View {
        Button {
            openMetricDetail(metric.id)
        } label: {
            VStack(spacing: 0) {
                Text(metric.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .padding(.bottom, WorthItSpacing.s)

                Text(metric.value)
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-3.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                if let footer = metric.footer {
                    metricPill(text: footer, iconName: metric.footerIcon, color: metric.footerColor)
                        .padding(.top, WorthItSpacing.m)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 210)
        }
        .buttonStyle(.plain)
    }

    private func metricPill(text: String, iconName: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 9, weight: .bold))

            Text(text)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.25)
        }
        .foregroundStyle(color.opacity(0.85))
        .padding(.horizontal, 13)
        .padding(.vertical, 5)
        .background(color.opacity(0.10), in: Capsule())
        .overlay {
            Capsule().stroke(color.opacity(0.20), lineWidth: 1)
        }
    }

    private var metricPageDots: some View {
        HStack(spacing: 6) {
            ForEach(availableMetrics) { metric in
                Circle()
                    .fill(currentSelectedMetricId == metric.id.rawValue ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.28))
                    .frame(width: 5, height: 5)
            }
        }
        .opacity(availableMetrics.count > 1 ? 1 : 0)
    }

    private var quickActions: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: WorthItSpacing.m), count: 3), spacing: WorthItSpacing.m) {
            overviewAction(title: "Expense", systemName: "plus") {
                openAddEntryChooserFromOverview()
            }
            overviewAction(title: "Usage", systemName: "speedometer") {
                navigateScenarioTab(.mileage)
            }
            overviewAction(title: "Compare", systemName: "arrow.left.arrow.right") {
                navigateScenarioTab(.compare)
            }
        }
    }

    private func overviewAction(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 21, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 32, height: 28)

                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.3)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .overview:
            mainKPI
            quickActions
            if hasEfficiencyChartData {
                efficiencyCard
            }
            supportingMetrics
        case .expenses:
            addEntryContent
        case .mileage:
            mileageContent
        case .insights:
            insightsContent
        case .compare:
            compareContent
        case .addEntryChooser:
            addEntryChooserContent
        case .logExpense:
            logExpenseContent
        case .scheduleService:
            scheduleServiceContent
        case .expenseHistory:
            expenseHistoryContent
        case .metricDetail:
            metricDetailContent
        case .logMileage:
            logMileageContent
        case .profile:
            profileContent
        }
    }

    private var addEntryContent: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            if let costEventsError {
                WITipInfo(title: "Maintenance unavailable", bodyText: costEventsError, size: .medium, tone: .info)
            } else if costEvents.isEmpty {
                expensesEmptyState
            } else {
                expenseHero
                expensesList
            }

            maintenanceContent
        }
    }

    private var expenseHero: some View {
        VStack(spacing: WorthItSpacing.l) {
            VStack(spacing: WorthItSpacing.xs) {
                Text("TOTAL SPENT • \(currentMonthName.uppercased())")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                    .tracking(2.5)
                    .textCase(.uppercase)

                Text(currentMonthExpenseTotalDisplay)
                    .font(.system(size: 60, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 25)
            }

            metricPill(
                text: currentMonthTrend.label,
                iconName: currentMonthTrend.iconName,
                color: currentMonthTrend.color
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WorthItSpacing.l)
        .background {
            GeometryReader { proxy in
                ZStack {
                    Ellipse()
                        .fill(WorthItColor.primaryContainer.opacity(0.12))
                        .frame(width: proxy.size.width * 0.78, height: 176)
                        .blur(radius: 54)
                        .offset(x: -18, y: -20)

                    Ellipse()
                        .fill(Color(hex: 0x2DD4BF).opacity(0.08))
                        .frame(width: proxy.size.width * 0.58, height: 148)
                        .blur(radius: 50)
                        .offset(x: proxy.size.width * 0.18, y: -34)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .allowsHitTesting(false)
            }
        }
    }

    private var expensesEmptyState: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            VStack(spacing: WorthItSpacing.xxl) {
                ZStack {
                    Circle()
                        .fill(WorthItColor.primaryContainer.opacity(0.10))
                        .frame(width: 144, height: 144)
                        .blur(radius: 32)

                    RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                        .fill(WorthItColor.surfaceContainer)
                        .frame(width: 96, height: 96)
                        .overlay {
                            Image(systemName: "receipt")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(WorthItColor.primaryContainer)
                        }
                }

                VStack(spacing: WorthItSpacing.m) {
                    Text("No expenses logged")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-0.6)

                    Text("Start tracking fuel, maintenance, and other\ncosts to see your true ownership story.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: WorthItSpacing.l), GridItem(.flexible(), spacing: WorthItSpacing.l)], spacing: WorthItSpacing.l) {
                expenseEducationCard(title: "Fuel Costs", subtitle: "Track efficiency and\nrange over time.", systemName: "fuelpump")
                expenseEducationCard(title: "Service", subtitle: "Keep your car in peak\ncondition.", systemName: "wrench.fill")
            }
        }
    }

    private func expenseEducationCard(title: String, subtitle: String, systemName: String) -> some View {
        VStack(alignment: .leading) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Spacer()

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(1)
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var expensesList: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                sectionTitle("Recent expenses")

                Button {
                    navigateScenarioTab(.expenseHistory)
                } label: {
                    Text("View all")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .buttonStyle(.plain)
            }

            if currentMonthExpenseEvents.isEmpty {
                currentMonthNoExpensesState
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(currentMonthExpenseEvents) { event in
                        expenseRow(event)
                    }
                }
            }
        }
    }

    private var currentMonthNoExpensesState: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("No expenses this month")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("You have older entries. Open the full history to review them.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var expenseHistoryContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            expenseHistoryHero
            expenseHistoryFilters

            if expenseHistoryGroups.isEmpty {
                WITipInfo(
                    title: "No expenses found",
                    bodyText: "There are no matching expenses for this filter yet.",
                    size: .medium,
                    tone: .info
                )
            } else {
                expenseHistoryGroupedList
            }
        }
    }

    private var expenseHistoryHero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("\(selectedExpenseHistoryBarTitle) spend")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.6)
                    .textCase(.uppercase)

                HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                    Text(selectedExpenseHistoryBarTotalDisplay)
                        .font(.system(size: 46, weight: .heavy))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-1.4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.54)

                    if let delta = selectedExpenseHistoryBarDeltaPercentDisplay {
                        Text(delta)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(WorthItColor.primaryContainer)
                            .padding(.bottom, 5)
                    }
                }

                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: selectedExpenseHistoryBarIconName)
                        .font(.system(size: 10, weight: .bold))

                    Text(selectedExpenseHistoryBarSubtitle)
                        .font(.system(size: 13, weight: .regular))
                }
                .foregroundStyle(WorthItColor.textSecondary)
            }

            expenseHistoryMiniBars
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack(alignment: .topTrailing) {
                WorthItColor.surfaceMetric

                Ellipse()
                    .fill(WorthItColor.primaryContainer.opacity(0.13))
                    .frame(width: 230, height: 180)
                    .blur(radius: 46)
                    .offset(x: 44, y: -48)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var expenseHistoryMiniBars: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                VStack(alignment: .trailing) {
                    Text("Max \(expenseHistoryBarMaxLabel)")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary)

                    Spacer()

                    Text("\(currencySymbol)0")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary)
                }
                .frame(width: 34, height: 96)

                GeometryReader { proxy in
                    ZStack(alignment: .bottom) {
                        VStack {
                            Rectangle()
                                .fill(WorthItColor.outlineSubtle.opacity(0.55))
                                .frame(height: 1)

                            Spacer()

                            Rectangle()
                                .fill(WorthItColor.outlineSubtle.opacity(0.55))
                                .frame(height: 1)
                        }

                        HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                            ForEach(expenseHistoryBars) { bar in
                                expenseHistoryMiniBar(bar, maxHeight: proxy.size.height)
                            }
                        }
                    }
                }
                .frame(height: 96)
            }

            HStack {
                Text("Spend")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.9)
                    .textCase(.uppercase)

                Spacer()

                Text("Month")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.9)
                    .textCase(.uppercase)
            }
            .padding(.leading, 34 + WorthItSpacing.m)
        }
    }

    private func expenseHistoryMiniBar(_ bar: ExpenseHistoryBar, maxHeight: CGFloat) -> some View {
        let isSelected = bar.selectionId == selectedExpenseHistoryBar.selectionId
        let height = expenseHistoryBarHeight(for: bar, maxHeight: maxHeight - 32)

        return Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                selectedExpenseHistoryBarLabel = bar.selectionId
                focusedExpenseHistoryMonthStart = bar.monthStart
            }
        } label: {
            VStack(spacing: WorthItSpacing.xs) {
                if isSelected {
                    Text(expenseHistoryBarValueLabel(for: bar))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                } else {
                    Text(" ")
                        .font(.system(size: 9, weight: .bold))
                }

                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .fill(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainerHigh.opacity(0.48))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)

                Text(bar.label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(bar.label) spend")
        .accessibilityValue("\(currencySymbol)\(formatDouble(bar.total, fractionDigits: 0))")
    }

    private var expenseHistoryFilters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: WorthItSpacing.s) {
                ForEach(ExpenseHistoryFilter.allCases) { filter in
                    expenseHistoryFilterChip(filter)
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
    }

    private func expenseHistoryFilterChip(_ filter: ExpenseHistoryFilter) -> some View {
        let isSelected = expenseHistoryFilter == filter

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                expenseHistoryFilter = filter
            }
        } label: {
            HStack(spacing: WorthItSpacing.s) {
                if isSelected {
                    Circle()
                        .fill(Color(hex: 0x122F5F))
                        .frame(width: 8, height: 8)
                }

                Text(filter.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(height: 40)
            .background(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var expenseHistoryGroupedList: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(expenseHistoryGroups) { group in
                VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                    expenseMonthHeader(group)

                    VStack(spacing: WorthItSpacing.m) {
                        ForEach(group.events) { event in
                            expenseHistoryRow(event)
                        }
                    }
                }
            }
        }
    }

    private func expenseMonthHeader(_ group: ExpenseMonthGroup) -> some View {
        HStack {
            Text(Self.monthYearFormatter.string(from: group.monthStart))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            Spacer()

            Text("Total: \(expenseHistoryGroupTotal(group))")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WorthItColor.textTertiary)
        }
        .padding(.leading, WorthItSpacing.l)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(group.monthStart == currentMonthStart ? WorthItColor.primaryContainer.opacity(0.32) : WorthItColor.outlineInput.opacity(0.60))
                .frame(width: 2)
        }
    }

    private func expenseHistoryRow(_ event: CostEvent) -> some View {
        Button {
            beginEditingExpense(event)
        } label: {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: expenseIconName(for: event.category))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(expenseAccentColor(for: event))
                    .frame(width: 48, height: 48)
                    .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(expenseTitle(for: event))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(expenseHistorySubtitle(for: event))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: WorthItSpacing.m)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(expenseAmountPrecise(event))
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(expenseBadgeText(for: event))
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(expenseAccentColor(for: event))
                        .tracking(0.1)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
            }
            .padding(WorthItSpacing.l)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private func expenseRow(_ event: CostEvent) -> some View {
        Button {
            beginEditingExpense(event)
        } label: {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: expenseIconName(for: event.category))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(expenseTitle(for: event))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(expenseSubtitle(for: event))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(expenseAmount(event))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
            }
            .padding(WorthItSpacing.l)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private var maintenanceContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            sectionTitle("Maintenance")

            VStack(spacing: WorthItSpacing.m) {
                wideAction(title: "Scheduled Services", subtitle: "Upcoming service reminders will live here.", systemName: "calendar.badge.clock")
                wideAction(title: "Completed Work", subtitle: "Finished services can be linked back to expenses.", systemName: "checkmark.seal.fill")
            }
        }
    }

    private var mileageContent: some View {
        VStack(alignment: .leading, spacing: 40) {
            mileageHeroCard
            mileageActivitySection
        }
    }

    private var mileageHeroCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("Current Odometer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(2.4)
                    .textCase(.uppercase)

                HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                    Text(formatInt(currentOdometerValue))
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-2.4)
                        .lineLimit(1)
                        .minimumScaleFactor(0.56)

                    Text("km")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
            }

            HStack(spacing: WorthItSpacing.l) {
                mileageHeroMetric(title: "Last Update", value: mileageLastUpdateText, color: WorthItColor.textPrimary)
                mileageHeroMetric(title: "This Month", value: mileageThisMonthText, color: WorthItColor.accentGold)
                mileageHeroMetric(title: "Avg / Day", value: mileageAveragePerDayText, color: WorthItColor.textPrimary)
            }
            .padding(.top, WorthItSpacing.xl)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(WorthItColor.outlineSubtle)
                    .frame(height: 1)
            }
        }
        .padding(WorthItSpacing.xxxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack(alignment: .topTrailing) {
                WorthItColor.surfaceContainer

                Circle()
                    .fill(WorthItColor.primaryContainer.opacity(0.05))
                    .frame(width: 256, height: 256)
                    .blur(radius: 32)
                    .offset(x: 80, y: -80)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .shadow(color: .black.opacity(0.30), radius: 50, y: 20)
    }

    private func mileageHeroMetric(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mileageActivitySection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack {
                Text("Log Activity")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.45)

                Spacer()

                Button {
                    actionError = "Mileage filters are coming next."
                } label: {
                    Text("Filter")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
                .buttonStyle(.plain)
            }

            if let usageEventsError {
                WITipInfo(
                    title: "Mileage unavailable",
                    bodyText: usageEventsError
                )
            } else if mileageLogItems.isEmpty {
                WITipInfo(
                    title: "No mileage logged",
                    bodyText: "No mileage logged yet. Log odometer updates or trips to make mileage history and cost per distance real."
                )
            } else {
                VStack(spacing: WorthItSpacing.l) {
                    ForEach(mileageLogItems) { item in
                        mileageLogRow(item)
                    }
                }
            }
        }
    }

    private func mileageLogRow(_ item: MileageLogItem) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: mileageIconName(for: item.kind))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(mileageAccentColor(for: item.kind))
                    .frame(width: 40, height: 40)
                    .background(mileageAccentColor(for: item.kind).opacity(item.kind == .trip ? 0.10 : 0.14), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(item.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: WorthItSpacing.m)

                Button {
                    beginEditingMileage(item.id)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .bottom) {
                mileageLogValue(item)

                Spacer(minLength: WorthItSpacing.m)

                VStack(alignment: .trailing, spacing: 1) {
                    Text(Self.mileageDateFormatter.string(from: item.date))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                        .textCase(.uppercase)

                    Text(Self.mileageTimeFormatter.string(from: item.date))
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary.opacity(0.40))
                }
            }
        }
        .padding(WorthItSpacing.xl)
        .background(Color(hex: 0x171B28), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
        .onTapGesture {
            beginEditingMileage(item.id)
        }
    }

    @ViewBuilder
    private func mileageLogValue(_ item: MileageLogItem) -> some View {
        switch item.kind {
        case .odometer:
            HStack(spacing: WorthItSpacing.s) {
                Text(item.previousOdometer.map(formatInt) ?? "—")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)

                Image(systemName: "arrow.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)

                Text(item.currentOdometer.map { "\(formatInt($0)) \(item.unit)" } ?? "—")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
            }
        case .trip:
            Text("+\(formatDouble(item.distance ?? 0, fractionDigits: 1)) \(item.unit)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.accentGold)
        }
    }

    private func mileageIconName(for kind: MileageLogItem.Kind) -> String {
        switch kind {
        case .odometer:
            "speedometer"
        case .trip:
            "point.topleft.down.curvedto.point.bottomright.up"
        }
    }

    private func mileageAccentColor(for kind: MileageLogItem.Kind) -> Color {
        switch kind {
        case .odometer:
            WorthItColor.primaryContainer
        case .trip:
            WorthItColor.accentGold
        }
    }

    private var currentOdometerValue: Int {
        let latestOdometerEvent = usageEvents
            .filter { $0.eventType == "odometer_update" }
            .sorted { $0.date > $1.date }
            .first
        let baseOdometer = latestOdometerEvent?.odometerValue ?? Double(activeScenario.purchaseOdometer ?? 0)
        let tripsAfterBase = usageEvents
            .filter { event in
                event.eventType == "trip" && latestOdometerEvent.map { event.date > $0.date } ?? true
            }
            .reduce(0) { $0 + $1.distanceValue }

        return max(Int((baseOdometer + tripsAfterBase).rounded()), 0)
    }

    private var mileageDisplayUnit: String {
        usageEvents.first?.distanceUnit ?? "km"
    }

    private var mileageThisMonthValue: Double {
        let calendar = Calendar.autoupdatingCurrent
        return mileageLogItems
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { total, item in
                switch item.kind {
                case .trip:
                    return total + (item.distance ?? 0)
                case .odometer:
                    guard let previous = item.previousOdometer, let current = item.currentOdometer else {
                        return total
                    }
                    return total + max(Double(current - previous), 0)
                }
            }
    }

    private var mileageLastUpdateText: String {
        guard let latestDate = usageEvents.map(\.date).max() else {
            return "No logs yet"
        }

        return Self.relativeMileageFormatter.localizedString(for: latestDate, relativeTo: Date())
    }

    private var mileageThisMonthText: String {
        mileageThisMonthValue > 0 ? "+\(formatDouble(mileageThisMonthValue, fractionDigits: 1)) \(mileageDisplayUnit)" : "—"
    }

    private var mileageAveragePerDayText: String {
        guard mileageThisMonthValue > 0 else { return "—" }
        let elapsedDays = max(Calendar.autoupdatingCurrent.component(.day, from: Date()), 1)
        return "\(formatDouble(mileageThisMonthValue / Double(elapsedDays), fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    private var mileageSaveTitle: String {
        if editingUsageEvent != nil {
            return "Save Changes"
        }

        return mileageMode == .trip ? "Save Trip" : "Save Reading"
    }

    private var previousOdometerForMileageForm: Int {
        guard let editingUsageEvent, editingUsageEvent.eventType == "odometer_update" else {
            return currentOdometerValue
        }

        return usageEvents
            .filter { $0.eventType == "odometer_update" && $0.date < editingUsageEvent.date }
            .sorted { $0.date > $1.date }
            .compactMap { $0.odometerValue.map { Int($0.rounded()) } }
            .first ?? activeScenario.purchaseOdometer ?? 0
    }

    private var previousOdometerText: String {
        previousOdometerForMileageForm > 0 ? "\(formatInt(previousOdometerForMileageForm)) \(mileageDisplayUnit)" : "—"
    }

    private var mileageOdometerDeltaText: String {
        guard let value = Double(mileageValue), previousOdometerForMileageForm > 0 else { return "—" }
        let delta = value - Double(previousOdometerForMileageForm)
        let sign = delta >= 0 ? "+" : "−"
        return "\(sign)\(formatDouble(abs(delta), fractionDigits: delta.rounded() == delta ? 0 : 1)) \(mileageDisplayUnit)"
    }

    private var resultingOdometerText: String {
        guard currentOdometerValue > 0, let tripDistance = Double(mileageValue), tripDistance > 0 else {
            return "—"
        }

        return "\(formatDouble(Double(currentOdometerValue) + tripDistance, fractionDigits: tripDistance.rounded() == tripDistance ? 0 : 1)) \(mileageDisplayUnit)"
    }

    private var mileageLogItems: [MileageLogItem] {
        let sortedEvents = usageEvents.sorted { $0.date < $1.date }
        var previousOdometer = activeScenario.purchaseOdometer
        var items: [MileageLogItem] = []

        for event in sortedEvents {
            switch event.eventType {
            case "odometer_update":
                let currentOdometer = event.odometerValue.map { Int($0.rounded()) }
                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .odometer,
                        title: "Odometer Update",
                        subtitle: mileageEventSubtitle(event.note, fallback: "Odometer reading"),
                        previousOdometer: previousOdometer,
                        currentOdometer: currentOdometer,
                        distance: nil,
                        unit: event.odometerUnit,
                        date: event.date
                    )
                )

                if let currentOdometer {
                    previousOdometer = currentOdometer
                }
            case "trip":
                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .trip,
                        title: "Trip Added",
                        subtitle: mileageEventSubtitle(event.note, fallback: "Trip"),
                        previousOdometer: nil,
                        currentOdometer: nil,
                        distance: event.distanceValue,
                        unit: event.distanceUnit,
                        date: event.date
                    )
                )
            default:
                break
            }
        }

        return items.sorted { $0.date > $1.date }
    }

    private func mileageEventSubtitle(_ note: String?, fallback: String) -> String {
        guard let note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallback
        }

        return note
    }

    private var logMileageContent: some View {
        VStack(alignment: .leading, spacing: 40) {
            WISegmentedControl(
                items: [
                    (title: "Update Odometer", value: MileageMode.odometer),
                    (title: "Add Trip", value: MileageMode.trip),
                ],
                selection: $mileageMode
            )
            .allowsHitTesting(editingUsageEvent == nil)
            .onChange(of: mileageMode) { _, newMode in
                guard editingUsageEvent == nil else { return }
                mileageValue = newMode == .odometer && currentOdometerValue > 0 ? "\(currentOdometerValue)" : ""
            }

            if mileageMode == .odometer {
                odometerMileageForm
            } else {
                tripMileageForm
            }

            if editingUsageEvent != nil {
                Button(role: .destructive) {
                    Task { await deleteEditingMileage() }
                } label: {
                    Text("Delete Mileage Entry")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.danger)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 120)
    }

    private var odometerMileageForm: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            mileageHeroInput(label: "Current Odometer (\(mileageDisplayUnit))", placeholder: "0")

            HStack(spacing: WorthItSpacing.l) {
                mileageStatTile(title: "Previous", value: previousOdometerText, color: WorthItColor.textPrimary)
                mileageStatTile(title: "Delta", value: mileageOdometerDeltaText, color: WorthItColor.accentGold)
            }

            mileageFormFields
        }
    }

    private var tripMileageForm: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            mileageHeroInput(label: "Trip Distance (\(mileageDisplayUnit))", placeholder: "0")

            mileageFormFields

            compactMileageResultRow(
                title: "Resulting Odometer",
                value: resultingOdometerText,
                systemName: "doc.text"
            )

            WITipInfo(
                title: "Usage Analytics",
                bodyText: "This trip improves your usage analytics and cost-per-\(mileageDisplayUnit) accuracy."
            )
        }
    }

    private var mileageFormFields: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(spacing: WorthItSpacing.l) {
                mileagePickerField(
                    label: "Date",
                    value: Self.shortDateFormatter.string(from: mileageDate),
                    systemName: "calendar"
                ) {
                    activeMileagePicker = .date
                }

                mileagePickerField(
                    label: "Time (optional)",
                    value: Self.timeFormatter.string(from: mileageDate),
                    systemName: "clock"
                ) {
                    activeMileagePicker = .time
                }
            }

            mileageNotesField
        }
    }

    private func mileageHeroInput(label: String, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            ZStack(alignment: .leading) {
                if mileageValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                }

                TextField("", text: $mileageValue)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: mileageValue) { _, newValue in
                        mileageValue = sanitizedDecimalInput(newValue)
                    }
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private func mileageStatTile(title: String, value: String, color: Color) -> some View {
        VStack(spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private func compactMileageResultRow(title: String, value: String, systemName: String) -> some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
        }
        .padding(21)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private func mileagePickerField(label: String, value: String, systemName: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            Button(action: action) {
                HStack(spacing: WorthItSpacing.s) {
                    Text(value)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    Spacer(minLength: WorthItSpacing.xs)

                    Image(systemName: systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.s)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var mileageNotesField: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Notes (optional)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                if mileageNotes.isEmpty {
                    Text("Add a description...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                        .padding(.top, 17)
                        .padding(.leading, 17)
                }

                TextEditor(text: $mileageNotes)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(12)
            }
            .frame(minHeight: 120)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private var addEntryChooserContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: WorthItSpacing.l) {
                entryOptionCard(
                    title: "Log Expense",
                    subtitle: "Record a completed cost: fuel, repairs, insurance, parts, wash, taxes, or one-off maintenance.",
                    systemName: "receipt",
                    kind: .expense
                )

                entryOptionCard(
                    title: "Schedule Service",
                    subtitle: "Plan upcoming service by date, mileage, or both, then track when it gets close.",
                    systemName: "wrench.fill",
                    kind: .service
                )
            }

            Spacer(minLength: 0)

            WIButton(title: "Continue") {
                if selectedEntryKind == .expense {
                    navigateScenarioTab(.logExpense)
                } else {
                    navigateScenarioTab(.scheduleService)
                }
            }
        }
        .frame(minHeight: 684, alignment: .top)
    }

    private var logExpenseContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            heroAmountField

            expenseCategorySection

            VStack(spacing: WorthItSpacing.l) {
                logDateField
                logTimeField
                notesField
            }

            recurringExpenseRow

            if editingCostEvent != nil {
                Button(role: .destructive) {
                    Task { await deleteEditingExpense() }
                } label: {
                    Text("Delete Expense")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.danger)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 104)
    }

    private var scheduleServiceContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text("What service is due?")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-1)

                Text("Select the required maintenance to keep your asset performing optimally.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            WISelectField(
                label: "Service type",
                options: serviceTypeSelectOptions,
                selection: $selectedServiceType
            )

            VStack(spacing: WorthItSpacing.xl) {
                triggerDivider

                WISegmentedControl(
                    items: [
                        (title: "Date", value: ScheduleTrigger.date),
                        (title: "Mileage", value: ScheduleTrigger.mileage),
                    ],
                    selection: $scheduleTrigger
                )
                .onChange(of: scheduleTrigger) { _, _ in
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isOptionalServiceDateEnabled = false
                        isOptionalServiceMileageEnabled = false
                    }
                }

                if scheduleTrigger == .date {
                    WIDateField(
                        label: "Service date",
                        placeholder: "MM/DD/YY",
                        date: $serviceDate
                    )

                    optionalScheduleMileageBlock
                } else {
                    WITextField(
                        label: "Due odometer",
                        placeholder: "0",
                        text: $serviceMileage,
                        trailingText: "km",
                        keyboardType: .numberPad
                    )

                    optionalScheduleDateBlock
                }
            }

            serviceDetailsField

            WITipInfo(
                title: "Smart Insight",
                bodyText: "Based on your driving history, your brake pads usually require attention around this time of year. Consider an inspection to be safe.",
                size: .medium,
                tone: .primary
            )
        }
        .padding(.bottom, 120)
    }

    private var optionalScheduleMileageBlock: some View {
        optionalTriggerBlock(
            title: "Add mileage trigger",
            subtitle: "Use odometer too, so the reminder fires by date or mileage, whichever comes first.",
            isEnabled: $isOptionalServiceMileageEnabled
        ) {
            WITextField(
                label: "Due odometer",
                placeholder: "0",
                text: $serviceMileage,
                trailingText: "km",
                keyboardType: .numberPad
            )
        }
    }

    private var optionalScheduleDateBlock: some View {
        optionalTriggerBlock(
            title: "Add date trigger",
            subtitle: "Use a date too, so the reminder fires by mileage or date, whichever comes first.",
            isEnabled: $isOptionalServiceDateEnabled
        ) {
            WIDateField(
                label: "Service date",
                placeholder: "MM/DD/YY",
                date: $serviceDate
            )
        }
    }

    private func optionalTriggerBlock<Content: View>(
        title: String,
        subtitle: String,
        isEnabled: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isEnabled.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: isEnabled.wrappedValue ? "minus.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)

                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text(title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            if isEnabled.wrappedValue {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private var serviceTypeSelectOptions: [String] {
        ["Select a service..."] + Self.defaultServiceTypeOptions
    }

    private static let defaultServiceTypeOptions = [
        "Oil Change",
        "Brake Pads",
        "Tires",
        "Inspection",
        "Battery",
        "Other",
    ]

    private var triggerDivider: some View {
        HStack(spacing: WorthItSpacing.m) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)

            Text("Triggered by")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                .tracking(1.4)
                .textCase(.uppercase)
                .lineLimit(1)

            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
    }

    private var heroAmountField: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Total Amount")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(currencySymbol)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                ZStack(alignment: .leading) {
                    if expenseAmount.isEmpty {
                        Text("0.00")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(WorthItColor.textPrimary)
                    }

                    TextField("", text: $expenseAmount)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .keyboardType(.decimalPad)
                        .onChange(of: expenseAmount) { _, newValue in
                            expenseAmount = sanitizedDecimalInput(newValue)
                        }
                }
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private var expenseCategorySection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack {
                Text("Category")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Spacer()

                Text("View All")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.primaryContainer)
            }
            .padding(.horizontal, WorthItSpacing.xs)

            ScrollView(.horizontal) {
                HStack(spacing: WorthItSpacing.m) {
                    ForEach(ExpenseCategory.allCases) { category in
                        expenseCategoryButton(category)
                    }
                }
                .padding(.horizontal, 1)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func expenseCategoryButton(_ category: ExpenseCategory) -> some View {
        let isSelected = expenseCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                expenseCategory = category
            }
        } label: {
            VStack(spacing: WorthItSpacing.s) {
                Image(systemName: category.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)

                Text(category.title)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.25)
            }
            .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
            .frame(width: 96, height: 96)
            .background(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(isSelected ? WorthItColor.primaryContainer : Color.clear, lineWidth: 1)
            }
            .shadow(color: isSelected ? WorthItColor.primaryContainer.opacity(0.15) : Color.clear, radius: 10)
        }
        .buttonStyle(.plain)
    }

    private var logDateField: some View {
        logPickerField(
            label: "Transaction Date",
            value: Self.fullDateFormatter.string(from: expenseDate),
            systemName: "calendar"
        ) {
            activeLogExpensePicker = .date
        }
    }

    private var logTimeField: some View {
        logPickerField(
            label: "Time",
            value: Self.timeFormatter.string(from: expenseDate),
            systemName: "clock"
        ) {
            activeLogExpensePicker = .time
        }
    }

    private func logPickerField(
        label: String,
        value: String,
        systemName: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            Button(action: action) {
                HStack {
                    Text(value)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Spacer()

                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 52)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
        }
    }

    private func logExpensePickerSheet(_ picker: LogExpensePicker) -> some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                Group {
                    switch picker {
                    case .date:
                        DatePicker(
                            "Transaction Date",
                            selection: $expenseDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(WorthItSpacing.xl)
                    case .time:
                        DatePicker(
                            "Time",
                            selection: $expenseDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding(WorthItSpacing.xl)
                    }
                }
                .tint(WorthItColor.primaryContainer)
            }
            .navigationTitle(picker == .date ? "Transaction Date" : "Time")
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        activeLogExpensePicker = nil
                    }
                    .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        activeLogExpensePicker = nil
                    }
                    .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Notes")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: WorthItSpacing.m) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.top, 2)

                    ZStack(alignment: .topLeading) {
                        if expenseNotes.isEmpty {
                            Text("Add details or receipt info...")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $expenseNotes)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(WorthItColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                }
                .padding(17)
            }
            .frame(minHeight: 110)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private var serviceDetailsField: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Details")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: WorthItSpacing.m) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.top, 2)

                    ZStack(alignment: .topLeading) {
                        if serviceDetails.isEmpty {
                            Text("Add specific instructions, part numbers, or preferred mechanic...")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $serviceDetails)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(WorthItColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                }
                .padding(17)
            }
            .frame(minHeight: 118)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private var recurringExpenseRow: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
                .padding(.bottom, WorthItSpacing.l)

            VStack(spacing: isRecurringExpense ? WorthItSpacing.xxl : 0) {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: 0x3A4666), in: Circle())

                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text("Recurring Cost")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text(recurringSubtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: recurringExpenseBinding)
                        .labelsHidden()
                        .tint(WorthItColor.primaryContainer)
                }

                if isRecurringExpense {
                    recurringControls
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(isRecurringExpense ? WorthItSpacing.xl : 0)
            .background {
                if isRecurringExpense {
                    WorthItColor.surfaceContainerLow
                        .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
                        .overlay {
                            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.18), radius: 18, y: 10)
                }
            }
        }
    }

    private var recurringExpenseBinding: Binding<Bool> {
        Binding {
            isRecurringExpense
        } set: { newValue in
            withAnimation(.easeInOut(duration: 0.20)) {
                isRecurringExpense = newValue
                if newValue && recurringStartDate == nil {
                    recurringStartDate = expenseDate
                }
            }
        }
    }

    private var recurringSubtitle: String {
        guard isRecurringExpense else { return "Repeat this cost monthly" }

        return "Repeats \(recurringFrequency.title.lowercased())"
    }

    private var recurringControls: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text("Frequency")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.5)
                    .textCase(.uppercase)

                WISegmentedControl(
                    items: RecurringFrequency.allCases.map { (title: $0.title, value: $0) },
                    selection: $recurringFrequency
                )
            }

            HStack(alignment: .top, spacing: WorthItSpacing.m) {
                compactRecurringDateField(
                    label: "Start Date",
                    placeholder: "Today",
                    date: $recurringStartDate
                )

                compactRecurringDateField(
                    label: "End Date",
                    placeholder: "Optional",
                    date: $recurringEndDate
                )
            }
        }
    }

    private func compactRecurringDateField(label: String, placeholder: String, date: Binding<Date?>) -> some View {
        WIDateField(
            label: label,
            placeholder: placeholder,
            date: date
        )
        .frame(maxWidth: .infinity)
    }

    private func stickyEntryCTA(title: String, bottomPadding: CGFloat = 40, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground,
                    WorthItColor.surfaceLowest
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 48)
            .allowsHitTesting(false)

            WIButton(title: title, action: action)
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.bottom, bottomPadding)
            .background(WorthItColor.surfaceLowest)
        }
    }

    private func entryOptionCard(title: String, subtitle: String, systemName: String, kind: EntryKind) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedEntryKind = kind
            }
        } label: {
            WIOptionCard(
                title: title,
                subtitle: subtitle,
                systemIcon: systemName,
                state: selectedEntryKind == kind ? .selected : .normal
            )
        }
        .buttonStyle(.plain)
    }

    private var insightsContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            sectionTitle("Insights")

            WITipInfo(
                title: "Coming next",
                bodyText: "This area will summarize ownership patterns, anomalies, and smart recommendations.",
                size: .medium,
                tone: .info
            )
        }
    }

    private var compareContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            sectionTitle("Compare")

            WITipInfo(
                title: "Alternatives",
                bodyText: "Taxi, car sharing, rental, and public transport comparisons will live here.",
                size: .medium,
                tone: .info
            )
        }
    }

    private var profileContent: some View {
        ProfileView(defaultCurrency: activeScenario.currency)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(WorthItColor.textPrimary)
            .tracking(-0.75)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func wideAction(title: String, subtitle: String, systemName: String) -> some View {
        Button {} label: {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private var efficiencyCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("EFFICIENCY\nCOMPARISON")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-0.45)
                        .lineSpacing(2)

                    Text("Cost per \(mileageDisplayUnit.uppercased())\nMonthly")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(2)
                }

                Spacer()

                compactSegmentedControl
            }

            efficiencyChartReadout
            chart
        }
        .padding(.horizontal, WorthItSpacing.l)
        .padding(.vertical, WorthItSpacing.xxl)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 12)
    }

    private var compactSegmentedControl: some View {
        HStack(spacing: WorthItSpacing.xs) {
            compactSegment(title: "Day", value: ChartRange.day)
            compactSegment(title: "Week", value: ChartRange.week)
            compactSegment(title: "Month", value: ChartRange.month)
        }
        .padding(WorthItSpacing.xs)
        .background(WorthItColor.surfaceLowest, in: Capsule())
    }

    private func compactSegment(title: String, value: ChartRange) -> some View {
        Button {
            chartRange = value
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(chartRange == value ? Color(hex: 0x385283) : WorthItColor.textPrimary)
                .padding(.horizontal, 10)
                .frame(height: 20)
                .background(chartRange == value ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var efficiencyChartReadout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let point = selectedEfficiencyChartPoint {
                Text(efficiencyPointValueLabel(point))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(efficiencyAxisLabel(for: point.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .textCase(.uppercase)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 18)
    }

    private var chart: some View {
        Chart(efficiencyChartPoints) { point in
            LineMark(
                x: .value("Month", point.date),
                y: .value("Cost per km", point.value)
            )
            .foregroundStyle(WorthItColor.primaryContainer)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.catmullRom)

            PointMark(
                x: .value("Month", point.date),
                y: .value("Cost per km", point.value)
            )
            .foregroundStyle(WorthItColor.primaryContainer)
            .symbolSize(42)

            if let selectedPoint = selectedEfficiencyChartPoint, selectedPoint.id == point.id {
                RuleMark(x: .value("Selected month", selectedPoint.date))
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(
                    x: .value("Selected month", selectedPoint.date),
                    y: .value("Selected value", selectedPoint.value)
                )
                .foregroundStyle(WorthItColor.primaryContainer)
                .symbolSize(82)
            }
        }
        .chartXSelection(value: selectedEfficiencyChartDateBinding)
        .chartYScale(domain: 0...efficiencyChartYAxisMax)
        .chartXAxis {
            AxisMarks(values: efficiencyChartPoints.map(\.date)) { value in
                AxisGridLine()
                    .foregroundStyle(WorthItColor.outlineSubtle.opacity(0.24))

                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(efficiencyAxisLabel(for: date))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WorthItColor.textTertiary)
                            .textCase(.uppercase)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: efficiencyChartYAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(WorthItColor.outlineInput.opacity(0.40))

                AxisValueLabel {
                    if let rawValue = value.as(Double.self) {
                        Text("\(currencySymbol)\(formatDouble(rawValue, fractionDigits: 2))")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .frame(height: 208)
    }

    private var supportingMetrics: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: WorthItSpacing.l), GridItem(.flexible(), spacing: WorthItSpacing.l)], spacing: WorthItSpacing.l) {
            ForEach(availableMetrics) { metric in
                supportingMetric(metric)
            }
        }
    }

    private func supportingMetric(_ metric: MetricSlide) -> some View {
        Button {
            openMetricDetail(metric.id)
        } label: {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(metric.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(metric.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let subtitle = metric.subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(0.6)
                        .lineLimit(1)
                        .textCase(.uppercase)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(WorthItColor.outlineInput.opacity(0.35))
                        Capsule()
                            .fill(metric.accentColor)
                            .frame(width: proxy.size.width * metric.progress)
                    }
                }
                .frame(height: 4)
                .padding(.top, WorthItSpacing.s)
            }
            .padding(WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 108, maxHeight: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private var metricDetailContent: some View {
        let metric = selectedDetailMetricSlide ?? availableMetrics.first

        return VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            metricDetailHero(metric)
            metricDetailChart(metric)
            metricDetailInsightGrid(metric)
            metricDetailRecommendation(metric)
        }
    }

    private func metricDetailHero(_ metric: MetricSlide?) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(metric?.title ?? "Metric")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.5)
                .textCase(.uppercase)

            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                Text(metric?.value ?? "—")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-1.9)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                if let metric, let footer = metric.footer, footer != "NO PREVIOUS MONTH DATA" {
                    metricPill(text: footer, iconName: metric.footerIcon, color: metric.footerColor)
                        .padding(.bottom, 9)
                }
            }

            Text(metricDetailSubtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.86))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func metricDetailChart(_ metric: MetricSlide?) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack {
                Text(metricTrendTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.6)
                    .textCase(.uppercase)

                Spacer()

                HStack(spacing: WorthItSpacing.s) {
                    metricRangePill("1Y", range: .oneYear)
                    metricRangePill("ALL", range: .all)
                }
            }

            metricTrendReadout

            Chart(metricTrendPoints) { point in
                AreaMark(
                    x: .value("Month", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            (metric?.accentColor ?? WorthItColor.primaryContainer).opacity(0.24),
                            (metric?.accentColor ?? WorthItColor.primaryContainer).opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Month", point.date),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(metric?.accentColor ?? WorthItColor.primaryContainer)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

                if let selectedPoint = selectedMetricTrendPoint, selectedPoint.id == point.id {
                    RuleMark(x: .value("Selected month", selectedPoint.date))
                        .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                    PointMark(
                        x: .value("Selected month", selectedPoint.date),
                        y: .value("Selected value", selectedPoint.value)
                    )
                    .foregroundStyle(metric?.accentColor ?? WorthItColor.primaryContainer)
                    .symbolSize(72)
                }
            }
            .chartXSelection(value: selectedMetricTrendDateBinding)
            .chartYScale(domain: 0...metricTrendYAxisMax)
            .chartXAxis {
                AxisMarks(values: metricTrendAxisDates) { value in
                    AxisGridLine()
                        .foregroundStyle(WorthItColor.outlineSubtle.opacity(0.32))

                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(metricTrendAxisLabel(for: date))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(WorthItColor.textTertiary)
                                .textCase(.uppercase)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: metricTrendYAxisValues) { value in
                    AxisGridLine()
                        .foregroundStyle(WorthItColor.outlineSubtle.opacity(0.42))

                    AxisValueLabel {
                        if let rawValue = value.as(Double.self) {
                            Text(metricTrendYAxisLabel(rawValue))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(WorthItColor.textTertiary)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(height: 178)
        }
        .padding(WorthItSpacing.xxl)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var metricTrendReadout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let selectedPoint = selectedMetricTrendPoint {
                Text(metricTrendPointValueLabel(selectedPoint))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(metricTrendAxisLabel(for: selectedPoint.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .textCase(.uppercase)
            } else {
                Text("No data")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 18)
    }

    private func metricRangePill(_ title: String, range: MetricTrendRange) -> some View {
        let selected = selectedMetricTrendRange == range

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedMetricTrendRange = range
                selectedMetricTrendDate = nil
            }
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(selected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                .padding(.horizontal, WorthItSpacing.s)
                .frame(height: 24)
                .background(selected ? WorthItColor.surfaceContainerHigh : Color.clear, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
        }
        .buttonStyle(.plain)
    }

    private func metricDetailInsightGrid(_ metric: MetricSlide?) -> some View {
        VStack(spacing: WorthItSpacing.l) {
            metricWideInsight(metric)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: WorthItSpacing.l), GridItem(.flexible(), spacing: WorthItSpacing.l)], spacing: WorthItSpacing.l) {
                metricSmallInsight(
                    title: "Volatility Score",
                    value: metricVolatilityValue,
                    body: "Stable enough for planning, but improves as more real entries are logged.",
                    systemName: "chart.xyaxis.line"
                )

                metricSmallInsight(
                    title: "Action required",
                    value: metricActionValue,
                    body: metricMissingDataText,
                    systemName: "exclamationmark.triangle.fill",
                    tone: .danger
                )
            }
        }
    }

    private func metricWideInsight(_ metric: MetricSlide?) -> some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(WorthItColor.accentGold)
                .frame(width: 32, height: 32)
                .background(WorthItColor.accentGold.opacity(0.14), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text("Seasonal Adjustment")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(metricSeasonalText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private enum MetricInsightTone {
        case normal
        case danger
    }

    private func metricSmallInsight(title: String, value: String, body: String, systemName: String, tone: MetricInsightTone = .normal) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tone == .danger ? WorthItColor.danger : WorthItColor.primaryContainer)

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tone == .danger ? WorthItColor.danger : WorthItColor.textPrimary)
                .textCase(tone == .danger ? .uppercase : nil)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(tone == .danger ? WorthItColor.danger : WorthItColor.primaryContainer)

            Text(body)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            if tone == .danger {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.danger.opacity(0.10), lineWidth: 1)
            }
        }
    }

    private func metricDetailRecommendation(_ metric: MetricSlide?) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack {
                Text("Strategic recommendation")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.2)
                    .textCase(.uppercase)

                Spacer()

                Text("Certified")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x001A42))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .padding(.horizontal, WorthItSpacing.m)
                    .frame(height: 22)
                    .background(WorthItColor.primaryContainer, in: Capsule())
            }

            Text(metricRecommendationText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textPrimary.opacity(0.92))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            WIButton(title: "Generate Full Appraisal", iconSystemName: "doc.text", action: {
                actionError = "Full appraisal generation is coming next."
            })
            .padding(.top, WorthItSpacing.s)
        }
        .padding(WorthItSpacing.xxl)
        .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private var bottomNav: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground.opacity(0.92),
                    WorthItColor.pageBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)

            HStack {
                bottomNavItem(
                    systemName: "rectangle.portrait.and.arrow.right",
                    accessibilityLabel: "Exit scenario",
                    isSelected: false,
                    isMirrored: true
                ) {
                    onExitScenario()
                }
                bottomNavItem(
                    systemName: "house.fill",
                    accessibilityLabel: "Scenario home",
                    isSelected: selectedTab != .profile
                ) {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        selectedTab = .overview
                        scenarioTabPath = []
                    }
                }
                bottomNavItem(
                    systemName: "person.fill",
                    accessibilityLabel: "Profile",
                    isSelected: selectedTab == .profile
                ) {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        selectedTab = .profile
                        scenarioTabPath = []
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, WorthItSpacing.l)
            .padding(.bottom, 28)
            .background {
                WorthItColor.pageBackground
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: WorthItRadius.l, topTrailingRadius: WorthItRadius.l))
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(WorthItColor.outlineSubtle)
                            .frame(height: 1)
                    }
                    .shadow(color: .black.opacity(0.30), radius: 24, y: -8)
            }
        }
    }

    private func bottomNavItem(
        systemName: String,
        accessibilityLabel: String,
        isSelected: Bool,
        isMirrored: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: WorthItSpacing.xs) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.82))
                    .frame(width: 34, height: 28)
                    .scaleEffect(x: isMirrored ? -1 : 1, y: 1)

                Circle()
                    .fill(isSelected ? WorthItColor.primaryContainer : Color.clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: isSelected ? WorthItColor.primaryContainer.opacity(0.80) : Color.clear, radius: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var atmosphericGlow: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x2C4677).opacity(0.05))
                .frame(width: 234, height: 578)
                .blur(radius: 75)
                .offset(x: -180, y: 350)
        }
        .allowsHitTesting(false)
    }

    private var costPerKm: String {
        if let costPerKm = currentMonthlyCostPerDistanceValue {
            return "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))"
        }

        return "—"
    }

    private var currentMonthExpenseEvents: [CostEvent] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        return costEvents.filter { event in
            calendar.isDate(event.date, equalTo: now, toGranularity: .month)
            && calendar.isDate(event.date, equalTo: now, toGranularity: .year)
        }
        .sorted { $0.date > $1.date }
    }

    private var previousMonthExpenseEvents: [CostEvent] {
        let calendar = Calendar(identifier: .gregorian)
        let previous = previousMonthAsOfDate

        return costEvents.filter { event in
            calendar.isDate(event.date, equalTo: previous, toGranularity: .month)
            && calendar.isDate(event.date, equalTo: previous, toGranularity: .year)
        }
    }

    private var currentMonthExpenseTotal: Decimal {
        currentMonthExpenseEvents.reduce(Decimal(0)) { total, event in
            total + decimalValue(event.amount)
        }
    }

    private var currentMonthExpenseTotalDisplay: String {
        "\(currencySymbol)\(formatDecimal(currentMonthExpenseTotal, fractionDigits: 0))"
    }

    private var currentMonthExpenseCount: Int {
        currentMonthExpenseEvents.count
    }

    private var previousMonthExpenseTotal: Decimal {
        previousMonthExpenseEvents.reduce(Decimal(0)) { total, event in
            total + decimalValue(event.amount)
        }
    }

    private var previousMonthExpenseCount: Int {
        previousMonthExpenseEvents.count
    }

    private var currentMonthStart: Date {
        expenseHistoryMonthStart(for: Date())
    }

    private func expenseHistoryMonthStart(for date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func expenseHistoryMonthIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: expenseHistoryMonthStart(for: date))
    }

    private func expenseHistoryMonthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func expenseHistoryIsSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDate(lhs, equalTo: rhs, toGranularity: .month)
            && calendar.isDate(lhs, equalTo: rhs, toGranularity: .year)
    }

    private var currentMonthTrend: MetricTrend {
        guard currentMonthExpenseCount > 0 else {
            return MetricTrend(label: "NO DATA AVAILABLE FOR THIS MONTH", iconName: "info.circle.fill", color: WorthItColor.textTertiary)
        }

        guard previousMonthExpenseCount > 0 else {
            return MetricTrend(label: "NO PREVIOUS MONTH DATA", iconName: "minus", color: WorthItColor.textTertiary)
        }

        let current = currentMonthExpenseTotal
        let previous = previousMonthExpenseTotal
        let delta = current - previous
        let color = delta <= 0 ? Color(hex: 0x34D399) : WorthItColor.danger
        let sign = delta >= 0 ? "+" : "-"

        return MetricTrend(
            label: "\(sign)\(currencySymbol)\(formatDecimal(abs(delta), fractionDigits: 0)) VS \(previousMonthName.uppercased())",
            iconName: delta == 0 ? "minus" : (delta < 0 ? "arrow.down.right" : "arrow.up.right"),
            color: color
        )
    }

    private var currentMonthExpenseDeltaPercentDisplay: String {
        guard previousMonthExpenseTotal > 0 else { return "" }

        let current = doubleValue(currentMonthExpenseTotal)
        let previous = doubleValue(previousMonthExpenseTotal)
        let deltaPercent = ((current - previous) / previous) * 100
        let sign = deltaPercent >= 0 ? "+" : "-"
        return "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
    }

    private var expenseHistoryHeroSubtitle: String {
        guard currentMonthExpenseCount > 0 else {
            return "No expenses logged this month."
        }

        guard previousMonthExpenseCount > 0 else {
            return "No previous month data yet."
        }

        let direction = currentMonthExpenseTotal > previousMonthExpenseTotal ? "Higher" : "Lower"
        return "\(direction) than \(previousMonthName) total."
    }

    private var selectedExpenseHistoryBarLabelBinding: Binding<String?> {
        Binding {
            selectedExpenseHistoryBar.selectionId
        } set: { newValue in
            guard let newValue, expenseHistoryBars.contains(where: { $0.selectionId == newValue }) else { return }
            selectedExpenseHistoryBarLabel = newValue
        }
    }

    private var selectedExpenseHistoryBar: ExpenseHistoryBar {
        if let selectedExpenseHistoryBarLabel,
           let selected = expenseHistoryBars.first(where: { $0.selectionId == selectedExpenseHistoryBarLabel }) {
            return selected
        }

        return expenseHistoryBars.last ?? ExpenseHistoryBar(
            monthStart: currentMonthStart,
            selectionId: expenseHistoryMonthIdentifier(for: currentMonthStart),
            label: "Now",
            total: 0,
            previousTotal: nil,
            count: 0,
            isCurrentMonth: true
        )
    }

    private var selectedExpenseHistoryBarTitle: String {
        selectedExpenseHistoryBar.isCurrentMonth ? "Current month" : selectedExpenseHistoryBar.label
    }

    private var selectedExpenseHistoryBarTotalDisplay: String {
        "\(currencySymbol)\(formatDouble(selectedExpenseHistoryBar.total, fractionDigits: 0))"
    }

    private var selectedExpenseHistoryBarDeltaPercentDisplay: String? {
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else { return nil }

        let deltaPercent = ((selectedExpenseHistoryBar.total - previousTotal) / previousTotal) * 100
        let sign = deltaPercent >= 0 ? "+" : "-"
        return "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
    }

    private var selectedExpenseHistoryBarIconName: String {
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else {
            return selectedExpenseHistoryBar.count > 0 ? "receipt" : "info.circle.fill"
        }

        let delta = selectedExpenseHistoryBar.total - previousTotal
        return delta == 0 ? "minus" : (delta < 0 ? "arrow.down.right" : "arrow.up.right")
    }

    private var selectedExpenseHistoryBarSubtitle: String {
        if selectedExpenseHistoryBar.count == 0 {
            return selectedExpenseHistoryBar.isCurrentMonth ? "No expenses logged this month." : "No expenses were logged in \(selectedExpenseHistoryBar.label)."
        }

        let entryWord = selectedExpenseHistoryBar.count == 1 ? "expense" : "expenses"
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else {
            return "\(selectedExpenseHistoryBar.count) \(entryWord) logged in \(selectedExpenseHistoryBar.label)."
        }

        let direction = selectedExpenseHistoryBar.total > previousTotal ? "Higher" : "Lower"
        return "\(direction) than previous month • \(selectedExpenseHistoryBar.count) \(entryWord)."
    }

    private var expenseHistoryBars: [ExpenseHistoryBar] {
        let calendar = Calendar(identifier: .gregorian)
        var starts = (0..<5).reversed().compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonthStart)
        }

        if let focusedExpenseHistoryMonthStart,
           !starts.contains(where: { expenseHistoryIsSameMonth($0, focusedExpenseHistoryMonthStart) }) {
            starts.append(focusedExpenseHistoryMonthStart)
            starts.sort()
        }

        return starts.map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart)
            let previousMonthEnd = previousMonthStart.flatMap { calendar.date(byAdding: .month, value: 1, to: $0) }
            let monthEvents = costEvents.filter { event in
                event.date >= monthStart && event.date < monthEnd
            }
            let total = costEvents.reduce(Decimal(0)) { partial, event in
                if event.date >= monthStart && event.date < monthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            }
            let previousTotal = costEvents.reduce(Decimal(0)) { partial, event in
                guard let previousMonthStart, let previousMonthEnd else { return partial }
                if event.date >= previousMonthStart && event.date < previousMonthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            }

            return ExpenseHistoryBar(
                monthStart: monthStart,
                selectionId: expenseHistoryMonthIdentifier(for: monthStart),
                label: expenseHistoryMonthLabel(for: monthStart),
                total: doubleValue(total),
                previousTotal: previousMonthStart == nil ? nil : doubleValue(previousTotal),
                count: monthEvents.count,
                isCurrentMonth: expenseHistoryIsSameMonth(monthStart, currentMonthStart)
            )
        }
    }

    private var expenseHistoryBarChartMax: Double {
        max(expenseHistoryBars.map(\.total).max() ?? 0, 1)
    }

    private var expenseHistoryBarMaxLabel: String {
        "\(currencySymbol)\(formatDouble(expenseHistoryBarChartMax, fractionDigits: 0))"
    }

    private func expenseHistoryBarValueLabel(for bar: ExpenseHistoryBar) -> String {
        "\(currencySymbol)\(formatDouble(bar.total, fractionDigits: 0))"
    }

    private func expenseHistoryBarHeight(for bar: ExpenseHistoryBar, maxHeight: CGFloat) -> CGFloat {
        guard expenseHistoryBarChartMax > 0 else { return 12 }

        let ratio = max(0, min(1, bar.total / expenseHistoryBarChartMax))
        if ratio == 0 {
            return bar.selectionId == selectedExpenseHistoryBar.selectionId ? 12 : 8
        }

        return max(16, maxHeight * ratio)
    }

    private var expenseHistoryGroups: [ExpenseMonthGroup] {
        let calendar = Calendar(identifier: .gregorian)
        let filteredEvents = costEvents
            .filter(expenseHistoryFilter.contains)
            .sorted { $0.date > $1.date }
        let grouped = Dictionary(grouping: filteredEvents) { event in
            calendar.date(from: calendar.dateComponents([.year, .month], from: event.date)) ?? event.date
        }

        return grouped
            .map { monthStart, events in
                ExpenseMonthGroup(monthStart: monthStart, events: events.sorted { $0.date > $1.date })
            }
            .sorted { $0.monthStart > $1.monthStart }
    }

    private var hasEfficiencyChartData: Bool {
        !efficiencyChartPoints.isEmpty
    }

    private var efficiencyChartPoints: [MetricTrendPoint] {
        monthlyEfficiencyChartPoints
    }

    private var monthlyEfficiencyChartPoints: [MetricTrendPoint] {
        monthlyEfficiencyTrendPoints(maxMonths: 12)
    }

    private var currentMonthlyCostPerDistanceValue: Double? {
        monthlyEfficiencyChartPoints.last?.value
    }

    private func monthlyEfficiencyTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        efficiencyMonthStarts(maxMonths: maxMonths).compactMap { monthStart in
            let cost = monthlyOwnershipCost(for: monthStart)
            let mileage = monthlyMileageDistance(for: monthStart)

            guard cost > 0, mileage > 0 else {
                return nil
            }

            return MetricTrendPoint(date: monthStart, value: cost / mileage)
        }
    }

    private func efficiencyMonthStarts(maxMonths: Int?) -> [Date] {
        let calendar = Calendar(identifier: .gregorian)
        let scenarioStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let start: Date
        if let maxMonths {
            let visibleStart = calendar.date(byAdding: .month, value: -(maxMonths - 1), to: currentMonthStart) ?? currentMonthStart
            start = max(scenarioStart, visibleStart)
        } else {
            start = scenarioStart
        }
        let monthCount = calendar.dateComponents([.month], from: start, to: currentMonthStart).month ?? 0

        return (0...max(monthCount, 0)).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: start)
        }
    }

    private func monthlyOwnershipCost(for monthStart: Date) -> Double {
        let loggedCosts = costEvents
            .filter { expenseHistoryIsSameMonth($0.date, monthStart) }
            .reduce(0) { total, event in
                total + doubleValue(decimalValue(event.amount))
            }

        return loggedCosts + monthlyLoanPayment(for: monthStart)
    }

    private func monthlyLoanPayment(for monthStart: Date) -> Double {
        guard activeScenario.acquisitionType == "loan",
              let loanTermMonths = activeScenario.loanTermMonths,
              loanTermMonths > 0
        else {
            return 0
        }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let loanEnd = calendar.date(byAdding: .month, value: loanTermMonths, to: loanStart) ?? loanStart

        guard monthStart >= loanStart, monthStart < loanEnd else {
            return 0
        }

        return doubleValue(loanMonthlyPayment)
    }

    private func monthlyMileageDistance(for monthStart: Date) -> Double {
        max(monthlyTripDistance(for: monthStart), monthlyOdometerDelta(for: monthStart))
    }

    private func monthlyTripDistance(for monthStart: Date) -> Double {
        guard let nextMonth = Calendar(identifier: .gregorian).date(byAdding: .month, value: 1, to: monthStart) else {
            return 0
        }

        return usageEvents
            .filter { event in
                event.eventType == "trip" && event.date >= monthStart && event.date < nextMonth
            }
            .reduce(0) { $0 + $1.distanceValue }
    }

    private func monthlyOdometerDelta(for monthStart: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return 0
        }

        let odometerEvents = usageEvents
            .filter { $0.eventType == "odometer_update" }
            .sorted { $0.date < $1.date }

        let baseline = odometerEvents
            .last { $0.date < monthStart }?
            .odometerValue ?? Double(activeScenario.purchaseOdometer ?? 0)
        let current = odometerEvents
            .last { $0.date < nextMonth }?
            .odometerValue ?? baseline

        return max(current - baseline, 0)
    }

    private var selectedEfficiencyChartDateBinding: Binding<Date?> {
        Binding {
            selectedEfficiencyChartDate ?? efficiencyChartPoints.last?.date
        } set: { newValue in
            guard let newValue else {
                selectedEfficiencyChartDate = nil
                return
            }

            selectedEfficiencyChartDate = nearestEfficiencyChartPoint(to: newValue)?.date
        }
    }

    private var selectedEfficiencyChartPoint: MetricTrendPoint? {
        guard let selectedEfficiencyChartDate else {
            return efficiencyChartPoints.last
        }

        return nearestEfficiencyChartPoint(to: selectedEfficiencyChartDate)
    }

    private func nearestEfficiencyChartPoint(to date: Date) -> MetricTrendPoint? {
        efficiencyChartPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    private var efficiencyChartYAxisMax: Double {
        max((efficiencyChartPoints.map(\.value).max() ?? 0) * 1.12, 1)
    }

    private var efficiencyChartYAxisValues: [Double] {
        let maxValue = efficiencyChartYAxisMax
        return [0, maxValue / 2, maxValue]
    }

    private func efficiencyAxisLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func efficiencyPointValueLabel(_ point: MetricTrendPoint) -> String {
        "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2)) / \(mileageDisplayUnit)"
    }

    private func expenseHistoryGroupTotal(_ group: ExpenseMonthGroup) -> String {
        let total = group.events.reduce(Decimal(0)) { partial, event in
            partial + decimalValue(event.amount)
        }

        return "\(currencySymbol)\(formatDecimal(total, fractionDigits: 2))"
    }

    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: Date())
    }

    private func expenseTitle(for event: CostEvent) -> String {
        event.note?.isEmpty == false ? event.note! : event.category.capitalized
    }

    private func expenseSubtitle(for event: CostEvent) -> String {
        "\(event.category.capitalized) • \(expenseDateFormatter.string(from: event.date))"
    }

    private func expenseHistorySubtitle(for event: CostEvent) -> String {
        let note = event.note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = note?.isEmpty == false ? note! : event.category.capitalized
        return "\(source) • \(expenseDateFormatter.string(from: event.date))"
    }

    private func expenseAmount(_ event: CostEvent) -> String {
        let symbol: String
        switch event.currency {
        case "USD":
            symbol = "$"
        case "GBP":
            symbol = "£"
        default:
            symbol = "€"
        }

        return "\(symbol)\(formatDecimal(decimalValue(event.amount), fractionDigits: 0))"
    }

    private func expenseAmountPrecise(_ event: CostEvent) -> String {
        let symbol: String
        switch event.currency {
        case "USD":
            symbol = "$"
        case "GBP":
            symbol = "£"
        default:
            symbol = "€"
        }

        return "\(symbol)\(formatDecimal(decimalValue(event.amount), fractionDigits: 2))"
    }

    private func expenseBadgeText(for event: CostEvent) -> String {
        if event.kind == "recurring" {
            return "Recurring"
        }

        switch event.category {
        case "repair", "maintenance", "tires":
            return "Maintenance"
        case "fuel", "wash":
            return "Approved"
        default:
            return event.category
        }
    }

    private func expenseAccentColor(for event: CostEvent) -> Color {
        switch event.category {
        case "fuel":
            WorthItColor.primaryContainer
        case "repair", "maintenance", "tires":
            WorthItColor.accentGold
        case "insurance":
            Color(hex: 0xBAC6EC)
        default:
            WorthItColor.textSecondary
        }
    }

    private func expenseIconName(for category: String) -> String {
        switch category {
        case "fuel":
            "fuelpump"
        case "maintenance", "repair":
            "wrench.fill"
        case "tires":
            "gearshape.2.fill"
        case "insurance":
            "shield.fill"
        case "parking":
            "parkingsign.circle.fill"
        case "tax":
            "building.columns.fill"
        case "wash":
            "sparkles"
        default:
            "receipt.fill"
        }
    }

    private func beginEditingExpense(_ event: CostEvent) {
        let returnTab = selectedTab
        editingCostEvent = event
        expenseAmount = plainAmount(event.amount)
        expenseDate = event.date
        expenseNotes = event.note ?? ""
        expenseCategory = expenseCategory(for: event.category)
        isRecurringExpense = event.kind == "recurring"

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [returnTab]
            selectedTab = .logExpense
        }
    }

    private func expenseCategory(for apiCategory: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: apiCategory) ?? .repair
    }

    private func plainAmount(_ value: String) -> String {
        let decimal = decimalValue(value)
        return formatDecimal(decimal, fractionDigits: decimal == Decimal(Int(truncating: NSDecimalNumber(decimal: decimal))) ? 0 : 2)
    }

    private var availableMetrics: [MetricSlide] {
        OverviewMetric.allCases
            .filter { enabledMetricSet.contains($0.rawValue) }
            .compactMap(metricSlide)
    }

    private var selectedDetailMetricSlide: MetricSlide? {
        metricSlide(for: selectedDetailMetric)
    }

    private var enabledMetricSet: Set<String> {
        let storedIds = enabledMetricIds
            .split(separator: ",")
            .map(String.init)

        if storedIds.isEmpty {
            return Set(OverviewMetric.allCases.map(\.rawValue))
        }

        return Set(storedIds)
    }

    private var metricDetailSubtitle: String {
        switch selectedDetailMetric {
        case .monthlyCost:
            "Shows the current monthly ownership load from loan payments and logged costs."
        case .costPerKm:
            "Shows how much each kilometer effectively costs after ownership costs and usage are combined."
        case .totalOwnership:
            "Shows the net cost of owning this car after purchase, known costs, and expected resale."
        case .projectedGain:
            "Shows potential upside after resale value exceeds purchase, interest, and non-daily costs."
        case .expectedResale:
            "Valuation estimate based on your scenario inputs and the latest resale assumptions."
        case .loanInterest:
            "Shows the projected interest paid across the loan term, separate from the vehicle value."
        }
    }

    private var metricSeasonalText: String {
        switch selectedDetailMetric {
        case .expectedResale, .projectedGain:
            "Market timing can move this metric. Seasonal demand may improve resale assumptions when the car remains in good condition."
        case .monthlyCost, .loanInterest:
            "Loan terms make this metric predictable, while logged maintenance can still create short-term spikes."
        case .costPerKm, .totalOwnership:
            "More usage data will make this trajectory more reliable and reduce noise from one-off expenses."
        }
    }

    private var metricMissingDataText: String {
        switch selectedDetailMetric {
        case .costPerKm:
            "Mileage history is needed for a precise trend."
        case .expectedResale, .projectedGain:
            "Condition and market comps will improve accuracy."
        default:
            "More monthly history will improve comparison."
        }
    }

    private var metricActionValue: String {
        switch selectedDetailMetric {
        case .costPerKm:
            "Mileage"
        case .expectedResale, .projectedGain:
            "Market"
        default:
            "History"
        }
    }

    private var metricVolatilityValue: String {
        switch selectedDetailMetric {
        case .monthlyCost, .loanInterest:
            "Low"
        case .costPerKm, .totalOwnership:
            "Medium"
        case .projectedGain, .expectedResale:
            "Low"
        }
    }

    private var metricRecommendationText: String {
        switch selectedDetailMetric {
        case .monthlyCost:
            "Your monthly cost is mostly shaped by fixed payments and this month’s logged expenses. Keep logging maintenance so spikes are visible instead of hidden."
        case .costPerKm:
            "Add mileage history next. Once usage is known, this metric becomes one of the clearest signals for whether ownership is still worth it."
        case .totalOwnership:
            "Track resale and non-daily maintenance separately. This gives the cleanest view of real ownership cost over time."
        case .projectedGain:
            "Projected gain should stay conservative. Daily running costs are excluded, but loan interest and non-daily maintenance still matter."
        case .expectedResale:
            "Keep the resale estimate fresh. Small valuation shifts can meaningfully change whether this ownership scenario still looks attractive."
        case .loanInterest:
            "Loan interest is predictable but real. Keeping it visible prevents the financed purchase from looking cheaper than it actually is."
        }
    }

    private var metricTrendPoints: [MetricTrendPoint] {
        if selectedDetailMetric == .costPerKm {
            return monthlyEfficiencyTrendPoints(maxMonths: selectedMetricTrendRange == .oneYear ? 12 : nil)
        }

        let realPoints = realMetricTrendPoints
        if realPoints.count >= 2 {
            return realPoints
        }

        let calendar = Calendar(identifier: .gregorian)
        let current = metricCurrentNumericValue
        let pointCount = selectedMetricTrendRange == .oneYear ? 7 : metricTrendAllPointCount

        return (0..<pointCount).compactMap { index in
            calendar.date(byAdding: .month, value: index - (pointCount - 1), to: currentMonthStart).map {
                MetricTrendPoint(date: $0, value: current)
            }
        }
    }

    private var realMetricTrendPoints: [MetricTrendPoint] {
        realMetricTrendPoints(for: selectedDetailMetric)
    }

    private func realMetricTrendPoints(for metric: OverviewMetric) -> [MetricTrendPoint] {
        switch metric {
        case .monthlyCost:
            return twoPointTrend(previous: previousMonthlySpendValue, current: monthlySpendValue)
        case .costPerKm:
            return monthlyEfficiencyTrendPoints(maxMonths: 12)
        case .totalOwnership:
            return twoPointTrend(
                previous: previousOwnershipNetCost.map { max($0, 0) },
                current: totalOwnershipCost.map(doubleValue)
            )
        case .projectedGain, .expectedResale, .loanInterest:
            return []
        }
    }

    private func twoPointTrend(previous: Double?, current: Double?) -> [MetricTrendPoint] {
        [
            previous.map { MetricTrendPoint(date: expenseHistoryMonthStart(for: previousMonthAsOfDate), value: $0) },
            current.map { MetricTrendPoint(date: currentMonthStart, value: $0) }
        ]
        .compactMap { $0 }
        .sorted { $0.date < $1.date }
    }

    private var metricTrendAllPointCount: Int {
        let calendar = Calendar(identifier: .gregorian)
        let start = expenseHistoryMonthStart(for: activeScenario.startDate)
        let components = calendar.dateComponents([.month], from: start, to: currentMonthStart)
        return max((components.month ?? 0) + 1, 2)
    }

    private var metricTrendTitle: String {
        switch selectedDetailMetric {
        case .monthlyCost, .costPerKm, .totalOwnership:
            realMetricTrendPoints.count >= 2 ? "Monthly trend" : "Current baseline"
        case .projectedGain, .expectedResale, .loanInterest:
            "Current snapshot"
        }
    }

    private var selectedMetricTrendDateBinding: Binding<Date?> {
        Binding {
            selectedMetricTrendDate ?? metricTrendPoints.last?.date
        } set: { newValue in
            guard let newValue else {
                selectedMetricTrendDate = nil
                return
            }

            selectedMetricTrendDate = nearestMetricTrendPoint(to: newValue)?.date
        }
    }

    private var selectedMetricTrendPoint: MetricTrendPoint? {
        guard let selectedMetricTrendDate else {
            return metricTrendPoints.last
        }

        return nearestMetricTrendPoint(to: selectedMetricTrendDate)
    }

    private func nearestMetricTrendPoint(to date: Date) -> MetricTrendPoint? {
        metricTrendPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    private var metricTrendYAxisValues: [Double] {
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

    private var metricTrendYAxisMax: Double {
        max((metricTrendPoints.map(\.value).max() ?? 0) * 1.08, 1)
    }

    private func metricTrendYAxisLabel(_ value: Double) -> String {
        metricTrendPointValueLabel(MetricTrendPoint(date: Date(), value: value))
    }

    private func metricTrendPointValueLabel(_ point: MetricTrendPoint) -> String {
        switch selectedDetailMetric {
        case .costPerKm:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2))"
        default:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 0))"
        }
    }

    private var metricCurrentNumericValue: Double {
        switch selectedDetailMetric {
        case .monthlyCost:
            monthlySpendValue ?? 0
        case .costPerKm:
            currentMonthlyCostPerDistanceValue ?? 0
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

    private var metricTrendAxisDates: [Date] {
        guard let first = metricTrendPoints.first?.date, let last = metricTrendPoints.last?.date else {
            return []
        }

        let middleIndex = metricTrendPoints.count / 2
        return [first, metricTrendPoints[middleIndex].date, last]
    }

    private func metricTrendAxisLabel(for date: Date) -> String {
        if Calendar(identifier: .gregorian).isDate(date, equalTo: currentMonthStart, toGranularity: .month) {
            return "Present"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    private var selectedMetricBinding: Binding<String> {
        Binding(
            get: { currentSelectedMetricId },
            set: { selectedMetricId = $0 }
        )
    }

    private var currentSelectedMetricId: String {
        let availableIds = availableMetrics.map(\.id.rawValue)
        if availableIds.contains(selectedMetricId) {
            return selectedMetricId
        }

        return availableIds.first ?? OverviewMetric.monthlyCost.rawValue
    }

    private func metricSlide(for metric: OverviewMetric) -> MetricSlide? {
        switch metric {
        case .monthlyCost:
            guard monthlySpend != "—" else { return nil }
            let trend = monthlyCostTrend
            return MetricSlide(
                id: metric,
                title: "Monthly Cost",
                value: monthlySpend,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: monthlySpendProgress,
                accentColor: WorthItColor.primaryContainer.opacity(0.42)
            )
        case .costPerKm:
            guard currentMonthlyCostPerDistanceValue != nil else { return nil }
            let trend = costPerKmTrend
            return MetricSlide(
                id: metric,
                title: "Cost per KM",
                value: costPerKm,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: costPerKmProgress,
                accentColor: WorthItColor.primaryContainer.opacity(0.42)
            )
        case .totalOwnership:
            guard totalOwnershipCost != nil else { return nil }
            let trend = totalOwnershipTrend
            return MetricSlide(
                id: metric,
                title: "Total Ownership",
                value: totalOwnershipDisplay,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: totalOwnershipProgress,
                accentColor: WorthItColor.accentGold
            )
        case .projectedGain:
            guard projectedGain > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Projected Gain",
                value: "\(currencySymbol)\(formatDecimal(projectedGain, fractionDigits: 0))",
                subtitle: nil,
                footer: "RESALE ABOVE KNOWN COSTS",
                footerIcon: "arrow.up.right",
                footerColor: Color(hex: 0x34D399),
                progress: projectedGainProgress,
                accentColor: Color(hex: 0x34D399)
            )
        case .expectedResale:
            guard expectedResaleValue > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Expected Resale",
                value: expectedResaleDisplay,
                subtitle: nil,
                footer: expectedResaleValue >= purchasePrice ? "ABOVE PURCHASE PRICE" : nil,
                footerIcon: "arrow.up.right",
                footerColor: Color(hex: 0x34D399),
                progress: expectedResaleProgress,
                accentColor: expectedResaleColor
            )
        case .loanInterest:
            guard loanInterestTotal > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Loan Interest",
                value: "\(currencySymbol)\(formatDecimal(loanInterestTotal, fractionDigits: 0))",
                subtitle: loanPaymentSubtitle,
                footer: "OVER LOAN TERM",
                footerIcon: "banknote",
                footerColor: WorthItColor.textTertiary,
                progress: loanInterestProgress,
                accentColor: WorthItColor.accentGold.opacity(0.70)
            )
        }
    }

    private var monthlySpend: String {
        if let monthlySpendValue {
            return "\(currencySymbol)\(formatDouble(monthlySpendValue, fractionDigits: 0))"
        }

        return "—"
    }

    private var monthlySpendValue: Double? {
        let currentExpenses = doubleValue(currentMonthExpenseTotal)
        let loanPayment = doubleValue(loanMonthlyPayment)

        if loanPayment > 0 || currentExpenses > 0 {
            return loanPayment + currentExpenses
        }

        return monthlyCostValue(from: currentSummary)
    }

    private var loanPaymentSubtitle: String? {
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

    private var previousMonthlySpendValue: Double? {
        guard previousMonthExpenseCount > 0 else { return nil }

        let previousExpenses = doubleValue(previousMonthExpenseTotal)
        let loanPayment = doubleValue(loanMonthlyPayment)

        if loanPayment > 0 || previousExpenses > 0 {
            return loanPayment + previousExpenses
        }

        return monthlyCostValue(from: previousMonthSummary)
    }

    private func monthlyCostValue(from summary: ScenarioSummary?) -> Double? {
        guard
            let summary,
            summary.includedCostsTotal > 0,
            summary.ownershipWindow.monthsOwned > 0
        else {
            return nil
        }

        return summary.includedCostsTotal / summary.ownershipWindow.monthsOwned
    }

    private var totalOwnershipCost: Decimal? {
        guard purchasePrice > 0 else { return nil }
        guard ownershipNetCost > 0 else { return nil }
        return ownershipNetCost
    }

    private var totalOwnershipDisplay: String {
        guard let totalOwnershipCost else { return "—" }
        return "\(currencySymbol)\(formatDecimal(totalOwnershipCost, fractionDigits: 0))"
    }

    private var expectedResaleDisplay: String {
        expectedResaleValue > 0 ? "\(currencySymbol)\(formatDecimal(expectedResaleValue, fractionDigits: 0))" : "—"
    }

    private var projectedGain: Decimal {
        max(expectedResaleValue - purchasePrice - loanInterestTotal - nonDailyExpenseTotal, 0)
    }

    private var ownershipNetCost: Decimal {
        if let currentSummary {
            return Decimal(currentSummary.netOwnershipCost)
        }

        return purchasePrice + loanInterestTotal - expectedResaleValue
    }

    private var previousOwnershipNetCost: Double? {
        previousMonthSummary?.netOwnershipCost
    }

    private var monthlySpendProgress: CGFloat {
        if loanMonthlyPayment > 0 {
            return normalizedProgress(doubleValue(loanMonthlyPayment) / max(doublePurchasePrice / 12, 1))
        }

        if let currentSummary, currentSummary.includedCostsTotal > 0, currentSummary.ownershipWindow.monthsOwned > 0 {
            let averageMonthlyCosts = currentSummary.includedCostsTotal / currentSummary.ownershipWindow.monthsOwned
            return normalizedProgress(averageMonthlyCosts / max(doublePurchasePrice / 12, 1))
        }

        return 0
    }

    private var costPerKmProgress: CGFloat {
        guard let costPerKm = currentMonthlyCostPerDistanceValue else { return 0 }
        return normalizedProgress(costPerKm / 1.0)
    }

    private var totalOwnershipProgress: CGFloat {
        guard purchasePrice > 0, let totalOwnershipCost else { return 0 }
        return normalizedProgress(doubleValue(totalOwnershipCost) / doublePurchasePrice)
    }

    private var projectedGainProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }
        return normalizedProgress(doubleValue(projectedGain) / doublePurchasePrice)
    }

    private var loanInterestProgress: CGFloat {
        let principal = decimalValue(activeScenario.loanAmount)
        guard principal > 0 else { return 0 }
        return normalizedProgress(doubleValue(loanInterestTotal) / doubleValue(principal))
    }

    private var expectedResaleProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }

        return normalizedProgress(doubleValue(expectedResaleValue) / doublePurchasePrice)
    }

    private var expectedResaleColor: Color {
        expectedResaleValue >= purchasePrice ? Color(hex: 0x34D399) : WorthItColor.accentGold
    }

    private var nonDailyExpenseTotal: Decimal {
        costEvents.reduce(Decimal(0)) { total, event in
            if Self.dailyExpenseCategories.contains(event.category) {
                return total
            }

            return total + decimalValue(event.amount)
        }
    }

    private static let dailyExpenseCategories: Set<String> = ["fuel", "wash"]

    private var monthlyCostTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .monthlyCost), lowerIsBetter: true)
    }

    private var costPerKmTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .costPerKm), lowerIsBetter: true)
    }

    private var totalOwnershipTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .totalOwnership), lowerIsBetter: true)
    }

    private func metricTrend(points: [MetricTrendPoint], lowerIsBetter: Bool) -> MetricTrend {
        if summaryError != nil {
            return MetricTrend(label: "SUMMARY LOAD FAILED", iconName: "minus", color: WorthItColor.textTertiary)
        }

        guard let previous = points.dropLast().last?.value, let current = points.last?.value, previous > 0 else {
            return MetricTrend(label: "NO PREVIOUS MONTH DATA", iconName: "minus", color: WorthItColor.textTertiary)
        }

        let deltaPercent = ((current - previous) / previous) * 100
        let isNeutral = abs(deltaPercent) < 0.05
        let isBetter = lowerIsBetter ? deltaPercent < 0 : deltaPercent > 0
        let iconName = isNeutral ? "minus" : (deltaPercent < 0 ? "arrow.down.right" : "arrow.up.right")
        let color = isNeutral ? WorthItColor.textTertiary : (isBetter ? Color(hex: 0x34D399) : WorthItColor.danger)

        return MetricTrend(
            label: "\(formatDouble(abs(deltaPercent), fractionDigits: 1))% VS \(previousMonthName.uppercased())",
            iconName: iconName,
            color: color
        )
    }

    private var previousMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: previousMonthAsOfDate)
    }

    private var previousMonthAsOfDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        return calendar.date(byAdding: .second, value: -1, to: startOfCurrentMonth) ?? now
    }

    private var expenseDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }

    private var purchasePrice: Decimal {
        Decimal(string: activeScenario.purchasePrice) ?? 0
    }

    private var doublePurchasePrice: Double {
        NSDecimalNumber(decimal: purchasePrice).doubleValue
    }

    private var monthlyMetricTitle: String {
        activeScenario.acquisitionType == "loan" ? "Loan Payment" : "Monthly Spend"
    }

    private var expectedResaleValue: Decimal {
        decimalValue(activeScenario.expectedResaleValue)
    }

    private var loanMonthlyPayment: Decimal {
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

    private var loanInterestTotal: Decimal {
        guard activeScenario.acquisitionType == "loan" else { return 0 }

        let months = Decimal(activeScenario.loanTermMonths ?? 0)
        let principal = decimalValue(activeScenario.loanAmount)
        return max(loanMonthlyPayment * months - principal, 0)
    }

    private var currencySymbol: String {
        switch activeScenario.currency {
        case "USD":
            "$"
        case "GBP":
            "£"
        default:
            "€"
        }
    }

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "'Today,' d MMM yyyy"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let mileageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let mileageTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let relativeMileageFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitsStyle = .full
        return formatter
    }()

    private var activeScenario: ScenarioListItem {
        displayedScenario ?? scenario
    }

    private var hasActionError: Binding<Bool> {
        Binding(
            get: { actionError != nil },
            set: { isPresented in
                if !isPresented {
                    actionError = nil
                }
            }
        )
    }

    private func formatDecimal(_ value: Decimal, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0"
    }

    private func formatDouble(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func formatInt(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatEditableNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(value)
    }

    private func decimalValue(_ value: String?) -> Decimal {
        guard let value else { return 0 }
        return Decimal(string: value) ?? 0
    }

    private func sanitizedDecimalInput(_ value: String) -> String {
        var result = ""
        var hasSeparator = false

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasSeparator else { continue }
                result.append(".")
                hasSeparator = true
            }
        }

        return result
    }

    private func doubleValue(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    private func normalizedProgress(_ value: Double) -> CGFloat {
        CGFloat(min(max(value, 0), 1))
    }

    private func loadSummary() async {
        summaryError = nil
        costEventsError = nil
        usageEventsError = nil
        previousMonthSummary = nil

        async let summaryTask = repository.getSummary(scenarioId: activeScenario.id)
        async let costEventsTask = repository.listCostEvents(scenarioId: activeScenario.id)
        async let usageEventsTask = repository.listUsageEvents(scenarioId: activeScenario.id)

        do {
            currentSummary = try await summaryTask
        } catch {
            summaryError = String(describing: error)
        }

        do {
            costEvents = try await costEventsTask
        } catch {
            costEvents = []
            costEventsError = String(describing: error)
        }

        do {
            usageEvents = try await usageEventsTask
        } catch {
            usageEvents = []
            usageEventsError = String(describing: error)
        }

        if summaryError == nil {
            do {
                previousMonthSummary = try await repository.getSummary(scenarioId: activeScenario.id, asOfDate: previousMonthAsOfDate)
            } catch {
                previousMonthSummary = nil
            }
        }
    }

    private func openMileageForm(mode: MileageMode = .odometer) {
        resetMileageForm()
        mileageMode = mode
        if mode == .odometer, currentOdometerValue > 0 {
            mileageValue = "\(currentOdometerValue)"
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.mileage]
            selectedTab = .logMileage
        }
    }

    private func beginEditingMileage(_ usageEventId: UUID) {
        guard let event = usageEvents.first(where: { $0.id == usageEventId }) else { return }

        editingUsageEvent = event
        mileageMode = event.eventType == "odometer_update" ? .odometer : .trip
        mileageDate = event.date
        mileageNotes = event.note ?? ""

        if mileageMode == .odometer {
            mileageValue = event.odometerValue.map { formatEditableNumber($0) } ?? ""
        } else {
            mileageValue = formatEditableNumber(event.distanceValue)
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.mileage]
            selectedTab = .logMileage
        }
    }

    private func mileagePickerSheet(_ picker: MileagePicker) -> some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                Group {
                    switch picker {
                    case .date:
                        DatePicker(
                            "Date",
                            selection: $mileageDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(WorthItSpacing.xl)
                    case .time:
                        DatePicker(
                            "Time",
                            selection: $mileageDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding(WorthItSpacing.xl)
                    }
                }
                .tint(WorthItColor.primaryContainer)
            }
            .navigationTitle(picker == .date ? "Date" : "Time")
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        activeMileagePicker = nil
                    }
                    .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        activeMileagePicker = nil
                    }
                    .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    private func saveMileage() async {
        guard !isSavingEntry else { return }
        guard let value = Double(mileageValue), value > 0 else {
            actionError = mileageMode == .trip ? "Enter trip distance." : "Enter odometer reading."
            return
        }

        if mileageMode == .odometer, previousOdometerForMileageForm > 0, value < Double(previousOdometerForMileageForm) {
            actionError = "Odometer reading cannot be lower than previous reading."
            return
        }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            if let editingUsageEvent {
                _ = try await repository.updateUsageEvent(
                    usageEventId: editingUsageEvent.id,
                    request: UpdateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        durationMinutes: nil,
                        note: trimmedMileageNotes.isEmpty ? "" : trimmedMileageNotes
                    )
                )
            } else {
                _ = try await repository.createUsageEvent(
                    scenarioId: activeScenario.id,
                    request: CreateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        durationMinutes: nil,
                        note: trimmedMileageNotes.isEmpty ? nil : trimmedMileageNotes
                    )
                )
            }

            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    private func deleteEditingMileage() async {
        guard !isSavingEntry, let editingUsageEvent else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteUsageEvent(usageEventId: editingUsageEvent.id)
            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    private func saveExpense() async {
        guard !isSavingEntry else { return }
        guard let amount = Decimal(string: expenseAmount), amount > 0 else {
            actionError = "Enter expense amount."
            return
        }

        let savedExpenseDate = expenseDate

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            if let editingCostEvent {
                _ = try await repository.updateCostEvent(
                    costEventId: editingCostEvent.id,
                    request: UpdateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? "" : trimmedExpenseNotes
                    )
                )
            } else {
                _ = try await repository.createCostEvent(
                    scenarioId: activeScenario.id,
                    request: CreateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? nil : trimmedExpenseNotes
                    )
                )
            }

            await loadSummary()
            navigateAfterEntrySave(savedExpenseDate: savedExpenseDate)
            resetExpenseForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    private func deleteEditingExpense() async {
        guard !isSavingEntry, let editingCostEvent else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteCostEvent(costEventId: editingCostEvent.id)
            await loadSummary()
            navigateAfterEntrySave()
            resetExpenseForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    private func saveScheduledService() async {
        guard !isSavingEntry else { return }
        let title = selectedServiceType
        let note = trimmedServiceDetails

        guard title != "Select a service..." else {
            actionError = "Select service type."
            return
        }

        guard title != "Other" || !note.isEmpty else {
            actionError = "Add details for Other service type."
            return
        }

        let dueOdometer = Double(serviceMileage)
        let hasDate = serviceDate != nil
        let hasMileage = dueOdometer != nil
        let shouldSendDate = scheduleTrigger == .date || isOptionalServiceDateEnabled
        let shouldSendMileage = scheduleTrigger == .mileage || isOptionalServiceMileageEnabled

        if shouldSendDate && !hasDate {
            actionError = "Select service date."
            return
        }

        if shouldSendMileage && !hasMileage {
            actionError = "Enter due odometer."
            return
        }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            _ = try await repository.createScheduledService(
                scenarioId: activeScenario.id,
                request: CreateScheduledServiceRequest(
                    title: title,
                    category: scheduledServiceCategory(for: title),
                    triggerType: shouldSendDate && shouldSendMileage ? "date_or_mileage" : scheduleTrigger.apiValue,
                    dueDate: shouldSendDate ? serviceDate : nil,
                    dueOdometerValue: shouldSendMileage ? dueOdometer : nil,
                    repeatIntervalMonths: nil,
                    repeatIntervalValue: nil,
                    leadTimeDays: 30,
                    note: note.isEmpty ? nil : note
                )
            )

            await loadSummary()
            navigateAfterEntrySave()
            resetScheduledServiceForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    private var trimmedExpenseNotes: String {
        expenseNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedServiceDetails: String {
        serviceDetails.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedMileageNotes: String {
        mileageNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func resetExpenseForm() {
        editingCostEvent = nil
        expenseAmount = ""
        expenseDate = Date()
        expenseNotes = ""
        expenseCategory = .fuel
        isRecurringExpense = false
    }

    private func resetScheduledServiceForm() {
        selectedServiceType = "Select a service..."
        scheduleTrigger = .date
        serviceDate = nil
        serviceMileage = ""
        isOptionalServiceDateEnabled = false
        isOptionalServiceMileageEnabled = false
        serviceDetails = ""
    }

    private func resetMileageForm() {
        editingUsageEvent = nil
        mileageMode = .odometer
        mileageValue = ""
        mileageDate = Date()
        mileageNotes = ""
        activeMileagePicker = nil
    }

    private func navigateAfterEntrySave(savedExpenseDate: Date? = nil) {
        let savedMonthStart = savedExpenseDate.map { expenseHistoryMonthStart(for: $0) }
        let opensHistoryForSavedMonth = savedMonthStart.map { !expenseHistoryIsSameMonth($0, currentMonthStart) } ?? false
        let destination: ScenarioTab = scenarioTabPath.contains(.expenseHistory) || opensHistoryForSavedMonth ? .expenseHistory : .expenses

        if let savedMonthStart {
            focusedExpenseHistoryMonthStart = savedMonthStart
            selectedExpenseHistoryBarLabel = expenseHistoryMonthIdentifier(for: savedMonthStart)
            expenseHistoryFilter = .all
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = destination == .expenseHistory ? [.expenses] : []
            selectedTab = destination
        }
    }

    private func navigateAfterMileageSave() {
        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = []
            selectedTab = .mileage
        }
    }

    private func resetEntryEditingState() {
        if editingCostEvent != nil {
            resetExpenseForm()
        }
        if editingUsageEvent != nil {
            resetMileageForm()
        }
    }

    private func scheduledServiceCategory(for title: String) -> String {
        switch title {
        case "Brake Pads":
            "repair"
        case "Inspection":
            "inspection"
        case "Other":
            "other"
        default:
            "maintenance"
        }
    }

    private func toggleFavorite() async {
        guard !isUpdatingFavorite else { return }

        isUpdatingFavorite = true
        actionError = nil
        defer { isUpdatingFavorite = false }

        do {
            let updatedScenario = try await repository.updateScenario(
                scenarioId: activeScenario.id,
                request: UpdateScenarioRequest.favorite(!activeScenario.isFavorite)
            )
            displayedScenario = updatedScenario
            onScenarioChanged(updatedScenario)
        } catch {
            actionError = String(describing: error)
        }
    }

    private func deleteScenario() async {
        guard !isDeleting else { return }

        isDeleting = true
        actionError = nil
        defer { isDeleting = false }

        do {
            try await repository.deleteScenario(scenarioId: activeScenario.id)
            onScenarioDeleted()
            onExitScenario()
        } catch {
            actionError = String(describing: error)
        }
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
