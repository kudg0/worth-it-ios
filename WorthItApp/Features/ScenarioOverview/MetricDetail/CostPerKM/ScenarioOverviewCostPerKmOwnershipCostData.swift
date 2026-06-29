import Foundation

extension ScenarioOverviewView {
    var kilometersPerMile: Double {
        1.609344
    }

    func distanceValue(_ value: Double, from sourceUnit: String, to targetUnit: String) -> Double {
        guard sourceUnit != targetUnit else {
            return value
        }

        if sourceUnit == "mi", targetUnit == "km" {
            return value * kilometersPerMile
        }

        if sourceUnit == "km", targetUnit == "mi" {
            return value / kilometersPerMile
        }

        return value
    }

    func usageDistanceInScenarioUnit(_ event: UsageEvent) -> Double {
        let distanceKm = Double(event.distanceKm)
        let sourceDistance = distanceKm ?? distanceValue(event.distanceValue, from: event.distanceUnit, to: "km")
        return distanceValue(sourceDistance, from: "km", to: mileageDisplayUnit)
    }

    func distanceRateInScenarioUnit(_ rate: Double, sourceUnit: String) -> Double {
        guard sourceUnit != mileageDisplayUnit else {
            return rate
        }

        if sourceUnit == "km", mileageDisplayUnit == "mi" {
            return rate * kilometersPerMile
        }

        if sourceUnit == "mi", mileageDisplayUnit == "km" {
            return rate / kilometersPerMile
        }

        return rate
    }

    func effectiveCostPerDistanceValue(asOf date: Date) -> Double? {
        effectiveCostPerDistanceValue(asOf: date, includesResidualValue: includesVehicleResidualValue)
    }

    func effectiveCostPerDistanceValue(asOf date: Date, includesResidualValue: Bool) -> Double? {
        let end = min(max(date, activeScenario.startDate), Date())
        let distance = mileageDistance(from: activeScenario.startDate, to: end)
        guard distance > 0 else { return nil }

        let cost = effectiveOwnershipCost(to: end, includesResidualValue: includesResidualValue)
        guard cost > 0 else { return nil }

        return cost / distance
    }

    func effectiveOwnershipCost(to date: Date) -> Double {
        effectiveOwnershipCost(to: date, includesResidualValue: includesVehicleResidualValue)
    }

    func effectiveOwnershipCost(to date: Date, includesResidualValue: Bool) -> Double {
        let loggedCosts = ownershipCost(from: activeScenario.startDate, to: date, includeFinancing: false)
        let vehicleValueCost = includesResidualValue ? depreciationCost : 0
        return loggedCosts + vehicleValueCost + accruedLoanInterest(to: date)
    }

    func netOwnershipCost(to date: Date) -> Double {
        let end = min(max(date, activeScenario.startDate), Date())
        let loggedCosts = ownershipCost(from: activeScenario.startDate, to: end, includeFinancing: false)

        // Match summary semantics: vehicle value is principal; financing adds only interest.
        return max(doublePurchasePrice + loggedCosts + doubleValue(loanInterestTotal) - doubleValue(expectedResaleValue), 0)
    }

    func totalOwnershipTrendPoints(maxMonths: Int?) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let firstLoggedCostMonth = costEvents
            .map { expenseHistoryMonthStart(for: $0.date) }
            .min()

        let monthStarts = efficiencyMonthStarts(maxMonths: maxMonths)
            .filter { monthStart in
                guard let firstLoggedCostMonth else { return true }
                return monthStart >= firstLoggedCostMonth
            }

        let points = monthStarts.map { monthStart in
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
            let asOf = min(monthEnd, Date())
            return MetricTrendPoint(date: monthStart, value: effectiveOwnershipCost(to: asOf, includesResidualValue: true))
        }

        guard let firstMeaningfulIndex = points.firstIndex(where: { $0.value > 0 }) else {
            return []
        }

        return Array(points[firstMeaningfulIndex...])
    }

    var depreciationCost: Double {
        max(doublePurchasePrice - doubleValue(expectedResaleValue), 0)
    }

    func accruedLoanInterest(to date: Date) -> Double {
        guard activeScenario.acquisitionType == "loan",
              let loanTermMonths = activeScenario.loanTermMonths,
              loanTermMonths > 0
        else {
            return 0
        }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let loanEnd = loanEndDate ?? date
        let cappedDate = min(max(date, loanStart), loanEnd)
        let elapsedDays = calendar.dateComponents([.day], from: loanStart, to: cappedDate).day ?? 0
        let termDays = max(calendar.dateComponents([.day], from: loanStart, to: loanEnd).day ?? loanTermMonths * 30, 1)
        let ratio = min(max(Double(elapsedDays) / Double(termDays), 0), 1)

        return doubleValue(loanInterestTotal) * ratio
    }

    func dateBucketStart(_ date: Date, period: Calendar.Component) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateInterval(of: period, for: date)?.start ?? date
    }

    func efficiencyMonthStarts(maxMonths: Int?) -> [Date] {
        let calendar = Calendar(identifier: .gregorian)
        let scenarioStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let start: Date
        if let maxMonths {
            let visibleStart = calendar.date(byAdding: .month, value: -(maxMonths - 1), to: currentMonthStart) ?? currentMonthStart
            start = max(scenarioStart, visibleStart)
        } else {
            start = scenarioStart
        }
        let monthCount = calendar.dateComponents([.month], from: start, to: currentMonthStart).month ?? 0

        return (0...max(monthCount, 0)).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: start)
        }
    }

    func ownershipCost(from start: Date, to end: Date, includeFinancing: Bool) -> Double {
        let loggedCosts = costEvents
            .filter { $0.date >= start && $0.date < end }
            .reduce(0) { total, event in
                total + doubleValue(decimalValue(event.amount))
            }

        guard includeFinancing else {
            return loggedCosts
        }

        return loggedCosts + loanInterestCost(from: start, to: end)
    }

    func loanPaymentCost(from start: Date, to end: Date) -> Double {
        guard let loanEnd = loanEndDate
        else {
            return 0
        }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let intervalStart = max(start, loanStart)
        let intervalEnd = min(end, loanEnd)

        guard intervalStart < intervalEnd else {
            return 0
        }

        var cursor = expenseHistoryMonthStart(for: intervalStart)
        var total = 0.0

        while cursor < intervalEnd {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: cursor),
                  let dayRange = calendar.range(of: .day, in: .month, for: cursor)
            else {
                break
            }

            let overlapStart = max(intervalStart, cursor)
            let overlapEnd = min(intervalEnd, nextMonth)

            if overlapStart < overlapEnd {
                let activeDays = calendar.dateComponents([.day], from: overlapStart, to: overlapEnd).day ?? 0
                total += doubleValue(loanMonthlyPayment) * Double(activeDays) / Double(dayRange.count)
            }

            cursor = nextMonth
        }

        return total
    }

    var shouldIncludeFinancingInCostPerKm: Bool {
        activeScenario.acquisitionType == "loan" && loanEndDate != nil
    }

    var hasActiveFinancing: Bool {
        guard let loanEnd = loanEndDate else { return false }
        return Date() < loanEnd
    }

    var loanEndDate: Date? {
        guard activeScenario.acquisitionType == "loan",
              let loanTermMonths = activeScenario.loanTermMonths,
              loanTermMonths > 0
        else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        return calendar.date(byAdding: .month, value: loanTermMonths, to: loanStart)
    }

    func mileageDistance(from start: Date, to end: Date) -> Double {
        usageEvents
            .filter { event in
                event.date >= start && event.date < end
            }
            .reduce(0) { $0 + usageDistanceInScenarioUnit($1) }
    }

    func tripDistance(from start: Date, to end: Date) -> Double {
        usageEvents
            .filter { event in
                event.eventType == "trip" && event.date >= start && event.date < end
            }
            .reduce(0) { $0 + usageDistanceInScenarioUnit($1) }
    }

    func odometerDelta(from start: Date, to end: Date) -> Double {
        usageEvents
            .filter { event in
                event.eventType == "odometer_update" && event.date >= start && event.date < end
            }
            .reduce(0) { $0 + usageDistanceInScenarioUnit($1) }
    }
}
