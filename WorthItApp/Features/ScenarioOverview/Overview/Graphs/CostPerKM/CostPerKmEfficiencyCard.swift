import Charts
import SwiftUI

struct CostPerKmEfficiencyCard: View {
    struct Model {
        let mileageUnit: String
        let chartRange: Binding<ScenarioOverviewView.ChartRange>
        let selectedDate: Binding<Date?>
        let selectedPoint: ScenarioOverviewView.MetricTrendPoint?
        let points: [ScenarioOverviewView.MetricTrendPoint]
        let comparisonSeries: [ScenarioCompareChartSeries]
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
    @State private var localSelectedDate: Date?
    @State private var hiddenComparisonSeriesIds: Set<String> = []

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
        .onChange(of: model.comparisonSeries.map(\.id)) { _, ids in
            hiddenComparisonSeriesIds.formIntersection(Set(ids))
        }
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
            CostPerKmRangePill(selection: model.chartRange, selectedDate: localSelectedDateBinding)
        }
    }

    private var readout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let point = selectedPoint {
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
        Chart {
            ForEach(solidPoints) { point in
                LineMark(x: .value("Period", point.date), y: .value("Cost per km", point.value))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(primaryInterpolationMethod)

                PointMark(x: .value("Period", point.date), y: .value("Cost per km", point.value))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .symbolSize(point.id == todayPoint?.id ? 70 : 42)
            }

            ForEach(visibleComparisonSeries) { series in
                ForEach(series.points) { point in
                    LineMark(
                        x: .value("Comparison period", point.date),
                        y: .value("Comparison cost per km", point.value),
                        series: .value("Comparison", series.id)
                    )
                    .foregroundStyle(series.color.opacity(0.74))
                    .lineStyle(StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round, dash: [4, 5]))
                    .interpolationMethod(.linear)
                }
            }

            ForEach(projectedDashPoints) { point in
                LineMark(
                    x: .value("Projected period", point.date),
                    y: .value("Projected cost per km", point.value),
                    series: .value("Projection dash", point.series)
                )
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.54))
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .butt, lineJoin: .miter))
                    .interpolationMethod(.linear)
            }

            if let todayPoint {
                RuleMark(x: .value("Today", todayPoint.date))
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.22))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }

            if let selectedPoint {
                RuleMark(x: .value("Selected month", selectedPoint.date))
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(x: .value("Selected month", selectedPoint.date), y: .value("Selected value", selectedPoint.value))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .symbolSize(82)
            }
        }
        .chartXSelection(value: localSelectedDateBinding)
        .chartYScale(domain: chartYDomain)
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
        .chartLegend(.hidden)
        .chartPlotStyle { plotArea in
            plotArea.clipped()
        }
        .frame(height: 208)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !model.comparisonSeries.isEmpty {
                legend
                    .padding(.top, WorthItSpacing.s)
            }
        }
    }

    private var legend: some View {
        EfficiencyLegendFlowLayout(spacing: WorthItSpacing.m, rowSpacing: WorthItSpacing.xs) {
            legendItem(title: i18n.t("Your car"), color: WorthItColor.primaryContainer)

            ForEach(model.comparisonSeries) { series in
                comparisonLegendItem(series)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Capsule()
                .fill(color.opacity(0.86))
                .frame(width: 14, height: 3)

            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    private func comparisonLegendItem(_ series: ScenarioCompareChartSeries) -> some View {
        let isHidden = hiddenComparisonSeriesIds.contains(series.id)

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                if isHidden {
                    hiddenComparisonSeriesIds.remove(series.id)
                } else {
                    hiddenComparisonSeriesIds.insert(series.id)
                }
            }
        } label: {
            HStack(spacing: 5) {
                Capsule()
                    .fill(series.color.opacity(isHidden ? 0.24 : 0.86))
                    .frame(width: 14, height: 3)

                Text(series.title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(isHidden ? WorthItColor.textTertiary.opacity(0.42) : WorthItColor.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if let deltaLabel = comparisonDeltaLabel(for: series) {
                    Text(deltaLabel)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(isHidden ? WorthItColor.textTertiary.opacity(0.34) : comparisonDeltaColor(for: series))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(series.title) comparison")
        .accessibilityValue(isHidden ? "Hidden" : "Visible")
    }

    private var visibleComparisonSeries: [ScenarioCompareChartSeries] {
        model.comparisonSeries.filter { !hiddenComparisonSeriesIds.contains($0.id) }
    }

    private var primaryInterpolationMethod: InterpolationMethod {
        model.chartRange.wrappedValue == .day ? .linear : .monotone
    }

    private var selectedPoint: ScenarioOverviewView.MetricTrendPoint? {
        guard let localSelectedDate else {
            return model.selectedPoint
        }

        return nearestPoint(to: localSelectedDate)
    }

    private var localSelectedDateBinding: Binding<Date?> {
        Binding {
            localSelectedDate ?? model.selectedDate.wrappedValue ?? model.selectedPoint?.date
        } set: { newValue in
            guard let newValue else {
                localSelectedDate = nil
                return
            }

            localSelectedDate = nearestPoint(to: newValue)?.date
        }
    }

    private func nearestPoint(to date: Date) -> ScenarioOverviewView.MetricTrendPoint? {
        model.points.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    private var chartYDomain: ClosedRange<Double> {
        let padding = max(model.yAxisMax * 0.08, 0.04)
        return -padding...(model.yAxisMax + padding)
    }

    private func comparisonDeltaLabel(for series: ScenarioCompareChartSeries) -> String? {
        guard let selectedPoint,
              let comparisonValue = comparisonValue(in: series, near: selectedPoint.date)
        else {
            return nil
        }

        let delta = comparisonValue - selectedPoint.value
        let sign = delta >= 0 ? "+" : "-"
        return "\(sign)\(model.currencySymbol)\(model.formatDouble(abs(delta), 2))/km"
    }

    private func comparisonDeltaColor(for series: ScenarioCompareChartSeries) -> Color {
        guard let selectedPoint,
              let comparisonValue = comparisonValue(in: series, near: selectedPoint.date)
        else {
            return WorthItColor.textTertiary
        }

        return comparisonValue > selectedPoint.value ? WorthItColor.accentGold : WorthItColor.primaryContainer
    }

    private func comparisonValue(in series: ScenarioCompareChartSeries, near date: Date) -> Double? {
        series.points.min { first, second in
            abs(first.date.timeIntervalSince(date)) < abs(second.date.timeIntervalSince(date))
        }?.value
    }

    private var solidPoints: [ScenarioOverviewView.MetricTrendPoint] {
        model.points.filter { !$0.isProjected }
    }

    private var dashedPoints: [ScenarioOverviewView.MetricTrendPoint] {
        guard let firstProjectedIndex = model.points.firstIndex(where: \.isProjected) else {
            return []
        }

        let anchor = firstProjectedIndex > 0 ? [model.points[firstProjectedIndex - 1]] : []
        return anchor + model.points[firstProjectedIndex...]
    }

    private var todayPoint: ScenarioOverviewView.MetricTrendPoint? {
        solidPoints.last
    }

    private var projectedDashPoints: [ProjectedEfficiencyDashPoint] {
        guard dashedPoints.count >= 2 else { return [] }

        return dashedPoints.indices.dropFirst().flatMap { index -> [ProjectedEfficiencyDashPoint] in
            let start = dashedPoints[index - 1]
            let end = dashedPoints[index]
            let dashFractions: [(Double, Double)] = [(0.00, 0.34), (0.58, 0.92)]

            return dashFractions.enumerated().flatMap { dashIndex, fraction -> [ProjectedEfficiencyDashPoint] in
                let series = "\(index)-\(dashIndex)"
                return [
                    ProjectedEfficiencyDashPoint(
                        id: "\(series)-start",
                        series: series,
                        date: interpolatedDate(from: start.date, to: end.date, fraction: fraction.0),
                        value: interpolatedValue(from: start.value, to: end.value, fraction: fraction.0)
                    ),
                    ProjectedEfficiencyDashPoint(
                        id: "\(series)-end",
                        series: series,
                        date: interpolatedDate(from: start.date, to: end.date, fraction: fraction.1),
                        value: interpolatedValue(from: start.value, to: end.value, fraction: fraction.1)
                    )
                ]
            }
        }
    }

    private func interpolatedDate(from start: Date, to end: Date, fraction: Double) -> Date {
        start.addingTimeInterval(end.timeIntervalSince(start) * fraction)
    }

    private func interpolatedValue(from start: Double, to end: Double, fraction: Double) -> Double {
        start + (end - start) * fraction
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

private struct ProjectedEfficiencyDashPoint: Identifiable {
    let id: String
    let series: String
    let date: Date
    let value: Double
}

private struct EfficiencyLegendFlowLayout: Layout {
    let spacing: CGFloat
    let rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(in: proposal.width ?? 0, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = max(width, 1)

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }

            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
