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
        ForEach(model.dashedPoints) { point in
            LineMark(
                x: .value(model.xValueName, point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(model.accentColor.opacity(0.70))
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 6]))
            .interpolationMethod(.monotone)
        }
    }

    @ChartContentBuilder
    private var selectedMarks: some ChartContent {
        if let selectedPoint = model.selectedPoint {
            RuleMark(x: .value(model.selectedRuleName, selectedPoint.date))
                .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

            PointMark(
                x: .value(model.selectedRuleName, selectedPoint.date),
                y: .value(model.selectedValueName, selectedPoint.value)
            )
            .foregroundStyle(model.accentColor)
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
