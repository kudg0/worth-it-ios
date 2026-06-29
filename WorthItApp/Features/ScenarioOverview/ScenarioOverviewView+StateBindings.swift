import SwiftUI

extension ScenarioOverviewView {
    var activeScenario: ScenarioListItem {
        displayedScenario ?? scenario
    }

    var costPerKmFinancingBinding: Binding<Bool> {
        Binding(
            get: { costPerKmIncludesFinancing },
            set: { newValue in
                withAnimation(.easeInOut(duration: 0.18)) {
                    costPerKmIncludesFinancing = newValue
                    selectedEfficiencyChartDate = nil
                    selectedMetricTrendDate = nil
                }
            }
        )
    }
}
