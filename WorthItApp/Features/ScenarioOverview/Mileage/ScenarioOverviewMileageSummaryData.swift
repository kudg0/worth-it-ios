import Foundation

extension ScenarioOverviewView {
    var currentOdometerValue: Int {
        let currentOdometer = Double(activeScenario.purchaseOdometer ?? 0) + usageEvents.reduce(0) { $0 + $1.distanceValue }

        return max(Int(currentOdometer.rounded()), 0)
    }

    var mileageDisplayUnit: String {
        usageEvents.first?.distanceUnit ?? "km"
    }

    var mileageThisMonthValue: Double {
        let calendar = Calendar.autoupdatingCurrent
        return mileageLogItems
            .filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + mileageDistance(for: $1) }
    }

    var currentMonthMileageLogItems: [MileageLogItem] {
        mileageLogItems.filter { expenseHistoryIsSameMonth($0.date, currentMonthStart) }
    }

    var mileageLastUpdateText: String {
        guard let latestDate = usageEvents.map(\.date).max() else {
            return "No logs yet"
        }

        return Self.relativeMileageFormatter.localizedString(for: latestDate, relativeTo: Date())
    }

    var mileageHeroDateText: String {
        Self.mileageHeroDateFormatter.string(from: Date())
    }

    var mileageThisMonthText: String {
        mileageThisMonthValue > 0 ? "+\(formatDouble(mileageThisMonthValue, fractionDigits: 1)) \(mileageDisplayUnit)" : "—"
    }

    var mileageAveragePerDayText: String {
        guard mileageThisMonthValue > 0 else { return "—" }
        let elapsedDays = max(Calendar.autoupdatingCurrent.component(.day, from: Date()), 1)
        return "\(formatDouble(mileageThisMonthValue / Double(elapsedDays), fractionDigits: 1)) \(mileageDisplayUnit)"
    }

    var mileageSaveTitle: String {
        if editingUsageEvent != nil {
            return "Save Changes"
        }

        return mileageMode == .trip ? "Save Trip" : "Save Reading"
    }

    var previousOdometerForMileageForm: Int {
        guard let editingUsageEvent, editingUsageEvent.eventType == "odometer_update" else {
            return currentOdometerValue
        }

        let baseOdometer = Double(activeScenario.purchaseOdometer ?? 0)
        let distanceBeforeEntry = usageEvents
            .filter { $0.id != editingUsageEvent.id && $0.date < editingUsageEvent.date }
            .reduce(0) { $0 + $1.distanceValue }

        return max(Int((baseOdometer + distanceBeforeEntry).rounded()), 0)
    }

    var previousOdometerText: String {
        previousOdometerForMileageForm > 0 ? "\(formatInt(previousOdometerForMileageForm)) \(mileageDisplayUnit)" : "—"
    }

    var mileageOdometerDeltaText: String {
        guard let value = Double(mileageValue), previousOdometerForMileageForm > 0 else { return "—" }
        let delta = value - Double(previousOdometerForMileageForm)
        let sign = delta >= 0 ? "+" : "−"
        return "\(sign)\(formatDouble(abs(delta), fractionDigits: delta.rounded() == delta ? 0 : 1)) \(mileageDisplayUnit)"
    }

    var resultingOdometerText: String {
        guard currentOdometerValue > 0, let tripDistance = Double(mileageValue), tripDistance > 0 else {
            return "—"
        }

        return "\(formatDouble(Double(currentOdometerValue) + tripDistance, fractionDigits: tripDistance.rounded() == tripDistance ? 0 : 1)) \(mileageDisplayUnit)"
    }

    func resetMileageValueForMode(_ mode: MileageMode) {
        mileageValue = mode == .odometer && currentOdometerValue > 0 ? "\(currentOdometerValue)" : ""
    }
}
