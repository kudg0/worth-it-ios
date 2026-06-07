import SwiftUI

extension ScenarioOverviewView {
    func beginCompletingScheduledService(_ serviceId: UUID) {
        guard let service = scheduledServices.first(where: { $0.id == serviceId }) else { return }

        resetExpenseForm()
        expenseCategory = expenseCategory(forScheduledServiceCategory: service.category)
        expenseNotes = service.note ?? service.title
        selectedExpenseScheduledServiceId = service.id
        shouldCompleteLinkedScheduledService = true
        isExpenseServiceLinkExpanded = true

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.expenses]
            selectedTab = .logExpense
        }
    }

    func saveExpense() async {
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
            let savedEvent: CostEvent
            if let editingCostEvent {
                savedEvent = try await repository.updateCostEvent(
                    costEventId: editingCostEvent.id,
                    request: UpdateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        scheduledServiceId: selectedExpenseScheduledServiceId,
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? "" : trimmedExpenseNotes
                    )
                )
            } else {
                savedEvent = try await repository.createCostEvent(
                    scenarioId: activeScenario.id,
                    request: CreateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        scheduledServiceId: selectedExpenseScheduledServiceId,
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? nil : trimmedExpenseNotes
                    )
                )
            }

            try await syncLinkedServiceCompletion(for: savedEvent)
            await loadSummary()
            navigateAfterEntrySave(savedExpenseDate: savedExpenseDate)
            resetExpenseForm()
        } catch {
            actionError = String(describing: error)
        }
    }

    func syncLinkedServiceCompletion(for event: CostEvent) async throws {
        if let selectedExpenseScheduledServiceId, shouldCompleteLinkedScheduledService {
            _ = try await repository.updateScheduledServiceCompletion(
                scheduledServiceId: selectedExpenseScheduledServiceId,
                request: UpdateScheduledServiceCompletionRequest(
                    status: "completed",
                    lastCompletedAt: event.date,
                    completedExpenseId: event.id
                )
            )
        }

        if let editingCostEvent,
           let oldServiceId = editingCostEvent.scheduledServiceId,
           oldServiceId != selectedExpenseScheduledServiceId,
           let oldService = scheduledServices.first(where: { $0.id == oldServiceId }),
           oldService.completedExpenseId == editingCostEvent.id {
            try await resetCompletedService(oldServiceId)
        }

        if let editingCostEvent,
           !shouldCompleteLinkedScheduledService,
           let serviceId = selectedExpenseScheduledServiceId,
           let service = scheduledServices.first(where: { $0.id == serviceId }),
           service.completedExpenseId == editingCostEvent.id {
            try await resetCompletedService(serviceId)
        }
    }

    func deleteEditingExpense() async {
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

    var trimmedExpenseNotes: String {
        expenseNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetExpenseForm() {
        editingCostEvent = nil
        expenseAmount = ""
        expenseDate = Date()
        expenseNotes = ""
        expenseCategory = .fuel
        isRecurringExpense = false
        isExpenseServiceLinkExpanded = false
        selectedExpenseScheduledServiceId = nil
        shouldCompleteLinkedScheduledService = false
    }

    func navigateAfterEntrySave(savedExpenseDate: Date? = nil) {
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
}
