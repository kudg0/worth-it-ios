import SwiftUI

struct AchievementDetailValueGrid: View {
    @Environment(\.i18n) private var i18n

    let currentTitle: String
    let neededTitle: String
    let leftTitle: String
    let current: Double
    let target: Double
    let remaining: Double

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .center, spacing: WorthItSpacing.m) {
                Image(systemName: isComplete ? "checkmark.seal.fill" : "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isComplete ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                    .frame(width: 30, height: 30)
                    .background(WorthItColor.surfaceMetric, in: Circle())

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(i18n.t(.achievements.detail.protocol.title))
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.1)
                        .textCase(.uppercase)
                        .foregroundStyle(WorthItColor.textSecondary)

                    Text(progressSummary)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .monospacedDigit()
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(isComplete ? WorthItColor.accentGold : WorthItColor.primaryContainer)
                    .monospacedDigit()
            }

            ProgressView(value: progress)
                .tint(isComplete ? WorthItColor.accentGoldBright : WorthItColor.primaryContainer)
                .background(WorthItColor.surfaceContainerHigh, in: Capsule())

            HStack(spacing: 0) {
                fact(title: currentTitle, value: AchievementValueFormatter.text(current), highlighted: !isComplete)
                divider
                fact(title: neededTitle, value: AchievementValueFormatter.text(target), highlighted: false)
                divider
                fact(title: leftTitle, value: AchievementValueFormatter.text(remaining), highlighted: false)
            }
        }
        .padding(WorthItSpacing.xl)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(max(current / target, 0), 1)
    }

    private var isComplete: Bool {
        target > 0 && current >= target
    }

    private var progressSummary: String {
        "\(AchievementValueFormatter.text(current)) / \(AchievementValueFormatter.text(target))"
    }

    private var divider: some View {
        Rectangle()
            .fill(WorthItColor.outlineSubtle)
            .frame(width: 1, height: 28)
            .padding(.horizontal, WorthItSpacing.m)
    }

    private func fact(title: String, value: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(highlighted ? WorthItColor.primaryContainer : WorthItColor.textSecondary)

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(highlighted ? WorthItColor.primaryContainer : WorthItColor.textPrimary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
