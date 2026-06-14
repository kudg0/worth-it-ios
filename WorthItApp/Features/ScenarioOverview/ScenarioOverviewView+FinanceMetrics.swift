import SwiftUI

extension ScenarioOverviewView {
    var monthlySpend: String {
        if let monthlySpendValue {
            return "\(currencySymbol)\(formatDouble(monthlySpendValue, fractionDigits: 0))"
        }

        return "—"
    }

    var monthlySpendValue: Double? {
        let currentSpend = doubleValue(currentMonthExpenseTotal)

        if currentSpend > 0 {
            return currentSpend
        }

        return monthlyCostValue(from: currentSummary)
    }

    var loanTermTiming: (remainingMonths: Int, progress: CGFloat)? {
        guard
            activeScenario.acquisitionType == "loan",
            let loanTermMonths = activeScenario.loanTermMonths,
            loanTermMonths > 0
        else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        let asOfMonth = expenseHistoryMonthStart(for: Date())
        let elapsedMonths = min(max(calendar.dateComponents([.month], from: loanStart, to: asOfMonth).month ?? 0, 0), loanTermMonths)
        let remainingMonths = max(loanTermMonths - elapsedMonths, 0)

        return (
            remainingMonths: remainingMonths,
            progress: normalizedProgress(Double(elapsedMonths) / Double(loanTermMonths))
        )
    }

    var loanPaymentSubtitle: String? {
        guard let loanTermTiming else { return nil }

        switch loanTermTiming.remainingMonths {
        case 0:
            return "Loan complete"
        case 1:
            return "1 month to go"
        default:
            return "\(loanTermTiming.remainingMonths) months to go"
        }
    }

    var previousMonthlySpendValue: Double? {
        let previousSpend = doubleValue(previousMonthExpenseTotal)

        if previousSpend > 0 {
            return previousSpend
        }

        return monthlyCostValue(from: previousMonthSummary)
    }

    func monthlyCostValue(from summary: ScenarioSummary?) -> Double? {
        guard
            let summary,
            summary.includedCostsTotal > 0,
            summary.ownershipWindow.monthsOwned > 0
        else {
            return nil
        }

        return summary.includedCostsTotal / summary.ownershipWindow.monthsOwned
    }

    var totalOwnershipCost: Decimal? {
        guard purchasePrice > 0 else { return nil }
        guard ownershipNetCost > 0 else { return nil }
        return ownershipNetCost
    }

    var totalOwnershipDisplay: String {
        guard let totalOwnershipCost else { return "—" }
        return "\(currencySymbol)\(formatDecimal(totalOwnershipCost, fractionDigits: 0))"
    }

    var expectedResaleDisplay: String {
        expectedResaleValue > 0 ? "\(currencySymbol)\(formatDecimal(expectedResaleValue, fractionDigits: 0))" : "—"
    }

    var projectedGain: Decimal {
        max(expectedResaleValue - purchasePrice - loanInterestTotal - nonDailyExpenseTotal, 0)
    }

    var ownershipNetCost: Decimal {
        if let currentSummary {
            return Decimal(currentSummary.netOwnershipCost)
        }

        return purchasePrice + loanInterestTotal - expectedResaleValue
    }

    var previousOwnershipNetCost: Double? {
        previousMonthSummary?.netOwnershipCost
    }

    var monthlySpendProgress: CGFloat {
        if let monthlySpendValue {
            return normalizedProgress(monthlySpendValue / max(doublePurchasePrice / 12, 1))
        }

        if let currentSummary, currentSummary.includedCostsTotal > 0, currentSummary.ownershipWindow.monthsOwned > 0 {
            let averageMonthlyCosts = currentSummary.includedCostsTotal / currentSummary.ownershipWindow.monthsOwned
            return normalizedProgress(averageMonthlyCosts / max(doublePurchasePrice / 12, 1))
        }

        return 0
    }

    var costPerKmProgress: CGFloat {
        guard let costPerKm = currentCostPerDistanceValue else { return 0 }
        return normalizedProgress(costPerKm / 1.0)
    }

    var currentMonthCostPerKmProgress: CGFloat {
        guard let costPerKm = currentMonthlyCostPerDistanceValue else { return 0 }
        return normalizedProgress(costPerKm / 1.0)
    }

    var totalOwnershipProgress: CGFloat {
        guard purchasePrice > 0, let totalOwnershipCost else { return 0 }
        return normalizedProgress(doubleValue(totalOwnershipCost) / doublePurchasePrice)
    }

    var projectedGainProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }
        return normalizedProgress(doubleValue(projectedGain) / doublePurchasePrice)
    }

    var loanInterestProgress: CGFloat {
        loanTermTiming?.progress ?? 0
    }

    var expectedResaleProgress: CGFloat {
        guard purchasePrice > 0 else { return 0 }

        return normalizedProgress(doubleValue(expectedResaleValue) / doublePurchasePrice)
    }

    var expectedResaleColor: Color {
        expectedResaleValue >= purchasePrice ? Color(hex: 0x34D399) : WorthItColor.accentGold
    }

    var nonDailyExpenseTotal: Decimal {
        costEvents.reduce(Decimal(0)) { total, event in
            if Self.dailyExpenseCategories.contains(event.category) {
                return total
            }

            return total + decimalValue(event.amount)
        }
    }

    static let dailyExpenseCategories: Set<String> = ["fuel", "wash"]

    var purchasePrice: Decimal {
        Decimal(string: activeScenario.purchasePrice) ?? 0
    }

    var doublePurchasePrice: Double {
        NSDecimalNumber(decimal: purchasePrice).doubleValue
    }

    var monthlyMetricTitle: String {
        activeScenario.acquisitionType == "loan" ? "Monthly Cost" : "Monthly Spend"
    }

    var expectedResaleValue: Decimal {
        decimalValue(activeScenario.expectedResaleValue)
    }

    var loanMonthlyPayment: Decimal {
        guard activeScenario.acquisitionType == "loan" else { return 0 }

        let principal = decimalValue(activeScenario.loanAmount)
        let months = Decimal(activeScenario.loanTermMonths ?? 0)
        let annualRate = decimalValue(activeScenario.loanAnnualInterestRate) / 100

        guard principal > 0, months > 0 else { return 0 }
        guard annualRate > 0 else { return principal / months }

        let monthlyRate = doubleValue(annualRate / 12)
        let monthCount = doubleValue(months)
        let principalValue = doubleValue(principal)
        let denominator = 1 - pow(1 + monthlyRate, -monthCount)

        guard denominator > 0 else { return 0 }
        return Decimal(principalValue * monthlyRate / denominator)
    }

    var currentMonthLoanInterest: Double {
        let calendar = Calendar(identifier: .gregorian)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: currentMonthStart) ?? currentMonthStart
        return loanInterestCost(from: currentMonthStart, to: monthEnd)
    }

    var previousMonthLoanInterest: Double {
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = expenseHistoryMonthStart(for: previousMonthAsOfDate)
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? monthStart
        return loanInterestCost(from: monthStart, to: monthEnd)
    }

    func loanInterestCost(from start: Date, to end: Date) -> Double {
        guard activeScenario.acquisitionType == "loan",
              let loanTermMonths = activeScenario.loanTermMonths,
              loanTermMonths > 0
        else {
            return 0
        }

        let principal = doubleValue(decimalValue(activeScenario.loanAmount))
        let annualRate = doubleValue(decimalValue(activeScenario.loanAnnualInterestRate) / 100)
        let monthlyPayment = doubleValue(loanMonthlyPayment)
        guard principal > 0, annualRate > 0, monthlyPayment > 0 else { return 0 }

        let calendar = Calendar(identifier: .gregorian)
        let loanStart = expenseHistoryMonthStart(for: activeScenario.startDate)
        guard let loanEnd = calendar.date(byAdding: .month, value: loanTermMonths, to: loanStart) else { return 0 }

        let intervalStart = max(start, loanStart)
        let intervalEnd = min(end, loanEnd)
        guard intervalStart < intervalEnd else { return 0 }

        let monthlyRate = annualRate / 12
        var cursor = expenseHistoryMonthStart(for: intervalStart)
        var total = 0.0

        while cursor < intervalEnd {
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: cursor) else {
                break
            }

            let monthOffset = max(calendar.dateComponents([.month], from: loanStart, to: cursor).month ?? 0, 0)
            let balanceBeforeMonth = principal * pow(1 + monthlyRate, Double(monthOffset))
                - monthlyPayment * ((pow(1 + monthlyRate, Double(monthOffset)) - 1) / monthlyRate)
            let monthlyInterest = max(balanceBeforeMonth, 0) * monthlyRate
            let overlapStart = max(intervalStart, cursor)
            let overlapEnd = min(intervalEnd, nextMonth)

            if overlapStart < overlapEnd {
                total += monthlyInterest
            }

            cursor = nextMonth
        }

        return total
    }

    var loanInterestTotal: Decimal {
        guard activeScenario.acquisitionType == "loan" else { return 0 }

        let months = Decimal(activeScenario.loanTermMonths ?? 0)
        let principal = decimalValue(activeScenario.loanAmount)
        return max(loanMonthlyPayment * months - principal, 0)
    }

    var currencySymbol: String {
        switch activeScenario.currency {
        case "USD":
            "$"
        case "GBP":
            "£"
        default:
            "€"
        }
    }
}
