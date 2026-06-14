import SwiftUI

extension ScenarioOverviewView {
    var metricTrendPoints: [MetricTrendPoint] {
        if selectedDetailMetric == .costPerKm {
            return sortedTrendPoints(costPerKmMetricTrendPoints)
        }

        if selectedDetailMetric == .currentMonthCostPerKm {
            return sortedTrendPoints(activeCostPerKmTrendRange == .oneYear ? monthlyEfficiencyTrendPoints(maxMonths: 12) : monthlyEfficiencyTrendPoints(maxMonths: nil))
        }

        if selectedDetailMetric == .totalOwnership {
            return sortedTrendPoints(totalOwnershipTrendPoints(maxMonths: selectedMetricTrendRange == .oneYear ? 12 : nil))
        }

        let realPoints = realMetricTrendPoints
        if realPoints.count >= 2 {
            return sortedTrendPoints(realPoints)
        }

        let calendar = Calendar(identifier: .gregorian)
        let current = metricCurrentNumericValue
        let pointCount = selectedMetricTrendRange == .oneYear ? 7 : metricTrendAllPointCount

        let points = (0..<pointCount).compactMap { index in
            calendar.date(byAdding: .month, value: index - (pointCount - 1), to: currentMonthStart).map {
                MetricTrendPoint(date: $0, value: current)
            }
        }

        return sortedTrendPoints(points)
    }

    var solidMetricTrendPoints: [MetricTrendPoint] {
        sortedTrendPoints(metricTrendPoints.filter { !$0.isProjected })
    }

    var dashedMetricTrendPoints: [MetricTrendPoint] {
        let points = sortedTrendPoints(metricTrendPoints)
        guard let firstProjectedIndex = points.firstIndex(where: \.isProjected) else {
            return []
        }

        let anchor = firstProjectedIndex > 0 ? [points[firstProjectedIndex - 1]] : []
        return anchor + points[firstProjectedIndex...]
    }

    var costPerKmMetricTrendPoints: [MetricTrendPoint] {
        projectedCostPerKmTrendPoints(maxMonths: activeCostPerKmTrendRange == .oneYear ? 12 : nil)
    }

    func effectiveCostPerKmTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        return efficiencyMonthStarts(maxMonths: maxMonths).compactMap { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let asOf = min(monthEnd, Date())
            return effectiveCostPerDistanceValue(asOf: asOf).map {
                MetricTrendPoint(date: monthStart, value: $0)
            }
        }
    }

    func projectedCostPerKmTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let count = maxMonths ?? max(efficiencyMonthStarts(maxMonths: nil).count, 1)
        return projectedEfficiencySnapshotTrendPoints(period: .month, count: count)
    }

    var costPerKmMonthlyComparisonTrendPoints: [MetricTrendPoint] {
        effectiveCostPerKmTrendPoints(maxMonths: nil).suffix(2).map { $0 }
    }

    var currentMonthCostPerKmComparisonTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart)

        return sortedTrendPoints([
            previousMonthStart.flatMap { start in
                previousMonthlyCostPerDistanceValue.map { MetricTrendPoint(date: start, value: $0) }
            },
            currentMonthlyCostPerDistanceValue.map { MetricTrendPoint(date: currentMonthStart, value: $0) }
        ].compactMap { $0 })
    }

    func sortedTrendPoints(_ points: [MetricTrendPoint]) -> [MetricTrendPoint] {
        points.sorted { lhs, rhs in
            if lhs.date == rhs.date {
                return !lhs.isProjected && rhs.isProjected
            }

            return lhs.date < rhs.date
        }
    }

    var costPerKmSelectedMonthTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = costPerKmSelectedMonthStart
        guard let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let now = Date()
        var realValues: [Double] = []

        return monthRange.compactMap { day -> MetricTrendPoint? in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) else { return nil }
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            let value = efficiencyPeriodValue(bucketStart: date, period: .day)

            if let value, dayEnd <= now {
                realValues.append(value)
                return MetricTrendPoint(date: date, value: value)
            }

            return MetricTrendPoint(
                date: date,
                value: projectedMetricTrendValue(from: realValues),
                isProjected: true
            )
        }
    }

    var costPerKmSelectedYearTrendPoints: [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let yearStart = costPerKmSelectedYearStart
        let now = Date()
        var realValues: [Double] = []

        return (0..<12).compactMap { monthOffset -> MetricTrendPoint? in
            guard let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: yearStart) else { return nil }
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let value = efficiencyPeriodValue(bucketStart: monthStart, period: .month)

            if let value, monthEnd <= now {
                realValues.append(value)
                return MetricTrendPoint(date: monthStart, value: value)
            }

            return MetricTrendPoint(
                date: monthStart,
                value: projectedMetricTrendValue(from: realValues),
                isProjected: true
            )
        }
    }

    func projectedMetricTrendValue(from values: [Double]) -> Double {
        guard !values.isEmpty else {
            return currentCostPerDistanceValue ?? 0
        }

        let sampleCount = max(Int(ceil(Double(values.count) * 0.25)), 1)
        let sample = values.suffix(sampleCount)
        return sample.reduce(0, +) / Double(sample.count)
    }

    var realMetricTrendPoints: [MetricTrendPoint] {
        realMetricTrendPoints(for: selectedDetailMetric)
    }

    func realMetricTrendPoints(for metric: OverviewMetric) -> [MetricTrendPoint] {
        switch metric {
        case .monthlyCost:
            return twoPointTrend(previous: previousMonthlySpendValue, current: monthlySpendValue)
        case .costPerKm:
            return costPerKmMonthlyComparisonTrendPoints
        case .currentMonthCostPerKm:
            return currentMonthCostPerKmComparisonTrendPoints
        case .totalExpenses:
            return totalExpensesTrendPoints(maxMonths: nil)
        case .totalOwnership:
            return totalOwnershipTrendPoints(maxMonths: nil)
        case .paybackDistance:
            return selectedAlternativeBreakEven.flatMap(alternativeSavingsSnapshot).map {
                [MetricTrendPoint(date: Date(), value: $0.savings)]
            } ?? []
        case .projectedGain, .expectedResale, .loanInterest:
            return []
        }
    }

    func twoPointTrend(previous: Double?, current: Double?) -> [MetricTrendPoint] {
        [
            previous.map { MetricTrendPoint(date: expenseHistoryMonthStart(for: previousMonthAsOfDate), value: $0) },
            current.map { MetricTrendPoint(date: currentMonthStart, value: $0) }
        ]
        .compactMap { $0 }
        .sorted { $0.date < $1.date }
    }

    var metricTrendAllPointCount: Int {
        let calendar = Calendar(identifier: .gregorian)
        let start = expenseHistoryMonthStart(for: activeScenario.startDate)
        let components = calendar.dateComponents([.month], from: start, to: currentMonthStart)
        return max((components.month ?? 0) + 1, 2)
    }

    var usesScrollableMetricTrendChart: Bool {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            return activeCostPerKmTrendRange == .all && metricTrendPoints.count > metricTrendVisiblePointCount
        }

        return selectedMetricTrendRange == .all && metricTrendPoints.count > metricTrendVisiblePointCount
    }

    var metricTrendVisiblePointCount: Int {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            switch costPerKmTrendScope {
            case .day:
                return 30
            case .week:
                return 12
            case .month, .all:
                return 12
            }
        }

        return 12
    }

    var metricTrendVisibleDomainLength: TimeInterval {
        switch metricTrendCalendarComponent {
        case .day:
            TimeInterval(60 * 60 * 24 * max(metricTrendVisiblePointCount - 1, 1))
        case .weekOfYear:
            TimeInterval(60 * 60 * 24 * 7 * max(metricTrendVisiblePointCount - 1, 1))
        default:
            TimeInterval(60 * 60 * 24 * 31 * max(metricTrendVisiblePointCount - 1, 1))
        }
    }

    var metricTrendTitle: String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm:
            "\(costPerKmTrendScope.trendTitle) trend"
        case .totalOwnership:
            realMetricTrendPoints.count >= 2 ? "Cost inputs trend" : "Current cost inputs"
        case .monthlyCost, .totalExpenses:
            realMetricTrendPoints.count >= 2 ? "Monthly trend" : "Current baseline"
        case .paybackDistance, .projectedGain, .expectedResale, .loanInterest:
            "Current snapshot"
        }
    }
}
