import Foundation

extension ScenarioOverviewView {
    var mileageLogItems: [MileageLogItem] {
        let sortedEvents = usageEvents.sorted { $0.date < $1.date }
        var currentOdometer = activeScenario.purchaseOdometer.map(Double.init) ?? 0
        var items: [MileageLogItem] = []

        for event in sortedEvents {
            switch event.eventType {
            case "odometer_update":
                let previousReading = Int(currentOdometer.rounded())
                currentOdometer += event.distanceValue
                let currentReading = Int(currentOdometer.rounded())

                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .odometer,
                        title: "Odometer Update",
                        subtitle: mileageEventSubtitle(event.note, fallback: "Odometer reading"),
                        previousOdometer: previousReading,
                        currentOdometer: currentReading,
                        distance: event.distanceValue,
                        estimatedCostLabel: nil,
                        unit: event.odometerUnit,
                        date: event.date
                    )
                )
            case "trip":
                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .trip,
                        title: "Trip Added",
                        subtitle: mileageEventSubtitle(event.note, fallback: "Trip"),
                        previousOdometer: nil,
                        currentOdometer: nil,
                        distance: event.distanceValue,
                        estimatedCostLabel: estimatedTripCostLabel(for: event),
                        unit: event.distanceUnit,
                        date: event.date
                    )
                )
                currentOdometer += event.distanceValue
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

        let estimatedCost = event.distanceValue * costPerDistance
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
            return "Cumulative car cost per \(event.distanceUnit) on \(Self.mileageDateFormatter.string(from: event.date))"
        case .currentMonth:
            return "Monthly car cost per \(event.distanceUnit) for \(Self.monthYearFormatter.string(from: event.date))"
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
            return item.distance ?? 0
        case .odometer:
            return item.distance ?? max(Double((item.currentOdometer ?? 0) - (item.previousOdometer ?? 0)), 0)
        }
    }
}
