import SwiftUI

struct RecentExpensesList: View {
    let events: [CostEvent]
    let rowTitle: (CostEvent) -> String
    let rowSubtitle: (CostEvent) -> String
    let rowValue: (CostEvent) -> String
    let rowIcon: (CostEvent) -> String
    let rowAccentColor: (CostEvent) -> Color
    let onOpenHistory: () -> Void
    let onEditExpense: (CostEvent) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                ScenarioSectionTitle(title: "Recent expenses")

                Button(action: onOpenHistory) {
                    Text("View all")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .buttonStyle(.plain)
            }

            if events.isEmpty {
                CurrentMonthNoExpensesState()
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(events) { event in
                        WIInfoListRow(
                            title: rowTitle(event),
                            subtitle: rowSubtitle(event),
                            value: rowValue(event),
                            systemIcon: rowIcon(event),
                            accentColor: rowAccentColor(event),
                            action: { onEditExpense(event) }
                        )
                    }
                }
            }
        }
    }
}

private struct CurrentMonthNoExpensesState: View {
    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("No expenses this month")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("You have older entries. Open the full history to review them.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
