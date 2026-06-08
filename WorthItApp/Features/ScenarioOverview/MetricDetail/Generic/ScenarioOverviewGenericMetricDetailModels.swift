import SwiftUI

extension ScenarioOverviewView {
    func genericMetricDetailModel(_ metric: MetricSlide?) -> GenericMetricDetailScreen.Model {
        let selectedReadout = selectedMetricTrendPoint.map(metricTrendPointValueLabel)
        let selectedAxisLabel = selectedMetricTrendPoint.map { metricTrendAxisLabel(for: $0.date) }

        return GenericMetricDetailScreen.Model(
            hero: GenericMetricHero.Model(
                title: metric?.title ?? "Metric",
                value: metric?.value ?? "—",
                footer: metric?.footer,
                footerIcon: metric?.footerIcon ?? "minus",
                footerColor: metric?.footerColor ?? WorthItColor.textTertiary,
                subtitle: metricDetailSubtitle
            ),
            chart: GenericMetricChartPanel.Model(
                title: metricTrendTitle,
                selectedRange: metricTrendRangeBinding,
                selectedReadout: selectedReadout,
                selectedAxisLabel: selectedAxisLabel,
                chart: AnyView(metricTrendChart(
                    metric: metric,
                    height: 178,
                    xValueName: "Month",
                    selectedRuleName: "Selected month",
                    selectedValueName: "Selected value",
                    selectedSymbolSize: 72,
                    areaOpacity: 0.24
                ))
            ),
            insights: GenericMetricInsightGrid.Model(
                wideTitle: metricInsightWideTitle,
                seasonalText: metricSeasonalText,
                volatilityValue: metricVolatilityValue,
                actionValue: metricActionValue,
                missingDataText: metricMissingDataText
            ),
            recommendation: GenericMetricRecommendation.Model(
                text: metricRecommendationText,
                onGenerateFullAppraisal: {
                    actionError = "Full appraisal generation is coming next."
                }
            )
        )
    }
}
