import Foundation

extension ScenarioOverviewView {
    var mileageLogItems: [MileageLogItem] {
        let sortedEvents = usageEvents.sorted { $0.date < $1.date }
        var currentOdometer = purchaseOdometerInScenarioUnit
        var items: [MileageLogItem] = []

        for event in sortedEvents {
            let scenarioDistance = usageDistanceInScenarioUnit(event)

            switch event.eventType {
            case "odometer_update":
                let previousReading = Int(currentOdometer.rounded())
                currentOdometer += scenarioDistance
                let currentReading = Int(currentOdometer.rounded())

                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .odometer,
                        title: i18n.t("Odometer Update"),
                        subtitle: mileageEventSubtitle(event.note, fallback: "Odometer reading"),
                        previousOdometer: previousReading,
                        currentOdometer: currentReading,
                        distance: scenarioDistance,
                        estimatedCostLabel: nil,
                        unit: mileageDisplayUnit,
                        date: event.date
                    )
                )
            case "trip":
                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .trip,
                        title: i18n.t("Trip Added"),
                        subtitle: mileageEventSubtitle(event.note, fallback: "Trip"),
                        previousOdometer: nil,
                        currentOdometer: nil,
                        distance: scenarioDistance,
                        estimatedCostLabel: estimatedTripCostLabel(for: event),
                        unit: mileageDisplayUnit,
                        date: event.date
                    )
                )
                currentOdometer += scenarioDistance
            default:
                break
            }
        }

        return items.sorted { $0.date > $1.date }
    }

    func mileageEventSubtitle(_ note: String?, fallback: String) -> String {
        guard let note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return fallback
        }

        return note
    }

    func estimatedTripCostLabel(for event: UsageEvent) -> String? {
        guard event.distanceValue > 0 else { return nil }

        guard let costPerDistance = tripCostPerDistanceValue(for: event) else {
            return nil
        }

        let estimatedCost = usageDistanceInScenarioUnit(event) * costPerDistance
        return "≈ \(currencySymbol)\(formatDouble(estimatedCost, fractionDigits: 2))"
    }

    func tripCostPerDistanceValue(for event: UsageEvent) -> Double? {
        switch costPerKmBasis {
        case .sincePurchase:
            return effectiveCostPerDistanceValue(asOf: tripCostAsOfDate(for: event))
        case .currentMonth:
            let monthStart = expenseHistoryMonthStart(for: event.date)
            return efficiencyPeriodValue(bucketStart: monthStart, period: .month)
                ?? effectiveCostPerDistanceValue(asOf: tripCostAsOfDate(for: event))
        }
    }

    func tripCostPerDistanceSourceText(for event: UsageEvent) -> String {
        switch costPerKmBasis {
        case .sincePurchase:
            return "Cumulative car cost per \(mileageDisplayUnit) on \(Self.mileageDateFormatter.string(from: event.date))"
        case .currentMonth:
            return "Monthly car cost per \(mileageDisplayUnit) for \(Self.monthYearFormatter.string(from: event.date))"
        }
    }

    func tripCostAsOfDate(for event: UsageEvent) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let dayStart = calendar.startOfDay(for: event.date)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? event.date
        return min(nextDay, Date())
    }

    func mileageDistance(for item: MileageLogItem) -> Double {
        switch item.kind {
        case .trip:
            return distanceValue(item.distance ?? 0, from: item.unit, to: mileageDisplayUnit)
        case .odometer:
            let distance = item.distance ?? max(Double((item.currentOdometer ?? 0) - (item.previousOdometer ?? 0)), 0)
            return distanceValue(distance, from: item.unit, to: mileageDisplayUnit)
        }
    }
}
