import Charts
import SwiftUI

struct ScenarioCompareChartPoint: Identifiable {
    let date: Date
    let value: Double

    var id: Date { date }
}

struct ScenarioCompareChartSeries: Identifiable {
    let id: String
    let title: String
    let color: Color
    let points: [ScenarioCompareChartPoint]
    let isBenchmark: Bool
}

struct ScenarioCompareScreen: View {
    let selectedMetric: Binding<ScenarioOverviewView.CompareMetric>
    let currency: String
    let summary: ScenarioSummary?
    let ownershipCostPerKm: Double?
    let ownershipMonthlyCost: Double?
    let comparison: ScenarioComparison?
    let alternatives: [AlternativeOption]
    let alternativesError: String?
    let chartSeries: [ScenarioCompareChartSeries]
    let scenarioStartDate: Date
    let focusedComparableId: UUID?
    let onAddComparable: () -> Void
    let onEditComparable: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: "Compare")

            if let insightText {
                WITipInfo(title: "Worth It", bodyText: insightText, size: .small, tone: .primary)
            }

            metricPills
            accumulationIsland

            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                Text("ALTERNATIVES COMPARISON")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(2.4)

                if let alternativesError {
                    Text(alternativesError)
                        .font(WorthItTypography.caption)
                        .foregroundStyle(Color(hex: 0xFFB4AB))
                        .fixedSize(horizontal: false, vertical: true)
                }

                if alternatives.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: WorthItSpacing.m) {
                        ForEach(alternatives) { alternative in
                            ComparableOptionRow(
                                alternative: alternative,
                                result: result(for: alternative.id),
                                selectedMetric: selectedMetric.wrappedValue,
                                currency: currency,
                                summary: summary,
                                ownershipCostPerKm: selectedMetric.wrappedValue == .perKm ? currentOwnershipChartValue ?? ownershipCostPerKm : ownershipCostPerKm,
                                ownershipMonthlyCost: ownershipMonthlyCost,
                                chartMetricValue: selectedMetric.wrappedValue == .perMonth ? latestChartValue(for: alternative.id) : nil,
                                chartOwnershipValue: selectedMetric.wrappedValue == .perMonth ? currentOwnershipChartValue : nil,
                                isFocused: focusedComparableId == alternative.id,
                                onEdit: { onEditComparable(alternative.id) }
                            )
                        }
                    }
                }
            }

            WIButton(title: "Add Comparable Option", height: 56, action: onAddComparable)
        }
        .onAppear(perform: normalizeSelectedMetric)
        .onChange(of: selectedMetric.wrappedValue) { _, _ in
            normalizeSelectedMetric()
        }
    }

    private var metricPills: some View {
        HStack(spacing: WorthItSpacing.s) {
            ForEach(ScenarioOverviewView.CompareMetric.compareVisibleCases) { metric in
                metricPill(metric)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func normalizeSelectedMetric() {
        guard !ScenarioOverviewView.CompareMetric.compareVisibleCases.contains(selectedMetric.wrappedValue) else { return }
        selectedMetric.wrappedValue = .perKm
    }

    private var accumulationIsland: some View {
        WIIsland(title: "Cost Accumulation") {
            VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
                ownershipMetricHero

                CompareBenchmarkChart(
                    series: chartSeries,
                    currency: currency,
                    selectedMetric: selectedMetric.wrappedValue,
                    scenarioStartDate: scenarioStartDate,
                    comparisonBaselineValue: comparisonBaselineValue
                )
            }
        }
    }

    private var ownershipMetricHero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            if let ownershipMetricCaption {
                Text(ownershipMetricCaption)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(1.4)
                    .textCase(.uppercase)
            }

            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                Text(ownershipMetricText)
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.8)

                Text(ownershipMetricUnit)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: WorthItSpacing.m) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 64, height: 64)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.l))

            Text("No comparable options yet")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)

            Text("Add taxi, car sharing, rental, or public transport to compare ownership performance.")
                .font(WorthItTypography.bodySmall)
                .lineSpacing(4)
                .foregroundStyle(WorthItColor.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.xxxl)
        .frame(maxWidth: .infinity)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private func metricPill(_ metric: ScenarioOverviewView.CompareMetric) -> some View {
        let isSelected = selectedMetric.wrappedValue == metric

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedMetric.wrappedValue = metric
            }
        } label: {
            Text(metric.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
                .padding(.horizontal, WorthItSpacing.xl)
                .frame(height: 34)
                .background(isSelected ? WorthItColor.primaryContainer : Color(hex: 0x3A4666), in: Capsule())
                .overlay {
                    Capsule().stroke(isSelected ? Color.clear : Color(hex: 0x44474F), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(metric.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func result(for id: UUID) -> ScenarioComparison.AlternativeResult? {
        comparison?.alternatives.first(where: { $0.id == id })
    }

    private var bestSelectedMetricResult: (result: ScenarioComparison.AlternativeResult, delta: Double)? {
        comparison?.alternatives
            .compactMap { result -> (ScenarioComparison.AlternativeResult, Double)? in
                guard let delta = selectedMetricDelta(for: result) else { return nil }
                return (result, delta)
            }
            .max { first, second in
                first.1 < second.1
            }
    }

    private var insightText: String? {
        guard let bestSelectedMetricResult else { return nil }

        let result = bestSelectedMetricResult.result
        let delta = bestSelectedMetricResult.delta
        let amount = money(abs(delta))
        let direction = delta >= 0 ? "cheaper" : "more expensive"
        return "\(insightScopeText): owning this car is \(amount) \(direction) than \(result.name)."
    }

    private var ownershipMetricText: String {
        switch selectedMetric.wrappedValue {
        case .perKm:
            currentOwnershipChartValue.map { money($0) } ?? ownershipCostPerKm.map { money($0) } ?? "-"
        case .perMonth:
            ownershipMonthlyCost.map { money($0) } ?? currentOwnershipChartValue.map { money($0) } ?? "-"
        case .totalCost:
            currentOwnershipChartValue.map { money($0) } ?? summary.map { money($0.netOwnershipCost) } ?? "-"
        }
    }

    private var ownershipMetricUnit: String {
        switch selectedMetric.wrappedValue {
        case .perKm: "/ km"
        case .perMonth: "/ month"
        case .totalCost: "total"
        }
    }

    private var ownershipMetricCaption: String? {
        switch selectedMetric.wrappedValue {
        case .perMonth:
            return "Average monthly cost"
        case .perKm, .totalCost:
            return nil
        }
    }

    private var comparisonBaselineValue: Double? {
        switch selectedMetric.wrappedValue {
        case .perKm:
            return currentOwnershipChartValue ?? ownershipCostPerKm
        case .perMonth:
            return ownershipMonthlyCost ?? currentOwnershipChartValue
        case .totalCost:
            return currentOwnershipChartValue ?? summary?.netOwnershipCost
        }
    }

    private func selectedMetricDelta(for result: ScenarioComparison.AlternativeResult) -> Double? {
        switch selectedMetric.wrappedValue {
        case .perKm:
            guard let ownershipValue = currentOwnershipChartValue ?? ownershipCostPerKm,
                  let alternativeCostPerKm = result.costBreakdown.perKm
            else { return nil }
            return alternativeCostPerKm - ownershipValue
        case .perMonth:
            guard let ownershipValue = currentOwnershipChartValue,
                  let alternativeCostPerMonth = latestChartValue(for: result.id)
            else { return nil }
            return alternativeCostPerMonth - ownershipValue
        case .totalCost:
            guard let ownershipValue = currentOwnershipChartValue ?? summary?.netOwnershipCost else { return nil }
            return result.estimatedTotalCost - ownershipValue
        }
    }

    private var currentOwnershipChartValue: Double? {
        chartSeries
            .first(where: { !$0.isBenchmark })?
            .points
            .sorted { $0.date < $1.date }
            .last?
            .value
    }

    private func latestChartValue(for alternativeId: UUID) -> Double? {
        chartSeries
            .first(where: { $0.id == alternativeId.uuidString })?
            .points
            .sorted { $0.date < $1.date }
            .last?
            .value
    }

    private var insightScopeText: String {
        switch selectedMetric.wrappedValue {
        case .perKm:
            return "Across total tracked distance"
        case .perMonth:
            return "For selected month usage"
        case .totalCost:
            return "Across full ownership period"
        }
    }

    private func money(_ value: Double) -> String {
        ScenarioCompareFormatter.money(value, currency: currency)
    }
}

private struct ComparableOptionRow: View {
    let alternative: AlternativeOption
    let result: ScenarioComparison.AlternativeResult?
    let selectedMetric: ScenarioOverviewView.CompareMetric
    let currency: String
    let summary: ScenarioSummary?
    let ownershipCostPerKm: Double?
    let ownershipMonthlyCost: Double?
    let chartMetricValue: Double?
    let chartOwnershipValue: Double?
    let isFocused: Bool
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: WorthItSpacing.l) {
                icon

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(alternative.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(deltaText)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(deltaColor)

                    Text(metricText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)

                    if let metricDetailText {
                        Text(metricDetailText)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(WorthItColor.textTertiary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: WorthItSpacing.m) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)

                    if !alternative.isIncluded {
                        Text("Hidden")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WorthItColor.textTertiary)
                    }
                }
            }
            .padding(WorthItSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(
                        isFocused ? WorthItColor.primaryContainer.opacity(0.92) : WorthItColor.outlineSubtle.opacity(0.55),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            }
            .shadow(color: isFocused ? WorthItColor.primaryContainer.opacity(0.20) : .clear, radius: 16, y: 8)
            .opacity(alternative.isIncluded ? 1 : 0.62)
        }
        .buttonStyle(.plain)
    }

    private var icon: some View {
        Image(systemName: iconName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(WorthItColor.primaryContainer)
            .frame(width: 52, height: 52)
            .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var iconName: String {
        let name = alternative.name.lowercased()
        if name.contains("taxi") { return "car.fill" }
        if name.contains("share") { return "car.2.fill" }
        if name.contains("rental") { return "key.fill" }
        if name.contains("transport") || name.contains("bus") { return "bus.fill" }
        return "arrow.triangle.branch"
    }

    private var deltaText: String {
        guard alternative.isIncluded, let result else { return "Not included" }
        guard let delta = selectedMetricDelta(for: result) else { return "Not enough data" }

        let amount = ScenarioCompareFormatter.money(abs(delta.value), currency: currency)
        let direction = delta.value >= 0 ? "more expensive" : "cheaper"
        return "\(delta.value >= 0 ? "+" : "-") \(amount) \(direction)\(delta.unitSuffix)"
    }

    private var deltaColor: Color {
        guard let result, let delta = selectedMetricDelta(for: result) else { return WorthItColor.textTertiary }
        return delta.value >= 0 ? WorthItColor.accentGold : WorthItColor.primaryContainer
    }

    private var metricText: String {
        if let result {
            switch selectedMetric {
            case .perKm:
                guard let perKm = result.costBreakdown.perKm else { return pricingDescription }
                return "\(ScenarioCompareFormatter.money(perKm, currency: currency)) per km"
            case .perMonth:
                guard let perMonth = chartMetricValue ?? result.costBreakdown.perMonth else { return pricingDescription }
                return "\(ScenarioCompareFormatter.money(perMonth, currency: currency)) per month"
            case .totalCost:
                return "\(ScenarioCompareFormatter.money(result.estimatedTotalCost, currency: currency)) total"
            }
        }

        return pricingDescription
    }

    private var metricDetailText: String? {
        guard let result else { return pricingDescription }

        let total = ScenarioCompareFormatter.money(result.estimatedTotalCost, currency: currency)
        switch selectedMetric {
        case .perKm:
            let distance = result.costBreakdown.inputs.totalDistanceKm
            guard distance > 0 else { return pricingBasisText }
            if alternative.pricingMode == .distanceCurve {
                return distanceCurveRateFormula(for: result.costBreakdown)
            }
            if alternative.pricingMode == .perPeriod {
                return monthlyPlanPerKmFormula(breakdown: result.costBreakdown)
            }
            return "\(total) ÷ \(ScenarioCompareFormatter.number(distance)) km • \(pricingBasisText)"
        case .perMonth:
            if chartMetricValue != nil {
                return "Selected month usage estimate"
            }

            let months = result.costBreakdown.inputs.monthsOwned
            guard months > 0 else { return pricingBasisText }
            if alternative.pricingMode == .distanceCurve {
               let distance = result.costBreakdown.inputs.totalDistanceKm
                return "\(distanceCurveTotalFormula(total: total, breakdown: result.costBreakdown, distance: distance)) ÷ \(ScenarioCompareFormatter.number(months)) mo"
            }
            return "\(total) ÷ \(ScenarioCompareFormatter.number(months)) mo • \(pricingBasisText)"
        case .totalCost:
            if alternative.pricingMode == .distanceCurve,
               let distance = summary?.totalDistanceKm,
               distance > 0 {
                return distanceCurveTotalFormula(total: total, breakdown: result.costBreakdown, distance: distance)
            }
            return "\(total) estimated total • \(pricingBasisText)"
        }
    }

    private var pricingDescription: String {
        switch alternative.pricingMode {
        case .perDistance:
            return "\(ScenarioCompareFormatter.money(alternative.paramsJson.pricePerKm ?? 0, currency: currency)) per km"
        case .distanceCurve:
            let rates = (alternative.paramsJson.pricePoints ?? []).compactMap { point -> Double? in
                guard point.distanceKm > 0 else { return nil }
                return point.totalPrice / point.distanceKm
            }
            let average = rates.isEmpty ? 0 : rates.reduce(0, +) / Double(rates.count)
            return "\(ScenarioCompareFormatter.money(average, currency: currency)) avg per km"
        case .perPeriod:
            return "\(ScenarioCompareFormatter.money(alternative.paramsJson.pricePerMonth ?? 0, currency: currency)) per month"
        case .perTime:
            return "\(ScenarioCompareFormatter.money(alternative.paramsJson.pricePerMinute ?? 0, currency: currency)) per minute"
        case .mixed:
            let perKm = ScenarioCompareFormatter.money(alternative.paramsJson.pricePerKm ?? 0, currency: currency)
            let perMinute = ScenarioCompareFormatter.money(alternative.paramsJson.pricePerMinute ?? 0, currency: currency)
            return "\(perKm)/km + \(perMinute)/min"
        case .manualEquivalent:
            return "\(ScenarioCompareFormatter.money(alternative.paramsJson.value ?? 0, currency: currency)) total"
        }
    }

    private var pricingBasisText: String {
        switch alternative.pricingMode {
        case .perDistance:
            return "configured \(ScenarioCompareFormatter.money(alternative.paramsJson.pricePerKm ?? 0, currency: currency))/km"
        case .distanceCurve:
            return "avg of curve point €/km rates"
        case .perPeriod:
            return "monthly plan estimate"
        case .perTime:
            return "time-based estimate"
        case .mixed:
            return "distance + time estimate"
        case .manualEquivalent:
            return "manual equivalent"
        }
    }

    private func selectedMetricDelta(for result: ScenarioComparison.AlternativeResult) -> (value: Double, unitSuffix: String)? {
        switch selectedMetric {
        case .perKm:
            guard let ownershipCostPerKm, let alternativeCostPerKm = result.costBreakdown.perKm else {
                return nil
            }

            return (alternativeCostPerKm - ownershipCostPerKm, " / km")
        case .perMonth:
            guard let ownershipValue = chartOwnershipValue ?? ownershipMonthlyCost,
                  let alternativeCostPerMonth = chartMetricValue ?? result.costBreakdown.perMonth else {
                return nil
            }

            return (alternativeCostPerMonth - ownershipValue, " / month")
        case .totalCost:
            guard let ownershipTotal = summary?.netOwnershipCost else {
                return nil
            }

            return (result.estimatedTotalCost - ownershipTotal, "")
        }
    }

    private func distanceCurveRateFormula(for breakdown: ScenarioComparison.CostBreakdown) -> String {
        let rates = breakdown.inputs.curvePointRates ?? []
        guard !rates.isEmpty else { return "No curve point rates" }

        let rateList = rates
            .map { ScenarioCompareFormatter.rate($0) }
            .joined(separator: " + ")
        let average = ScenarioCompareFormatter.rate(breakdown.inputs.averageCurvePricePerKm ?? breakdown.perKm ?? 0)
        return "Avg of point rates: (\(rateList)) ÷ \(rates.count) = \(average) €/km"
    }

    private func distanceCurveTotalFormula(total: String, breakdown: ScenarioComparison.CostBreakdown, distance: Double) -> String {
        let rate = ScenarioCompareFormatter.money(breakdown.inputs.averageCurvePricePerKm ?? 0, currency: currency)
        let pointCount = breakdown.inputs.curvePointRates?.count ?? 0
        let pointSummary = pointCount > 0 ? "\(pointCount) point rates avg" : "Curve rates avg"
        return "\(pointSummary) → \(rate)/km; × \(ScenarioCompareFormatter.number(distance)) km = \(total)"
    }

    private func monthlyPlanPerKmFormula(breakdown: ScenarioComparison.CostBreakdown) -> String {
        let monthlyPrice = breakdown.inputs.pricePerMonth ?? 0
        let months = breakdown.inputs.monthsOwned
        let distance = breakdown.inputs.totalDistanceKm
        let inheritedText = breakdown.inheritedCostsTotal > 0 ? " + inherited \(ScenarioCompareFormatter.money(breakdown.inheritedCostsTotal, currency: currency))" : ""
        let rate = breakdown.perKm ?? 0
        return "(\(ScenarioCompareFormatter.money(monthlyPrice, currency: currency))/mo × \(ScenarioCompareFormatter.number(months)) mo\(inheritedText)) ÷ \(ScenarioCompareFormatter.number(distance)) km = \(ScenarioCompareFormatter.money(rate, currency: currency))/km"
    }
}

private struct CompareBenchmarkChart: View {
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

private struct FlowLayout: Layout {
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

private enum ScenarioCompareFormatter {
    static func money(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 2
        formatter.minimumFractionDigits = value.rounded() == value ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(currency) \(value)"
    }

    static func number(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func rate(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
