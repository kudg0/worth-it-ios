import SwiftUI

extension ScenarioOverviewView {
    var metricTrendYAxisValues: [Double] {
        let values = metricTrendPoints.map(\.value)
        guard let minValue = values.min(), let maxValue = values.max() else { return [] }

        if minValue == maxValue {
            return [0, max(maxValue, 1)]
        }

        let paddedMin = max(0, minValue * 0.92)
        let paddedMax = maxValue * 1.08
        let middle = (paddedMin + paddedMax) / 2
        return [paddedMin, middle, paddedMax]
    }

    var metricTrendYAxisMax: Double {
        max((metricTrendPoints.map(\.value).max() ?? 0) * 1.08, 1)
    }

    func metricTrendYAxisLabel(_ value: Double) -> String {
        metricTrendPointValueLabel(MetricTrendPoint(date: Date(), value: value))
    }

    func metricTrendPointValueLabel(_ point: MetricTrendPoint) -> String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2))"
        case .paybackDistance:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 0))"
        default:
            "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 0))"
        }
    }

    var metricCurrentNumericValue: Double {
        switch selectedDetailMetric {
        case .monthlyCost:
            monthlySpendValue ?? 0
        case .costPerKm:
            currentCostPerDistanceValue ?? 0
        case .currentMonthCostPerKm:
            currentMonthlyCostPerDistanceValue ?? 0
        case .totalExpenses:
            totalLoggedExpensesValue
        case .totalOwnership:
            totalOwnershipCost.map(doubleValue) ?? 0
        case .paybackDistance:
            selectedAlternativeBreakEven.flatMap(alternativeSavingsSnapshot)?.savings ?? 0
        case .projectedGain:
            doubleValue(projectedGain)
        case .expectedResale:
            doubleValue(expectedResaleValue)
        case .loanInterest:
            doubleValue(loanInterestTotal)
        }
    }

    var metricTrendAxisDates: [Date] {
        guard let first = metricTrendPoints.first?.date, let last = metricTrendPoints.last?.date else {
            return []
        }

        let middleIndex = metricTrendPoints.count / 2
        return [first, metricTrendPoints[middleIndex].date, last]
    }

    func metricTrendAxisLabel(for date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)

        if (selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm),
           let currentBucketStart = calendar.dateInterval(of: metricTrendCalendarComponent, for: Date())?.start,
           calendar.isDate(date, equalTo: currentBucketStart, toGranularity: metricTrendCalendarComponent) {
            return "Present"
        }

        if selectedDetailMetric != .costPerKm && selectedDetailMetric != .currentMonthCostPerKm,
           calendar.isDate(date, equalTo: currentMonthStart, toGranularity: .month) {
            return "Present"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            switch costPerKmTrendScope {
            case .day, .week:
                formatter.dateFormat = "d MMM"
            case .month, .all:
                formatter.dateFormat = "MMM yyyy"
            }
        } else {
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: date)
    }

    var metricTrendCalendarComponent: Calendar.Component {
        if selectedDetailMetric == .costPerKm {
            return .month
        }

        if selectedDetailMetric == .currentMonthCostPerKm {
            return .month
        }

        switch costPerKmTrendScope {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month, .all:
            return .month
        }
    }
}
