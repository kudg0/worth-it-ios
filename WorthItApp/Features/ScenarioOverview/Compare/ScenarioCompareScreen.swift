import SwiftUI

struct ScenarioCompareScreen: View {
    @AppStorage("scenarioCompare.metricExplanationDismissed.perKm") private var isPerKmExplanationDismissed = false
    @AppStorage("scenarioCompare.metricExplanationDismissed.perMonth") private var isPerMonthExplanationDismissed = false

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
            ScenarioSectionTitle(title: i18n.t("Compare"))

            if let insightText {
                WITipInfo(title: i18n.t("Worth It"), bodyText: insightText, size: .small, tone: .primary)
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

            WIButton(title: i18n.t("Add Comparable Option"), height: 56, action: onAddComparable)
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

    @ViewBuilder
    private var metricExplanation: some View {
        if shouldShowMetricExplanation {
            WITipInfo(
                title: i18n.t("Metric context"),
                bodyText: metricExplanationText,
                size: .small,
                tone: .info,
                onDismiss: dismissMetricExplanation
            )
        }
    }

    private func normalizeSelectedMetric() {
        guard !ScenarioOverviewView.CompareMetric.compareVisibleCases.contains(selectedMetric.wrappedValue) else { return }
        selectedMetric.wrappedValue = .perKm
    }

    private var accumulationIsland: some View {
        WIIsland(title: i18n.t("Cost Accumulation")) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
                ownershipMetricHero

                CompareBenchmarkChart(
                    series: chartSeries,
                    currency: currency,
                    selectedMetric: selectedMetric.wrappedValue,
                    scenarioStartDate: scenarioStartDate,
                    comparisonBaselineValue: comparisonBaselineValue
                )

                metricExplanation
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

    private var metricExplanationText: String {
        switch selectedMetric.wrappedValue {
        case .perKm:
            return "Per KM shows distance efficiency: total ownership cost spread across tracked kilometers. It can look strong even when monthly spend is high, because fixed ownership costs are diluted by usage."
        case .perMonth:
            return "Per Month shows cumulative average monthly cost through each month. It keeps fixed ownership costs visible, so a car can be efficient per kilometer but still expensive to own each month."
        case .totalCost:
            return "Total Cost compares full accumulated ownership cost against alternatives across the same usage history."
        }
    }

    private var shouldShowMetricExplanation: Bool {
        switch selectedMetric.wrappedValue {
        case .perKm:
            return !isPerKmExplanationDismissed
        case .perMonth:
            return !isPerMonthExplanationDismissed
        case .totalCost:
            return true
        }
    }

    private func dismissMetricExplanation() {
        switch selectedMetric.wrappedValue {
        case .perKm:
            isPerKmExplanationDismissed = true
        case .perMonth:
            isPerMonthExplanationDismissed = true
        case .totalCost:
            break
        }
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
            let alternativeCostPerKm = result.pricingMode == .distanceCurve
                ? distanceCurveAverageRate(from: result.costBreakdown)
                : result.costBreakdown.perKm
            guard let ownershipValue = currentOwnershipChartValue ?? ownershipCostPerKm,
                  let alternativeCostPerKm
            else { return nil }
            return alternativeCostPerKm - ownershipValue
        case .perMonth:
            guard let ownershipValue = currentOwnershipChartValue ?? ownershipMonthlyCost,
                  let alternativeCostPerMonth = latestChartValue(for: result.id) ?? result.costBreakdown.perMonth
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
            return "Average monthly cost"
        case .totalCost:
            return "Across full ownership period"
        }
    }

    private func money(_ value: Double) -> String {
        ScenarioCompareFormatter.money(value, currency: currency)
    }

    private func distanceCurveAverageRate(from breakdown: ScenarioComparison.CostBreakdown) -> Double? {
        if let rates = breakdown.inputs.curvePointRates, !rates.isEmpty {
            return rates.reduce(0, +) / Double(rates.count)
        }

        return breakdown.inputs.averageCurvePricePerKm
    }
}
