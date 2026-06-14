import Charts
import SwiftUI

struct CompareBenchmarkChart: View {
    let series: [ScenarioCompareChartSeries]
    let currency: String
    let selectedMetric: ScenarioOverviewView.CompareMetric
    let scenarioStartDate: Date
    let comparisonBaselineValue: Double?
    @State private var hiddenSeriesIds: Set<String> = []
    @State private var selectedDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            readout
            chart
            legend
        }
        .onChange(of: chartSeries.map(\.id)) { _, ids in
            hiddenSeriesIds.formIntersection(Set(ids))
        }
    }

    private var readout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let point = selectedReferencePoint {
                Text(yAxisLabel(point.value))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(monthLabel(point.date))
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
            ForEach(visibleSeries) { item in
                ForEach(item.points) { point in
                    LineMark(
                        x: .value("Month", point.date),
                        y: .value("Cost", point.value),
                        series: .value("Series", item.id)
                    )
                    .foregroundStyle(item.color)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: item.isBenchmark ? 1.8 : 2.6,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: item.isBenchmark ? [5, 6] : []
                        )
                    )
                    .interpolationMethod(interpolationMethod(for: item))

                    if !item.isBenchmark {
                        PointMark(x: .value("Month", point.date), y: .value("Cost", point.value))
                            .foregroundStyle(item.color)
                            .symbolSize(point.id == selectedReferencePoint?.id ? 64 : 38)
                    }
                }
            }

            if let selectedReferencePoint {
                RuleMark(x: .value("Selected month", selectedReferencePoint.date))
                    .foregroundStyle(WorthItColor.primaryContainer.opacity(0.28))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

                PointMark(
                    x: .value("Selected month", selectedReferencePoint.date),
                    y: .value("Selected value", selectedReferencePoint.value)
                )
                .foregroundStyle(WorthItColor.primaryContainer)
                .symbolSize(82)
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartXScale(domain: chartDomain)
        .chartYScale(domain: chartYDomain)
        .chartXAxis { xAxis }
        .chartYAxis { yAxis }
        .chartLegend(.hidden)
        .chartPlotStyle { plotArea in
            plotArea.clipped()
        }
        .frame(height: 178)
    }

    private var legend: some View {
        FlowLayout(spacing: WorthItSpacing.m, rowSpacing: WorthItSpacing.s) {
            ForEach(chartSeries) { item in
                legendItem(item)
            }
        }
    }

    private func interpolationMethod(for item: ScenarioCompareChartSeries) -> InterpolationMethod {
        if item.isBenchmark || selectedMetric == .perMonth {
            return .linear
        }

        return .catmullRom
    }

    private func legendItem(_ item: ScenarioCompareChartSeries) -> some View {
        let isHidden = hiddenSeriesIds.contains(item.id)

        return Button {
            guard item.isBenchmark else { return }

            withAnimation(.easeInOut(duration: 0.18)) {
                if isHidden {
                    hiddenSeriesIds.remove(item.id)
                } else {
                    hiddenSeriesIds.insert(item.id)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Capsule()
                    .fill(item.color.opacity(isHidden ? 0.24 : 0.86))
                    .frame(width: 18, height: 3)

                Text(item.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isHidden ? WorthItColor.textTertiary.opacity(0.42) : WorthItColor.textSecondary)
                    .lineLimit(1)

                if item.isBenchmark, let comparisonValueLabel = comparisonValueLabel(for: item) {
                    Text(comparisonValueLabel)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(isHidden ? WorthItColor.textTertiary.opacity(0.34) : WorthItColor.textSecondary)
                        .lineLimit(1)
                }

                if item.isBenchmark, let deltaLabel = deltaLabel(for: item) {
                    Text(deltaLabel)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(isHidden ? WorthItColor.textTertiary.opacity(0.34) : deltaColor(for: item))
                        .lineLimit(1)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.isBenchmark ? "\(item.title) comparison" : item.title)
        .accessibilityValue(isHidden ? "Hidden" : "Visible")
    }

    @AxisContentBuilder
    private var xAxis: some AxisContent {
        AxisMarks(values: axisDates) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineSubtle.opacity(0.24))
            AxisValueLabel {
                if let date = value.as(Date.self) {
                    Text(monthLabel(date))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .textCase(.uppercase)
                }
            }
        }
    }

    @AxisContentBuilder
    private var yAxis: some AxisContent {
        AxisMarks(position: .leading, values: yAxisValues) { value in
            AxisGridLine().foregroundStyle(WorthItColor.outlineInput.opacity(0.38))
            AxisValueLabel {
                if let rawValue = value.as(Double.self) {
                    Text(yAxisLabel(rawValue))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.74))
                }
            }
        }
    }

    private var allDates: [Date] {
        Array(Set(([dataDomainStart] + chartSeries.flatMap { $0.points.map(\.date) }))).sorted()
    }

    private var axisDates: [Date] {
        let dates = allDates.filter { $0 >= dataDomainStart && $0 <= dataDomainEnd }
        guard dates.count > 2 else { return dates }
        return [
            dates.first,
            dates[dates.count / 2],
            dates.last
        ].compactMap(\.self)
    }

    private var chartDomain: ClosedRange<Date> {
        let interval = max(dataDomainEnd.timeIntervalSince(dataDomainStart), 86_400)
        let padding = interval * 0.04
        return dataDomainStart.addingTimeInterval(-padding)...dataDomainEnd.addingTimeInterval(padding)
    }

    private var dataDomainStart: Date {
        ownershipSeries?.points.map(\.date).min()
            ?? Calendar(identifier: .gregorian).dateInterval(of: .month, for: scenarioStartDate)?.start
            ?? scenarioStartDate
    }

    private var dataDomainEnd: Date {
        let lastDate = chartSeries.flatMap { $0.points.map(\.date) }.max() ?? Date()
        return max(lastDate, dataDomainStart)
    }

    private var chartMaxValue: Double {
        max((chartSeries.flatMap { $0.points.map(\.value) }.max() ?? 1) * 1.08, 1)
    }

    private var chartYDomain: ClosedRange<Double> {
        let padding = max(chartMaxValue * 0.08, 0.04)
        return -padding...(chartMaxValue + padding)
    }

    private var yAxisValues: [Double] {
        [chartMaxValue, chartMaxValue / 2, 0]
    }

    private func monthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private func yAxisLabel(_ value: Double) -> String {
        switch selectedMetric {
        case .perKm:
            return "\(ScenarioCompareFormatter.money(value, currency: currency))/km"
        case .perMonth:
            return "\(ScenarioCompareFormatter.money(value, currency: currency))/mo"
        case .totalCost:
            return ScenarioCompareFormatter.money(value, currency: currency)
        }
    }

    private var visibleSeries: [ScenarioCompareChartSeries] {
        chartSeries.filter { !$0.isBenchmark || !hiddenSeriesIds.contains($0.id) }
    }

    private var ownershipSeries: ScenarioCompareChartSeries? {
        series.first(where: { !$0.isBenchmark })
    }

    private var chartSeries: [ScenarioCompareChartSeries] {
        series
    }

    private var referencePoint: ScenarioCompareChartPoint? {
        ownershipSeries?.points.sorted { $0.date < $1.date }.last
    }

    private var selectedReferencePoint: ScenarioCompareChartPoint? {
        guard let ownershipPoints = ownershipSeries?.points.sorted(by: { $0.date < $1.date }),
              !ownershipPoints.isEmpty
        else {
            return nil
        }

        guard let selectedDate else {
            return ownershipPoints.last
        }

        return ownershipPoints.min { first, second in
            abs(first.date.timeIntervalSince(selectedDate)) < abs(second.date.timeIntervalSince(selectedDate))
        }
    }

    private func deltaLabel(for item: ScenarioCompareChartSeries) -> String? {
        guard let selectedReferencePoint,
              let comparisonValue = comparisonValue(in: item, near: selectedReferencePoint.date)
        else {
            return nil
        }

        let delta = comparisonValue - selectedReferencePoint.value
        let sign = delta >= 0 ? "+" : "-"
        return "\(sign)\(ScenarioCompareFormatter.money(abs(delta), currency: currency))\(deltaUnit)"
    }

    private func deltaColor(for item: ScenarioCompareChartSeries) -> Color {
        guard let selectedReferencePoint,
              let comparisonValue = comparisonValue(in: item, near: selectedReferencePoint.date)
        else {
            return WorthItColor.textTertiary
        }

        return comparisonValue > selectedReferencePoint.value ? WorthItColor.accentGold : WorthItColor.primaryContainer
    }

    private func comparisonValueLabel(for item: ScenarioCompareChartSeries) -> String? {
        guard selectedMetric == .perMonth,
              let selectedReferencePoint,
              let comparisonValue = comparisonValue(in: item, near: selectedReferencePoint.date)
        else {
            return nil
        }

        return yAxisLabel(comparisonValue)
    }

    private func comparisonValue(in item: ScenarioCompareChartSeries, near date: Date) -> Double? {
        item.points.min { first, second in
            abs(first.date.timeIntervalSince(date)) < abs(second.date.timeIntervalSince(date))
        }?.value
    }

    private var deltaUnit: String {
        switch selectedMetric {
        case .perKm:
            return "/km"
        case .perMonth:
            return "/mo"
        case .totalCost:
            return ""
        }
    }
}
