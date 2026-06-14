import SwiftUI

struct ScenarioExpensesScreen: View {
    struct Model {
        let costEventsError: String?
        let isEmpty: Bool
        let hero: ExpenseHero.Model
        let currentMonthItems: [RecentExpenseItem]
        let maintenance: MaintenanceSection.Model
        let onOpenHistory: () -> Void
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
                    items: model.currentMonthItems,
                    onOpenHistory: model.onOpenHistory
                )
            }

            MaintenanceSection(model: model.maintenance)
        }
    }
}
