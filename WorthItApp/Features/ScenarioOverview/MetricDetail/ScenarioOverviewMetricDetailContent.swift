import SwiftUI

extension ScenarioOverviewView {
    var metricDetailContent: some View {
        let metric = selectedDetailMetricSlide ?? availableMetrics.first

        return Group {
            if selectedDetailMetric == .costPerKm {
                CostPerKmDetailScreen(model: costPerKmDetailModel(metric))
            } else {
                GenericMetricDetailScreen(model: genericMetricDetailModel(metric))
            }
        }
    }
}
