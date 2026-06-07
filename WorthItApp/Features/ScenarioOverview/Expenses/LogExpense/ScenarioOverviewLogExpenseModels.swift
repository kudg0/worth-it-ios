import SwiftUI

extension ScenarioOverviewView {
    var logExpenseScreenModel: LogExpenseScreen.Model {
        LogExpenseScreen.Model(
            currencySymbol: currencySymbol,
            amount: $expenseAmount,
            category: $expenseCategory,
            dateText: Self.fullDateFormatter.string(from: expenseDate),
            timeText: Self.timeFormatter.string(from: expenseDate),
            notes: $expenseNotes,
            isRecurring: recurringExpenseBinding,
            recurringSubtitle: recurringSubtitle,
            recurringFrequency: $recurringFrequency,
            recurringStartDate: $recurringStartDate,
            recurringEndDate: $recurringEndDate,
            serviceLink: logExpenseServiceLinkModel,
            isEditing: editingCostEvent != nil,
            sanitizeAmount: sanitizedDecimalInput,
            onOpenDatePicker: { activeLogExpensePicker = .date },
            onOpenTimePicker: { activeLogExpensePicker = .time },
            onDelete: { Task { await deleteEditingExpense() } }
        )
    }

    var logExpenseServiceLinkModel: LogExpenseServiceLink.Model {
        LogExpenseServiceLink.Model(
            isExpanded: $isExpenseServiceLinkExpanded,
            selectedServiceId: $selectedExpenseScheduledServiceId,
            shouldCompleteService: $shouldCompleteLinkedScheduledService,
            scheduledServices: scheduledServices,
            subtitle: expenseLinkedServiceSubtitle,
            optionSubtitle: expenseServiceOptionSubtitle
        )
    }
}
