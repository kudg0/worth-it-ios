import SwiftUI

extension ScenarioOverviewView {
    var recurringExpenseBinding: Binding<Bool> {
        Binding {
            isRecurringExpense
        } set: { newValue in
            withAnimation(.easeInOut(duration: 0.20)) {
                isRecurringExpense = newValue
                if newValue && recurringStartDate == nil {
                    recurringStartDate = expenseDate
                }
            }
        }
    }

    var recurringSubtitle: String {
        guard isRecurringExpense else { return "Repeat this cost monthly" }

        return "Repeats \(recurringFrequency.title.lowercased())"
    }

    var selectedExpenseScheduledService: ScheduledService? {
        guard let selectedExpenseScheduledServiceId else { return nil }
        return scheduledServices.first { $0.id == selectedExpenseScheduledServiceId }
    }

    var expenseLinkedServiceSubtitle: String {
        guard let service = selectedExpenseScheduledService else {
            return "Optional. Link this expense to maintenance or service work."
        }

        let completedText = shouldCompleteLinkedScheduledService ? " • will mark completed" : ""
        return "\(service.title)\(completedText)"
    }

    func expenseServiceOptionSubtitle(_ service: ScheduledService) -> String {
        let status = service.status.capitalized
        if let dueDate = service.dueDate {
            return "\(status) • due \(Self.serviceDateFormatter.string(from: dueDate))"
        }

        if let dueOdometer = service.dueOdometerValue {
            return "\(status) • due at \(formatDouble(dueOdometer, fractionDigits: 0)) \(service.dueOdometerUnit)"
        }

        return status
    }
}
