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
        async let scheduledServicesTask = repository.listScheduledServices(scenarioId: activeScenario.id)
        async let scheduledDueTask = repository.listScheduledServiceDueStates(scenarioId: activeScenario.id)

        do {
            analyticsOverview = try await analyticsTask
        } catch {
            analyticsOverview = nil
            analyticsError = String(describing: error)
        }

        do {
            currentSummary = try await summaryTask
        } catch {
            summaryError = String(describing: error)
        }

        do {
            currentComparison = try await comparisonTask
            normalizeSelectedBreakEvenAlternative()
        } catch {
            currentComparison = nil
            alternativesError = String(describing: error)
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

        do {
            alternatives = try await alternativesTask
        } catch {
            alternatives = []
            alternativesError = alternativesError ?? String(describing: error)
        }

        do {
            scheduledServices = try await scheduledServicesTask
        } catch {
            scheduledServices = []
            scheduledServicesError = String(describing: error)
        }

        do {
            let dueResponse = try await scheduledDueTask
            scheduledServiceDueItems = dueResponse.items
        } catch {
            scheduledServiceDueItems = []
            scheduledServicesError = scheduledServicesError ?? String(describing: error)
        }

        if summaryError == nil {
            do {
                previousMonthSummary = try await repository.getSummary(scenarioId: activeScenario.id, asOfDate: previousMonthAsOfDate)
            } catch {
                previousMonthSummary = nil
            }
        }
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
