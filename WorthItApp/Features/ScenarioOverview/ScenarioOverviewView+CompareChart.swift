import SwiftUI

extension ScenarioOverviewView {
    var compareChartSeries: [ScenarioCompareChartSeries] {
        if let backendSeries = backendCompareChartSeries, !backendSeries.isEmpty {
            return backendSeries
        }

        return []
    }

    var backendCompareChartSeries: [ScenarioCompareChartSeries]? {
        guard let series = currentComparison?.series else { return nil }

        var result: [ScenarioCompareChartSeries] = []
        let ownershipPoints = series.ownership.compactMap { point -> ScenarioCompareChartPoint? in
            guard let value = compareChartValue(point) else { return nil }
            return ScenarioCompareChartPoint(date: point.date, value: value)
        }

        if !ownershipPoints.isEmpty {
            result.append(
                ScenarioCompareChartSeries(
                    id: "ownership",
                    title: i18n.t("Your car"),
                    color: WorthItColor.primaryContainer,
                    points: ownershipPoints,
                    isBenchmark: false
                )
            )
        }

        let visibleAlternativeIds = Set(alternatives.filter(\.isIncluded).map(\.id))
        let colors = [
            Color(hex: 0x7DD3FC),
            Color(hex: 0xA7F3D0),
            Color(hex: 0xC4B5FD),
            Color(hex: 0xF9A8D4)
        ]

        result.append(
            contentsOf: series.alternatives
                .filter { visibleAlternativeIds.contains($0.id) }
                .enumerated()
                .compactMap { index, alternative -> ScenarioCompareChartSeries? in
                    let comparisonResult = currentComparison?.alternatives.first { $0.id == alternative.id }
                    let breakEven = currentComparison?.alternativeBreakEvens.first {
                        $0.alternativeId == alternative.id
                    }
                    let points = alternative.points.compactMap { point -> ScenarioCompareChartPoint? in
                        guard let value = compareChartValue(
                            point,
                            result: comparisonResult,
                            breakEven: breakEven
                        ) else { return nil }
                        return ScenarioCompareChartPoint(date: point.date, value: value)
                    }
                    guard !points.isEmpty else { return nil }

                    return ScenarioCompareChartSeries(
                        id: alternative.id.uuidString,
                        title: alternative.name,
                        color: colors[index % colors.count].opacity(0.86),
                        points: points,
                        isBenchmark: true
                    )
                }
        )

        return result
    }

    func compareChartValue(
        _ point: ScenarioComparison.Series.Point,
        result: ScenarioComparison.AlternativeResult?,
        breakEven: ScenarioComparison.AlternativeBreakEven?
    ) -> Double? {
        if compareMetric == .perKm,
           let dynamicAverageRate = dynamicAlternativeAverageRate(for: breakEven) {
            return dynamicAverageRate
        }

        if compareMetric == .perKm,
           result?.pricingMode == .distanceCurve,
           let averageRate = distanceCurveAverageRate(from: result?.costBreakdown) {
            return averageRate
        }

        return compareChartValue(point)
    }

    func dynamicAlternativeAverageRate(for row: ScenarioComparison.AlternativeBreakEven?) -> Double? {
        let rates = row?.dynamicTripSavings?.items.compactMap(\.alternativeCostPerKm) ?? []
        guard !rates.isEmpty else { return nil }
        return rates.reduce(0, +) / Double(rates.count)
    }

    func compareChartValue(_ point: ScenarioComparison.Series.Point) -> Double? {
        switch compareMetric {
        case .perKm:
            return point.perKm
        case .perMonth:
            return point.perMonth
        case .totalCost:
            return point.total
        }
    }

    func distanceCurveAverageRate(from breakdown: ScenarioComparison.CostBreakdown?) -> Double? {
        if let rates = breakdown?.inputs.curvePointRates, !rates.isEmpty {
            return rates.reduce(0, +) / Double(rates.count)
        }

        return breakdown?.inputs.averageCurvePricePerKm
    }

    func averageMonthlyOwnershipCost(asOf date: Date) -> Double? {
        let calendar = Calendar(identifier: .gregorian)
        let start = expenseHistoryMonthStart(for: activeScenario.startDate)
        let end = min(max(date, start), Date())
        let monthCount = max((calendar.dateComponents([.month], from: start, to: end).month ?? 0) + 1, 1)
        return netOwnershipCost(to: end) / Double(monthCount)
    }
}
