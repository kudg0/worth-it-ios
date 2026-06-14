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
            let monthLoanInterest = expenseHistoryLoanInterest(for: monthStart)
            let total = costEvents.reduce(Decimal(0)) { partial, event in
                if event.date >= monthStart && event.date < monthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            } + Decimal(monthLoanInterest)
            let previousTotal = costEvents.reduce(Decimal(0)) { partial, event in
                guard let previousMonthStart, let previousMonthEnd else { return partial }
                if event.date >= previousMonthStart && event.date < previousMonthEnd {
                    return partial + decimalValue(event.amount)
                }

                return partial
            } + Decimal(previousMonthStart.map(expenseHistoryLoanInterest(for:)) ?? 0)

            return ExpenseHistoryBar(
                monthStart: monthStart,
                selectionId: expenseHistoryMonthIdentifier(for: monthStart),
                label: expenseHistoryMonthLabel(for: monthStart),
                total: doubleValue(total),
                previousTotal: previousMonthStart == nil ? nil : doubleValue(previousTotal),
                count: monthEvents.count + (monthLoanInterest > 0 ? 1 : 0),
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
        let groupedEvents = Dictionary(grouping: filteredEvents) { event in
            calendar.date(from: calendar.dateComponents([.year, .month], from: event.date)) ?? event.date
        }

        let eventMonthStarts = Set(groupedEvents.keys)
        let syntheticMonthStarts: [Date]
        if expenseHistoryFilter == .all {
            syntheticMonthStarts = expenseHistoryBars
                .filter { bar in
                    guard bar.total > 0 else { return false }
                    guard isExpenseHistoryMonthFiltered else { return true }
                    return expenseHistoryIsSameMonth(bar.monthStart, selectedExpenseHistoryBar.monthStart)
                }
                .map(\.monthStart)
        } else {
            syntheticMonthStarts = []
        }
        let monthStarts = Set(eventMonthStarts).union(syntheticMonthStarts)

        return monthStarts
            .map { monthStart in
                let events = groupedEvents[monthStart] ?? []
                let syntheticItems = expenseHistorySyntheticItems(for: monthStart)
                return ExpenseMonthGroup(
                    monthStart: monthStart,
                    events: events.sorted { $0.date > $1.date },
                    syntheticItems: expenseHistoryFilter == .all ? syntheticItems : []
                )
            }
            .sorted { $0.monthStart > $1.monthStart }
    }

    func expenseHistorySyntheticItems(for monthStart: Date) -> [ExpenseMonthGroup.SyntheticItem] {
        let loanInterest = expenseHistoryLoanInterest(for: monthStart)
        guard loanInterest > 0 else { return [] }

        return [
            ExpenseMonthGroup.SyntheticItem(
                id: "loan-interest-\(expenseHistoryMonthIdentifier(for: monthStart))",
                title: i18n.t("Loan interest accrued"),
                subtitle: i18n.t("Financing cost • \(expenseHistoryMonthLabel(for: monthStart))"),
                value: loanInterest,
                valueText: "\(currencySymbol)\(formatDouble(loanInterest, fractionDigits: 2))",
                detail: "Loan interest",
                systemIcon: "building.columns.fill",
                accentColor: "finance"
            )
        ]
    }

    func expenseHistoryLoanInterest(for monthStart: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        return loanInterestCost(from: monthStart, to: monthEnd)
    }
}
