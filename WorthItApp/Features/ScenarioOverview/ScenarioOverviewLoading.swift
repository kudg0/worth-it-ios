import Foundation

extension ScenarioOverviewView {
    func loadSummary() async {
        summaryError = nil
        costEventsError = nil
        usageEventsError = nil
        alternativesError = nil
        scheduledServicesError = nil
        previousMonthSummary = nil

        async let summaryTask = repository.getSummary(scenarioId: activeScenario.id)
        async let comparisonTask = repository.getComparison(scenarioId: activeScenario.id)
        async let costEventsTask = repository.listCostEvents(scenarioId: activeScenario.id)
        async let usageEventsTask = repository.listUsageEvents(scenarioId: activeScenario.id)
        async let alternativesTask = repository.listAlternatives(scenarioId: activeScenario.id)
        async let scheduledServicesTask = repository.listScheduledServices(scenarioId: activeScenario.id)
        async let scheduledDueTask = repository.listScheduledServiceDueStates(scenarioId: activeScenario.id)

        do {
            currentSummary = try await summaryTask
        } catch {
            summaryError = String(describing: error)
        }

        do {
            currentComparison = try await comparisonTask
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
}
