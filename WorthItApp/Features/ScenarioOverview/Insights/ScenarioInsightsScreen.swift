import SwiftUI

struct ScenarioInsightsScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: "Insights")

            WITipInfo(
                title: "Coming next",
                bodyText: "This area will summarize ownership patterns, anomalies, and smart recommendations.",
                size: .medium,
                tone: .info
            )
        }
    }
}
