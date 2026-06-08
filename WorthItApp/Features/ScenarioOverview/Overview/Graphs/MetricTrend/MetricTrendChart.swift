import Charts
import SwiftUI

struct MetricTrendChart: View {
    struct Model {
        let allPoints: [ScenarioOverviewView.MetricTrendPoint]
        let solidPoints: [ScenarioOverviewView.MetricTrendPoint]
        let dashedPoints: [ScenarioOverviewView.MetricTrendPoint]
        let selectedPoint: ScenarioOverviewView.MetricTrendPoint?
        let selectedDate: Binding<Date?>
        let accentColor: Color
        let showsArea: Bool
        let yAxisMax: Double
        let yAxisValues: [Double]
        let xAxisDates: [Date]
        let isScrollable: Bool
        let visibleDomainLength: TimeInterval
        let initialScrollDate: Date
        let height: CGFloat
        let xValueName: String
        let selectedRuleName: String
        let selectedValueName: String
        let selectedSymbolSize: CGFloat
        let areaOpacity: Double
        let xAxisLabel: (Date) -> String
        let yAxisLabel: (Double) -> String
    }

    let model: Model

    var body: some View {
        if model.isScrollable {
            chart
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: model.visibleDomainLength)
                .chartScrollPosition(initialX: model.initialScrollDate)
                .frame(height: model.height)
        } else {
            chart
                .frame(height: model.height)
        }
    }

    private var chart: some View {
        Chart {
            if model.showsArea {
                areaMarks
            }

            solidLineMarks
            dashedLineMarks
            selectedMarks
        }
        .chartXSelection(value: model.selectedDate)
        .chartYScale(domain: 0...model.yAxisMax)
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
        .chartLegend(.hidden)
    }

    private var areaMarks: some ChartContent {
        ForEach(model.allPoints) { point in
            AreaMark(
                x: .value(model.xValueName, point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        model.accentColor.opacity(model.areaOpacity),
                        model.accentColor.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.monotone)
        }
    }

    private var solidLineMarks: some ChartContent {
        ForEach(model.solidPoints) { point in
            LineMark(
                x: .value(model.xValueName, point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(model.accentColor)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.monotone)
        }
    }

    private var dashedLineMarks: some ChartContent {
        ForEach(projectedDashPoints) { point in
            LineMark(
                x: .value(model.xValueName, point.date),
                y: .value("Projected value", point.value),
                series: .value("Projection dash", point.series)
            )
            .foregroundStyle(WorthItColor.projectedBlue.opacity(0.68))
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .butt, lineJoin: .miter))
            .interpolationMethod(.linear)
        }
    }

    private var projectedDashPoints: [ProjectedDashPoint] {
        Self.dashPoints(from: model.dashedPoints)
    }

    private static func dashPoints(from points: [ScenarioOverviewView.MetricTrendPoint]) -> [ProjectedDashPoint] {
        guard points.count >= 2 else { return [] }

        return points.indices.dropFirst().flatMap { index -> [ProjectedDashPoint] in
            let start = points[index - 1]
            let end = points[index]
            let dashFractions: [(Double, Double)] = [(0.00, 0.34), (0.58, 0.92)]

            return dashFractions.enumerated().flatMap { dashIndex, fraction -> [ProjectedDashPoint] in
                let series = "\(index)-\(dashIndex)"
                return [
                    ProjectedDashPoint(
                        id: "\(series)-start",
                        series: series,
                        date: interpolatedDate(from: start.date, to: end.date, fraction: fraction.0),
                        value: interpolatedValue(from: start.value, to: end.value, fraction: fraction.0)
                    ),
                    ProjectedDashPoint(
                        id: "\(series)-end",
                        series: series,
                        date: interpolatedDate(from: start.date, to: end.date, fraction: fraction.1),
                        value: interpolatedValue(from: start.value, to: end.value, fraction: fraction.1)
                    )
                ]
            }
        }
    }

    private static func interpolatedDate(from start: Date, to end: Date, fraction: Double) -> Date {
        start.addingTimeInterval(end.timeIntervalSince(start) * fraction)
    }

    private static func interpolatedValue(from start: Double, to end: Double, fraction: Double) -> Double {
        start + (end - start) * fraction
    }

    @ChartContentBuilder
    private var selectedMarks: some ChartContent {
        if let selectedPoint = model.selectedPoint {
            RuleMark(x: .value(model.selectedRuleName, selectedPoint.date))
                .foregroundStyle(selectedPoint.isProjected ? WorthItColor.projectedBlue.opacity(0.30) : WorthItColor.primaryContainer.opacity(0.28))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

            PointMark(
                x: .value(model.selectedRuleName, selectedPoint.date),
                y: .value(model.selectedValueName, selectedPoint.value)
            )
            .foregroundStyle(selectedPoint.isProjected ? WorthItColor.projectedBlue : model.accentColor)
            .symbolSize(model.selectedSymbolSize)
        }
    }

    @AxisContentBuilder
    private var xAxis: some AxisContent {
        AxisMarks(values: model.xAxisDates) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineSubtle.opacity(0.32))
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(model.xAxisLabel(date))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .textCase(.uppercase)
                }
            }
        }
    }

    @AxisContentBuilder
    private var yAxis: some AxisContent {
        AxisMarks(position: .leading, values: model.yAxisValues) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineSubtle.opacity(0.42))
            AxisValueLabel {
                if let rawValue = value.as(Double.self) {
                    Text(model.yAxisLabel(rawValue))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                }
            }
        }
    }
}

private struct ProjectedDashPoint: Identifiable {
    let id: String
    let series: String
    let date: Date
    let value: Double
}
