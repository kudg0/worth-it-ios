import SwiftUI

extension ScenarioOverviewView {
    var costPerKmBreakdownSources: [CostPerKmBreakdownSource] {
        var sources = costPerKmIncludedCostEvents.map { event in
            CostPerKmBreakdownSource(
                id: "cost-\(event.id.uuidString)",
                date: event.date,
                title: expenseTitle(for: event),
                subtitle: i18n.t("\(expenseDateFormatter.string(from: event.date)) • \(event.category.capitalized)"),
                value: expenseAmountPrecise(event),
                status: "Added to Total",
                systemName: expenseIconName(for: event.category),
                accentColor: expenseAccentColor(for: event),
                target: .expense(event.id)
            )
        }

        if let financingSource = costPerKmFinancingSource {
            sources.append(financingSource)
        }

        sources.append(contentsOf: costPerKmEffectiveOwnershipSources)

        if costPerKmUsesTripDistance {
            sources.append(contentsOf: costPerKmIncludedTripEvents.map { event in
                CostPerKmBreakdownSource(
                    id: "trip-\(event.id.uuidString)",
                    date: event.date,
                    title: event.note?.isEmpty == false ? event.note! : "Trip Added",
                    subtitle: i18n.t("\(expenseDateFormatter.string(from: event.date)) • Mileage"),
                    value: "\(formatDouble(event.distanceValue, fractionDigits: 0)) \(event.distanceUnit)",
                    status: "Added to Dist",
                    systemName: "point.topleft.down.curvedto.point.bottomright.up",
                    accentColor: WorthItColor.primaryContainer,
                    target: .mileage(event.id)
                )
            })
        } else {
            sources.append(contentsOf: costPerKmOdometerSources)
        }

        return sources.sorted { $0.date > $1.date }
    }

    var costPerKmEffectiveOwnershipSources: [CostPerKmBreakdownSource] {
        guard usesEffectiveCostPerKmBreakdown else { return [] }

        var sources: [CostPerKmBreakdownSource] = []

        if includesVehicleResidualValue, depreciationCost > 0 {
            sources.append(
                CostPerKmBreakdownSource(
                    id: "depreciation-\(activeScenario.id.uuidString)",
                    date: costPerKmBreakdownEnd,
                    title: i18n.t("Vehicle depreciation"),
                    subtitle: i18n.t("Purchase minus current resale estimate"),
                    value: "\(currencySymbol)\(formatDouble(depreciationCost, fractionDigits: 0))",
                    status: "Added to Total",
                    systemName: "car.fill",
                    accentColor: WorthItColor.accentGold,
                    target: nil
                )
            )
        }

        let interest = accruedLoanInterest(to: costPerKmBreakdownEnd)
        if interest > 0 {
            sources.append(
                CostPerKmBreakdownSource(
                    id: "interest-\(activeScenario.id.uuidString)",
                    date: costPerKmBreakdownEnd,
                    title: i18n.t("Loan interest accrued"),
                    subtitle: i18n.t("Interest only, principal excluded"),
                    value: "\(currencySymbol)\(formatDouble(interest, fractionDigits: 0))",
                    status: "Added to Total",
                    systemName: "banknote",
                    accentColor: WorthItColor.primaryContainer,
                    target: nil
                )
            )
        }

        return sources
    }

    var costPerKmFinancingSource: CostPerKmBreakdownSource? {
        guard !usesEffectiveCostPerKmBreakdown,
              shouldIncludeFinancingInCostPerKm
        else {
            return nil
        }

        let interest = loanInterestCost(from: costPerKmBreakdownStart, to: costPerKmBreakdownEnd)
        guard interest > 0 else {
            return nil
        }

        return CostPerKmBreakdownSource(
            id: "interest-\(expenseHistoryMonthIdentifier(for: costPerKmBreakdownStart))",
            date: costPerKmBreakdownEnd,
            title: i18n.t("Loan interest accrued"),
            subtitle: i18n.t("Interest only, principal excluded"),
            value: "\(currencySymbol)\(formatDouble(interest, fractionDigits: 2))",
            status: "Added to Total",
            systemName: "banknote",
            accentColor: WorthItColor.primaryContainer,
            target: nil
        )
    }

    var costPerKmOdometerSources: [CostPerKmBreakdownSource] {
        var sources: [CostPerKmBreakdownSource] = []

        if let baseline = odometerReading(before: costPerKmBreakdownStart) {
            sources.append(
                CostPerKmBreakdownSource(
                    id: "odometer-baseline-\(costPerKmBreakdownStart.timeIntervalSince1970)",
                    date: baseline.date,
                    title: i18n.t("Odometer baseline"),
                    subtitle: i18n.t("\(expenseDateFormatter.string(from: costPerKmBreakdownStart)) • Distance start"),
                    value: "\(formatDouble(baseline.value, fractionDigits: 0)) \(mileageDisplayUnit)",
                    status: "Baseline",
                    systemName: "speedometer",
                    accentColor: WorthItColor.textSecondary,
                    target: baseline.id.map { .mileage($0) }
                )
            )
        }

        if let current = odometerReading(before: costPerKmBreakdownEnd) {
            sources.append(
                CostPerKmBreakdownSource(
                    id: "odometer-current-\(costPerKmBreakdownEnd.timeIntervalSince1970)",
                    date: current.date,
                    title: i18n.t("Current odometer"),
                    subtitle: i18n.t("\(expenseDateFormatter.string(from: min(current.date, Date()))) • Distance end"),
                    value: "\(formatDouble(current.value, fractionDigits: 0)) \(mileageDisplayUnit)",
                    status: "+\(formatDouble(costPerKmBreakdownDistance, fractionDigits: 0)) \(mileageDisplayUnit)",
                    systemName: "speedometer",
                    accentColor: WorthItColor.primaryContainer,
                    target: current.id.map { .mileage($0) }
                )
            )
        }

        return sources
    }

    func odometerReading(before date: Date) -> (id: UUID?, value: Double, date: Date)? {
        let odometerEvents = usageEvents
            .filter { $0.eventType == "odometer_update" && $0.date < date }
            .sorted { $0.date < $1.date }

        if let event = odometerEvents.last {
            let value = purchaseOdometerInScenarioUnit + mileageDistance(from: activeScenario.startDate, to: event.date.addingTimeInterval(0.001))
            return (event.id, value, event.date)
        }

        if let purchaseOdometer = activeScenario.purchaseOdometer {
            return (nil, distanceValue(Double(purchaseOdometer), from: "km", to: mileageDisplayUnit), activeScenario.startDate)
        }

        return nil
    }
}
