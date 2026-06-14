import SwiftUI

extension ScenarioOverviewView {
    var monthlyCostTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .monthlyCost), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var costPerKmTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .costPerKm), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var currentMonthCostPerKmTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .currentMonthCostPerKm), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var totalOwnershipTrend: MetricTrend {
        metricTrend(points: realMetricTrendPoints(for: .totalOwnership), lowerIsBetter: true, deltaDisplay: analyticsMetricTrendDeltaDisplay)
    }

    var totalLoggedExpensesValue: Double {
        costEvents.reduce(0) { total, event in
            total + doubleValue(decimalValue(event.amount))
        }
    }

    var totalLoggedExpensesDisplay: String {
        "\(currencySymbol)\(formatDouble(totalLoggedExpensesValue, fractionDigits: 0))"
    }

    var totalLoggedExpensesProgress: CGFloat {
        normalizedProgress(totalLoggedExpensesValue / max(doublePurchasePrice, 1))
    }

    func totalExpensesTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        return efficiencyMonthStarts(maxMonths: maxMonths).map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let total = costEvents
                .filter { $0.date < monthEnd }
                .reduce(0) { $0 + doubleValue(decimalValue($1.amount)) }
            return MetricTrendPoint(date: monthStart, value: total)
        }
    }

    func metricTrend(
        points: [MetricTrendPoint],
        lowerIsBetter: Bool,
        deltaDisplay: MetricTrendDeltaDisplay = .percent
    ) -> MetricTrend {
        if summaryError != nil {
            return MetricTrend(label: i18n.t("SUMMARY LOAD FAILED"), iconName: "minus", color: WorthItColor.textTertiary)
        }

        guard let previousPoint = points.dropLast().last,
              let current = points.last?.value,
              previousPoint.value > 0
        else {
            return MetricTrend(label: i18n.t("NO PREVIOUS MONTH DATA"), iconName: "minus", color: WorthItColor.textTertiary)
        }

        return metricTrend(
            previousPoint: previousPoint,
            currentPoint: MetricTrendPoint(date: points.last?.date ?? Date(), value: current),
            lowerIsBetter: lowerIsBetter,
            deltaDisplay: deltaDisplay
        )
    }

    func metricTrend(
        previousPoint: MetricTrendPoint,
        currentPoint: MetricTrendPoint,
        lowerIsBetter: Bool,
        deltaDisplay: MetricTrendDeltaDisplay = .percent
    ) -> MetricTrend {
        let previous = previousPoint.value
        let delta = currentPoint.value - previous
        let deltaPercent = (delta / previous) * 100
        let neutralThreshold = 0.05
        let trend = trendPresentation(delta: deltaPercent, neutralThreshold: neutralThreshold, lowerIsBetter: lowerIsBetter)
        let previousMonth = monthName(for: previousPoint.date).uppercased()
        guard abs(deltaPercent) > neutralThreshold else {
            return MetricTrend(
                label: i18n.t("NO CHANGE VS \(previousMonth)"),
                iconName: trend.iconName,
                color: trend.color
            )
        }

        let sign = abs(deltaPercent) > neutralThreshold ? (deltaPercent > 0 ? "+" : "-") : ""
        let deltaLabel: String = switch deltaDisplay {
        case .percent:
            "\(sign)\(formatDouble(abs(deltaPercent), fractionDigits: 1))%"
        case .currency:
            "\(sign)\(currencySymbol)\(formatDouble(abs(delta), fractionDigits: 2))"
        }

        return MetricTrend(
            label: i18n.t("\(deltaLabel) VS \(previousMonth)"),
            iconName: trend.iconName,
            color: trend.color
        )
    }

    func trendPresentation(delta: Double, neutralThreshold: Double, lowerIsBetter: Bool) -> (iconName: String, color: Color) {
        guard abs(delta) > neutralThreshold else {
            return ("minus", WorthItColor.textTertiary)
        }

        let isImprovement = lowerIsBetter ? delta < 0 : delta > 0
        let iconName = delta < 0 ? "arrow.down.right" : "arrow.up.right"
        let color = isImprovement ? Color(hex: 0x34D399) : WorthItColor.danger

        return (iconName, color)
    }

    var previousMonthName: String {
        monthName(for: previousMonthAsOfDate)
    }

    func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: date)
    }

    var previousMonthAsOfDate: Date {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        return calendar.date(byAdding: .second, value: -1, to: startOfCurrentMonth) ?? now
    }

    var expenseDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }
}
