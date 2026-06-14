import SwiftUI

extension ScenarioOverviewView {
    var costPerKmSelectedMonthStart: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sourceDate = selectedMetricTrendDate ?? Date()
        return calendar.dateInterval(of: .month, for: sourceDate)?.start ?? currentMonthStart
    }

    var effectiveCostPerKmSelectedEnd: Date {
        let calendar = Calendar(identifier: .gregorian)
        let selectedMonthStart = selectedMetricTrendPoint?.date ?? currentMonthStart
        let selectedMonthEnd = calendar.date(byAdding: .month, value: 1, to: selectedMonthStart) ?? Date()
        return min(selectedMonthEnd, Date())
    }

    var costPerKmSelectedPeriodEnd: Date {
        let calendar = Calendar(identifier: .gregorian)
        guard let point = selectedMetricTrendPoint else {
            return Date()
        }

        if !point.isProjected {
            let periodEnd = calendar.date(byAdding: metricTrendCalendarComponent, value: 1, to: point.date) ?? Date()
            if periodEnd >= Date() {
                return Date()
            }

            return calendar.date(byAdding: .day, value: -1, to: periodEnd) ?? point.date
        }

        if calendar.isDate(point.date, inSameDayAs: currentYearEndDate(from: point.date, calendar: calendar)) {
            return point.date
        }

        let nextPeriod = calendar.date(byAdding: metricTrendCalendarComponent, value: 1, to: point.date) ?? point.date
        return calendar.date(byAdding: .day, value: -1, to: nextPeriod) ?? point.date
    }

    var costPerKmSelectedYearStart: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sourceDate = selectedMetricTrendDate ?? Date()
        return calendar.dateInterval(of: .year, for: sourceDate)?.start ?? sourceDate
    }

    var activeCostPerKmTrendRange: MetricTrendRange {
        showsCostPerKmYearRangeToggle ? selectedMetricTrendRange : .oneYear
    }

    var showsCostPerKmYearRangeToggle: Bool {
        let currentYearStart = Calendar(identifier: .gregorian).dateInterval(of: .year, for: Date())?.start ?? currentMonthStart
        if selectedDetailMetric == .currentMonthCostPerKm {
            return monthlyEfficiencyTrendPoints(maxMonths: nil).contains { $0.date < currentYearStart }
        }

        return effectiveCostPerKmTrendPoints(maxMonths: nil).contains { $0.date < currentYearStart }
    }

    var costPerKmBreakdownTrend: MetricTrend? {
        if selectedDetailMetric == .currentMonthCostPerKm {
            return costPerKmPeriodBreakdownTrend
        }

        let points = sortedTrendPoints(costPerKmMetricTrendPoints)
        guard let currentPoint = selectedMetricTrendPoint ?? points.last,
              let currentIndex = points.lastIndex(where: { $0.id == currentPoint.id }),
              currentIndex > 0
        else {
            return nil
        }

        return metricTrend(
            previousPoint: points[currentIndex - 1],
            currentPoint: currentPoint,
            lowerIsBetter: true,
            deltaDisplay: analyticsMetricTrendDeltaDisplay
        )
    }

    var costPerKmPeriodBreakdownTrend: MetricTrend? {
        guard costPerKmBreakdownDistance > 0 else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let component: Calendar.Component = activeCostPerKmTrendRange == .oneYear ? .month : metricTrendCalendarComponent
        guard let previousStart = calendar.date(byAdding: component, value: -1, to: costPerKmBreakdownStart),
              let previous = efficiencyPeriodValue(bucketStart: previousStart, period: component),
              previous > 0
        else {
            return nil
        }

        let current = costPerKmBreakdownCost / costPerKmBreakdownDistance
        return metricTrend(
            previousPoint: MetricTrendPoint(date: previousStart, value: previous),
            currentPoint: MetricTrendPoint(date: costPerKmBreakdownStart, value: current),
            lowerIsBetter: true,
            deltaDisplay: analyticsMetricTrendDeltaDisplay
        )
    }
}
