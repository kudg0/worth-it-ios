import SwiftUI

struct WIScenarioMetric: Hashable {
    let label: String
    let value: String
}

struct WIScenarioCard: View {
    enum Mode {
        case filled
        case create
    }

    var mode: Mode = .filled
    var title: String
    var subtitle: String = "Car Ownership"
    var iconSystemName: String = "car.fill"
    var metric1: WIScenarioMetric?
    var metric2: WIScenarioMetric?

    var body: some View {
        switch mode {
        case .filled:
            filledBody
        case .create:
            createBody
        }
    }

    private var filledBody: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 48, height: 48)
                    .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(subtitle)
                        .font(WorthItTypography.overline)
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(1)
                        .textCase(.uppercase)
                        .lineLimit(1)

                    Text(title)
                        .font(WorthItTypography.cardTitle)
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(2)
                }

                Spacer(minLength: WorthItSpacing.s)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .padding(.top, WorthItSpacing.xs)
            }

            HStack(spacing: WorthItSpacing.m) {
                metricTile(metric1 ?? WIScenarioMetric(label: "Cost / KM", value: "—"))
                metricTile(metric2 ?? WIScenarioMetric(label: "Monthly", value: "—"))
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
        .shadow(color: WorthItColor.primaryContainer.opacity(0.05), radius: 10)
    }

    private var createBody: some View {
        VStack(spacing: WorthItSpacing.m) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 40, height: 40)
                .background(WorthItColor.surfaceContainerHigh, in: Circle())

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(1.2)
                .textCase(.uppercase)
        }
        .padding(WorthItSpacing.xxxxl)
        .frame(maxWidth: .infinity, minHeight: 132)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.textTertiary.opacity(0.20), lineWidth: 1)
        }
    }

    private func metricTile(_ metric: WIScenarioMetric) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            Text(metric.label)
                .font(WorthItTypography.overline)
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.5)
                .textCase(.uppercase)
                .lineLimit(1)

            Text(metric.value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 73, alignment: .leading)
        .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.s)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}
