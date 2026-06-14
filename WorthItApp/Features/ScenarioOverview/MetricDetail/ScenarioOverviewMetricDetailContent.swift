import SwiftUI

extension ScenarioOverviewView {
    var metricDetailContent: some View {
        let metric = selectedDetailMetricSlide ?? availableMetrics.first

        return Group {
            if isLoadingMetricDetail {
                BackendMetricDetailLoadingView()
            } else {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
                    metricSpecificDetail(metric)

                    if let selectedDetailMetricPayload {
                        BackendMetricBreakdownView(payload: selectedDetailMetricPayload)
                    } else if let metricDetailError {
                        BackendMetricDetailErrorView(message: friendlyMetricDetailError(metricDetailError)) {
                            Task { await loadSelectedMetricDetail() }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func metricSpecificDetail(_ metric: MetricSlide?) -> some View {
        if selectedDetailMetric == .paybackDistance {
            BreakEvenDetailScreen(model: breakEvenDetailModel)
        } else if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            CostPerKmDetailScreen(model: costPerKmDetailModel(metric))
        } else {
            GenericMetricDetailScreen(model: genericMetricDetailModel(metric))
        }
    }

    func friendlyMetricDetailError(_ rawError: String) -> String {
        if rawError.contains("NSURLErrorDomain Code=-1004") || rawError.contains("Could not connect to the server") {
            return "Backend analytics is unavailable. Start the local API server and retry."
        }

        if rawError.contains("statusCode: 404") {
            return "Backend analytics endpoint is not available in the running API server. Restart the API server and retry."
        }

        return "Backend analytics could not be loaded. Retry in a moment."
    }
}
