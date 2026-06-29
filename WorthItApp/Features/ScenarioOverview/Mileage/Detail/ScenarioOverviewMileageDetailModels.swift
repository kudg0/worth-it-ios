import SwiftUI

extension ScenarioOverviewView {
    struct ComparableTripCostBreakdown {
        let total: Double
        let detailLines: [String]
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
                title: i18n.t("Trip unavailable"),
                bodyText: i18n.t("This trip is no longer available in mileage history.")
            )
        }
    }

    var selectedMileageDetailModel: MileageTripDetailScreen.Model? {
        guard let selectedMileageDetailId,
              let event = usageEvents.first(where: { $0.id == selectedMileageDetailId && $0.eventType == "trip" })
        else {
            return nil
        }

        guard let dynamicTrip = dynamicTripSavingsItem(for: event),
              let costPerDistance = dynamicTrip.carCostPerKm,
              let estimatedCost = dynamicTrip.carTripCost
        else {
            return nil
        }

        let monthStart = expenseHistoryMonthStart(for: event.date)
        let note = mileageEventSubtitle(event.note, fallback: "Trip Added")
        let monthLabel = Self.monthYearFormatter.string(from: monthStart)
        let tripDistance = usageDistanceInScenarioUnit(event)
        let displayedCostPerDistance = distanceRateInScenarioUnit(costPerDistance, sourceUnit: "km")

        return MileageTripDetailScreen.Model(
            title: note,
            estimatedCostText: "\(currencySymbol)\(formatDouble(estimatedCost, fractionDigits: 2))",
            distanceText: "\(formatDouble(tripDistance, fractionDigits: 1)) \(mileageDisplayUnit)",
            costPerDistanceText: "\(currencySymbol)\(formatDouble(displayedCostPerDistance, fractionDigits: 2))",
            costPerDistanceSourceText: "Trip-date ownership rate",
            unitText: mileageDisplayUnit,
            dateTimeText: "\(Self.mileageDateFormatter.string(from: event.date)), \(Self.mileageTimeFormatter.string(from: event.date))",
            notesText: event.note?.isEmpty == false ? event.note! : "No notes",
            periodLabel: monthLabel,
            confidenceLevel: "High",
            confidenceSource: "Calculated from trip-date pricing",
            dataSource: "Manual Entry",
            attachments: event.attachments ?? [],
            links: event.links ?? [],
            comparableCosts: comparableTripCosts(
                for: event,
                ownershipTripCost: estimatedCost
            ),
            onOpenAttachment: { activeResourceAction = .attachment($0) },
            onOpenLink: { activeResourceAction = .link($0) },
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
                guard let breakdown = dynamicComparableTripCostBreakdown(for: alternative, event: event) else {
                    return nil
                }
                let delta = breakdown.total - ownershipTripCost

                return MileageTripDetailScreen.ComparableCost(
                    id: alternative.id,
                    name: alternative.name,
                    iconSystemName: comparableIconName(for: alternative),
                    basisText: i18n.t("Same trip distance"),
                    costValue: breakdown.total,
                    costText: "\(currencySymbol)\(formatDouble(breakdown.total, fractionDigits: 2))",
                    deltaText: tripSavingsDeltaDisplay(delta, includesOutcome: true),
                    isCheaper: delta < 0,
                    detailLines: breakdown.detailLines
                )
            }
            .sorted { lhs, rhs in
                lhs.costValue < rhs.costValue
            }
    }

    func dynamicTripSavingsItem(for event: UsageEvent) -> ScenarioComparison.DynamicTripSavingsItem? {
        currentComparison?.alternativeBreakEvens
            .compactMap(\.dynamicTripSavings)
            .flatMap(\.items)
            .first { $0.usageEventId == event.id }
    }

    func dynamicComparableTripCostBreakdown(
        for alternative: AlternativeOption,
        event: UsageEvent
    ) -> ComparableTripCostBreakdown? {
        guard let item = currentComparison?.alternativeBreakEvens
            .first(where: { $0.alternativeId == alternative.id })?
            .dynamicTripSavings?
            .items
            .first(where: { $0.usageEventId == event.id }),
            let alternativeTripCost = item.alternativeTripCost
        else {
            return nil
        }

        let carRate = item.carCostPerKm.map {
            "\(currencySymbol)\(formatDouble(distanceRateInScenarioUnit($0, sourceUnit: "km"), fractionDigits: 2))/\(mileageDisplayUnit)"
        } ?? "-"
        let alternativeRate = item.alternativeCostPerKm.map {
            "\(currencySymbol)\(formatDouble(distanceRateInScenarioUnit($0, sourceUnit: "km"), fractionDigits: 2))/\(mileageDisplayUnit)"
        } ?? "-"
        let carCost = item.carTripCost.map {
            "\(currencySymbol)\(formatDouble($0, fractionDigits: 2))"
        } ?? "-"

        return ComparableTripCostBreakdown(
            total: alternativeTripCost,
            detailLines: [
                "Trip pricing: car \(carRate) = \(carCost); \(alternative.name) effective \(alternativeRate) = \(currencySymbol)\(formatDouble(alternativeTripCost, fractionDigits: 2))"
            ]
        )
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
