import SwiftUI

extension ScenarioOverviewView {
    var expensesScreenModel: ScenarioExpensesScreen.Model {
        ScenarioExpensesScreen.Model(
            costEventsError: costEventsError,
            isEmpty: costEvents.isEmpty && currentMonthLoanInterest <= 0,
            hero: expenseHeroModel,
            currentMonthItems: currentMonthRecentExpenseItems,
            maintenance: maintenanceSectionModel,
            onOpenHistory: { openExpenseHistory() },
            onRetry: { Task { await loadSummary() } }
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
