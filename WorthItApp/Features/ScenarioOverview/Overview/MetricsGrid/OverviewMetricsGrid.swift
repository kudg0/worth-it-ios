import SwiftUI

struct OverviewMetricsGrid: View {
    let metrics: [ScenarioOverviewView.MetricSlide]
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: WorthItSpacing.l),
                GridItem(.flexible(), spacing: WorthItSpacing.l)
            ],
            spacing: WorthItSpacing.l
        ) {
            ForEach(metrics) { metric in
                OverviewMetricTile(metric: metric, onOpenMetric: onOpenMetric)
            }
        }
    }
}

private struct OverviewMetricTile: View {
    let metric: ScenarioOverviewView.MetricSlide
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void

    var body: some View {
        Button {
            onOpenMetric(metric.id)
        } label: {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(metric.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(metric.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let subtitle = metric.subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(0.6)
                        .lineLimit(1)
                        .textCase(.uppercase)
                }

                progressBar
                    .padding(.top, WorthItSpacing.s)
            }
            .padding(WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 108, maxHeight: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(WorthItColor.outlineInput.opacity(0.35))
                Capsule()
                    .fill(metric.accentColor)
                    .frame(width: proxy.size.width * metric.progress)
            }
        }
        .frame(height: 4)
    }
}
