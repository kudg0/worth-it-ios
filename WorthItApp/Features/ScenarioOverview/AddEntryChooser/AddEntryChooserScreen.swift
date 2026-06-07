import SwiftUI

struct AddEntryChooserScreen: View {
    let selectedEntryKind: Binding<ScenarioOverviewView.EntryKind>
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: WorthItSpacing.l) {
                entryOptionCard(
                    title: "Log Expense",
                    subtitle: "Record a completed cost: fuel, repairs, insurance, parts, wash, taxes, or one-off maintenance.",
                    systemName: "receipt",
                    kind: .expense
                )

                entryOptionCard(
                    title: "Schedule Service",
                    subtitle: "Plan upcoming service by date, mileage, or both, then track when it gets close.",
                    systemName: "wrench.fill",
                    kind: .service
                )
            }

            Spacer(minLength: 0)

            WIButton(title: "Continue", action: onContinue)
        }
        .frame(minHeight: 684, alignment: .top)
    }

    private func entryOptionCard(
        title: String,
        subtitle: String,
        systemName: String,
        kind: ScenarioOverviewView.EntryKind
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedEntryKind.wrappedValue = kind
            }
        } label: {
            WIOptionCard(
                title: title,
                subtitle: subtitle,
                systemIcon: systemName,
                state: selectedEntryKind.wrappedValue == kind ? .selected : .normal
            )
        }
        .buttonStyle(.plain)
    }
}
