import SwiftUI

extension ScenarioOverviewView {
    var selectedExpenseHistoryBarLabelBinding: Binding<String?> {
        Binding {
            selectedExpenseHistoryBar.selectionId
        } set: { newValue in
            guard let newValue, expenseHistoryBars.contains(where: { $0.selectionId == newValue }) else { return }
            selectedExpenseHistoryBarLabel = newValue
        }
    }

    var selectedExpenseHistoryBar: ExpenseHistoryBar {
        if let selectedExpenseHistoryBarLabel,
           let selected = expenseHistoryBars.first(where: { $0.selectionId == selectedExpenseHistoryBarLabel }) {
            return selected
        }

        return expenseHistoryBars.last ?? ExpenseHistoryBar(
            monthStart: currentMonthStart,
            selectionId: expenseHistoryMonthIdentifier(for: currentMonthStart),
            label: "Now",
            total: 0,
            previousTotal: nil,
            count: 0,
            isCurrentMonth: true
        )
    }

    var isExpenseHistoryMonthFiltered: Bool {
        selectedExpenseHistoryBarLabel != nil
    }

    func resetExpenseHistoryMonthSelection() {
        withAnimation(.easeInOut(duration: 0.16)) {
            selectedExpenseHistoryBarLabel = nil
            focusedExpenseHistoryMonthStart = nil
        }
    }

    func selectExpenseHistoryBar(_ bar: ExpenseHistoryBar) {
        withAnimation(.easeInOut(duration: 0.16)) {
            if selectedExpenseHistoryBarLabel == bar.selectionId {
                resetExpenseHistoryMonthSelection()
            } else {
                selectedExpenseHistoryBarLabel = bar.selectionId
                focusedExpenseHistoryMonthStart = bar.monthStart
            }
        }
    }

    var selectedExpenseHistoryBarTitle: String {
        selectedExpenseHistoryBar.isCurrentMonth ? "Current month" : selectedExpenseHistoryBar.label
    }

    var selectedExpenseHistoryBarTotalDisplay: String {
        "\(currencySymbol)\(formatDouble(selectedExpenseHistoryBar.total, fractionDigits: 0))"
    }

    var selectedExpenseHistoryBarDeltaPercentDisplay: String? {
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else { return nil }

        let deltaPercent = ((selectedExpenseHistoryBar.total - previousTotal) / previousTotal) * 100
        let sign = deltaPercent >= 0 ? "+" : "-"
        return "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
    }

    var selectedExpenseHistoryBarIconName: String {
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else {
            return selectedExpenseHistoryBar.count > 0 ? "receipt" : "info.circle.fill"
        }

        let delta = selectedExpenseHistoryBar.total - previousTotal
        return delta == 0 ? "minus" : (delta < 0 ? "arrow.down.right" : "arrow.up.right")
    }

    var selectedExpenseHistoryBarSubtitle: String {
        if selectedExpenseHistoryBar.count == 0 {
            return selectedExpenseHistoryBar.isCurrentMonth ? "No expenses logged this month." : "No expenses were logged in \(selectedExpenseHistoryBar.label)."
        }

        let entryWord = selectedExpenseHistoryBar.count == 1 ? "expense" : "expenses"
        guard let previousTotal = selectedExpenseHistoryBar.previousTotal, previousTotal > 0 else {
            return "\(selectedExpenseHistoryBar.count) \(entryWord) logged in \(selectedExpenseHistoryBar.label)."
        }

        let direction = selectedExpenseHistoryBar.total > previousTotal ? "Higher" : "Lower"
        return "\(direction) than previous month • \(selectedExpenseHistoryBar.count) \(entryWord)."
    }
}
