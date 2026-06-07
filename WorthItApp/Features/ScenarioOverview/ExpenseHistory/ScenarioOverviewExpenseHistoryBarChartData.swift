import SwiftUI

extension ScenarioOverviewView {
    var expenseHistoryBars: [ExpenseHistoryBar] {
        let calendar = Calendar(identifier: .gregorian)
        var starts = (0..<5).reversed().compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonthStart)
        }

        if let focusedExpenseHistoryMonthStart,
           !starts.contains(where: { expenseHistoryIsSameMonth($0, focusedExpenseHistoryMonthStart) }) {
            starts.append(focusedExpenseHistoryMonthStart)
            starts.sort()
        }

        return starts.map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart)
            let previousMonthEnd = previousMonthStart.flatMap { calendar.date(byAdding: .month, value: 1, to: $0) }
            let monthEvents = costEvents.filter { event in
                event.date >= monthStart && event.date < monthEnd
            }
            let total = costEvents.reduce(Decimal(0)) { partial, event in
                if event.date >= monthStart && event.date < monthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            }
            let previousTotal = costEvents.reduce(Decimal(0)) { partial, event in
                guard let previousMonthStart, let previousMonthEnd else { return partial }
                if event.date >= previousMonthStart && event.date < previousMonthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            }

            return ExpenseHistoryBar(
                monthStart: monthStart,
                selectionId: expenseHistoryMonthIdentifier(for: monthStart),
                label: expenseHistoryMonthLabel(for: monthStart),
                total: doubleValue(total),
                previousTotal: previousMonthStart == nil ? nil : doubleValue(previousTotal),
                count: monthEvents.count,
                isCurrentMonth: expenseHistoryIsSameMonth(monthStart, currentMonthStart)
            )
        }
    }

    var expenseHistoryBarChartMax: Double {
        max(expenseHistoryBars.map(\.total).max() ?? 0, 1)
    }

    var expenseHistoryBarMaxLabel: String {
        "\(currencySymbol)\(formatDouble(expenseHistoryBarChartMax, fractionDigits: 0))"
    }

    func expenseHistoryBarValueLabel(for bar: ExpenseHistoryBar) -> String {
        "\(currencySymbol)\(formatDouble(bar.total, fractionDigits: 0))"
    }

    func expenseHistoryBarHeight(for bar: ExpenseHistoryBar, maxHeight: CGFloat) -> CGFloat {
        guard expenseHistoryBarChartMax > 0 else { return 12 }

        let ratio = max(0, min(1, bar.total / expenseHistoryBarChartMax))
        if ratio == 0 {
            return bar.selectionId == selectedExpenseHistoryBar.selectionId ? 12 : 8
        }

        return max(16, maxHeight * ratio)
    }

    var expenseHistoryGroups: [ExpenseMonthGroup] {
        let calendar = Calendar(identifier: .gregorian)
        let filteredEvents = costEvents
            .filter(expenseHistoryFilter.contains)
            .filter { event in
                guard isExpenseHistoryMonthFiltered else { return true }
                return expenseHistoryIsSameMonth(event.date, selectedExpenseHistoryBar.monthStart)
            }
            .sorted { $0.date > $1.date }
        let grouped = Dictionary(grouping: filteredEvents) { event in
            calendar.date(from: calendar.dateComponents([.year, .month], from: event.date)) ?? event.date
        }

        return grouped
            .map { monthStart, events in
                ExpenseMonthGroup(monthStart: monthStart, events: events.sorted { $0.date > $1.date })
            }
            .sorted { $0.monthStart > $1.monthStart }
    }
}
