import SwiftUI

struct ScenarioOverviewScreen: View {
    let metrics: [ScenarioOverviewView.MetricSlide]
    let selectedMetric: Binding<String>
    let selectedMetricId: String
    let showsEfficiencyCard: Bool
    let efficiencyModel: CostPerKmEfficiencyCard.Model
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onAddExpense: () -> Void
    let onOpenUsage: () -> Void
    let onOpenCompare: () -> Void

    var body: some View {
        OverviewMetricHero(
            metrics: metrics,
            selectedMetric: selectedMetric,
            selectedMetricId: selectedMetricId,
            onOpenMetric: onOpenMetric
        )

        OverviewQuickActions(
            onAddExpense: onAddExpense,
            onOpenUsage: onOpenUsage,
            onOpenCompare: onOpenCompare
        )

        if showsEfficiencyCard {
            CostPerKmEfficiencyCard(model: efficiencyModel) {
                onOpenMetric(.costPerKm)
            }
        }

        OverviewMetricsGrid(metrics: metrics, onOpenMetric: onOpenMetric)
    }
}
