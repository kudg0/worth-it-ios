import SwiftUI

extension ScenarioOverviewView {
    var metricDetailContent: some View {
        let metric = selectedDetailMetricSlide ?? availableMetrics.first

        return Group {
            if selectedDetailMetric == .paybackDistance {
                BreakEvenDetailScreen(model: breakEvenDetailModel)
            } else if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
                CostPerKmDetailScreen(model: costPerKmDetailModel(metric))
            } else {
                GenericMetricDetailScreen(model: genericMetricDetailModel(metric))
            }
        }
    }
}
