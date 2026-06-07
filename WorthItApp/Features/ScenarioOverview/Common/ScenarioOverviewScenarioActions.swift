import Foundation

extension ScenarioOverviewView {
    func resetEntryEditingState() {
        if editingCostEvent != nil {
            resetExpenseForm()
        }
        if editingUsageEvent != nil {
            resetMileageForm()
        }
        if editingScheduledService != nil {
            resetScheduledServiceForm()
        }
    }

    func toggleFavorite() async {
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

    func deleteScenario() async {
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
