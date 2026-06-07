import SwiftUI

extension ScenarioOverviewView {
    var mileageHistoryMiniBars: some View {
        MileageHistoryMiniBars(
            bars: mileageHistoryBars,
            selectedBar: selectedMileageHistoryBar,
            maxLabel: mileageHistoryBarMaxLabel,
            zeroLabel: "0 \(mileageDisplayUnit)",
            valueLabel: mileageHistoryBarValueLabel,
            height: mileageHistoryBarHeight,
            accessibilityValue: { "\(formatDouble($0.total, fractionDigits: 1)) \(mileageDisplayUnit)" },
            onSelect: selectMileageHistoryBar
        )
    }

    var mileageMonthGroups: [MileageMonthGroup] {
        let calendar = Calendar(identifier: .gregorian)
        let filteredItems = mileageLogItems.filter { item in
            guard isMileageHistoryMonthFiltered else { return true }
            return expenseHistoryIsSameMonth(item.date, selectedMileageHistoryBar.monthStart)
        }
        let grouped = Dictionary(grouping: filteredItems) { item in
            calendar.date(from: calendar.dateComponents([.year, .month], from: item.date)) ?? item.date
        }

        return grouped
            .map { monthStart, items in
                MileageMonthGroup(monthStart: monthStart, items: items.sorted { $0.date > $1.date })
            }
            .sorted { $0.monthStart > $1.monthStart }
    }

    func mileageMonthTotalText(_ group: MileageMonthGroup) -> String {
        let total = group.items.reduce(0) { $0 + mileageDistance(for: $1) }

        return "Total: +\(formatDouble(total, fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    var selectedMileageHistoryBar: MileageHistoryBar {
        if let selectedMileageHistoryBarLabel,
           let selected = mileageHistoryBars.first(where: { $0.selectionId == selectedMileageHistoryBarLabel }) {
            return selected
        }

        return mileageHistoryBars.last ?? MileageHistoryBar(
            monthStart: currentMonthStart,
            selectionId: expenseHistoryMonthIdentifier(for: currentMonthStart),
            label: "Now",
            total: 0,
            previousTotal: nil,
            count: 0,
            isCurrentMonth: true
        )
    }

    var isMileageHistoryMonthFiltered: Bool {
        selectedMileageHistoryBarLabel != nil
    }

    func resetMileageHistoryMonthSelection() {
        withAnimation(.easeInOut(duration: 0.16)) {
            selectedMileageHistoryBarLabel = nil
            focusedMileageHistoryMonthStart = nil
        }
    }

    func selectMileageHistoryBar(_ bar: MileageHistoryBar) {
        withAnimation(.easeInOut(duration: 0.16)) {
            if selectedMileageHistoryBarLabel == bar.selectionId {
                resetMileageHistoryMonthSelection()
            } else {
                selectedMileageHistoryBarLabel = bar.selectionId
                focusedMileageHistoryMonthStart = bar.monthStart
            }
        }
    }

    var selectedMileageHistoryBarTitle: String {
        selectedMileageHistoryBar.isCurrentMonth ? "Current month" : selectedMileageHistoryBar.label
    }

    var selectedMileageHistoryBarTotalDisplay: String {
        "+\(formatDouble(selectedMileageHistoryBar.total, fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    var selectedMileageHistoryBarDeltaPercentDisplay: String? {
        guard let previousTotal = selectedMileageHistoryBar.previousTotal, previousTotal > 0 else { return nil }

        let deltaPercent = ((selectedMileageHistoryBar.total - previousTotal) / previousTotal) * 100
        let sign = deltaPercent >= 0 ? "+" : "-"
        return "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
    }

    var selectedMileageHistoryBarIconName: String {
        guard let previousTotal = selectedMileageHistoryBar.previousTotal, previousTotal > 0 else {
            return selectedMileageHistoryBar.count > 0 ? "speedometer" : "info.circle.fill"
        }

        let delta = selectedMileageHistoryBar.total - previousTotal
        return delta == 0 ? "minus" : (delta < 0 ? "arrow.down.right" : "arrow.up.right")
    }

    var selectedMileageHistoryBarSubtitle: String {
        if selectedMileageHistoryBar.count == 0 {
            return selectedMileageHistoryBar.isCurrentMonth ? "No mileage logged this month." : "No mileage was logged in \(selectedMileageHistoryBar.label)."
        }

        let entryWord = selectedMileageHistoryBar.count == 1 ? "entry" : "entries"
        guard let previousTotal = selectedMileageHistoryBar.previousTotal, previousTotal > 0 else {
            return "\(selectedMileageHistoryBar.count) \(entryWord) logged in \(selectedMileageHistoryBar.label)."
        }

        let direction = selectedMileageHistoryBar.total > previousTotal ? "Higher" : "Lower"
        return "\(direction) than previous month • \(selectedMileageHistoryBar.count) \(entryWord)."
    }
}
