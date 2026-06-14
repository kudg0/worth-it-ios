import SwiftUI

struct BackendMetricDetailScreen: View {
    let payload: ScenarioAnalyticsMetricPayload
    let fallbackMetric: ScenarioOverviewView.MetricSlide?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            hero

            if let summaries = payload.detail?.summary, !summaries.isEmpty {
                BackendMetricDetailSections.SummaryIsland(summaries: summaries)
            }

            ForEach(payload.detail?.sections ?? []) { section in
                BackendMetricDetailSections.SectionIsland(section: section)
            }
        }
    }

    private var hero: some View {
        WIIsland(title: payload.card?.title ?? fallbackMetric?.title ?? payload.metricId.rawValue, systemIcon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                Text(payload.card?.value ?? fallbackMetric?.value ?? "-")
                    .font(.system(size: 52, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                if let footer = payload.card?.trend?.label ?? payload.card?.footer ?? fallbackMetric?.footer {
                    Text(footer)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(1.1)
                        .textCase(.uppercase)
                }

                if !payload.availability.isAvailable, let reason = payload.availability.reason {
                    Text(reason)
                        .font(WorthItTypography.caption)
                        .foregroundStyle(WorthItColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

}

enum BackendMetricDetailSections {
    struct SummaryIsland: View {
        let summaries: [ScenarioAnalyticsMetricPayload.Detail.Summary]

        var body: some View {
            WIIsland(title: i18n.t("Backend Breakdown"), systemIcon: "sum") {
                VStack(spacing: WorthItSpacing.l) {
                    ForEach(summaries) { item in
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.title)
                                .font(WorthItTypography.caption)
                                .foregroundStyle(WorthItColor.textSecondary)
                            Spacer(minLength: WorthItSpacing.l)
                            Text(item.value)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(WorthItColor.textPrimary)
                        }
                    }
                }
            }
        }
    }

    struct SectionIsland: View {
        let section: ScenarioAnalyticsMetricPayload.Detail.Section

        var body: some View {
            WIIsland(title: section.title, systemIcon: "list.bullet.rectangle") {
                sectionContent
            }
        }

        private var sectionContent: some View {
            VStack(spacing: WorthItSpacing.l) {
                if let subtitle = section.subtitle {
                    Text(subtitle)
                        .font(WorthItTypography.caption)
                        .foregroundStyle(WorthItColor.textTertiary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let total = section.total {
                    HStack {
                        Text("Total")
                            .font(WorthItTypography.caption)
                            .foregroundStyle(WorthItColor.textSecondary)
                        Spacer()
                        Text(total.value)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)
                    }
                }

                ForEach(section.items) { item in
                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.title.capitalized)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(WorthItColor.textPrimary)
                            Spacer(minLength: WorthItSpacing.l)
                            if let value = item.value {
                                Text(value)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(WorthItColor.textPrimary)
                            }
                        }

                        if let subtitle = item.subtitle {
                            Text(subtitle)
                                .font(WorthItTypography.caption)
                                .foregroundStyle(WorthItColor.textTertiary)
                                .lineLimit(2)
                        }

                        if let status = item.status {
                            Text(status)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(WorthItColor.textSecondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
    }
}

struct BackendMetricDetailLoadingView: View {
    var body: some View {
        WIIsland(title: i18n.t("Loading Metric"), systemIcon: "arrow.triangle.2.circlepath") {
            HStack(spacing: WorthItSpacing.l) {
                ProgressView()
                Text("Fetching backend analytics")
                    .font(WorthItTypography.caption)
                    .foregroundStyle(WorthItColor.textSecondary)
            }
        }
    }
}

struct BackendMetricDetailErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        WIIsland(title: i18n.t("Backend Metric"), systemIcon: "exclamationmark.triangle") {
            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                Text(message)
                    .font(WorthItTypography.caption)
                    .foregroundStyle(WorthItColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onRetry) {
                    HStack(spacing: WorthItSpacing.s) {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .padding(.horizontal, WorthItSpacing.l)
                    .frame(height: 36)
                    .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct BackendMetricBreakdownView: View {
    let payload: ScenarioAnalyticsMetricPayload

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            if let summaries = payload.detail?.summary, !summaries.isEmpty {
                BackendMetricDetailSections.SummaryIsland(summaries: summaries)
            }

            ForEach(payload.detail?.sections ?? []) { section in
                BackendMetricDetailSections.SectionIsland(section: section)
            }
        }
    }
}
