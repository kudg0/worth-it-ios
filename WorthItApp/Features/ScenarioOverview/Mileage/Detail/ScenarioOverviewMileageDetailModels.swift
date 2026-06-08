import SwiftUI

extension ScenarioOverviewView {
    struct ComparableTripCostBreakdown {
        let total: Double
        let detailLines: [String]
    }

    struct DistanceCurveTripEstimate {
        let total: Double
        let formula: String
    }

    @ViewBuilder
    var mileageDetailContent: some View {
        if let model = selectedMileageDetailModel {
            MileageTripDetailScreen(model: model)
                .task(id: selectedMileageDetailId) {
                    await loadSummary()
                }
        } else {
            WITipInfo(
                title: "Trip unavailable",
                bodyText: "This trip is no longer available in mileage history."
            )
        }
    }

    var selectedMileageDetailModel: MileageTripDetailScreen.Model? {
        guard let selectedMileageDetailId,
              let event = usageEvents.first(where: { $0.id == selectedMileageDetailId && $0.eventType == "trip" }),
              let costPerDistance = tripCostPerDistanceValue(for: event)
        else {
            return nil
        }

        let monthStart = expenseHistoryMonthStart(for: event.date)
        let estimatedCost = event.distanceValue * costPerDistance
        let note = mileageEventSubtitle(event.note, fallback: "Trip Added")
        let monthLabel = Self.monthYearFormatter.string(from: monthStart)

        return MileageTripDetailScreen.Model(
            title: note,
            estimatedCostText: "\(currencySymbol)\(formatDouble(estimatedCost, fractionDigits: 2))",
            distanceText: "\(formatDouble(event.distanceValue, fractionDigits: 1)) \(event.distanceUnit)",
            costPerDistanceText: "\(currencySymbol)\(formatDouble(costPerDistance, fractionDigits: 2))",
            costPerDistanceSourceText: tripCostPerDistanceSourceText(for: event),
            unitText: event.distanceUnit,
            dateTimeText: "\(Self.mileageDateFormatter.string(from: event.date)), \(Self.mileageTimeFormatter.string(from: event.date))",
            notesText: event.note?.isEmpty == false ? event.note! : "No notes",
            periodLabel: monthLabel,
            confidenceLevel: "High",
            confidenceSource: "Calculated from manual trip distance",
            dataSource: "Manual Entry",
            comparableCosts: comparableTripCosts(
                for: event,
                ownershipTripCost: estimatedCost
            ),
            onOpenLedger: {
                openMileageHistory(focusedOn: event.id, monthStart: monthStart)
            },
            onOpenComparableInCompare: { alternativeId in
                openComparableInCompare(alternativeId)
            }
        )
    }

    func comparableTripCosts(
        for event: UsageEvent,
        ownershipTripCost: Double
    ) -> [MileageTripDetailScreen.ComparableCost] {
        alternatives
            .filter(\.isIncluded)
            .compactMap { alternative -> MileageTripDetailScreen.ComparableCost? in
                guard let breakdown = comparableTripCostBreakdown(for: alternative, event: event) else { return nil }
                let delta = breakdown.total - ownershipTripCost

                return MileageTripDetailScreen.ComparableCost(
                    id: alternative.id,
                    name: alternative.name,
                    iconSystemName: comparableIconName(for: alternative),
                    durationText: comparableDurationText(for: event),
                    costValue: breakdown.total,
                    costText: "\(currencySymbol)\(formatDouble(breakdown.total, fractionDigits: 2))",
                    deltaText: "\(delta >= 0 ? "+" : "-")\(currencySymbol)\(formatDouble(abs(delta), fractionDigits: 2))",
                    isCheaper: delta < 0,
                    detailLines: breakdown.detailLines
                )
            }
            .sorted { lhs, rhs in
                lhs.costValue < rhs.costValue
            }
    }

    func comparableTripCostBreakdown(
        for alternative: AlternativeOption,
        event: UsageEvent
    ) -> ComparableTripCostBreakdown? {
        let distanceKm = event.distanceValue
        let durationMinutes = Double(event.durationMinutes ?? estimatedComparableDurationMinutes(for: event))
        var inheritedCost = inheritedTripCostShare(for: alternative, event: event)
        var inheritedLabel = inheritedTripCostLine(for: alternative, amount: inheritedCost, event: event)

        let base: Double
        let formula: String
        switch alternative.pricingMode {
        case .perDistance:
            guard let pricePerKm = alternative.paramsJson.pricePerKm else { return nil }
            base = pricePerKm * distanceKm
            formula = "\(formatDouble(distanceKm, fractionDigits: 1)) km × \(currencySymbol)\(formatDouble(pricePerKm, fractionDigits: 2))/km = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
        case .distanceCurve:
            guard let estimate = distanceCurveTripPrice(distanceKm: distanceKm, points: alternative.paramsJson.pricePoints ?? []) else { return nil }
            base = estimate.total
            formula = estimate.formula
        case .perPeriod:
            guard let pricePerMonth = alternative.paramsJson.pricePerMonth else { return nil }
            if let comparisonResult = currentComparison?.alternatives.first(where: { $0.id == alternative.id }),
               let costPerKm = comparisonResult.costBreakdown.perKm {
                base = costPerKm * distanceKm
                inheritedCost = 0
                inheritedLabel = nil
                formula = "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))/km × \(formatDouble(distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
            } else {
                let monthlyDistance = max(currentSummary?.totalDistanceKm ?? distanceKm, distanceKm, 1)
                base = pricePerMonth * (distanceKm / monthlyDistance)
                formula = "\(currencySymbol)\(formatDouble(pricePerMonth, fractionDigits: 2))/mo × \(formatDouble(distanceKm, fractionDigits: 1))/\(formatDouble(monthlyDistance, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
            }
        case .perTime:
            guard let pricePerMinute = alternative.paramsJson.pricePerMinute else { return nil }
            base = pricePerMinute * durationMinutes
            formula = "\(formatDouble(durationMinutes, fractionDigits: 0)) min × \(currencySymbol)\(formatDouble(pricePerMinute, fractionDigits: 2))/min = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
        case .mixed:
            let perKm = alternative.paramsJson.pricePerKm ?? 0
            let perMinute = alternative.paramsJson.pricePerMinute ?? 0
            let distancePart = perKm * distanceKm
            let timePart = perMinute * durationMinutes
            base = distancePart + timePart
            formula = "\(formatDouble(distanceKm, fractionDigits: 1)) km × \(currencySymbol)\(formatDouble(perKm, fractionDigits: 2))/km + \(formatDouble(durationMinutes, fractionDigits: 0)) min × \(currencySymbol)\(formatDouble(perMinute, fractionDigits: 2))/min = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
        case .manualEquivalent:
            guard let value = alternative.paramsJson.value else { return nil }
            switch alternative.paramsJson.kind {
            case "per_km":
                base = value * distanceKm
                formula = "\(formatDouble(distanceKm, fractionDigits: 1)) km × \(currencySymbol)\(formatDouble(value, fractionDigits: 2))/km = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
            case "per_month":
                let monthlyDistance = max(currentSummary?.totalDistanceKm ?? distanceKm, distanceKm, 1)
                base = value * (distanceKm / monthlyDistance)
                formula = "\(currencySymbol)\(formatDouble(value, fractionDigits: 2))/mo × trip share = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
            case "total":
                base = value
                formula = "Manual trip equivalent = \(currencySymbol)\(formatDouble(base, fractionDigits: 2))"
            default:
                return nil
            }
        }

        let lines = [formula, inheritedLabel].compactMap { $0 }
        return ComparableTripCostBreakdown(total: base + inheritedCost, detailLines: lines)
    }

    func inheritedTripCostShare(for alternative: AlternativeOption, event: UsageEvent) -> Double {
        guard let categories = alternative.paramsJson.includedCostCategories, !categories.isEmpty else {
            return 0
        }

        let categorySet = Set(categories)
        let total = costEvents
            .filter { categorySet.contains($0.category) }
            .compactMap { Double($0.amount) }
            .reduce(0, +)

        let totalDistance = max(currentSummary?.totalDistanceKm ?? event.distanceValue, event.distanceValue, 1)
        return total * event.distanceValue / totalDistance
    }

    func inheritedTripCostLine(for alternative: AlternativeOption, amount: Double, event: UsageEvent) -> String? {
        guard amount > 0,
              event.distanceValue > 0,
              let categories = alternative.paramsJson.includedCostCategories,
              !categories.isEmpty
        else {
            return nil
        }

        let names = categories
            .compactMap { ExpenseCategory(rawValue: $0)?.title }
            .joined(separator: ", ")

        let inheritedCostPerDistance = amount / event.distanceValue
        return "\(names): \(currencySymbol)\(formatDouble(inheritedCostPerDistance, fractionDigits: 2))/km × \(formatDouble(event.distanceValue, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(amount, fractionDigits: 2))"
    }

    func distanceCurveTripPrice(distanceKm: Double, points: [AlternativePricePoint]) -> DistanceCurveTripEstimate? {
        let sortedPoints = points.sorted { $0.distanceKm < $1.distanceKm }
        guard let first = sortedPoints.first else { return nil }
        guard sortedPoints.count > 1 else {
            guard first.distanceKm > 0 else {
                return DistanceCurveTripEstimate(
                    total: first.totalPrice,
                    formula: "Single curve point = \(currencySymbol)\(formatDouble(first.totalPrice, fractionDigits: 2))"
                )
            }

            let rate = first.totalPrice / first.distanceKm
            let total = rate * distanceKm
            return DistanceCurveTripEstimate(
                total: total,
                formula: "Single curve point \(currencySymbol)\(formatDouble(first.totalPrice, fractionDigits: 2)) ÷ \(formatDouble(first.distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(rate, fractionDigits: 2))/km; × \(formatDouble(distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(total, fractionDigits: 2))"
            )
        }

        if distanceKm <= first.distanceKm {
            guard first.distanceKm > 0 else {
                return DistanceCurveTripEstimate(
                    total: first.totalPrice,
                    formula: "First curve point = \(currencySymbol)\(formatDouble(first.totalPrice, fractionDigits: 2))"
                )
            }

            let rate = first.totalPrice / first.distanceKm
            let total = rate * distanceKm
            return DistanceCurveTripEstimate(
                total: total,
                formula: "Below first point: \(currencySymbol)\(formatDouble(first.totalPrice, fractionDigits: 2)) ÷ \(formatDouble(first.distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(rate, fractionDigits: 2))/km; × \(formatDouble(distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(total, fractionDigits: 2))"
            )
        }

        if let exactPoint = sortedPoints.first(where: { abs($0.distanceKm - distanceKm) < 0.001 }) {
            return DistanceCurveTripEstimate(
                total: exactPoint.totalPrice,
                formula: "Known curve point \(formatDouble(exactPoint.distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(exactPoint.totalPrice, fractionDigits: 2))"
            )
        }

        for index in 1..<sortedPoints.count {
            let previous = sortedPoints[index - 1]
            let next = sortedPoints[index]
            guard distanceKm <= next.distanceKm else { continue }

            let span = next.distanceKm - previous.distanceKm
            guard span > 0 else {
                return DistanceCurveTripEstimate(
                    total: next.totalPrice,
                    formula: "Curve point \(formatDouble(next.distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(next.totalPrice, fractionDigits: 2))"
                )
            }

            let previousRate = previous.totalPrice / previous.distanceKm
            let nextRate = next.totalPrice / next.distanceKm
            let rate = (previousRate + nextRate) / 2
            let total = rate * distanceKm
            return DistanceCurveTripEstimate(
                total: total,
                formula: "Between \(formatDouble(previous.distanceKm, fractionDigits: 1))–\(formatDouble(next.distanceKm, fractionDigits: 1)) km: avg \(currencySymbol)\(formatDouble(rate, fractionDigits: 2))/km × \(formatDouble(distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(total, fractionDigits: 2))"
            )
        }

        guard let last = sortedPoints.last, last.distanceKm > 0 else { return nil }
        let rate = last.totalPrice / last.distanceKm
        let total = rate * distanceKm
        return DistanceCurveTripEstimate(
            total: total,
            formula: "Beyond last point: \(currencySymbol)\(formatDouble(last.totalPrice, fractionDigits: 2)) ÷ \(formatDouble(last.distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(rate, fractionDigits: 2))/km; × \(formatDouble(distanceKm, fractionDigits: 1)) km = \(currencySymbol)\(formatDouble(total, fractionDigits: 2))"
        )
    }

    func comparableDurationText(for event: UsageEvent) -> String {
        "Est. ~\(estimatedComparableDurationMinutes(for: event)) mins"
    }

    func estimatedComparableDurationMinutes(for event: UsageEvent) -> Int {
        if let durationMinutes = event.durationMinutes, durationMinutes > 0 {
            return durationMinutes
        }

        return max(Int((event.distanceValue / 35 * 60).rounded()), 5)
    }

    func comparableIconName(for alternative: AlternativeOption) -> String {
        let lowerName = alternative.name.lowercased()
        if lowerName.contains("taxi") { return "car.fill" }
        if lowerName.contains("share") { return "car.2.fill" }
        if lowerName.contains("bus") || lowerName.contains("transport") || lowerName.contains("transit") { return "bus.fill" }
        if lowerName.contains("rental") { return "key.fill" }
        return "arrow.triangle.branch"
    }
}
