import SwiftUI

extension ScenarioOverviewView {
    var activeScenario: ScenarioListItem {
        displayedScenario ?? scenario
    }

    var hasActionError: Binding<Bool> {
        Binding(
            get: { actionError != nil },
            set: { isPresented in
                if !isPresented {
                    actionError = nil
                }
            }
        )
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
