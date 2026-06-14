import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

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
    @State var selectedBreakEvenAlternativeId: UUID?
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
    @State var activeExpenseActionId: UUID?
    @State var activeExpenseDaySelection: ScenarioExpenseDaySelection?
    @State var activeScheduledServiceActionId: UUID?
    @State var activeResourceUploadSource: ScenarioResourceUploadSource?
    @State var activeResourceLinkEditor: ScenarioResourceLinkEditor?
    @State var activeResourceLocationEditor: ScenarioResourceLocationEditor?
    @State var activeResourceAction: ScenarioResourceAction?
    @State var selectedResourcePhotoItem: PhotosPickerItem?
    @State var pendingResourceFileOwner: ScenarioResourceOwner?
    @State var showsResourcePhotoPicker = false
    @State var showsResourceFileImporter = false
    @State var resourceLinkLabel = ""
    @State var resourceLinkURL = ""
    @State var resourceLocationLabel = ""
    @State var resourceLocationAddress = ""
    @State var resourceLocationLatitude = ""
    @State var resourceLocationLongitude = ""
    @State var selectedExpenseDetailId: UUID?
    @State var displayedExpenseDetailWeekStart: Date?
    @State var selectedScheduledServiceDetailId: UUID?
    @State var displayedScheduledServiceMonth: Date?
    @State var selectedScheduledServiceDate: Date?
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
    @State var analyticsOverview: ScenarioAnalyticsOverview?
    @State var selectedDetailMetricPayload: ScenarioAnalyticsMetricPayload?
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
    @State var analyticsError: String?
    @State var metricDetailError: String?
    @State var isLoadingMetricDetail = false
    @State var costEventsError: String?
    @State var usageEventsError: String?
    @State var alternativesError: String?
    @State var scheduledServicesError: String?
    @State var isUpdatingFavorite = false
    @State var isDeleting = false
    @State var isSavingEntry = false
    @State var showsScenarioActions = false
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
                    isDeleting: isDeleting,
                    onBack: popScenarioTab,
                    onOpenScenarioActions: { showsScenarioActions = true },
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
                stickyEntryCTA(title: i18n.t("Log Mileage"), bottomPadding: 124) {
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

            if let expenseId = activeExpenseActionId {
                ExpenseActionOverlay(
                    onDismiss: { activeExpenseActionId = nil },
                    onEdit: {
                        activeExpenseActionId = nil
                        beginEditingExpense(expenseId)
                    }
                )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if let activeResourceUploadSource {
                ScenarioResourceUploadSourceSheet(
                    onDismiss: { self.activeResourceUploadSource = nil },
                    onPickPhoto: {
                        self.activeResourceUploadSource = nil
                        pendingResourceFileOwner = owner(from: activeResourceUploadSource)
                        selectedResourcePhotoItem = nil
                        showsResourcePhotoPicker = true
                    },
                    onPickFile: {
                        self.activeResourceUploadSource = nil
                        pendingResourceFileOwner = owner(from: activeResourceUploadSource)
                        showsResourceFileImporter = true
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if let activeResourceAction {
                ScenarioResourceActionSheet(
                    action: activeResourceAction,
                    onDismiss: { self.activeResourceAction = nil },
                    onOpen: { openResource(activeResourceAction) },
                    onEdit: { editResource(activeResourceAction) },
                    onDelete: { Task { await deleteResource(activeResourceAction) } }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if showsScenarioActions {
                ScenarioActionsOverlay(
                    scenario: activeScenario,
                    isUpdatingFavorite: isUpdatingFavorite,
                    isDeleting: isDeleting,
                    onDismiss: { showsScenarioActions = false },
                    onToggleFavorite: {
                        showsScenarioActions = false
                        Task { await toggleFavorite() }
                    },
                    onEditScenario: {
                        showsScenarioActions = false
                        onEditScenario(activeScenario)
                    },
                    onDeleteScenario: {
                        showsScenarioActions = false
                        showsDeleteConfirmation = true
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
        .sheet(item: $activeExpenseDaySelection) { selection in
            expenseDaySelectionSheet(selection)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $activeResourceLinkEditor) { editor in
            ScenarioResourceLinkEditorSheet(
                title: resourceLinkEditorTitle(editor),
                label: $resourceLinkLabel,
                url: $resourceLinkURL,
                isSaving: isSavingEntry,
                onSave: { Task { await saveResourceLink(editor) } },
                onDelete: resourceLinkDeleteAction(editor)
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $activeResourceLocationEditor) { editor in
            ScenarioResourceLocationEditorSheet(
                title: resourceLocationEditorTitle(editor),
                label: $resourceLocationLabel,
                address: $resourceLocationAddress,
                latitude: $resourceLocationLatitude,
                longitude: $resourceLocationLongitude,
                isSaving: isSavingEntry,
                onSave: { Task { await saveResourceLocation(editor) } },
                onDelete: resourceLocationDeleteAction(editor)
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .photosPicker(
            isPresented: $showsResourcePhotoPicker,
            selection: $selectedResourcePhotoItem,
            matching: .images
        )
        .onChange(of: selectedResourcePhotoItem) { _, item in
            guard let item else { return }
            Task { await uploadResourcePhoto(item) }
        }
        .fileImporter(
            isPresented: $showsResourceFileImporter,
            allowedContentTypes: [.image, .pdf, .data],
            allowsMultipleSelection: false
        ) { result in
            Task { await handleResourceFileImport(result) }
        }
        .task(id: scenario.id) {
            displayedScenario = scenario
            selectedTab = .overview
            scenarioTabPath = []
            await loadSummary()
        }
    }


}
