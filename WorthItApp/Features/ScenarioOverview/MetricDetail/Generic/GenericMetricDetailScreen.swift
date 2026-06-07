import SwiftUI

struct GenericMetricDetailScreen: View {
    struct Model {
        let hero: GenericMetricHero.Model
        let chart: GenericMetricChartPanel.Model
        let insights: GenericMetricInsightGrid.Model
        let recommendation: GenericMetricRecommendation.Model
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            GenericMetricHero(model: model.hero)
            GenericMetricChartPanel(model: model.chart)
            GenericMetricInsightGrid(model: model.insights)
            GenericMetricRecommendation(model: model.recommendation)
        }
    }
}
