import SwiftUI

extension ScenarioOverviewView {
    func expenseHistoryGroupTotal(_ group: ExpenseMonthGroup) -> String {
        let total = group.events.reduce(Decimal(0)) { partial, event in
            partial + decimalValue(event.amount)
        }

        return "\(currencySymbol)\(formatDecimal(total, fractionDigits: 2))"
    }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: Date())
    }

    func expenseTitle(for event: CostEvent) -> String {
        event.note?.isEmpty == false ? event.note! : event.category.capitalized
    }

    func expenseSubtitle(for event: CostEvent) -> String {
        "\(event.category.capitalized) • \(expenseDateFormatter.string(from: event.date))"
    }

    func expenseHistorySubtitle(for event: CostEvent) -> String {
        let note = event.note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = note?.isEmpty == false ? note! : event.category.capitalized
        return "\(source) • \(expenseDateFormatter.string(from: event.date))"
    }

    func expenseAmount(_ event: CostEvent) -> String {
        "\(currencySymbol(for: event.currency))\(formatDecimal(decimalValue(event.amount), fractionDigits: 0))"
    }

    func expenseAmountPrecise(_ event: CostEvent) -> String {
        "\(currencySymbol(for: event.currency))\(formatDecimal(decimalValue(event.amount), fractionDigits: 2))"
    }

    func expenseBadgeText(for event: CostEvent) -> String {
        if event.kind == "recurring" {
            return "Recurring"
        }

        switch event.category {
        case "repair", "maintenance", "tires":
            return "Maintenance"
        case "fuel", "wash":
            return "Approved"
        default:
            return event.category
        }
    }

    func expenseAccentColor(for event: CostEvent) -> Color {
        switch event.category {
        case "fuel":
            WorthItColor.primaryContainer
        case "repair", "maintenance", "tires":
            WorthItColor.accentGold
        case "insurance":
            Color(hex: 0xBAC6EC)
        default:
            WorthItColor.textSecondary
        }
    }

    func expenseIconName(for category: String) -> String {
        switch category {
        case "fuel":
            "fuelpump"
        case "maintenance", "repair":
            "wrench.fill"
        case "tires":
            "gearshape.2.fill"
        case "insurance":
            "shield.fill"
        case "parking":
            "parkingsign.circle.fill"
        case "tax":
            "building.columns.fill"
        case "wash":
            "sparkles"
        default:
            "receipt.fill"
        }
    }

    func currencySymbol(for currency: String) -> String {
        switch currency {
        case "USD":
            "$"
        case "GBP":
            "£"
        default:
            "€"
        }
    }
}
