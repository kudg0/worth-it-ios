import Foundation

extension ScenarioOverviewView {
    func loadSummary() async {
        summaryError = nil
        costEventsError = nil
        usageEventsError = nil
        alternativesError = nil
        scheduledServicesError = nil
        analyticsError = nil
        metricDetailError = nil
        previousMonthSummary = nil

        async let analyticsTask = repository.getAnalyticsOverview(scenarioId: activeScenario.id)
        async let summaryTask = repository.getSummary(scenarioId: activeScenario.id)
        async let comparisonTask = repository.getComparison(scenarioId: activeScenario.id)
        async let costEventsTask = repository.listCostEvents(scenarioId: activeScenario.id)
        async let usageEventsTask = repository.listUsageEvents(scenarioId: activeScenario.id)
        async let alternativesTask = repository.listAlternatives(scenarioId: activeScenario.id)
        async let alternativePresetsTask = repository.listAlternativePresets(region: activeScenario.region)
        async let scheduledServicesTask = repository.listScheduledServices(scenarioId: activeScenario.id)
        async let scheduledDueTask = repository.listScheduledServiceDueStates(scenarioId: activeScenario.id)
        async let scenarioSettingsTask = repository.getScenarioSettings(scenarioId: activeScenario.id)
        async let settingsOptionsTask = repository.getSettingsOptions()

        do {
            analyticsOverview = try await analyticsTask
            if let analyticsOverview {
                enabledMetricIds = analyticsOverview.enabledMetricIds.map(\.rawValue).joined(separator: ",")
                selectedMetricId = analyticsOverview.defaultMetricId.rawValue
            }
        } catch {
            analyticsOverview = nil
            analyticsError = userFacingLoadErrorMessage(for: error)
        }

        do {
            currentSummary = try await summaryTask
        } catch {
            summaryError = userFacingLoadErrorMessage(for: error)
        }

        do {
            currentComparison = try await comparisonTask
            normalizeSelectedBreakEvenAlternative()
        } catch {
            currentComparison = nil
            alternativesError = userFacingLoadErrorMessage(for: error)
        }

        do {
            costEvents = try await costEventsTask
        } catch {
            costEvents = []
            costEventsError = userFacingLoadErrorMessage(for: error)
        }

        do {
            usageEvents = try await usageEventsTask
        } catch {
            usageEvents = []
            usageEventsError = userFacingLoadErrorMessage(for: error)
        }

        do {
            alternatives = try await alternativesTask
        } catch {
            alternatives = []
            alternativesError = alternativesError ?? userFacingLoadErrorMessage(for: error)
        }

        do {
            alternativePresets = try await alternativePresetsTask
        } catch {
            alternativePresets = []
        }

        do {
            scheduledServices = try await scheduledServicesTask
        } catch {
            scheduledServices = []
            scheduledServicesError = userFacingLoadErrorMessage(for: error)
        }

        do {
            let dueResponse = try await scheduledDueTask
            scheduledServiceDueItems = dueResponse.items
        } catch {
            scheduledServiceDueItems = []
            scheduledServicesError = scheduledServicesError ?? userFacingLoadErrorMessage(for: error)
        }

        do {
            let settings = try await scenarioSettingsTask
            scenarioSettings = settings
            displayedScenario = activeScenario.applying(settings: settings)
        } catch {
            scenarioSettings = nil
        }

        do {
            scenarioSettingsOptions = try await settingsOptionsTask
        } catch {
            scenarioSettingsOptions = nil
        }

        if summaryError == nil {
            do {
                previousMonthSummary = try await repository.getSummary(scenarioId: activeScenario.id, asOfDate: previousMonthAsOfDate)
            } catch {
                previousMonthSummary = nil
            }
        }
    }

    func userFacingLoadErrorMessage(for error: Error) -> String {
        if case APIError.requestFailed(let statusCode, _) = error, statusCode >= 500 {
            return i18n.t("Worth It could not refresh this data. Try again in a moment.")
        }

        return i18n.t("Worth It could not refresh this data. Check your connection and try again.")
    }

    func selectedBreakEvenStorageKey(for scenarioId: UUID) -> String {
        "scenarioOverview.breakEvenBenchmark.\(scenarioId.uuidString)"
    }

    func normalizeSelectedBreakEvenAlternative() {
        let rows = currentComparison?.alternativeBreakEvens ?? []
        guard !rows.isEmpty else {
            selectedBreakEvenAlternativeId = nil
            return
        }

        if let selectedBreakEvenAlternativeId,
           rows.contains(where: { $0.alternativeId == selectedBreakEvenAlternativeId }) {
            return
        }

        if let preferredId = scenarioSettings?.analytics.savingsAlternativeId,
           rows.contains(where: { $0.alternativeId == preferredId }) {
            selectedBreakEvenAlternativeId = preferredId
            UserDefaults.standard.set(preferredId.uuidString, forKey: selectedBreakEvenStorageKey(for: activeScenario.id))
            return
        }

        let key = selectedBreakEvenStorageKey(for: activeScenario.id)
        if let stored = UserDefaults.standard.string(forKey: key),
           let storedId = UUID(uuidString: stored),
           rows.contains(where: { $0.alternativeId == storedId }) {
            selectedBreakEvenAlternativeId = storedId
            return
        }

        selectedBreakEvenAlternativeId = rows.first?.alternativeId
        if let selectedBreakEvenAlternativeId {
            UserDefaults.standard.set(selectedBreakEvenAlternativeId.uuidString, forKey: key)
        }
    }

    func selectBreakEvenAlternative(_ id: UUID) {
        selectedBreakEvenAlternativeId = id
        UserDefaults.standard.set(id.uuidString, forKey: selectedBreakEvenStorageKey(for: activeScenario.id))
        Task { await persistSelectedBreakEvenAlternative(id) }
    }

    @MainActor
    func persistSelectedBreakEvenAlternative(_ id: UUID) async {
        do {
            let settings = try await repository.updateScenarioSettings(
                scenarioId: activeScenario.id,
                request: ScenarioSettingsPatch(
                    analytics: ScenarioAnalyticsSettingsPatch(savingsAlternativeId: id)
                )
            )
            scenarioSettings = settings
            await reloadAnalyticsOverview()
        } catch {
            actionError = WIUpdateErrorText.message(for: error)
        }
    }

    @MainActor
    func reloadAnalyticsOverview() async {
        do {
            let overview = try await repository.getAnalyticsOverview(scenarioId: activeScenario.id)
            analyticsOverview = overview
            enabledMetricIds = overview.enabledMetricIds.map(\.rawValue).joined(separator: ",")
            selectedMetricId = overview.defaultMetricId.rawValue
            analyticsError = nil
        } catch {
            analyticsError = userFacingLoadErrorMessage(for: error)
        }
    }

    func loadSelectedMetricDetail() async {
        isLoadingMetricDetail = true
        metricDetailError = nil
        selectedDetailMetricPayload = nil

        do {
            selectedDetailMetricPayload = try await repository.getAnalyticsMetric(
                scenarioId: activeScenario.id,
                metricId: selectedDetailMetric
            )
        } catch {
            metricDetailError = String(describing: error)
        }

        isLoadingMetricDetail = false
    }
}
