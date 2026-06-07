import SwiftUI

struct ExpenseHistoryHero: View {
    struct Model {
        let title: String
        let total: String
        let delta: String?
        let iconName: String
        let subtitle: String
        let isFiltered: Bool
        let miniBars: AnyView
        let onReset: () -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            header
            model.miniBars
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { background }
        .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            HStack(alignment: .center) {
                Text("\(model.title) spend")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.6)
                    .textCase(.uppercase)

                Spacer(minLength: WorthItSpacing.m)

                if model.isFiltered {
                    Button(action: model.onReset) {
                        Text("Reset")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WorthItColor.primaryContainer)
                            .padding(.horizontal, WorthItSpacing.m)
                            .frame(height: 26)
                            .background(WorthItColor.primaryContainer.opacity(0.10), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                Text(model.total)
                    .font(.system(size: 46, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-1.4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.54)

                if let delta = model.delta {
                    Text(delta)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.bottom, 5)
                }
            }

            HStack(spacing: WorthItSpacing.s) {
                Image(systemName: model.iconName)
                    .font(.system(size: 10, weight: .bold))

                Text(model.subtitle)
                    .font(.system(size: 13, weight: .regular))
            }
            .foregroundStyle(WorthItColor.textSecondary)
        }
    }

    private var background: some View {
        ZStack(alignment: .topTrailing) {
            WorthItColor.surfaceMetric

            Ellipse()
                .fill(WorthItColor.primaryContainer.opacity(0.13))
                .frame(width: 230, height: 180)
                .blur(radius: 46)
                .offset(x: 44, y: -48)
        }
    }
}
