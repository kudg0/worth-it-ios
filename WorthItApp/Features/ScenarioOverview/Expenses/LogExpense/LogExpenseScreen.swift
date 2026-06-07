import SwiftUI

struct LogExpenseScreen: View {
    struct Model {
        let currencySymbol: String
        let amount: Binding<String>
        let category: Binding<ScenarioOverviewView.ExpenseCategory>
        let dateText: String
        let timeText: String
        let notes: Binding<String>
        let isRecurring: Binding<Bool>
        let recurringSubtitle: String
        let recurringFrequency: Binding<ScenarioOverviewView.RecurringFrequency>
        let recurringStartDate: Binding<Date?>
        let recurringEndDate: Binding<Date?>
        let serviceLink: LogExpenseServiceLink.Model
        let isEditing: Bool
        let sanitizeAmount: (String) -> String
        let onOpenDatePicker: () -> Void
        let onOpenTimePicker: () -> Void
        let onDelete: () -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            LogExpenseAmountField(
                currencySymbol: model.currencySymbol,
                amount: model.amount,
                sanitizeAmount: model.sanitizeAmount
            )

            LogExpenseCategorySection(category: model.category)

            VStack(spacing: WorthItSpacing.l) {
                LogExpensePickerField(label: "Transaction Date", value: model.dateText, systemName: "calendar", action: model.onOpenDatePicker)
                LogExpensePickerField(label: "Time", value: model.timeText, systemName: "clock", action: model.onOpenTimePicker)
                LogExpenseNotesField(title: "Notes", placeholder: "Add details or receipt info...", text: model.notes)
            }

            LogExpenseRecurringSection(
                isRecurring: model.isRecurring,
                subtitle: model.recurringSubtitle,
                frequency: model.recurringFrequency,
                startDate: model.recurringStartDate,
                endDate: model.recurringEndDate
            )

            LogExpenseServiceLink(model: model.serviceLink)

            if model.isEditing {
                LogExpenseDeleteButton(action: model.onDelete)
            }
        }
        .padding(.bottom, 104)
    }
}

private struct LogExpenseDeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Text("Delete Expense")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
