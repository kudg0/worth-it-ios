import SwiftUI

extension ScenarioOverviewView {
    var overviewEfficiencyModel: CostPerKmEfficiencyCard.Model {
        CostPerKmEfficiencyCard.Model(
            mileageUnit: mileageDisplayUnit,
            chartRange: $chartRange,
            selectedDate: selectedEfficiencyChartDateBinding,
            selectedPoint: selectedEfficiencyChartPoint,
            points: efficiencyChartPoints,
            comparisonSeries: overviewEfficiencyComparisonSeries,
            yAxisMax: overviewEfficiencyYAxisMax,
            yAxisValues: overviewEfficiencyYAxisValues,
            axisDates: efficiencyChartAxisDates,
            currencySymbol: currencySymbol,
            valueLabel: efficiencyPointValueLabel,
            axisLabel: efficiencyAxisLabel,
            formatDouble: formatDouble
        )
    }

    var overviewEfficiencyComparisonSeries: [ScenarioCompareChartSeries] {
        if let backendSeries = backendOverviewEfficiencyComparisonSeries, !backendSeries.isEmpty {
            return backendSeries.map(normalizedEfficiencyComparisonSeries)
        }

        let visibleAlternativeIds = Set(alternatives.filter(\.isIncluded).map(\.id))
        let colors = [
            Color(hex: 0x7DD3FC),
            Color(hex: 0xA7F3D0),
            Color(hex: 0xC4B5FD)
        ]

        if let series = currentComparison?.series {
            let backendSeries = series.alternatives
                .filter { visibleAlternativeIds.contains($0.id) }
                .enumerated()
                .compactMap { index, alternative -> ScenarioCompareChartSeries? in
                    let points = alternative.points.compactMap { point -> ScenarioCompareChartPoint? in
                        guard let perKm = point.perKm else { return nil }
                        return ScenarioCompareChartPoint(
                            date: expenseHistoryMonthStart(for: point.date),
                            value: perKm
                        )
                    }
                    .filter { point in
                        guard let firstDate = efficiencyChartPoints.first?.date,
                              let lastDate = efficiencyChartPoints.last?.date
                        else { return true }
                        return point.date >= firstDate && point.date <= lastDate
                    }
                    .prolongated(
                        from: efficiencyChartPoints.first?.date,
                        to: efficiencyChartPoints.last?.date
                    )
                    guard points.count >= 2 else { return nil }

                    return ScenarioCompareChartSeries(
                        id: alternative.id.uuidString,
                        title: alternative.name,
                        color: colors[index % colors.count].opacity(0.84),
                        points: points,
                        isBenchmark: true
                    )
                }
                .map(normalizedEfficiencyComparisonSeries)

            if !backendSeries.isEmpty {
                return backendSeries
            }
        }

        return []
    }

    var backendOverviewEfficiencyComparisonSeries: [ScenarioCompareChartSeries]? {
        let series = backendEfficiencyMetric?.chart?.seriesRanges?[chartRange.analyticsRangeKey]?.series
            ?? backendEfficiencyMetric?.chart?.series
        guard let series else { return nil }

        let colors = [
            Color(hex: 0x7DD3FC),
            Color(hex: 0xA7F3D0),
            Color(hex: 0xC4B5FD)
        ]

        return series
            .filter { $0.role == "benchmark" }
            .enumerated()
            .map { index, item in
                ScenarioCompareChartSeries(
                    id: item.id,
                    title: item.title,
                    color: colors[index % colors.count].opacity(0.84),
                    points: item.points.map {
                        ScenarioCompareChartPoint(date: $0.date, value: $0.value)
                    },
                    isBenchmark: true
                )
            }
    }

    func normalizedEfficiencyComparisonSeries(_ series: ScenarioCompareChartSeries) -> ScenarioCompareChartSeries {
        guard let id = UUID(uuidString: series.id),
              let result = currentComparison?.alternatives.first(where: { $0.id == id })
        else {
            return series
        }

        let breakEven = currentComparison?.alternativeBreakEvens.first { $0.alternativeId == id }
        let normalizedRate = dynamicAlternativeAverageRate(for: breakEven)
            ?? (result.pricingMode == .distanceCurve
                ? distanceCurveAverageRate(from: result.costBreakdown)
                : nil)

        guard let normalizedRate else {
            return series
        }

        return ScenarioCompareChartSeries(
            id: series.id,
            title: series.title,
            color: series.color,
            points: series.points.map { ScenarioCompareChartPoint(date: $0.date, value: normalizedRate) },
            isBenchmark: series.isBenchmark
        )
    }

    var overviewEfficiencyYAxisMax: Double {
        let comparisonMax = overviewEfficiencyComparisonSeries
            .flatMap { $0.points.map(\.value) }
            .max() ?? 0
        return max(efficiencyChartYAxisMax, comparisonMax * 1.08, 1)
    }

    var overviewEfficiencyYAxisValues: [Double] {
        [overviewEfficiencyYAxisMax, overviewEfficiencyYAxisMax / 2, 0]
    }
}

extension Array where Element == ScenarioCompareChartPoint {
    func prolongated(from startDate: Date?, to endDate: Date?) -> [ScenarioCompareChartPoint] {
        let sortedPoints = sorted { $0.date < $1.date }
        guard !sortedPoints.isEmpty else { return [] }

        var points = sortedPoints

        if let startDate,
           let firstPoint = points.first,
           firstPoint.date > startDate {
            points.insert(ScenarioCompareChartPoint(date: startDate, value: firstPoint.value), at: 0)
        }

        if let endDate,
           let lastPoint = points.last,
           lastPoint.date < endDate {
            points.append(ScenarioCompareChartPoint(date: endDate, value: lastPoint.value))
        }

        return points
    }
}
