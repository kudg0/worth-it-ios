import SwiftUI

struct CostPerKmRangePill: View {
    let selection: Binding<ScenarioOverviewView.ChartRange>
    let selectedDate: Binding<Date?>

    var body: some View {
        HStack(spacing: WorthItSpacing.xs) {
            segment(title: i18n.t("Day"), value: .day)
            segment(title: i18n.t("Week"), value: .week)
            segment(title: i18n.t("Month"), value: .month)
        }
        .padding(WorthItSpacing.xs)
        .background(WorthItColor.surfaceLowest, in: Capsule())
        .fixedSize(horizontal: true, vertical: false)
        .layoutPriority(2)
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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, WorthItSpacing.s)
                .frame(height: 20)
                .background(selection.wrappedValue == value ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
