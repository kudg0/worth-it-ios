import SwiftUI

struct ExpenseSpendMiniBars: View {
    let bars: [ScenarioOverviewView.ExpenseHistoryBar]
    let selectedBar: ScenarioOverviewView.ExpenseHistoryBar
    let maxLabel: String
    let zeroLabel: String
    let valueLabel: (ScenarioOverviewView.ExpenseHistoryBar) -> String
    let height: (ScenarioOverviewView.ExpenseHistoryBar, CGFloat) -> CGFloat
    let accessibilityValue: (ScenarioOverviewView.ExpenseHistoryBar) -> String
    let onSelect: (ScenarioOverviewView.ExpenseHistoryBar) -> Void

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
        .frame(width: 34, height: 96)
    }

    private var barsArea: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                gridLines

                HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                    ForEach(bars) { bar in
                        ExpenseSpendMiniBar(
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
            Text("Spend")
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
        .padding(.leading, 34 + WorthItSpacing.m)
    }
}

private struct ExpenseSpendMiniBar: View {
    let bar: ScenarioOverviewView.ExpenseHistoryBar
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
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .fill(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainerHigh.opacity(0.48))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)

                Text(bar.label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(bar.label) spend")
        .accessibilityValue(accessibilityValue)
    }
}
