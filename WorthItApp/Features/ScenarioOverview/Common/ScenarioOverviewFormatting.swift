import SwiftUI

enum ScenarioOverviewFormatting {
    static func formatDecimal(_ value: Decimal, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0"
    }

    static func formatDouble(_ value: Double, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func formatInt(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func formatEditableNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        return String(value)
    }

    static func decimalValue(_ value: String?) -> Decimal {
        guard let value else { return 0 }
        return Decimal(string: value) ?? 0
    }

    static func sanitizedDecimalInput(_ value: String) -> String {
        var result = ""
        var hasSeparator = false

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasSeparator else { continue }
                result.append(".")
                hasSeparator = true
            }
        }

        return result
    }

    static func doubleValue(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }

    static func normalizedProgress(_ value: Double) -> CGFloat {
        CGFloat(min(max(value, 0), 1))
    }
}

extension ScenarioOverviewView {
    func formatDecimal(_ value: Decimal, fractionDigits: Int) -> String {
        ScenarioOverviewFormatting.formatDecimal(value, fractionDigits: fractionDigits)
    }

    func formatDouble(_ value: Double, fractionDigits: Int) -> String {
        ScenarioOverviewFormatting.formatDouble(value, fractionDigits: fractionDigits)
    }

    func formatInt(_ value: Int) -> String {
        ScenarioOverviewFormatting.formatInt(value)
    }

    func formatEditableNumber(_ value: Double) -> String {
        ScenarioOverviewFormatting.formatEditableNumber(value)
    }

    func decimalValue(_ value: String?) -> Decimal {
        ScenarioOverviewFormatting.decimalValue(value)
    }

    func sanitizedDecimalInput(_ value: String) -> String {
        ScenarioOverviewFormatting.sanitizedDecimalInput(value)
    }

    func doubleValue(_ value: Decimal) -> Double {
        ScenarioOverviewFormatting.doubleValue(value)
    }

    func normalizedProgress(_ value: Double) -> CGFloat {
        ScenarioOverviewFormatting.normalizedProgress(value)
    }
}
