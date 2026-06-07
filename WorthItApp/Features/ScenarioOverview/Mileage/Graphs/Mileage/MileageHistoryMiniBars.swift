import SwiftUI

struct MileageHistoryMiniBars: View {
    let bars: [ScenarioOverviewView.MileageHistoryBar]
    let selectedBar: ScenarioOverviewView.MileageHistoryBar
    let maxLabel: String
    let zeroLabel: String
    let valueLabel: (ScenarioOverviewView.MileageHistoryBar) -> String
    let height: (ScenarioOverviewView.MileageHistoryBar, CGFloat) -> CGFloat
    let accessibilityValue: (ScenarioOverviewView.MileageHistoryBar) -> String
    let onSelect: (ScenarioOverviewView.MileageHistoryBar) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                axisLabels
                barsArea
            }

            footer
        }
    }

    private var axisLabels: some View {
        VStack(alignment: .trailing) {
            Text("Max \(maxLabel)")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)

            Spacer()

            Text(zeroLabel)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
        }
        .frame(width: 44, height: 96)
    }

    private var barsArea: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                gridLines

                HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                    ForEach(bars) { bar in
                        MileageHistoryMiniBar(
                            bar: bar,
                            isSelected: bar.selectionId == selectedBar.selectionId,
                            height: height(bar, proxy.size.height - 32),
                            valueLabel: valueLabel(bar),
                            accessibilityValue: accessibilityValue(bar),
                            onSelect: { onSelect(bar) }
                        )
                    }
                }
            }
        }
        .frame(height: 96)
    }

    private var gridLines: some View {
        VStack {
            Rectangle()
                .fill(WorthItColor.outlineSubtle.opacity(0.55))
                .frame(height: 1)

            Spacer()

            Rectangle()
                .fill(WorthItColor.outlineSubtle.opacity(0.55))
                .frame(height: 1)
        }
    }

    private var footer: some View {
        HStack {
            Text("Mileage")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.9)
                .textCase(.uppercase)

            Spacer()

            Text("Month")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.9)
                .textCase(.uppercase)
        }
        .padding(.leading, 44 + WorthItSpacing.m)
    }
}

private struct MileageHistoryMiniBar: View {
    let bar: ScenarioOverviewView.MileageHistoryBar
    let isSelected: Bool
    let height: CGFloat
    let valueLabel: String
    let accessibilityValue: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: WorthItSpacing.xs) {
                Text(isSelected ? valueLabel : " ")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(WorthItColor.accentGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .fill(isSelected ? WorthItColor.accentGold : WorthItColor.surfaceContainerHigh.opacity(0.48))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)

                Text(bar.label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.accentGold : WorthItColor.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(bar.label) mileage")
        .accessibilityValue(accessibilityValue)
    }
}
