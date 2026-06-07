import SwiftUI

extension ScenarioOverviewView {
    var costPerKmBreakdownStart: Date {
        if costPerKmMode == .effective {
            return activeScenario.startDate
        }

        if usesThreeMonthAverageCostPerKm {
            return costPerKmThreeMonthAverageStart
        }

        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = selectedMetricTrendPoint?.date ?? currentMonthStart
        if activeCostPerKmTrendRange == .oneYear {
            return calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        }

        return calendar.dateInterval(of: metricTrendCalendarComponent, for: selectedDate)?.start ?? selectedDate
    }

    var costPerKmBreakdownEnd: Date {
        if costPerKmMode == .effective {
            return effectiveCostPerKmSelectedEnd
        }

        if usesThreeMonthAverageCostPerKm {
            return costPerKmThreeMonthAverageEnd
        }

        let calendar = Calendar(identifier: .gregorian)
        let component: Calendar.Component = activeCostPerKmTrendRange == .oneYear ? .month : metricTrendCalendarComponent
        return calendar.date(byAdding: component, value: 1, to: costPerKmBreakdownStart) ?? Date()
    }

    var costPerKmBreakdownCost: Double {
        if costPerKmMode == .effective {
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
        if costPerKmMode == .effective {
            return "Since purchase"
        }

        if usesThreeMonthAverageCostPerKm {
            return "Previous 3 month average"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        switch metricTrendCalendarComponent {
        case .day:
            if activeCostPerKmTrendRange == .oneYear {
                formatter.dateFormat = "d MMM"
                let start = formatter.string(from: costPerKmBreakdownStart)
                let endDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: costPerKmBreakdownEnd) ?? costPerKmBreakdownEnd
                let end = formatter.string(from: endDate)
                let yearFormatter = DateFormatter()
                yearFormatter.locale = Locale(identifier: "en_US_POSIX")
                yearFormatter.dateFormat = "yyyy"
                return "\(start) - \(end) \(yearFormatter.string(from: costPerKmBreakdownStart))"
            }

            formatter.dateFormat = "d MMM yyyy"
        case .weekOfYear:
            formatter.dateFormat = "d MMM"
            let start = formatter.string(from: costPerKmBreakdownStart)
            let end = formatter.string(from: Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: costPerKmBreakdownEnd) ?? costPerKmBreakdownEnd)
            return "\(start) - \(end)"
        default:
            formatter.dateFormat = "LLLL yyyy"
        }

        return formatter.string(from: costPerKmBreakdownStart)
    }

    var costPerKmBreakdownRangeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"

        if costPerKmMode == .effective {
            let calendar = Calendar(identifier: .gregorian)
            let now = Date()
            let endLabel: String
            if calendar.isDate(costPerKmBreakdownEnd, inSameDayAs: now) {
                endLabel = "Today"
            } else {
                let inclusiveEnd = calendar.date(byAdding: .day, value: -1, to: costPerKmBreakdownEnd) ?? costPerKmBreakdownEnd
                endLabel = formatter.string(from: inclusiveEnd)
            }
            return "\(formatter.string(from: activeScenario.startDate)) - \(endLabel)"
        }

        let inclusiveEnd = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: costPerKmBreakdownEnd) ?? costPerKmBreakdownEnd
        return "\(formatter.string(from: costPerKmBreakdownStart)) - \(formatter.string(from: inclusiveEnd))"
    }

    var costPerKmFormulaPrefix: String {
        if costPerKmMode == .effective {
            return "effective "
        }

        return usesThreeMonthAverageCostPerKm ? "3-mo avg " : ""
    }

    var costPerKmFormulaValue: String {
        guard costPerKmBreakdownDistance > 0 else {
            return "—"
        }

        return "\(currencySymbol)\(formatDouble(costPerKmBreakdownCost / costPerKmBreakdownDistance, fractionDigits: 2))/\(mileageDisplayUnit)"
    }

    var costPerKmBreakdownDisplayValue: String {
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
