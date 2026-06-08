import SwiftUI

extension ScenarioOverviewView {
    var usesEffectiveCostPerKmBreakdown: Bool {
        selectedDetailMetric == .costPerKm
    }

    var costPerKmBreakdownStart: Date {
        if usesEffectiveCostPerKmBreakdown {
            return activeScenario.startDate
        }

        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = selectedMetricTrendPoint?.date ?? currentMonthStart
        return calendar.dateInterval(of: .month, for: selectedDate)?.start ?? currentMonthStart
    }

    var costPerKmBreakdownEnd: Date {
        if usesEffectiveCostPerKmBreakdown {
            return effectiveCostPerKmSelectedEnd
        }

        let calendar = Calendar(identifier: .gregorian)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: costPerKmBreakdownStart) ?? Date()
        return min(monthEnd, Date())
    }

    var costPerKmBreakdownCost: Double {
        if usesEffectiveCostPerKmBreakdown {
            return effectiveOwnershipCost(to: costPerKmBreakdownEnd)
        }

        return ownershipCost(
            from: costPerKmBreakdownStart,
            to: costPerKmBreakdownEnd,
            includeFinancing: shouldIncludeFinancingInCostPerKm
        )
    }

    var costPerKmBreakdownDistance: Double {
        mileageDistance(from: costPerKmBreakdownStart, to: costPerKmBreakdownEnd)
    }

    var costPerKmBreakdownCostSubtitle: String {
        let expenseCount = costPerKmIncludedCostEvents.count
        let virtualCostCount = costPerKmVirtualCostSourceCount

        if virtualCostCount == 0 {
            return "\(expenseCount) \(expenseCount == 1 ? "expense" : "expenses")"
        }

        if expenseCount == 0 {
            return "\(virtualCostCount) virtual \(virtualCostCount == 1 ? "cost" : "costs")"
        }

        return "\(expenseCount) expenses + \(virtualCostCount) virtual"
    }

    var costPerKmVirtualCostSourceCount: Int {
        if usesEffectiveCostPerKmBreakdown {
            return costPerKmEffectiveOwnershipSources.count
        }

        return costPerKmFinancingSource == nil ? 0 : 1
    }

    var costPerKmIncludedCostEvents: [CostEvent] {
        costEvents
            .filter { $0.date >= costPerKmBreakdownStart && $0.date < costPerKmBreakdownEnd }
            .sorted { $0.date > $1.date }
    }

    var costPerKmIncludedTripEvents: [UsageEvent] {
        usageEvents
            .filter { $0.eventType == "trip" && $0.date >= costPerKmBreakdownStart && $0.date < costPerKmBreakdownEnd }
            .sorted { $0.date > $1.date }
    }

    var costPerKmUsesTripDistance: Bool {
        tripDistance(from: costPerKmBreakdownStart, to: costPerKmBreakdownEnd) >= odometerDelta(from: costPerKmBreakdownStart, to: costPerKmBreakdownEnd)
            && !costPerKmIncludedTripEvents.isEmpty
    }

    var costPerKmMileageBasisLabel: String {
        if costPerKmUsesTripDistance {
            return "\(costPerKmIncludedTripEvents.count) trips"
        }

        return "Odometer delta"
    }

    var costPerKmBreakdownPeriodTitle: String {
        if usesEffectiveCostPerKmBreakdown {
            guard let point = selectedMetricTrendPoint else {
                return "Since purchase"
            }

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "MMM yyyy"

            if point.isProjected {
                return "Projected \(formatter.string(from: point.date))"
            }

            let calendar = Calendar(identifier: .gregorian)
            if calendar.isDate(point.date, equalTo: Date(), toGranularity: .month) {
                return "Since purchase"
            }

            return "Through \(formatter.string(from: point.date))"
        }

        let calendar = Calendar(identifier: .gregorian)
        if calendar.isDate(costPerKmBreakdownStart, equalTo: currentMonthStart, toGranularity: .month) {
            return "This month"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: costPerKmBreakdownStart)
    }

    var costPerKmBreakdownRangeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"

        let calendar = Calendar(identifier: .gregorian)
        if usesEffectiveCostPerKmBreakdown {
            let selectedEnd = costPerKmSelectedPeriodEnd
            let endLabel: String
            if calendar.isDate(selectedEnd, inSameDayAs: Date()) {
                endLabel = "Today"
            } else {
                endLabel = formatter.string(from: selectedEnd)
            }

            return "\(formatter.string(from: costPerKmBreakdownStart)) - \(endLabel)"
        }

        let now = Date()
        let endLabel: String
        if calendar.isDate(costPerKmBreakdownEnd, inSameDayAs: now) {
            endLabel = "Today"
        } else {
            let inclusiveEnd = calendar.date(byAdding: .day, value: -1, to: costPerKmBreakdownEnd) ?? costPerKmBreakdownEnd
            endLabel = formatter.string(from: inclusiveEnd)
        }
        return "\(formatter.string(from: costPerKmBreakdownStart)) - \(endLabel)"
    }

    var costPerKmFormulaPrefix: String {
        usesEffectiveCostPerKmBreakdown ? "effective " : ""
    }

    var costPerKmFormulaValue: String {
        if usesEffectiveCostPerKmBreakdown, let point = selectedMetricTrendPoint {
            return "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2))/\(mileageDisplayUnit)"
        }

        guard costPerKmBreakdownDistance > 0 else {
            return "—"
        }

        return "\(currencySymbol)\(formatDouble(costPerKmBreakdownCost / costPerKmBreakdownDistance, fractionDigits: 2))/\(mileageDisplayUnit)"
    }

    var costPerKmFormulaText: String? {
        guard usesEffectiveCostPerKmBreakdown, let point = selectedMetricTrendPoint, point.isProjected else {
            return nil
        }

        return "\(costPerKmFormulaValue) projected from current ownership trend"
    }

    var costPerKmBreakdownDisplayValue: String {
        if usesEffectiveCostPerKmBreakdown, let point = selectedMetricTrendPoint {
            return "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2))"
        }

        guard costPerKmBreakdownDistance > 0 else {
            return "—"
        }

        return "\(currencySymbol)\(formatDouble(costPerKmBreakdownCost / costPerKmBreakdownDistance, fractionDigits: 2))"
    }

    var costPerKmBreakdownCostProgress: CGFloat {
        normalizedProgress(costPerKmBreakdownCost / max(costEvents.map { doubleValue(decimalValue($0.amount)) }.max() ?? costPerKmBreakdownCost, 1))
    }

    var costPerKmBreakdownDistanceProgress: CGFloat {
        normalizedProgress(costPerKmBreakdownDistance / max(usageEvents.map { $0.distanceValue }.max() ?? costPerKmBreakdownDistance, 1))
    }
}
