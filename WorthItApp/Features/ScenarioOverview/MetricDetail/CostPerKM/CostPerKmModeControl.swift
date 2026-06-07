import SwiftUI

struct CostPerKmModeControl: View {
    let mode: Binding<ScenarioOverviewView.CostPerKmMode>
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            WISegmentedControl(
                items: [
                    (title: ScenarioOverviewView.CostPerKmMode.effective.title, value: ScenarioOverviewView.CostPerKmMode.effective),
                    (title: ScenarioOverviewView.CostPerKmMode.period.title, value: ScenarioOverviewView.CostPerKmMode.period),
                ],
                selection: mode
            )

            Text(description)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
