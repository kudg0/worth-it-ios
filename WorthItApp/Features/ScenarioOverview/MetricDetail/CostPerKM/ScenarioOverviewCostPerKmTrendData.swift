import Foundation

extension ScenarioOverviewView {
    var costPerKm: String {
        if let costPerKm = currentCostPerDistanceValue {
            return "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))"
        }

        return "—"
    }

    var currentMonthCostPerKm: String {
        if let costPerKm = currentMonthlyCostPerDistanceValue {
            return "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))"
        }

        return "—"
    }

    var hasEfficiencyChartData: Bool {
        !efficiencyChartPoints.isEmpty
    }

    var efficiencyChartPoints: [MetricTrendPoint] {
        if !backendEfficiencyChartPoints.isEmpty {
            return backendEfficiencyChartPoints
        }

        let points: [MetricTrendPoint] = switch chartRange {
        case .day:
            projectedEfficiencySnapshotTrendPoints(period: .day, count: 10, projectedCount: 5)
        case .week:
            projectedEfficiencySnapshotTrendPoints(period: .weekOfYear, count: 8, projectedCount: 4)
        case .month:
            projectedEfficiencySnapshotTrendPoints(period: .month, count: 12)
        }

        return sortedTrendPoints(points)
    }

    var backendEfficiencyMetric: ScenarioAnalyticsMetricPayload? {
        analyticsOverview?.metrics.first { $0.metricId == .efficiencyComparison }
    }

    var backendEfficiencyChartPoints: [MetricTrendPoint] {
        if let range = backendEfficiencyMetric?.chart?.ranges?[chartRange.analyticsRangeKey],
           !range.points.isEmpty {
            return sortedTrendPoints(range.points.map {
                MetricTrendPoint(date: $0.date, value: $0.value, isProjected: $0.isProjected ?? false)
            })
        }

        guard let primary = backendEfficiencyMetric?.chart?.series?.first(where: { $0.role == "primary" }) else {
            return []
        }

        return sortedTrendPoints(primary.points.map {
            MetricTrendPoint(date: $0.date, value: $0.value, isProjected: $0.isProjected ?? false)
        })
    }

    var monthlyEfficiencyChartPoints: [MetricTrendPoint] {
        monthlyEfficiencyTrendPoints(maxMonths: 12)
    }

    var currentMonthlyCostPerDistanceValue: Double? {
        efficiencyPeriodValue(bucketStart: currentMonthStart, period: .month)
    }

    var currentCostPerDistanceValue: Double? {
        effectiveCostPerDistanceValue(asOf: Date())
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
        false
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

    func effectiveEfficiencySnapshotTrendPoints(period: Calendar.Component, count: Int) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let currentStart = calendar.dateInterval(of: period, for: now)?.start ?? now
        let scenarioStart = dateBucketStart(activeScenario.startDate, period: period)
        let visibleStart = calendar.date(byAdding: period, value: -(count - 1), to: currentStart) ?? currentStart
        let start = max(scenarioStart, visibleStart)
        let periodCount = calendar.dateComponents([period], from: start, to: currentStart).value(for: period) ?? 0

        return (0...max(periodCount, 0)).compactMap { offset in
            guard let bucketStart = calendar.date(byAdding: period, value: offset, to: start) else {
                return nil
            }

            let bucketEnd = calendar.date(byAdding: period, value: 1, to: bucketStart) ?? bucketStart
            let asOf = min(bucketEnd, now)
            return effectiveCostPerDistanceValue(asOf: asOf).map {
                MetricTrendPoint(date: bucketStart, value: $0)
            }
        }
    }

    func projectedEfficiencySnapshotTrendPoints(period: Calendar.Component, count: Int, projectedCount: Int? = nil) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let currentStart = calendar.dateInterval(of: period, for: now)?.start ?? now
        let scenarioStart = dateBucketStart(activeScenario.startDate, period: period)
        let visibleStart = calendar.date(byAdding: period, value: -(count - 1), to: currentStart) ?? currentStart
        let start = max(scenarioStart, visibleStart)
        let currentPeriodOffset = calendar.dateComponents([period], from: start, to: currentStart).value(for: period) ?? 0
        let yearEnd = currentYearEndDate(from: now, calendar: calendar)
        var points: [MetricTrendPoint] = []

        for offset in 0...max(currentPeriodOffset, 0) {
            guard let bucketStart = calendar.date(byAdding: period, value: offset, to: start) else {
                continue
            }

            let bucketEnd = calendar.date(byAdding: period, value: 1, to: bucketStart) ?? bucketStart
            let pointDate = bucketEnd <= now ? bucketStart : now
            let asOf = min(bucketEnd, now)

            if let value = effectiveCostPerDistanceValue(asOf: asOf) {
                points.append(MetricTrendPoint(date: pointDate, value: value))
            }
        }

        let factualPoints = sortedTrendPoints(points)
        guard !factualPoints.isEmpty else {
            return []
        }

        var projectedStart = calendar.date(byAdding: period, value: 1, to: currentStart) ?? currentStart
        var projectedOffset = 0
        while projectedStart <= yearEnd && projectedOffset < (projectedCount ?? Int.max) {
            points.append(
                MetricTrendPoint(
                    date: projectedStart,
                    value: projectedEfficiencyValue(from: factualPoints, projectedDate: projectedStart),
                    isProjected: true
                )
            )
            projectedOffset += 1
            projectedStart = calendar.date(byAdding: period, value: 1, to: projectedStart) ?? yearEnd.addingTimeInterval(1)
        }

        if projectedCount == nil, let lastDate = sortedTrendPoints(points).last?.date, lastDate < yearEnd {
            points.append(
                MetricTrendPoint(
                    date: yearEnd,
                    value: projectedEfficiencyValue(from: factualPoints, projectedDate: yearEnd),
                    isProjected: true
                )
            )
        }

        return points
    }

    func currentYearEndDate(from date: Date, calendar: Calendar) -> Date {
        guard let yearInterval = calendar.dateInterval(of: .year, for: date),
              let finalDay = calendar.date(byAdding: .day, value: -1, to: yearInterval.end)
        else {
            return date
        }

        return finalDay
    }

    func projectedEfficiencyValue(from factualPoints: [MetricTrendPoint], projectedDate: Date) -> Double {
        let sample = Array(factualPoints.suffix(min(factualPoints.count, 6)))
        guard sample.count >= 2,
              let firstDate = sample.first?.date,
              let lastDate = sample.last?.date,
              let lastValue = sample.last?.value,
              lastValue > 0
        else {
            return projectedMetricTrendValue(from: factualPoints.map(\.value))
        }

        let ratios = zip(sample, sample.dropFirst()).compactMap { previous, current -> Double? in
            guard previous.value > 0, current.value > 0 else { return nil }
            return current.value / previous.value
        }
        guard !ratios.isEmpty else {
            return lastValue
        }

        let averageLogRatio = ratios.map { log($0) }.reduce(0, +) / Double(ratios.count)
        let rawPeriodRatio = exp(averageLogRatio)
        let clampedPeriodRatio = min(max(rawPeriodRatio, 0.72), 1.08)
        let elapsedPeriods = max(Double(sample.count - 1), 1)
        let averagePeriodLength = max(lastDate.timeIntervalSince(firstDate) / elapsedPeriods, 1)
        let projectedPeriods = max(projectedDate.timeIntervalSince(lastDate) / averagePeriodLength, 0)

        return lastValue * pow(clampedPeriodRatio, projectedPeriods)
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

        guard cost >= 0, mileage > 0 else {
            return nil
        }

        return cost / mileage
    }
}
