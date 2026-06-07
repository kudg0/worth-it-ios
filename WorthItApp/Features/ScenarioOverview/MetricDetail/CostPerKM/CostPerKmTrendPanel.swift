import SwiftUI

struct CostPerKmTrendPanel: View {
    struct Model {
        let rangeLabel: String
        let chart: AnyView
        let showsRangeToggle: Bool
        let selectedRange: Binding<ScenarioOverviewView.MetricTrendRange>
        let onMovePeriod: (ScenarioOverviewView.MetricTrendSwipeDirection) -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            Text("Efficiency trend")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)

            HStack(alignment: .center, spacing: WorthItSpacing.l) {
                HStack(spacing: WorthItSpacing.s) {
                    periodArrow(systemName: "chevron.left", direction: .older)

                    Text(model.rangeLabel)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    periodArrow(systemName: "chevron.right", direction: .newer)
                }
                .contentShape(Rectangle())
                .highPriorityGesture(swipeGesture)

                Spacer()

                if model.showsRangeToggle {
                    HStack(spacing: WorthItSpacing.m) {
                        rangePill("Month", range: .oneYear)
                        rangePill("Year", range: .all)
                    }
                }
            }

            model.chart
        }
        .padding(WorthItSpacing.xl)
        .background(WorthItColor.pageBackground, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.surfaceContainerLow, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.22), radius: 15, y: 4)
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > 44, abs(horizontal) > abs(vertical) * 1.2 else { return }

                withAnimation(.easeInOut(duration: 0.18)) {
                    model.onMovePeriod(horizontal < 0 ? .newer : .older)
                }
            }
    }

    private func periodArrow(systemName: String, direction: ScenarioOverviewView.MetricTrendSwipeDirection) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.onMovePeriod(direction)
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 24, height: 24)
                .background(WorthItColor.surfaceContainerLow.opacity(0.82), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(direction == .older ? "Previous period" : "Next period")
    }

    private func rangePill(_ title: String, range: ScenarioOverviewView.MetricTrendRange) -> some View {
        let selected = model.selectedRange.wrappedValue == range

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.selectedRange.wrappedValue = range
            }
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(selected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                .padding(.horizontal, WorthItSpacing.s)
                .frame(height: 24)
                .background(selected ? WorthItColor.surfaceContainerHigh : Color.clear, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
        }
        .buttonStyle(.plain)
    }
}
