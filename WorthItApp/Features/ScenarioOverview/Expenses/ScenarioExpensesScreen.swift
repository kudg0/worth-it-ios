import SwiftUI

struct ScenarioExpensesScreen: View {
    struct Model {
        let costEventsError: String?
        let isEmpty: Bool
        let hero: ExpenseHero.Model
        let currentMonthEvents: [CostEvent]
        let maintenance: MaintenanceSection.Model
        let rowTitle: (CostEvent) -> String
        let rowSubtitle: (CostEvent) -> String
        let rowValue: (CostEvent) -> String
        let rowIcon: (CostEvent) -> String
        let rowAccentColor: (CostEvent) -> Color
        let onOpenHistory: () -> Void
        let onEditExpense: (CostEvent) -> Void
    }

    let model: Model

    var body: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            if let costEventsError = model.costEventsError {
                WITipInfo(title: "Maintenance unavailable", bodyText: costEventsError, size: .medium, tone: .info)
            } else if model.isEmpty {
                ExpensesEmptyState()
            } else {
                ExpenseHero(model: model.hero)
                RecentExpensesList(
                    events: model.currentMonthEvents,
                    rowTitle: model.rowTitle,
                    rowSubtitle: model.rowSubtitle,
                    rowValue: model.rowValue,
                    rowIcon: model.rowIcon,
                    rowAccentColor: model.rowAccentColor,
                    onOpenHistory: model.onOpenHistory,
                    onEditExpense: model.onEditExpense
                )
            }

            MaintenanceSection(model: model.maintenance)
        }
    }
}
