import SwiftUI

struct CostPerKmRangePill: View {
    let selection: Binding<ScenarioOverviewView.ChartRange>
    let selectedDate: Binding<Date?>

    var body: some View {
        HStack(spacing: WorthItSpacing.xs) {
            segment(title: "Day", value: .day)
            segment(title: "Week", value: .week)
            segment(title: "Month", value: .month)
        }
        .padding(WorthItSpacing.xs)
        .background(WorthItColor.surfaceLowest, in: Capsule())
    }

    private func segment(title: String, value: ScenarioOverviewView.ChartRange) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selection.wrappedValue = value
                selectedDate.wrappedValue = nil
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(selection.wrappedValue == value ? Color(hex: 0x385283) : WorthItColor.textPrimary)
                .padding(.horizontal, 10)
                .frame(height: 20)
                .background(selection.wrappedValue == value ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
