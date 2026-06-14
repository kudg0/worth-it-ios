import SwiftUI

extension ScenarioOverviewView {
    @ViewBuilder
    var scheduledServiceDetailContent: some View {
        if let selectedScheduledServiceDetailId,
           let item = upcomingServiceItems.first(where: { $0.id == selectedScheduledServiceDetailId }) {
            ScheduledServiceDetailScreen(
                item: item,
                service: scheduledServices.first(where: { $0.id == selectedScheduledServiceDetailId }),
                dueSubtitle: serviceDueSubtitle,
                serviceStateTitle: serviceStateTitle,
                serviceStateColor: serviceStateColor,
                serviceIconName: serviceIconName,
                onEdit: beginEditingScheduledService,
                onCompleteWithExpense: beginCompletingScheduledService,
                onOpenActions: openScheduledServiceActions,
                onOpenResourceAction: { activeResourceAction = $0 }
            )
        } else {
            ScenarioWideAction(
                title: i18n.t("Service unavailable"),
                subtitle: i18n.t("Open the schedule again to refresh this reminder."),
                systemName: "calendar.badge.exclamationmark"
            )
        }
    }

    @ViewBuilder
    var expenseDetailContent: some View {
        if let selectedExpenseDetailId,
           let event = costEvents.first(where: { $0.id == selectedExpenseDetailId }) {
            ExpenseDetailScreen(
                event: event,
                scenarioName: activeScenario.name,
                amountText: expenseAmountPrecise(event),
                categoryTitle: expenseCategoryTitle(for: event.category),
                categoryIconName: expenseIconName(for: event.category),
                accentColor: expenseAccentColor(for: event),
                dateText: Self.shortDateFormatter.string(from: event.date),
                timeText: Self.timeFormatter.string(from: event.date),
                kindText: expenseKindTitle(for: event),
                monthText: expenseHistoryMonthLabel(for: event.date),
                linkedServiceTitle: expenseLinkedServiceTitle(for: event),
                weekRail: expenseWeekRailModel(for: event),
                onMoveWeek: moveExpenseDetailWeek,
                onSelectWeekDay: selectExpenseDetailDay,
                onOpenActions: { activeExpenseActionId = event.id },
                onOpenResourceAction: { activeResourceAction = $0 }
            )
        } else {
            ScenarioWideAction(
                title: i18n.t("Expense unavailable"),
                subtitle: i18n.t("Open expense history again to refresh this entry."),
                systemName: "receipt"
            )
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
        case .scheduledServices:
            ScheduledServicesScreen(
                month: scheduledServiceMonthBinding,
                selectedDate: $selectedScheduledServiceDate,
                ownershipStartDate: activeScenario.startDate,
                items: upcomingServiceItems,
                dueSubtitle: serviceDueSubtitle,
                serviceStateTitle: serviceStateTitle,
                serviceStateColor: serviceStateColor,
                serviceIconName: serviceIconName,
                onOpenScheduledService: openScheduledServiceDetail,
                onOpenScheduledServiceActions: openScheduledServiceActions
            )
        case .scheduledServiceDetail:
            scheduledServiceDetailContent
        case .expenseDetail:
            expenseDetailContent
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

}
