import Charts
import SwiftUI

struct CostPerKmEfficiencyCard: View {
    struct Model {
        let mileageUnit: String
        let chartRange: Binding<ScenarioOverviewView.ChartRange>
        let selectedDate: Binding<Date?>
        let selectedPoint: ScenarioOverviewView.MetricTrendPoint?
        let points: [ScenarioOverviewView.MetricTrendPoint]
        let yAxisMax: Double
        let yAxisValues: [Double]
        let axisDates: [Date]
        let currencySymbol: String
        let valueLabel: (ScenarioOverviewView.MetricTrendPoint) -> String
        let axisLabel: (Date) -> String
        let formatDouble: (Double, Int) -> String
    }

    let model: Model
    let onOpenDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            header
            readout
            chart
        }
        .padding(.horizontal, WorthItSpacing.l)
        .padding(.vertical, WorthItSpacing.xxl)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 12)
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
        .onTapGesture(perform: onOpenDetail)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("EFFICIENCY\nCOMPARISON")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.45)
                    .lineSpacing(2)

                Text("Cost per \(model.mileageUnit.uppercased())\n\(model.chartRange.wrappedValue.title)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
            }

            Spacer()
            CostPerKmRangePill(selection: model.chartRange, selectedDate: model.selectedDate)
        }
    }

    private var readout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let point = model.selectedPoint {
                Text(model.valueLabel(point))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(model.axisLabel(point.date))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .textCase(.uppercase)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 18)
    }

    private var chart: some View {
        Chart(model.points) { point in
            LineMark(x: .value("Period", point.date), y: .value("Cost per km", point.value))
                .foregroundStyle(WorthItColor.primaryContainer)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

            PointMark(x: .value("Period", point.date), y: .value("Cost per km", point.value))
                .foregroundStyle(WorthItColor.primaryContainer)
                .symbolSize(42)

            if let selectedPoint = model.selectedPoint, selectedPoint.id == point.id {
                RuleMark(x: .value("Selected month", selectedPoint.date))
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(x: .value("Selected month", selectedPoint.date), y: .value("Selected value", selectedPoint.value))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .symbolSize(82)
            }
        }
        .chartXSelection(value: model.selectedDate)
        .chartYScale(domain: 0...model.yAxisMax)
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
        .chartLegend(.hidden)
        .frame(height: 208)
    }

    @AxisContentBuilder
    private var xAxis: some AxisContent {
        AxisMarks(values: model.axisDates) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineSubtle.opacity(0.24))
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(model.axisLabel(date))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .textCase(.uppercase)
                }
            }
        }
    }

    @AxisContentBuilder
    private var yAxis: some AxisContent {
        AxisMarks(position: .leading, values: model.yAxisValues) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineInput.opacity(0.40))
            AxisValueLabel {
                if let rawValue = value.as(Double.self) {
                    Text("\(model.currencySymbol)\(model.formatDouble(rawValue, 2))")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                }
            }
        }
    }
}
