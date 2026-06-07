import SwiftUI

struct GenericMetricHero: View {
    struct Model {
        let title: String
        let value: String
        let footer: String?
        let footerIcon: String
        let footerColor: Color
        let subtitle: String
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(model.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.5)
                .textCase(.uppercase)

            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                Text(model.value)
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-1.9)
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)

                if let footer = model.footer, footer != "NO PREVIOUS MONTH DATA" {
                    ScenarioMetricPill(text: footer, iconName: model.footerIcon, color: model.footerColor)
                        .padding(.bottom, 9)
                }
            }

            Text(model.subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.86))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
