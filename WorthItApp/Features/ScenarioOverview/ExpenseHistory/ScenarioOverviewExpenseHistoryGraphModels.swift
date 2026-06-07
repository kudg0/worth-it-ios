import SwiftUI

extension ScenarioOverviewView {
    var expenseHistoryMiniBars: some View {
        ExpenseSpendMiniBars(
            bars: expenseHistoryBars,
            selectedBar: selectedExpenseHistoryBar,
            maxLabel: expenseHistoryBarMaxLabel,
            zeroLabel: "\(currencySymbol)0",
            valueLabel: expenseHistoryBarValueLabel,
            height: expenseHistoryBarHeight,
            accessibilityValue: { "\(currencySymbol)\(formatDouble($0.total, fractionDigits: 0))" },
            onSelect: selectExpenseHistoryBar
        )
    }
}
