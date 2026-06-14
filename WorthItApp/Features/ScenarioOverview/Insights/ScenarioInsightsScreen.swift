import SwiftUI

struct ScenarioInsightsScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: i18n.t("Insights"))

            WITipInfo(
                title: i18n.t("Coming next"),
                bodyText: i18n.t("This area will summarize ownership patterns, anomalies, and smart recommendations."),
                size: .medium,
                tone: .info
            )
        }
    }
}
