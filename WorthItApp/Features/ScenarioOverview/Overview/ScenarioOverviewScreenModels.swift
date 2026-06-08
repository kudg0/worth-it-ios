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
                    .prolongatedTo(efficiencyChartPoints.last?.date)
                    guard points.count >= 2 else { return nil }

                    return ScenarioCompareChartSeries(
                        id: alternative.id.uuidString,
                        title: alternative.name,
                        color: colors[index % colors.count].opacity(0.84),
                        points: points,
                        isBenchmark: true
                    )
                }

            if !backendSeries.isEmpty {
                return backendSeries
            }
        }

        return []
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

private extension Array where Element == ScenarioCompareChartPoint {
    func prolongatedTo(_ endDate: Date?) -> [ScenarioCompareChartPoint] {
        let sortedPoints = sorted { $0.date < $1.date }
        guard let endDate,
              let lastPoint = sortedPoints.last,
              lastPoint.date < endDate
        else {
            return sortedPoints
        }

        return sortedPoints + [ScenarioCompareChartPoint(date: endDate, value: lastPoint.value)]
    }
}
