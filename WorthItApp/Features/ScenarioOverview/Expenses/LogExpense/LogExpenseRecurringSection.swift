import SwiftUI

struct LogExpenseRecurringSection: View {
    let isRecurring: Binding<Bool>
    let subtitle: String
    let frequency: Binding<ScenarioOverviewView.RecurringFrequency>
    let startDate: Binding<Date?>
    let endDate: Binding<Date?>

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
                .padding(.bottom, WorthItSpacing.l)

            VStack(spacing: isRecurring.wrappedValue ? WorthItSpacing.xxl : 0) {
                header

                if isRecurring.wrappedValue {
                    controls
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(isRecurring.wrappedValue ? WorthItSpacing.xl : 0)
            .background { expandedBackground }
        }
    }

    private var header: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 40, height: 40)
                .background(Color(hex: 0x3A4666), in: Circle())

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("Recurring Cost")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
            }

            Spacer()

            Toggle("", isOn: isRecurring)
                .labelsHidden()
                .tint(WorthItColor.primaryContainer)
        }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text("Frequency")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.5)
                    .textCase(.uppercase)

                WISegmentedControl(
                    items: ScenarioOverviewView.RecurringFrequency.allCases.map { (title: $0.title, value: $0) },
                    selection: frequency
                )
            }

            HStack(alignment: .top, spacing: WorthItSpacing.m) {
                WIDateField(label: "Start Date", placeholder: "Today", date: startDate)
                    .frame(maxWidth: .infinity)

                WIDateField(label: "End Date", placeholder: "Optional", date: endDate)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var expandedBackground: some View {
        if isRecurring.wrappedValue {
            WorthItColor.surfaceContainerLow
                .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                        .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.18), radius: 18, y: 10)
        }
    }
}
