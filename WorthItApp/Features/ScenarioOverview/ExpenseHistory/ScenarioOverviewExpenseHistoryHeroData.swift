import Foundation

extension ScenarioOverviewView {
    var currentMonthExpenseEvents: [CostEvent] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()

        return costEvents.filter { event in
            calendar.isDate(event.date, equalTo: now, toGranularity: .month)
            && calendar.isDate(event.date, equalTo: now, toGranularity: .year)
        }
        .sorted { $0.date > $1.date }
    }

    var previousMonthExpenseEvents: [CostEvent] {
        let calendar = Calendar(identifier: .gregorian)
        let previous = previousMonthAsOfDate

        return costEvents.filter { event in
            calendar.isDate(event.date, equalTo: previous, toGranularity: .month)
            && calendar.isDate(event.date, equalTo: previous, toGranularity: .year)
        }
    }

    var currentMonthExpenseTotal: Decimal {
        currentMonthExpenseEvents.reduce(Decimal(0)) { total, event in
            total + decimalValue(event.amount)
        } + Decimal(currentMonthLoanInterest)
    }

    var currentMonthExpenseTotalDisplay: String {
        "\(currencySymbol)\(formatDecimal(currentMonthExpenseTotal, fractionDigits: 0))"
    }

    var currentMonthExpenseCount: Int {
        currentMonthExpenseEvents.count + (currentMonthLoanInterest > 0 ? 1 : 0)
    }

    var previousMonthExpenseTotal: Decimal {
        previousMonthExpenseEvents.reduce(Decimal(0)) { total, event in
            total + decimalValue(event.amount)
        } + Decimal(previousMonthLoanInterest)
    }

    var previousMonthExpenseCount: Int {
        previousMonthExpenseEvents.count + (previousMonthLoanInterest > 0 ? 1 : 0)
    }

    var currentMonthTrend: MetricTrend {
        guard currentMonthExpenseCount > 0 else {
            return MetricTrend(label: i18n.t("NO DATA AVAILABLE FOR THIS MONTH"), iconName: "info.circle.fill", color: WorthItColor.textTertiary)
        }

        guard previousMonthExpenseCount > 0 else {
            return MetricTrend(label: i18n.t("NO PREVIOUS MONTH DATA"), iconName: "minus", color: WorthItColor.textTertiary)
        }

        let current = currentMonthExpenseTotal
        let previous = previousMonthExpenseTotal
        let delta = current - previous
        let trend = trendPresentation(delta: doubleValue(delta), neutralThreshold: 0, lowerIsBetter: true)
        let sign = delta >= 0 ? "+" : "-"

        return MetricTrend(
            label: i18n.t("\(sign)\(currencySymbol)\(formatDecimal(abs(delta), fractionDigits: 0)) VS \(previousMonthName.uppercased())"),
            iconName: trend.iconName,
            color: trend.color
        )
    }

    var currentMonthExpenseDeltaPercentDisplay: String {
        guard previousMonthExpenseTotal > 0 else { return "" }

        let current = doubleValue(currentMonthExpenseTotal)
        let previous = doubleValue(previousMonthExpenseTotal)
        let deltaPercent = ((current - previous) / previous) * 100
        let sign = deltaPercent >= 0 ? "+" : "-"
        return "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
    }

    var expenseHistoryHeroSubtitle: String {
        guard currentMonthExpenseCount > 0 else {
            return "No expenses logged this month."
        }

        guard previousMonthExpenseCount > 0 else {
            return "No previous month data yet."
        }

        let direction = currentMonthExpenseTotal > previousMonthExpenseTotal ? "Higher" : "Lower"
        return "\(direction) than \(previousMonthName) total."
    }
}
