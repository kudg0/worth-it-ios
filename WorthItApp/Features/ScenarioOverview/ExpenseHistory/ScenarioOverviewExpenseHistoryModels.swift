import SwiftUI

extension ScenarioOverviewView {
    var expenseHistoryScreenModel: ExpenseHistoryScreen.Model {
        ExpenseHistoryScreen.Model(
            hero: expenseHistoryHeroModel,
            groups: expenseHistoryGroups,
            focusedExpenseId: focusedExpenseId,
            filter: $expenseHistoryFilter,
            currentMonthStart: currentMonthStart,
            groupTotal: expenseHistoryGroupTotal,
            rowTitle: { expenseTitle(for: $0) },
            rowSubtitle: { expenseHistorySubtitle(for: $0) },
            rowValue: expenseAmountPrecise,
            rowDetail: { expenseBadgeText(for: $0) },
            rowIcon: { expenseIconName(for: $0.category) },
            rowAccentColor: { expenseAccentColor(for: $0) },
            onEditExpense: beginEditingExpense
        )
    }

    var expenseHistoryHeroModel: ExpenseHistoryHero.Model {
        ExpenseHistoryHero.Model(
            title: selectedExpenseHistoryBarTitle,
            total: selectedExpenseHistoryBarTotalDisplay,
            delta: selectedExpenseHistoryBarDeltaPercentDisplay,
            iconName: selectedExpenseHistoryBarIconName,
            subtitle: selectedExpenseHistoryBarSubtitle,
            isFiltered: isExpenseHistoryMonthFiltered,
            miniBars: AnyView(expenseHistoryMiniBars),
            onReset: resetExpenseHistoryMonthSelection
        )
    }
}
