import SwiftUI

extension ScenarioOverviewView {
    var availableMetrics: [MetricSlide] {
        OverviewMetric.allCases
            .filter { enabledMetricSet.contains($0.rawValue) }
            .compactMap(metricSlide)
    }

    var selectedDetailMetricSlide: MetricSlide? {
        metricSlide(for: selectedDetailMetric)
    }

    var enabledMetricSet: Set<String> {
        let storedIds = enabledMetricIds
            .split(separator: ",")
            .map(String.init)

        if storedIds.isEmpty {
            return Set(OverviewMetric.allCases.map(\.rawValue))
        }

        var enabled = Set(storedIds)
        enabled.insert(OverviewMetric.currentMonthCostPerKm.rawValue)
        enabled.insert(OverviewMetric.paybackDistance.rawValue)
        return enabled
    }

    var selectedMetricBinding: Binding<String> {
        Binding(
            get: { currentSelectedMetricId },
            set: { selectedMetricId = $0 }
        )
    }

    var currentSelectedMetricId: String {
        let availableIds = availableMetrics.map(\.id.rawValue)
        if availableIds.contains(selectedMetricId) {
            return selectedMetricId
        }

        return availableIds.first ?? OverviewMetric.monthlyCost.rawValue
    }

    func metricSlide(for metric: OverviewMetric) -> MetricSlide? {
        switch metric {
        case .monthlyCost:
            guard monthlySpend != "—" else { return nil }
            let trend = monthlyCostTrend
            return MetricSlide(
                id: metric,
                title: "Monthly Cost",
                value: monthlySpend,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: monthlySpendProgress,
                accentColor: WorthItColor.primaryContainer.opacity(0.42)
            )
        case .costPerKm:
            guard currentCostPerDistanceValue != nil else { return nil }
            let trend = costPerKmTrend
            return MetricSlide(
                id: metric,
                title: "Cost per KM",
                value: costPerKm,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: costPerKmProgress,
                accentColor: WorthItColor.primaryContainer.opacity(0.42)
            )
        case .currentMonthCostPerKm:
            let trend = currentMonthlyCostPerDistanceValue == nil
                ? MetricTrend(label: "LOG THIS MONTH DATA", iconName: "plus", color: WorthItColor.textTertiary)
                : currentMonthCostPerKmTrend
            return MetricSlide(
                id: metric,
                title: "This Month / KM",
                value: currentMonthCostPerKm,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: currentMonthCostPerKmProgress,
                accentColor: Color(hex: 0x2DD4BF).opacity(0.50)
            )
        case .totalExpenses:
            guard totalLoggedExpensesValue > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Total Expenses",
                value: totalLoggedExpensesDisplay,
                subtitle: "\(costEvents.count) entries",
                footer: "OPEN HISTORY",
                footerIcon: "list.bullet.rectangle",
                footerColor: WorthItColor.textTertiary,
                progress: totalLoggedExpensesProgress,
                accentColor: WorthItColor.primaryContainer.opacity(0.58)
            )
        case .totalOwnership:
            guard totalOwnershipCost != nil else { return nil }
            let trend = totalOwnershipTrend
            return MetricSlide(
                id: metric,
                title: "Total Ownership",
                value: totalOwnershipDisplay,
                subtitle: nil,
                footer: trend.label,
                footerIcon: trend.iconName,
                footerColor: trend.color,
                progress: totalOwnershipProgress,
                accentColor: WorthItColor.accentGold
            )
        case .paybackDistance:
            guard let selected = selectedAlternativeBreakEven else { return nil }
            let snapshot = alternativeSavingsSnapshot(for: selected)
            return MetricSlide(
                id: metric,
                title: "Savings",
                value: savingsHeroValue(for: snapshot),
                subtitle: "vs \(selected.alternativeName)",
                footer: savingsStatusPill(for: snapshot),
                footerIcon: snapshot?.isSaving == false ? "arrow.down.right" : "arrow.up.right",
                footerColor: savingsColor(for: snapshot),
                progress: normalizedProgress(abs(snapshot?.savings ?? 0) / max(abs(snapshot?.alternativeTotal ?? 1), 1)),
                accentColor: savingsColor(for: snapshot)
            )
        case .projectedGain:
            guard projectedGain > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Projected Gain",
                value: "\(currencySymbol)\(formatDecimal(projectedGain, fractionDigits: 0))",
                subtitle: nil,
                footer: "RESALE ABOVE KNOWN COSTS",
                footerIcon: "arrow.up.right",
                footerColor: Color(hex: 0x34D399),
                progress: projectedGainProgress,
                accentColor: Color(hex: 0x34D399)
            )
        case .expectedResale:
            guard expectedResaleValue > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Expected Resale",
                value: expectedResaleDisplay,
                subtitle: nil,
                footer: expectedResaleValue >= purchasePrice ? "ABOVE PURCHASE PRICE" : nil,
                footerIcon: "arrow.up.right",
                footerColor: Color(hex: 0x34D399),
                progress: expectedResaleProgress,
                accentColor: expectedResaleColor
            )
        case .loanInterest:
            guard loanInterestTotal > 0 else { return nil }
            return MetricSlide(
                id: metric,
                title: "Loan Interest",
                value: "\(currencySymbol)\(formatDecimal(loanInterestTotal, fractionDigits: 0))",
                subtitle: loanPaymentSubtitle,
                footer: "OVER LOAN TERM",
                footerIcon: "banknote",
                footerColor: WorthItColor.textTertiary,
                progress: loanInterestProgress,
                accentColor: WorthItColor.accentGold.opacity(0.70)
            )
        }
    }

}
