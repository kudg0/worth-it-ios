import SwiftUI

struct ScenarioCompareScreen: View {
    let selectedMetric: Binding<ScenarioOverviewView.CompareMetric>
    let onAddComparable: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: "Compare")

            VStack(spacing: WorthItSpacing.xxl) {
                metricPills
                emptyVisual
                emptyCopy

                WIButton(title: "Add Comparable Option", height: 56, action: onAddComparable)
            }
        }
    }

    private var metricPills: some View {
        HStack(spacing: WorthItSpacing.s) {
            ForEach(ScenarioOverviewView.CompareMetric.allCases) { metric in
                metricPill(metric)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyCopy: some View {
        VStack(spacing: WorthItSpacing.m) {
            Text("No comparable options yet")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-0.6)
                .multilineTextAlignment(.center)

            Text("Add taxi, car sharing, rental, or public transport to compare your ownership performance.")
                .font(WorthItTypography.bodySmall)
                .lineSpacing(4)
                .foregroundStyle(WorthItColor.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 306)
        }
        .frame(maxWidth: .infinity)
    }

    private func metricPill(_ metric: ScenarioOverviewView.CompareMetric) -> some View {
        let isSelected = selectedMetric.wrappedValue == metric

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedMetric.wrappedValue = metric
            }
        } label: {
            HStack(spacing: WorthItSpacing.s) {
                if isSelected {
                    Circle()
                        .fill(Color(hex: 0x385283))
                        .frame(width: 6, height: 6)
                }

                Text(metric.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(height: 34)
            .background(isSelected ? WorthItColor.primaryContainer : Color(hex: 0x3A4666), in: Capsule())
            .overlay {
                Capsule().stroke(isSelected ? Color.clear : Color(hex: 0x44474F), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(metric.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var emptyVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: WorthItRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            WorthItColor.surfaceContainerLow.opacity(0.70),
                            WorthItColor.surfaceLowest.opacity(0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: WorthItRadius.xl)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)

            VStack(spacing: 0) {
                Spacer()
                centerLine
                bottomTicks
            }

            LinearGradient(
                colors: [
                    WorthItColor.surfaceLowest.opacity(0.08),
                    WorthItColor.surfaceLowest.opacity(0.56)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xl))
        }
        .frame(height: 256)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var centerLine: some View {
        ZStack {
            Rectangle()
                .fill(WorthItColor.primaryContainer.opacity(0.14))
                .frame(height: 1)

            Circle()
                .fill(WorthItColor.primaryContainer)
                .frame(width: 4, height: 4)
                .shadow(color: WorthItColor.primaryContainer.opacity(0.90), radius: 8)
        }
        .padding(.horizontal, WorthItSpacing.xxxxl)
        .padding(.bottom, WorthItSpacing.xxl)
    }

    private var bottomTicks: some View {
        HStack(spacing: 28) {
            ForEach(0..<4, id: \.self) { _ in
                Capsule()
                    .fill(WorthItColor.surfaceContainerHigh.opacity(0.92))
                    .frame(width: 48, height: 4)
            }
        }
        .padding(.bottom, WorthItSpacing.xxxl)
    }
}
