import SwiftUI

struct AchievementDetailValueGrid: View {
    let currentTitle: String
    let neededTitle: String
    let leftTitle: String
    let current: Double
    let target: Double
    let remaining: Double

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            tile(title: currentTitle, value: AchievementValueFormatter.text(current), highlighted: true)
            tile(title: neededTitle, value: AchievementValueFormatter.text(target), highlighted: false)
            tile(title: leftTitle, value: AchievementValueFormatter.text(remaining), highlighted: false)
        }
    }

    private func tile(title: String, value: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(highlighted ? WorthItColor.primaryContainer : WorthItColor.textSecondary)

            Text(value)
                .font(.system(size: 13, weight: highlighted ? .bold : .medium))
                .foregroundStyle(highlighted ? WorthItColor.primaryContainer : WorthItColor.textPrimary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
        .padding(WorthItSpacing.m)
        .background(
            highlighted ? WorthItColor.surfaceContainerHigh : WorthItColor.surfaceContainerLow,
            in: RoundedRectangle(cornerRadius: WorthItRadius.m)
        )
    }
}

enum AchievementValueFormatter {
    static func text(_ value: Double) -> String {
        if value >= 100 {
            return integer.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        }

        if value.rounded() == value {
            return "\(Int(value))"
        }

        return decimal.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static let integer: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}
