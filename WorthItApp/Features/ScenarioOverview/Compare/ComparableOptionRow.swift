import SwiftUI

struct ComparableOptionRow: View {
    let alternative: AlternativeOption
    let result: ScenarioComparison.AlternativeResult?
    let breakEven: ScenarioComparison.AlternativeBreakEven?
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
                if let rateRangeText = dynamicAlternativeRateRangeText {
                    return rateRangeText
                }
                if alternative.pricingMode == .distanceCurve,
                   let average = distanceCurvePointAverageRate(from: result.costBreakdown) {
                    return "\(ScenarioCompareFormatter.money(average, currency: currency)) per km"
                }
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
            if let dynamicDetailText {
                return dynamicDetailText
            }
            if alternative.pricingMode == .distanceCurve {
                return distanceCurveRateFormula(for: result.costBreakdown)
            }
            if alternative.pricingMode == .perPeriod {
                return monthlyPlanPerKmFormula(breakdown: result.costBreakdown)
            }
            return "\(total) ÷ \(ScenarioCompareFormatter.number(distance)) km • \(pricingBasisText)"
        case .perMonth:
            if chartMetricValue != nil {
                return monthlyAverageFormula(total: total, breakdown: result.costBreakdown)
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
            let average = distanceCurvePointAverageRate ?? 0
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

    private var distanceCurvePointRates: [Double] {
        (alternative.paramsJson.pricePoints ?? []).compactMap { point -> Double? in
            guard point.distanceKm > 0 else { return nil }
            return point.totalPrice / point.distanceKm
        }
    }

    private var distanceCurvePointAverageRate: Double? {
        let rates = distanceCurvePointRates
        guard !rates.isEmpty else { return nil }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private func selectedMetricDelta(for result: ScenarioComparison.AlternativeResult) -> (value: Double, unitSuffix: String)? {
        switch selectedMetric {
        case .perKm:
            let alternativeCostPerKm = dynamicAlternativeAverageRate
                ?? (alternative.pricingMode == .distanceCurve
                    ? distanceCurvePointAverageRate(from: result.costBreakdown)
                    : result.costBreakdown.perKm)
            guard let ownershipCostPerKm, let alternativeCostPerKm else {
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
        let rates = breakdown.inputs.curvePointRates ?? distanceCurvePointRates
        guard !rates.isEmpty else { return "No curve point rates" }

        let rateList = rates
            .map { ScenarioCompareFormatter.rate($0) }
            .joined(separator: " + ")
        let average = ScenarioCompareFormatter.rate(rates.reduce(0, +) / Double(rates.count))
        return "Avg of point rates: (\(rateList)) ÷ \(rates.count) = \(average) €/km"
    }

    private var dynamicAlternativeRates: [Double] {
        breakEven?.dynamicTripSavings?.items.compactMap(\.alternativeCostPerKm) ?? []
    }

    private var dynamicAlternativeRateRange: (min: Double, max: Double)? {
        guard let min = dynamicAlternativeRates.min(), let max = dynamicAlternativeRates.max() else {
            return nil
        }

        return (min, max)
    }

    private var dynamicAlternativeAverageRate: Double? {
        let rates = dynamicAlternativeRates
        guard !rates.isEmpty else { return nil }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var dynamicAlternativeRateRangeText: String? {
        guard let range = dynamicAlternativeRateRange else { return nil }

        if abs(range.max - range.min) < 0.0001 {
            return "\(ScenarioCompareFormatter.money(range.min, currency: currency)) per km"
        }

        return "\(ScenarioCompareFormatter.money(range.min, currency: currency))-\(ScenarioCompareFormatter.money(range.max, currency: currency)) per km"
    }

    private var dynamicDetailText: String? {
        guard dynamicAlternativeRateRangeText != nil,
              let itemCount = breakEven?.dynamicTripSavings?.tripCount
        else {
            return nil
        }

        return "Across \(itemCount) dated trip calculations"
    }

    private func distanceCurvePointAverageRate(from breakdown: ScenarioComparison.CostBreakdown) -> Double? {
        if let rates = breakdown.inputs.curvePointRates, !rates.isEmpty {
            return rates.reduce(0, +) / Double(rates.count)
        }

        return breakdown.inputs.averageCurvePricePerKm ?? distanceCurvePointAverageRate
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

    private func monthlyAverageFormula(
        total: String,
        breakdown: ScenarioComparison.CostBreakdown
    ) -> String {
        let months = breakdown.inputs.monthsOwned
        guard months > 0 else { return pricingBasisText }
        return "\(total) across tracked trips ÷ \(ScenarioCompareFormatter.number(months)) months"
    }
}
