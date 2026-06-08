import SwiftUI

struct CostPerKmDetailHero: View {
    struct Model {
        let periodTitle: String
        let value: String
        let mileageUnit: String
        let isProjected: Bool
        let trend: ScenarioOverviewView.MetricTrend?
        let fallbackTrend: ScenarioOverviewView.MetricTrend?
    }

    let model: Model

    var body: some View {
        VStack(alignment: .center, spacing: WorthItSpacing.s) {
            Text(model.periodTitle)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)

            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.xs) {
                Text(model.value)
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(model.isProjected ? WorthItColor.projectedBlue : WorthItColor.primaryContainer)
                    .tracking(-1.2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .shadow(color: (model.isProjected ? WorthItColor.projectedBlue : WorthItColor.primaryContainer).opacity(0.28), radius: 8)

                Text("/ \(model.mileageUnit)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .padding(.bottom, 7)
            }

            if let trend = model.trend ?? model.fallbackTrend {
                ScenarioMetricPill(text: trend.label, iconName: trend.iconName, color: trend.color)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
