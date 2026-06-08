import SwiftUI

extension ScenarioOverviewView {
    var metricTrendRangeBinding: Binding<MetricTrendRange> {
        Binding {
            selectedMetricTrendRange
        } set: { newValue in
            selectedMetricTrendRange = newValue
            selectedMetricTrendDate = nil
        }
    }

    @ViewBuilder
    func metricTrendChart(
        metric: MetricSlide?,
        height: CGFloat,
        xValueName: String,
        selectedRuleName: String,
        selectedValueName: String,
        selectedSymbolSize: CGFloat,
        areaOpacity: Double
    ) -> some View {
        let allPoints = sortedTrendPoints(metricTrendPoints)
        let solidPoints = sortedTrendPoints(allPoints.filter { !$0.isProjected })

        MetricTrendChart(
            model: MetricTrendChart.Model(
                allPoints: allPoints,
                solidPoints: solidPoints,
                dashedPoints: dashedMetricTrendPoints,
                selectedPoint: selectedMetricTrendPoint,
                selectedDate: selectedMetricTrendDateBinding,
                accentColor: metric?.accentColor ?? WorthItColor.primaryContainer,
                showsArea: showsMetricTrendArea,
                yAxisMax: metricTrendYAxisMax,
                yAxisValues: metricTrendYAxisValues,
                xAxisDates: metricTrendAxisDates,
                isScrollable: usesScrollableMetricTrendChart,
                visibleDomainLength: metricTrendVisibleDomainLength,
                initialScrollDate: metricTrendPoints.last?.date ?? Date(),
                height: height,
                xValueName: xValueName,
                selectedRuleName: selectedRuleName,
                selectedValueName: selectedValueName,
                selectedSymbolSize: selectedSymbolSize,
                areaOpacity: areaOpacity,
                xAxisLabel: metricTrendAxisLabel,
                yAxisLabel: metricTrendYAxisLabel
            )
        )
    }

    var showsMetricTrendArea: Bool {
        selectedDetailMetric != .costPerKm
    }
}
