import SwiftUI

struct CostPerKmSourceTimeline: View {
    struct Model {
        let periodTitle: String
        let sources: [ScenarioOverviewView.CostPerKmBreakdownSource]
        let onOpenSource: (ScenarioOverviewView.CostPerKmBreakdownSource) -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            Text("Source timeline: \(model.periodTitle)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.1)
                .textCase(.uppercase)

            if model.sources.isEmpty {
                Text("No source entries found for this period.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(WorthItSpacing.l)
                    .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(model.sources) { source in
                        WIInfoListRow(
                            title: source.title,
                            subtitle: source.subtitle,
                            value: source.value,
                            detail: source.status,
                            systemIcon: source.systemName,
                            accentColor: source.accentColor,
                            detailColor: source.accentColor,
                            action: source.target == nil ? nil : { model.onOpenSource(source) }
                        )
                    }
                }
            }
        }
    }
}
