import Foundation

extension ScenarioOverviewView {
    func effectiveCostPerDistanceValue(asOf date: Date) -> Double? {
        let end = min(max(date, activeScenario.startDate), Date())
        let distance = mileageDistance(from: activeScenario.startDate, to: end)
        guard distance > 0 else { return nil }

        let cost = effectiveOwnershipCost(to: end)
        guard cost > 0 else { return nil }

        return cost / distance
    }

    func effectiveOwnershipCost(to date: Date) -> Double {
        let loggedCosts = ownershipCost(from: activeScenario.startDate, to: date, includeFinancing: false)
        return loggedCosts + depreciationCost + accruedLoanInterest(to: date)
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

        return loggedCosts + loanPaymentCost(from: start, to: end)
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
        hasActiveFinancing && costPerKmIncludesFinancing
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
        max(tripDistance(from: start, to: end), odometerDelta(from: start, to: end))
    }

    func tripDistance(from start: Date, to end: Date) -> Double {
        usageEvents
            .filter { event in
                event.eventType == "trip" && event.date >= start && event.date < end
            }
            .reduce(0) { $0 + $1.distanceValue }
    }

    func odometerDelta(from start: Date, to end: Date) -> Double {
        let odometerEvents = usageEvents
            .filter { $0.eventType == "odometer_update" }
            .sorted { $0.date < $1.date }

        let baseline = odometerEvents
            .last { $0.date < start }?
            .odometerValue ?? Double(activeScenario.purchaseOdometer ?? 0)
        let current = odometerEvents
            .last { $0.date < end }?
            .odometerValue ?? baseline

        return max(current - baseline, 0)
    }
}
