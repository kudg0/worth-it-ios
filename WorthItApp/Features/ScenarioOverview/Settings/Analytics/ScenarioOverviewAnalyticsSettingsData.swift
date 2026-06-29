import SwiftUI

extension ScenarioOverviewView {
    var analyticsModelScreen: ScenarioAnalyticsModelScreen {
        ScenarioAnalyticsModelScreen(
            perKmValue: analyticsPerKmPreview,
            monthlyValue: analyticsMonthlyPreview,
            lifetimeValue: analyticsLifetimePreview,
            includesResidualValue: $analyticsDraftIncludesResidualValue,
            defaultMetric: $analyticsDraftDefaultMetric,
            costPerKmBasis: $analyticsDraftCostPerKmBasis,
            deltaDisplay: $analyticsDraftDeltaDisplay,
            onReset: resetAnalyticsSettingsDraft,
            onSave: saveAnalyticsSettings
        )
    }

    var analyticsPerKmPreview: String {
        if let value = analyticsDraftCostPerKmValue {
            return "\(currencySymbol)\(formatDouble(value, fractionDigits: 2))/\(mileageDisplayUnit)"
        }

        return "—/\(mileageDisplayUnit)"
    }

    var costPerKmBasis: ScenarioAnalyticsCostPerKmBasis {
        ScenarioAnalyticsCostPerKmBasis(rawValue: costPerKmBasisRawValue) ?? .sincePurchase
    }

    var analyticsDeltaDisplay: ScenarioAnalyticsDeltaDisplay {
        ScenarioAnalyticsDeltaDisplay(rawValue: analyticsDeltaDisplayRawValue) ?? .absolute
    }

    var analyticsMetricTrendDeltaDisplay: MetricTrendDeltaDisplay {
        analyticsDeltaDisplay.metricTrendDisplay
    }

    var analyticsCostPerKmValue: Double? {
        switch costPerKmBasis {
        case .sincePurchase:
            return currentCostPerDistanceValue
        case .currentMonth:
            return currentMonthlyCostPerDistanceValue
        }
    }

    var analyticsDraftCostPerKmValue: Double? {
        switch analyticsDraftCostPerKmBasis {
        case .sincePurchase:
            return effectiveCostPerDistanceValue(
                asOf: Date(),
                includesResidualValue: analyticsDraftIncludesResidualValue
            )
        case .currentMonth:
            return currentMonthlyCostPerDistanceValue
        }
    }

    var analyticsMonthlyPreview: String {
        if let value = analyticsDraftMonthlyCostValue {
            return "\(currencySymbol)\(formatDouble(value, fractionDigits: 0))/mo"
        }

        return "—/mo"
    }

    var analyticsMonthlyCostValue: Double? {
        averageMonthlyEffectiveOwnershipCost(includesResidualValue: includesVehicleResidualValue)
    }

    var analyticsDraftMonthlyCostValue: Double? {
        averageMonthlyEffectiveOwnershipCost(includesResidualValue: analyticsDraftIncludesResidualValue)
    }

    func averageMonthlyEffectiveOwnershipCost(includesResidualValue: Bool) -> Double? {
        guard let monthsOwned = currentSummary?.ownershipWindow.monthsOwned, monthsOwned > 0 else {
            return monthlySpendValue
        }

        return effectiveOwnershipCost(to: Date(), includesResidualValue: includesResidualValue) / monthsOwned
    }

    var analyticsLifetimePreview: String {
        totalOwnershipDisplay
    }

    func openAnalyticsSettings() {
        analyticsDraftIncludesResidualValue = includesVehicleResidualValue
        analyticsDraftDefaultMetric = ScenarioAnalyticsDefaultMetric.fromOverviewMetricId(selectedMetricId)
        analyticsDraftCostPerKmBasis = ScenarioAnalyticsCostPerKmBasis.fromOverviewMetricId(selectedMetricId) ?? costPerKmBasis
        analyticsDraftDeltaDisplay = analyticsDeltaDisplay

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .analyticsSettings
        }
    }

    func resetAnalyticsSettingsDraft() {
        analyticsDraftIncludesResidualValue = true
        analyticsDraftDefaultMetric = .perKm
        analyticsDraftCostPerKmBasis = .sincePurchase
        analyticsDraftDeltaDisplay = .absolute
    }

    func saveAnalyticsSettings() {
        includesVehicleResidualValue = analyticsDraftIncludesResidualValue
        costPerKmBasisRawValue = analyticsDraftCostPerKmBasis.rawValue
        analyticsDeltaDisplayRawValue = analyticsDraftDeltaDisplay.rawValue
        selectedMetricId = analyticsDraftDefaultMetric == .perKm
            ? analyticsDraftCostPerKmBasis.overviewMetric.rawValue
            : analyticsDraftDefaultMetric.overviewMetric.rawValue

        Task {
            await persistAnalyticsSettings()
        }
    }

    @MainActor
    func persistAnalyticsSettings() async {
        do {
            let settings = try await repository.updateScenarioSettings(
                scenarioId: activeScenario.id,
                request: ScenarioSettingsPatch(
                    currency: activeScenario.currency,
                    region: activeScenario.region,
                    distanceUnit: activeScenario.baseUnit,
                    analytics: ScenarioAnalyticsSettingsPatch(
                        enabledMetricIds: enabledMetricIdsForSave,
                        defaultMetricId: selectedMetricId,
                        costPerKmBasis: costPerKmBasisRawValue,
                        includesResidualValue: includesVehicleResidualValue,
                        deltaDisplay: analyticsDeltaDisplayRawValue,
                        savingsAlternativeId: selectedBreakEvenAlternativeId
                    )
                )
            )

            scenarioSettings = settings
            applyAnalyticsSettings(settings.analytics)
            await loadSummary()
            popScenarioTab()
        } catch {
            actionError = WIUpdateErrorText.message(for: error)
        }
    }
}
