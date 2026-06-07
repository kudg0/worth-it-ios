import SwiftUI

struct ExpenseHero: View {
    struct Model {
        let monthName: String
        let total: String
        let trend: ScenarioOverviewView.MetricTrend
        let onOpenHistory: () -> Void
    }

    let model: Model

    var body: some View {
        Button(action: model.onOpenHistory) {
            VStack(spacing: WorthItSpacing.l) {
                VStack(spacing: WorthItSpacing.xs) {
                    Text("TOTAL SPENT • \(model.monthName.uppercased())")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                        .tracking(2.5)
                        .textCase(.uppercase)

                    Text(model.total)
                        .font(.system(size: 60, weight: .heavy))
                        .foregroundStyle(.white)
                        .tracking(-3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 25)
                }

                ScenarioMetricPill(
                    text: model.trend.label,
                    iconName: model.trend.iconName,
                    color: model.trend.color
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, WorthItSpacing.l)
            .background { ExpenseHeroGlow() }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open expense history")
    }
}

private struct ExpenseHeroGlow: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Ellipse()
                    .fill(WorthItColor.primaryContainer.opacity(0.12))
                    .frame(width: proxy.size.width * 0.78, height: 176)
                    .blur(radius: 54)
                    .offset(x: -18, y: -20)

                Ellipse()
                    .fill(Color(hex: 0x2DD4BF).opacity(0.08))
                    .frame(width: proxy.size.width * 0.58, height: 148)
                    .blur(radius: 50)
                    .offset(x: proxy.size.width * 0.18, y: -34)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .allowsHitTesting(false)
        }
    }
}
