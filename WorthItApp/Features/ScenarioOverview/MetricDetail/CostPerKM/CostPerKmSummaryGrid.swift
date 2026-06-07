import SwiftUI

struct CostPerKmSummaryGrid: View {
    struct Model {
        let cost: Stat
        let distance: Stat
    }

    struct Stat {
        let title: String
        let value: String
        let unit: String?
        let subtitle: String
        let systemName: String
        let accentColor: Color
        let progress: CGFloat
        let action: () -> Void
    }

    let model: Model

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: WorthItSpacing.l),
                GridItem(.flexible(), spacing: WorthItSpacing.l),
            ],
            spacing: WorthItSpacing.l
        ) {
            CostPerKmBreakdownStatCard(stat: model.cost)
            CostPerKmBreakdownStatCard(stat: model.distance)
        }
    }
}

private struct CostPerKmBreakdownStatCard: View {
    let stat: CostPerKmSummaryGrid.Stat

    var body: some View {
        Button(action: stat.action) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: stat.systemName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(stat.accentColor)

                    Text(stat.title)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.xs) {
                    Text(stat.value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if let unit = stat.unit {
                        Text(unit)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(WorthItColor.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(WorthItColor.surfaceContainerHigh)
                        Capsule()
                            .fill(stat.accentColor)
                            .frame(width: max(4, proxy.size.width * stat.progress))
                    }
                }
                .frame(height: 5)

                Text(stat.subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, minHeight: 133, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
