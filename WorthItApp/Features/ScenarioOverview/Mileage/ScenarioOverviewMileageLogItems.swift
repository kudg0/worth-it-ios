import Foundation

extension ScenarioOverviewView {
    var mileageLogItems: [MileageLogItem] {
        let sortedEvents = usageEvents.sorted { $0.date < $1.date }
        var previousOdometer = activeScenario.purchaseOdometer
        var items: [MileageLogItem] = []

        for event in sortedEvents {
            switch event.eventType {
            case "odometer_update":
                let currentOdometer = event.odometerValue.map { Int($0.rounded()) }
                items.append(
                    MileageLogItem(
                        id: event.id,
                        kind: .odometer,
                        title: "Odometer Update",
                        subtitle: mileageEventSubtitle(event.note, fallback: "Odometer reading"),
                        previousOdometer: previousOdometer,
                        currentOdometer: currentOdometer,
                        distance: nil,
                        unit: event.odometerUnit,
                        date: event.date
                    )
                )

                if let currentOdometer {
                    previousOdometer = currentOdometer
                }
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
                        unit: event.distanceUnit,
                        date: event.date
                    )
                )
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

    func mileageDistance(for item: MileageLogItem) -> Double {
        switch item.kind {
        case .trip:
            return item.distance ?? 0
        case .odometer:
            guard let previous = item.previousOdometer, let current = item.currentOdometer else {
                return 0
            }
            return max(Double(current - previous), 0)
        }
    }
}
