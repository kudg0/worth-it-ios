import SwiftUI

extension ScenarioOverviewView {
    func beginEditingExpense(_ event: CostEvent) {
        let returnTab = selectedTab
        editingCostEvent = event
        expenseAmount = plainAmount(event.amount)
        expenseDate = event.date
        expenseNotes = event.note ?? ""
        expenseCategory = expenseCategory(for: event.category)
        isRecurringExpense = event.kind == "recurring"
        selectedExpenseScheduledServiceId = event.scheduledServiceId
        isExpenseServiceLinkExpanded = event.scheduledServiceId != nil
        shouldCompleteLinkedScheduledService = scheduledServices.contains { service in
            service.completedExpenseId == event.id
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(returnTab)
            selectedTab = .logExpense
        }
    }

    func expenseCategory(for apiCategory: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: apiCategory) ?? .repair
    }

    func plainAmount(_ value: String) -> String {
        let decimal = decimalValue(value)
        return formatDecimal(decimal, fractionDigits: decimal == Decimal(Int(truncating: NSDecimalNumber(decimal: decimal))) ? 0 : 2)
    }
}
