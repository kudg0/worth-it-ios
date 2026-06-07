import SwiftUI

extension ScenarioOverviewView {
    var mileageHistoryBars: [MileageHistoryBar] {
        let calendar = Calendar(identifier: .gregorian)
        var starts = (0..<5).reversed().compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: currentMonthStart)
        }

        if let focusedMileageHistoryMonthStart,
           !starts.contains(where: { expenseHistoryIsSameMonth($0, focusedMileageHistoryMonthStart) }) {
            starts.append(focusedMileageHistoryMonthStart)
            starts.sort()
        }

        return starts.map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart)
            let previousMonthEnd = previousMonthStart.flatMap { calendar.date(byAdding: .month, value: 1, to: $0) }
            let monthItems = mileageLogItems.filter { item in
                item.date >= monthStart && item.date < monthEnd
            }
            let total = monthItems.reduce(0) { $0 + mileageDistance(for: $1) }
            let previousTotal = mileageLogItems.reduce(0) { partial, item in
                guard let previousMonthStart, let previousMonthEnd else { return partial }
                if item.date >= previousMonthStart && item.date < previousMonthEnd {
                    return partial + mileageDistance(for: item)
                }

                return partial
            }

            return MileageHistoryBar(
                monthStart: monthStart,
                selectionId: expenseHistoryMonthIdentifier(for: monthStart),
                label: expenseHistoryMonthLabel(for: monthStart),
                total: total,
                previousTotal: previousMonthStart == nil ? nil : previousTotal,
                count: monthItems.count,
                isCurrentMonth: expenseHistoryIsSameMonth(monthStart, currentMonthStart)
            )
        }
    }

    var mileageHistoryBarChartMax: Double {
        max(mileageHistoryBars.map(\.total).max() ?? 0, 1)
    }

    var mileageHistoryBarMaxLabel: String {
        "\(formatDouble(mileageHistoryBarChartMax, fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    func mileageHistoryBarValueLabel(for bar: MileageHistoryBar) -> String {
        "\(formatDouble(bar.total, fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    func mileageHistoryBarHeight(for bar: MileageHistoryBar, maxHeight: CGFloat) -> CGFloat {
        guard mileageHistoryBarChartMax > 0 else { return 12 }

        let ratio = max(0, min(1, bar.total / mileageHistoryBarChartMax))
        if ratio == 0 {
            return bar.selectionId == selectedMileageHistoryBar.selectionId ? 12 : 8
        }

        return max(16, maxHeight * ratio)
    }
}
