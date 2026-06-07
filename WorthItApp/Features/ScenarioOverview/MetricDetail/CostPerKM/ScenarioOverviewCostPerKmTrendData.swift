import Foundation

extension ScenarioOverviewView {
    var costPerKm: String {
        if let costPerKm = currentCostPerDistanceValue {
            return "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))"
        }

        return "—"
    }

    var hasEfficiencyChartData: Bool {
        !efficiencyChartPoints.isEmpty
    }

    var efficiencyChartPoints: [MetricTrendPoint] {
        let points: [MetricTrendPoint] = switch chartRange {
        case .day:
            efficiencySnapshotTrendPoints(period: .day, count: 30)
        case .week:
            efficiencySnapshotTrendPoints(period: .weekOfYear, count: 12)
        case .month:
            monthlyEfficiencyChartPoints
        }

        return sortedTrendPoints(points)
    }

    var monthlyEfficiencyChartPoints: [MetricTrendPoint] {
        monthlyEfficiencyTrendPoints(maxMonths: 12)
    }

    var currentMonthlyCostPerDistanceValue: Double? {
        if let currentValue = efficiencyPeriodValue(bucketStart: currentMonthStart, period: .month) {
            return currentValue
        }

        return latestAvailableCostPerDistanceValue
    }

    var currentCostPerDistanceValue: Double? {
        switch costPerKmMode {
        case .effective:
            return effectiveCostPerDistanceValue(asOf: Date())
        case .period:
            return currentMonthlyCostPerDistanceValue
        }
    }

    var previousMonthlyCostPerDistanceValue: Double? {
        let calendar = Calendar(identifier: .gregorian)
        guard let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) else {
            return nil
        }

        return efficiencyPeriodValue(bucketStart: previousMonthStart, period: .month)
    }

    var latestAvailableCostPerDistanceValue: Double? {
        monthlyEfficiencyChartPoints.last?.value ?? costPerKmThreeMonthAverageValue
    }

    var currentMonthUsageEvents: [UsageEvent] {
        let calendar = Calendar(identifier: .gregorian)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? Date()

        return usageEvents.filter { event in
            event.date >= currentMonthStart && event.date < monthEnd
        }
    }

    var isCurrentMonthCostPerKmInputEmpty: Bool {
        currentMonthExpenseEvents.isEmpty && currentMonthUsageEvents.isEmpty
    }

    var usesThreeMonthAverageCostPerKm: Bool {
        costPerKmMode == .period && isCurrentMonthCostPerKmInputEmpty && costPerKmThreeMonthAverageValue != nil
    }

    var costPerKmThreeMonthAverageStart: Date {
        Calendar(identifier: .gregorian).date(byAdding: .month, value: -3, to: currentMonthStart) ?? currentMonthStart
    }

    var costPerKmThreeMonthAverageEnd: Date {
        currentMonthStart
    }

    var costPerKmThreeMonthAverageValue: Double? {
        let cost = ownershipCost(
            from: costPerKmThreeMonthAverageStart,
            to: costPerKmThreeMonthAverageEnd,
            includeFinancing: shouldIncludeFinancingInCostPerKm
        )
        let mileage = mileageDistance(from: costPerKmThreeMonthAverageStart, to: costPerKmThreeMonthAverageEnd)

        guard cost >= 0, mileage > 0 else {
            return nil
        }

        return cost / mileage
    }

    func monthlyEfficiencyTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        efficiencyMonthStarts(maxMonths: maxMonths).compactMap { monthStart in
            efficiencyPeriodPoint(bucketStart: monthStart, period: .month)
        }
    }

    func efficiencySnapshotTrendPoints(period: Calendar.Component, count: Int) -> [MetricTrendPoint] {
        efficiencySnapshotTrendPoints(period: period, count: Optional(count))
    }

    func efficiencySnapshotTrendPoints(period: Calendar.Component, count: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let currentStart = calendar.dateInterval(of: period, for: now)?.start ?? now
        let scenarioStart = dateBucketStart(activeScenario.startDate, period: period)
        let start: Date
        if let count {
            let visibleStart = calendar.date(byAdding: period, value: -(count - 1), to: currentStart) ?? currentStart
            start = max(scenarioStart, visibleStart)
        } else {
            start = scenarioStart
        }
        let periodCount = calendar.dateComponents([period], from: start, to: currentStart).value(for: period) ?? 0

        return (0...max(periodCount, 0)).compactMap { offset in
            calendar.date(byAdding: period, value: offset, to: start).flatMap {
                efficiencyPeriodPoint(bucketStart: $0, period: period)
            }
        }
    }

    func efficiencyPeriodPoint(bucketStart: Date, period: Calendar.Component) -> MetricTrendPoint? {
        guard let value = efficiencyPeriodValue(bucketStart: bucketStart, period: period) else {
            return nil
        }

        return MetricTrendPoint(date: bucketStart, value: value)
    }

    func efficiencyPeriodValue(bucketStart: Date, period: Calendar.Component) -> Double? {
        let calendar = Calendar(identifier: .gregorian)
        let bucketEnd = calendar.date(byAdding: period, value: 1, to: bucketStart) ?? bucketStart
        let end = min(bucketEnd, Date())

        guard bucketStart < end else {
            return nil
        }

        let cost = ownershipCost(from: bucketStart, to: end, includeFinancing: shouldIncludeFinancingInCostPerKm)
        let mileage = mileageDistance(from: bucketStart, to: end)

        guard cost > 0, mileage > 0 else {
            return nil
        }

        return cost / mileage
    }
}
