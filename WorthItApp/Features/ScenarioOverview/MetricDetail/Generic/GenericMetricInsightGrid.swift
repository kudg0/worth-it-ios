import SwiftUI

struct GenericMetricInsightGrid: View {
    struct Model {
        let seasonalText: String
        let volatilityValue: String
        let actionValue: String
        let missingDataText: String
    }

    let model: Model

    var body: some View {
        VStack(spacing: WorthItSpacing.l) {
            wideInsight

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: WorthItSpacing.l),
                    GridItem(.flexible(), spacing: WorthItSpacing.l),
                ],
                spacing: WorthItSpacing.l
            ) {
                smallInsight(
                    title: "Volatility Score",
                    value: model.volatilityValue,
                    body: "Stable enough for planning, but improves as more real entries are logged.",
                    systemName: "chart.xyaxis.line"
                )

                smallInsight(
                    title: "Action required",
                    value: model.actionValue,
                    body: model.missingDataText,
                    systemName: "exclamationmark.triangle.fill",
                    isDanger: true
                )
            }
        }
    }

    private var wideInsight: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            Image(systemName: "sparkles")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(WorthItColor.accentGold)
                .frame(width: 32, height: 32)
                .background(WorthItColor.accentGold.opacity(0.14), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text("Seasonal Adjustment")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(model.seasonalText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func smallInsight(title: String, value: String, body: String, systemName: String, isDanger: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isDanger ? WorthItColor.danger : WorthItColor.primaryContainer)

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isDanger ? WorthItColor.danger : WorthItColor.textPrimary)
                .textCase(isDanger ? .uppercase : nil)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(isDanger ? WorthItColor.danger : WorthItColor.primaryContainer)

            Text(body)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            if isDanger {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.danger.opacity(0.10), lineWidth: 1)
            }
        }
    }
}
