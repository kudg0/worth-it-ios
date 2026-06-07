import SwiftUI

struct OverviewMetricHero: View {
    let metrics: [ScenarioOverviewView.MetricSlide]
    let selectedMetric: Binding<String>
    let selectedMetricId: String
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if metrics.isEmpty {
                OverviewMetricSlide(
                    metric: emptyMetric,
                    onOpenMetric: onOpenMetric
                )
            } else {
                TabView(selection: selectedMetric) {
                    ForEach(metrics) { metric in
                        OverviewMetricSlide(metric: metric, onOpenMetric: onOpenMetric)
                            .tag(metric.id.rawValue)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .frame(height: 210)

                pageDots
                    .padding(.top, WorthItSpacing.m)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, WorthItSpacing.xxxxl)
        .background { heroGlow }
    }

    private var emptyMetric: ScenarioOverviewView.MetricSlide {
        ScenarioOverviewView.MetricSlide(
            id: .monthlyCost,
            title: "Summary",
            value: "-",
            subtitle: nil,
            footer: "ADD USAGE OR COST DATA",
            footerIcon: "plus",
            footerColor: WorthItColor.textTertiary,
            progress: 0,
            accentColor: WorthItColor.textTertiary
        )
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(metrics) { metric in
                Circle()
                    .fill(selectedMetricId == metric.id.rawValue ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.28))
                    .frame(width: 5, height: 5)
            }
        }
        .opacity(metrics.count > 1 ? 1 : 0)
    }

    private var heroGlow: some View {
        GeometryReader { proxy in
            ZStack {
                Ellipse()
                    .fill(WorthItColor.primaryContainer.opacity(0.16))
                    .frame(width: proxy.size.width * 0.78, height: 190)
                    .blur(radius: 54)
                    .offset(x: -18, y: -16)

                Ellipse()
                    .fill(Color(hex: 0x2DD4BF).opacity(0.11))
                    .frame(width: proxy.size.width * 0.58, height: 168)
                    .blur(radius: 50)
                    .offset(x: proxy.size.width * 0.18, y: -30)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }
    }
}

private struct OverviewMetricSlide: View {
    let metric: ScenarioOverviewView.MetricSlide
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void

    var body: some View {
        Button {
            onOpenMetric(metric.id)
        } label: {
            VStack(spacing: 0) {
                Text(metric.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .padding(.bottom, WorthItSpacing.s)

                Text(metric.value)
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-3.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.48)

                if let footer = metric.footer {
                    ScenarioMetricPill(text: footer, iconName: metric.footerIcon, color: metric.footerColor)
                        .padding(.top, WorthItSpacing.m)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 210)
        }
        .buttonStyle(.plain)
    }
}
