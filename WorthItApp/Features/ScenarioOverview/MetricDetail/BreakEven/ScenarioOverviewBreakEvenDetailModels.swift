import SwiftUI

struct AlternativeSavingsSnapshot {
    let row: ScenarioComparison.AlternativeBreakEven
    let carTotal: Double
    let alternativeTotal: Double
    let savings: Double
    let carRate: Double
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
            eyebrow: "Saved vs \(selectedName)",
            value: savingsHeroValue(for: snapshot),
            valueColor: savingsColor(for: snapshot),
            subtitle: savingsSubtitle(for: selected, snapshot: snapshot),
            statusPill: savingsStatusPill(for: snapshot),
            statusColor: savingsColor(for: snapshot),
            selectedOptionId: selected?.alternativeId,
            options: rows.map { BreakEvenDetailScreen.Option(id: $0.alternativeId, title: $0.alternativeName) },
            calculationRows: savingsCalculationRows(for: selected, snapshot: snapshot),
            benchmarkRows: rows.map(savingsBenchmarkRow),
            explanationTitle: "How this is calculated",
            explanationBody: savingsExplanationBody(for: selected, snapshot: snapshot),
            onSelectOption: selectBreakEvenAlternative
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

        return AlternativeSavingsSnapshot(
            row: row,
            carTotal: carTotal,
            alternativeTotal: alternativeTotal,
            savings: savings,
            carRate: carRate,
            alternativeRate: alternativeRate,
            alternativeRateMin: row.alternativeCostPerKmMin,
            alternativeRateMax: row.alternativeCostPerKmMax
        )
    }

    func savingsHeroValue(for snapshot: AlternativeSavingsSnapshot?) -> String {
        guard let snapshot else { return "-" }
        let prefix = snapshot.savings >= 0 ? "+" : "-"
        return "\(prefix)\(currencySymbol)\(formatDouble(abs(snapshot.savings), fractionDigits: 0))"
    }

    func savingsColor(for snapshot: AlternativeSavingsSnapshot?) -> Color {
        guard let snapshot else { return WorthItColor.textPrimary }
        return snapshot.isSaving ? WorthItColor.accentGold : WorthItColor.danger
    }

    func savingsStatusPill(for snapshot: AlternativeSavingsSnapshot?) -> String {
        guard let snapshot else { return "NEED MORE DATA" }
        return snapshot.isSaving ? "SAVED" : "BEHIND"
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
                title: "Your car",
                value: snapshot.map { "\(currencySymbol)\(formatDouble($0.carTotal, fractionDigits: 0))" } ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "alternative",
                title: "Alternative",
                value: snapshot.map { "\(currencySymbol)\(formatDouble($0.alternativeTotal, fractionDigits: 0))" } ?? "-",
                accentColor: WorthItColor.primaryContainer,
                showsDot: true
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "difference",
                title: "Difference",
                value: savingsHeroValue(for: snapshot),
                accentColor: savingsColor(for: snapshot),
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "distance",
                title: "Distance",
                value: row.map { "\(formatDouble($0.currentDistanceKm, fractionDigits: 0)) \(mileageDisplayUnit)" } ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "car-rate",
                title: "Car \(currencySymbol)/\(mileageDisplayUnit)",
                value: snapshot.map { "\(currencySymbol)\(formatDouble($0.carRate, fractionDigits: 2))" } ?? "-",
                accentColor: WorthItColor.textPrimary,
                showsDot: false
            ),
            BreakEvenDetailScreen.CalculationRow(
                id: "alternative-rate",
                title: "Alternative \(currencySymbol)/\(mileageDisplayUnit)",
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
        let suffix = snapshot.isSaving ? " saved" : " behind"
        return "\(savingsHeroValue(for: snapshot))\(suffix)"
    }

    func alternativeRateDisplay(for snapshot: AlternativeSavingsSnapshot) -> String {
        guard
            let min = snapshot.alternativeRateMin,
            let max = snapshot.alternativeRateMax
        else {
            return "\(currencySymbol)\(formatDouble(snapshot.alternativeRate, fractionDigits: 2))"
        }

        if abs(max - min) < 0.0001 {
            return "\(currencySymbol)\(formatDouble(snapshot.alternativeRate, fractionDigits: 2))"
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

        return "We compare your actual ownership and running costs against estimated \(row.alternativeName) cost for the same \(formatDouble(row.currentDistanceKm, fractionDigits: 0)) \(mileageDisplayUnit). Positive means the car saved money; negative means the alternative would have been cheaper."
    }
}
