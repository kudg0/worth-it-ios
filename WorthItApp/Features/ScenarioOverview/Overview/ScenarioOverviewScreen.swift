import SwiftUI

struct ScenarioOverviewScreen: View {
    let metrics: [ScenarioOverviewView.MetricSlide]
    let hiddenMetrics: [ScenarioOverviewView.MetricSlide]
    let selectedMetric: Binding<String>
    let selectedMetricId: String
    let editorInteraction: Binding<OverviewMetricEditorInteractionState>
    let showsEfficiencyCard: Bool
    let efficiencyModel: CostPerKmEfficiencyCard.Model
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onMoveMetric: (ScenarioOverviewView.OverviewMetric, ScenarioOverviewView.OverviewMetric) -> Void
    let onHideMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onShowMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onResetMetricsLayout: () -> Void
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

        OverviewMetricsGrid(
            metrics: metrics,
            hiddenMetrics: hiddenMetrics,
            onOpenMetric: onOpenMetric,
            onMoveMetric: onMoveMetric,
            onHideMetric: onHideMetric,
            onShowMetric: onShowMetric,
            onResetLayout: onResetMetricsLayout,
            editorInteraction: editorInteraction
        )
    }
}
