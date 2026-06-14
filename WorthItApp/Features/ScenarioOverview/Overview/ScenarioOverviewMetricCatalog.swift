import SwiftUI

extension ScenarioOverviewView {
    var availableMetrics: [MetricSlide] {
        if let analyticsOverview {
            let backendSlides = analyticsOverview.metrics.compactMap { metricSlide($0) }
            if !backendSlides.isEmpty {
                return backendSlides
            }
        }

        return OverviewMetric.allCases
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
        if let payload = analyticsOverview?.metrics.first(where: { $0.metricId.overviewMetric == metric }),
           let slide = metricSlide(from: payload) {
            return slide
        }

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
            return nil
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

    func metricSlide(_ payload: ScenarioAnalyticsMetricPayload) -> MetricSlide? {
        guard payload.availability.isAvailable else { return nil }
        return metricSlide(from: payload)
    }

    func metricSlide(from payload: ScenarioAnalyticsMetricPayload) -> MetricSlide? {
        guard
            let metric = payload.metricId.overviewMetric,
            let card = payload.card
        else { return nil }

        return MetricSlide(
            id: metric,
            title: card.title,
            value: heroValue(for: card),
            subtitle: card.subtitle,
            footer: footerText(for: card),
            footerIcon: footerIcon(for: card, metric: metric),
            footerColor: footerColor(for: card),
            progress: normalizedProgress(card.progress ?? 0),
            accentColor: accentColor(for: card, metric: metric)
        )
    }

    func heroValue(for card: ScenarioAnalyticsMetricPayload.Card) -> String {
        guard card.unit == "currencyPerKm" else {
            return card.value
        }

        return card.value
            .replacingOccurrences(of: "/km", with: "")
            .replacingOccurrences(of: " / km", with: "")
    }

    func footerText(for card: ScenarioAnalyticsMetricPayload.Card) -> String? {
        guard let trend = card.trend else {
            return card.footer
        }

        return compactTrendFooter(for: card, trend: trend)
    }

    func compactTrendFooter(
        for card: ScenarioAnalyticsMetricPayload.Card,
        trend: ScenarioAnalyticsMetricPayload.Trend
    ) -> String {
        let comparisonMonth = monthName(for: previousMonthAsOfDate)

        guard
            let delta = trend.delta,
            delta.isFinite
        else {
            return "NO TREND YET"
        }

        guard abs(delta) > .ulpOfOne else {
            return "No change vs \(comparisonMonth)"
        }

        let sign = delta < 0 ? "-" : ""
        let value = abs(delta)
        let displayValue: String

        switch card.unit {
        case "currencyPerKm":
            displayValue = "\(currencySymbol)\(compactTrendNumber(value, fractionDigits: 2))"
        case "currency":
            displayValue = "\(currencySymbol)\(compactTrendNumber(value, fractionDigits: 0))"
        case "percent":
            displayValue = "\(compactTrendNumber(value, fractionDigits: 1))%"
        default:
            displayValue = compactTrendNumber(value, fractionDigits: 1)
        }

        return "\(sign)\(displayValue) vs \(comparisonMonth)"
    }

    func compactTrendNumber(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    func footerIcon(for card: ScenarioAnalyticsMetricPayload.Card, metric: OverviewMetric) -> String {
        if let direction = card.trend?.direction {
            switch direction {
            case "up": return "arrow.up.right"
            case "down": return "arrow.down.right"
            case "flat": return "minus"
            default: break
            }
        }

        switch metric {
        case .totalExpenses: return "list.bullet.rectangle"
        case .loanInterest: return "banknote"
        case .paybackDistance: return (card.numericValue ?? 0) < 0 ? "arrow.down.right" : "arrow.up.right"
        default: return "chart.line.uptrend.xyaxis"
        }
    }

    func footerColor(for card: ScenarioAnalyticsMetricPayload.Card) -> Color {
        if let tone = card.trend?.tone {
            switch tone {
            case "good": return Color(hex: 0x34D399)
            case "bad": return WorthItColor.danger
            default: return WorthItColor.textTertiary
            }
        }

        switch card.tone {
        case "good": return WorthItColor.accentGold
        case "warning", "danger": return WorthItColor.danger
        case "premium": return WorthItColor.primaryContainer
        default: return WorthItColor.textTertiary
        }
    }

    func accentColor(for card: ScenarioAnalyticsMetricPayload.Card, metric: OverviewMetric) -> Color {
        switch card.tone {
        case "good": return WorthItColor.accentGold
        case "warning", "danger": return WorthItColor.danger
        case "premium": return WorthItColor.primaryContainer.opacity(0.58)
        default:
            if metric == .currentMonthCostPerKm {
                return Color(hex: 0x2DD4BF).opacity(0.50)
            }
            return WorthItColor.primaryContainer.opacity(0.42)
        }
    }
}
