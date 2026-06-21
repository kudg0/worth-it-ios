import SwiftUI

struct AlternativeSavingsSnapshot {
    let row: ScenarioComparison.AlternativeBreakEven
    let carTotal: Double
    let alternativeTotal: Double
    let savings: Double
    let carRate: Double
    let carRateMin: Double?
    let carRateMax: Double?
    let alternativeRate: Double
    let alternativeRateMin: Double?
    let alternativeRateMax: Double?

    var isSaving: Bool { savings >= 0 }
}

extension ScenarioOverviewView {
    var selectedAlternativeBreakEven: ScenarioComparison.AlternativeBreakEven? {
        let rows = currentComparison?.alternativeBreakEvens ?? []
        guard !rows.isEmpty else { return nil }

        if let selectedBreakEvenAlternativeId,
           let selected = rows.first(where: { $0.alternativeId == selectedBreakEvenAlternativeId }) {
            return selected
        }

        return rows.first
    }

    var breakEvenDetailModel: BreakEvenDetailScreen.Model {
        let selected = selectedAlternativeBreakEven
        let rows = currentComparison?.alternativeBreakEvens ?? []
        let snapshot = selected.flatMap(alternativeSavingsSnapshot)
        let selectedName = selected?.alternativeName ?? "Alternative"

        return BreakEvenDetailScreen.Model(
            eyebrow: "Compared vs \(selectedName)",
            value: savingsHeroValue(for: snapshot),
            valueColor: savingsColor(for: snapshot),
            subtitle: savingsSubtitle(for: selected, snapshot: snapshot),
            statusPill: savingsStatusPill(for: snapshot),
            statusColor: savingsColor(for: snapshot),
            selectedOptionId: selected?.alternativeId,
            options: rows.map { BreakEvenDetailScreen.Option(id: $0.alternativeId, title: $0.alternativeName) },
            calculationRows: savingsCalculationRows(for: selected, snapshot: snapshot),
            tripRows: selected.map(savingsTripRows) ?? [],
            benchmarkRows: rows.map(savingsBenchmarkRow),
            explanationTitle: "How this is calculated",
            explanationBody: savingsExplanationBody(for: selected, snapshot: snapshot),
            onSelectOption: selectBreakEvenAlternative,
            onOpenTrip: openMileageDetail
        )
    }

    func alternativeSavingsSnapshot(
        for row: ScenarioComparison.AlternativeBreakEven
    ) -> AlternativeSavingsSnapshot? {
        guard
            row.currentDistanceKm > 0,
            let carRate = row.carRunningCostPerKm,
            let alternativeRate = row.alternativeCostPerKm,
            let carTotal = row.carTotalCost,
            let alternativeTotal = row.alternativeTotalCost,
            let savings = row.savingsAmount
        else {
            return nil
        }

        let dynamicCarRates = dynamicRateRange(row.dynamicTripSavings?.items.compactMap(\.carCostPerKm) ?? [])
        let dynamicAlternativeRates = dynamicRateRange(
            row.dynamicTripSavings?.items.compactMap(\.alternativeCostPerKm) ?? []
        )

        return AlternativeSavingsSnapshot(
            row: row,
            carTotal: carTotal,
            alternativeTotal: alternativeTotal,
            savings: savings,
            carRate: carRate,
            carRateMin: dynamicCarRates?.min,
            carRateMax: dynamicCarRates?.max,
            alternativeRate: alternativeRate,
            alternativeRateMin: dynamicAlternativeRates?.min ?? row.alternativeCostPerKmMin,
            alternativeRateMax: dynamicAlternativeRates?.max ?? row.alternativeCostPerKmMax
        )
    }

    func savingsTripRows(
        for row: ScenarioComparison.AlternativeBreakEven
    ) -> [BreakEvenDetailScreen.TripRow] {
        guard let dynamic = row.dynamicTripSavings else { return [] }

        return dynamic.items.reversed().map { item in
            let carRate = item.carCostPerKm.map {
                "\(currencySymbol)\(formatDouble($0, fractionDigits: 2))/\(mileageDisplayUnit)"
            } ?? "-"
            let alternativeRate = item.alternativeCostPerKm.map {
                "\(currencySymbol)\(formatDouble($0, fractionDigits: 2))/\(mileageDisplayUnit)"
            } ?? "-"
            let savings = item.savingsAmount ?? 0

            return BreakEvenDetailScreen.TripRow(
                id: item.usageEventId,
                title: "\(formatDouble(item.distanceKm, fractionDigits: 0)) \(mileageDisplayUnit) · \(Self.shortDateFormatter.string(from: item.date))",
                subtitle: "Car \(carRate) · \(row.alternativeName) \(alternativeRate)",
                value: tripSavingsDeltaDisplay(savings, includesOutcome: true),
                valueColor: savings >= 0 ? WorthItColor.accentGold : WorthItColor.danger
            )
        }
    }

    func savingsHeroValue(for snapshot: AlternativeSavingsSnapshot?) -> String {
        guard let snapshot else { return "-" }
        return savingsDeltaDisplay(snapshot.savings, includesOutcome: false)
    }

    func savingsColor(for snapshot: AlternativeSavingsSnapshot?) -> Color {
        guard let snapshot else { return WorthItColor.textPrimary }
        return snapshot.isSaving ? WorthItColor.accentGold : WorthItColor.danger
    }

    func savingsStatusPill(for snapshot: AlternativeSavingsSnapshot?) -> String {
        guard let snapshot else { return "NEED MORE DATA" }
        return savingsOutcomeLabel(snapshot.savings).uppercased()
    }

    func savingsSubtitle(
        for row: ScenarioComparison.AlternativeBreakEven?,
        snapshot: AlternativeSavingsSnapshot?
    ) -> String {
        guard let row else {
            return "Add a comparison option to estimate savings against the same distance."
        }

        guard snapshot != nil else {
            return row.reason ?? "Log mileage and comparison pricing to estimate savings."
        }

        return "Based on \(formatDouble(row.currentDistanceKm, fractionDigits: 0)) \(mileageDisplayUnit) driven."
    }

    func savingsCalculationRows(
        for row: ScenarioComparison.AlternativeBreakEven?,
        snapshot: AlternativeSavingsSnapshot?
    ) -> [BreakEvenDetailScreen.CalculationRow] {
        [
            BreakEvenDetailScreen.CalculationRow(
                id: "car",
                title: i18n.t("Your car"),
                value: snapshot.map { "\(currencySymbol)\(formatDouble($0.carTotal, fractionDigits: 0))" } ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "alternative",
                title: i18n.t("Alternative"),
                value: snapshot.map { "\(currencySymbol)\(formatDouble($0.alternativeTotal, fractionDigits: 0))" } ?? "-",
                accentColor: WorthItColor.primaryContainer,
                showsDot: true
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "difference",
                title: i18n.t("Difference"),
                value: savingsHeroValue(for: snapshot),
                accentColor: savingsColor(for: snapshot),
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "distance",
                title: i18n.t("Distance"),
                value: row.map { "\(formatDouble($0.currentDistanceKm, fractionDigits: 0)) \(mileageDisplayUnit)" } ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "car-rate",
                title: i18n.t("Car \(currencySymbol)/\(mileageDisplayUnit)"),
                value: snapshot.map(carRateDisplay) ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "alternative-rate",
                title: i18n.t("Alternative \(currencySymbol)/\(mileageDisplayUnit)"),
                value: snapshot.map(alternativeRateDisplay) ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
        ]
    }

    func savingsBenchmarkRow(_ row: ScenarioComparison.AlternativeBreakEven) -> BreakEvenDetailScreen.BenchmarkRow {
        let snapshot = alternativeSavingsSnapshot(for: row)

        return BreakEvenDetailScreen.BenchmarkRow(
            id: row.alternativeId,
            title: row.alternativeName,
            status: savingsBenchmarkStatus(for: snapshot),
            color: savingsColor(for: snapshot),
            magnitude: snapshot.map { abs($0.savings) } ?? 0,
            isSaving: snapshot?.isSaving ?? false
        )
    }

    func savingsBenchmarkStatus(for snapshot: AlternativeSavingsSnapshot?) -> String {
        guard let snapshot else { return "-" }
        return savingsDeltaDisplay(snapshot.savings, includesOutcome: true)
    }

    func savingsDeltaDisplay(_ value: Double, includesOutcome: Bool) -> String {
        let prefix = value >= 0 ? "+" : "-"
        let absoluteValue = abs(value)
        let fractionDigits = absoluteValue > 0 && absoluteValue < 1 ? 2 : 0
        let money = "\(prefix)\(currencySymbol)\(formatDouble(absoluteValue, fractionDigits: fractionDigits))"

        guard includesOutcome else { return money }
        return "\(money) \(savingsOutcomeLabel(value))"
    }

    func tripSavingsDeltaDisplay(_ value: Double, includesOutcome: Bool) -> String {
        let prefix = value >= 0 ? "+" : "-"
        let money = "\(prefix)\(currencySymbol)\(formatDouble(abs(value), fractionDigits: 2))"

        guard includesOutcome else { return money }
        return "\(money) \(savingsOutcomeLabel(value))"
    }

    func savingsOutcomeLabel(_ value: Double) -> String {
        value >= 0 ? "ahead" : "behind"
    }

    func dynamicRateRange(_ rates: [Double]) -> (min: Double, max: Double)? {
        guard let min = rates.min(), let max = rates.max() else {
            return nil
        }

        return (min, max)
    }

    func carRateDisplay(for snapshot: AlternativeSavingsSnapshot) -> String {
        rateDisplay(
            fallbackRate: snapshot.carRate,
            minRate: snapshot.carRateMin,
            maxRate: snapshot.carRateMax
        )
    }

    func alternativeRateDisplay(for snapshot: AlternativeSavingsSnapshot) -> String {
        rateDisplay(
            fallbackRate: snapshot.alternativeRate,
            minRate: snapshot.alternativeRateMin,
            maxRate: snapshot.alternativeRateMax
        )
    }

    func rateDisplay(
        fallbackRate: Double,
        minRate: Double?,
        maxRate: Double?
    ) -> String {
        guard
            let min = minRate,
            let max = maxRate
        else {
            return "\(currencySymbol)\(formatDouble(fallbackRate, fractionDigits: 2))"
        }

        if abs(max - min) < 0.0001 {
            return "\(currencySymbol)\(formatDouble(fallbackRate, fractionDigits: 2))"
        }

        return "\(currencySymbol)\(formatDouble(min, fractionDigits: 2))-\(currencySymbol)\(formatDouble(max, fractionDigits: 2))"
    }

    func savingsExplanationBody(
        for row: ScenarioComparison.AlternativeBreakEven?,
        snapshot: AlternativeSavingsSnapshot?
    ) -> String {
        guard let row else {
            return "Savings needs at least one pinned comparison option with a per-\(mileageDisplayUnit) estimate."
        }

        guard snapshot != nil else {
            return row.reason ?? "Savings needs mileage, your car cost per \(mileageDisplayUnit), and the selected alternative cost per \(mileageDisplayUnit)."
        }

        if row.dynamicTripSavings != nil {
            return "Each mileage entry is priced on its own date. The calculation card shows the effective \(currencySymbol)/\(mileageDisplayUnit) range from those trip calculations, while each row shows the exact rate for that trip. We add the entry-level results to show whether the car is ahead or behind."
        }

        return "We compare your actual ownership and running costs against estimated \(row.alternativeName) cost for the same \(formatDouble(row.currentDistanceKm, fractionDigits: 0)) \(mileageDisplayUnit). Positive means the car is ahead; negative means the car is behind."
    }
}
