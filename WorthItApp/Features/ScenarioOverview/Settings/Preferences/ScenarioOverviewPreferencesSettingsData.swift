import SwiftUI

extension ScenarioOverviewView {
    var preferencesSettingsScreen: ScenarioPreferencesSettingsScreen {
        ScenarioPreferencesSettingsScreen(
            currencyOptions: scenarioCurrencyOptions,
            regionOptions: scenarioRegionOptions,
            distanceOptions: scenarioDistanceOptions,
            currencyChangeAllowed: scenarioSettings?.currencyChangeAllowed ?? true,
            currencyChangeBlockedReason: scenarioSettings?.currencyChangeBlockedReason,
            isLoading: isLoadingScenarioSettings,
            isSaving: isSavingScenarioSettings,
            errorText: scenarioSettingsError,
            currency: $scenarioDraftCurrency,
            region: $scenarioDraftRegion,
            distanceUnit: $scenarioDraftDistanceUnit,
            onRetry: { Task { await loadScenarioSettings() } },
            onSave: { Task { await saveScenarioSettings() } },
            onDismissError: { scenarioSettingsError = nil }
        )
    }

    var scenarioCurrencyOptions: [WISelectSheetOption] {
        scenarioSettingsOptions?.currencies.map(scenarioOption) ?? [
            WISelectSheetOption(id: activeScenario.currency, title: activeScenario.currency, textBadge: activeScenario.currency)
        ]
    }

    var scenarioRegionOptions: [WISelectSheetOption] {
        scenarioSettingsOptions?.regions.map(scenarioOption) ?? [
            WISelectSheetOption(id: activeScenario.region, title: activeScenario.region)
        ]
    }

    var scenarioDistanceOptions: [WISelectSheetOption] {
        scenarioSettingsOptions?.distanceUnits.map(scenarioOption) ?? [
            WISelectSheetOption(id: activeScenario.baseUnit, title: activeScenario.baseUnit)
        ]
    }

    func openPreferencesSettings() {
        scenarioDraftCurrency = scenarioSettings?.currency ?? activeScenario.currency
        scenarioDraftRegion = scenarioSettings?.region ?? activeScenario.region
        scenarioDraftDistanceUnit = scenarioSettings?.distanceUnit ?? activeScenario.baseUnit
        scenarioSettingsError = nil

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(selectedTab)
            selectedTab = .preferencesSettings
        }

        Task {
            await loadScenarioSettings()
        }
    }

    @MainActor
    func loadScenarioSettings() async {
        guard !isLoadingScenarioSettings else { return }

        isLoadingScenarioSettings = true
        scenarioSettingsError = nil
        defer { isLoadingScenarioSettings = false }

        do {
            async let loadedSettings = repository.getScenarioSettings(scenarioId: activeScenario.id)
            async let loadedOptions = repository.getSettingsOptions()
            let (settings, options) = try await (loadedSettings, loadedOptions)

            scenarioSettings = settings
            scenarioSettingsOptions = options
            scenarioDraftCurrency = settings.currency
            scenarioDraftRegion = settings.region
            scenarioDraftDistanceUnit = settings.distanceUnit

            applyAnalyticsSettings(settings.analytics)
        } catch {
            scenarioSettingsError = friendlyScenarioSettingsError(error)
        }
    }

    @MainActor
    func saveScenarioSettings() async {
        guard !isSavingScenarioSettings else { return }

        isSavingScenarioSettings = true
        scenarioSettingsError = nil
        defer { isSavingScenarioSettings = false }

        do {
            let analytics = ScenarioAnalyticsSettingsPatch(
                enabledMetricIds: enabledMetricIdsForSave,
                defaultMetricId: selectedMetricId,
                costPerKmBasis: costPerKmBasisRawValue,
                includesResidualValue: includesVehicleResidualValue,
                deltaDisplay: analyticsDeltaDisplayRawValue,
                savingsAlternativeId: selectedBreakEvenAlternativeId
            )
            let settings = try await repository.updateScenarioSettings(
                scenarioId: activeScenario.id,
                request: ScenarioSettingsPatch(
                    currency: scenarioDraftCurrency,
                    region: scenarioDraftRegion,
                    distanceUnit: scenarioDraftDistanceUnit,
                    analytics: analytics
                )
            )

            scenarioSettings = settings
            let updatedScenario = activeScenario.applying(settings: settings)
            displayedScenario = updatedScenario
            onScenarioChanged(updatedScenario)
            applyAnalyticsSettings(settings.analytics)
            await loadSummary()
            popScenarioTab()
        } catch {
            scenarioSettingsError = friendlyScenarioSettingsError(error)
        }
    }

    func friendlyScenarioSettingsError(_ error: Error) -> String {
        WIUpdateErrorText.message(
            for: error,
            fallbackKey: .common.errors.update.settingsSaveChanges
        )
    }

    var enabledMetricIdsForSave: [String] {
        let ids = enabledMetricIds
            .split(separator: ",")
            .map(String.init)
            .filter { !$0.isEmpty }

        return ids.isEmpty ? ScenarioOverviewMetric.allCases.map(\.rawValue) : ids
    }

    func applyAnalyticsSettings(_ settings: ScenarioAnalyticsSettings) {
        enabledMetricIds = settings.enabledMetricIds.joined(separator: ",")
        selectedMetricId = settings.defaultMetricId
        costPerKmBasisRawValue = settings.costPerKmBasis
        includesVehicleResidualValue = settings.includesResidualValue
        analyticsDeltaDisplayRawValue = settings.deltaDisplay
        if let savingsAlternativeId = settings.savingsAlternativeId {
            selectedBreakEvenAlternativeId = savingsAlternativeId
            UserDefaults.standard.set(savingsAlternativeId.uuidString, forKey: selectedBreakEvenStorageKey(for: activeScenario.id))
        }
    }

    private func scenarioOption(_ option: UserSettingsOption) -> WISelectSheetOption {
        WISelectSheetOption(
            id: option.id,
            title: option.title,
            systemName: scenarioOptionSystemName(for: option.id),
            textBadge: scenarioOptionTextBadge(for: option.id),
            groupId: option.groupId,
            groupTitle: option.groupTitle
        )
    }

    private func scenarioOptionSystemName(for id: String) -> String? {
        switch id {
        case "EUR": "eurosign"
        case "USD": "dollarsign"
        case "GBP": "sterlingsign"
        case "JPY", "CNY": "yensign"
        case "km", "mi": "ruler"
        default:
            id.hasPrefix("en-") ? "globe.europe.africa" : nil
        }
    }

    private func scenarioOptionTextBadge(for id: String) -> String? {
        scenarioOptionSystemName(for: id) == nil ? id : nil
    }
}
