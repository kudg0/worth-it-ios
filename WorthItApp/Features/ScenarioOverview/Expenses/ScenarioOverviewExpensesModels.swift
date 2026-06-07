import SwiftUI

extension ScenarioOverviewView {
    var expensesScreenModel: ScenarioExpensesScreen.Model {
        ScenarioExpensesScreen.Model(
            costEventsError: costEventsError,
            isEmpty: costEvents.isEmpty,
            hero: expenseHeroModel,
            currentMonthEvents: currentMonthExpenseEvents,
            maintenance: maintenanceSectionModel,
            rowTitle: { expenseTitle(for: $0) },
            rowSubtitle: { expenseSubtitle(for: $0) },
            rowValue: expenseAmount,
            rowIcon: { expenseIconName(for: $0.category) },
            rowAccentColor: { expenseAccentColor(for: $0) },
            onOpenHistory: { openExpenseHistory() },
            onEditExpense: beginEditingExpense
        )
    }

    var expenseHeroModel: ExpenseHero.Model {
        ExpenseHero.Model(
            monthName: currentMonthName,
            total: currentMonthExpenseTotalDisplay,
            trend: currentMonthTrend,
            onOpenHistory: { openExpenseHistory() }
        )
    }
}
