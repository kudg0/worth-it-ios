import SwiftUI

struct MileageTripDetailScreen: View {
    struct ComparableCost: Identifiable, Hashable {
        let id: UUID
        let name: String
        let iconSystemName: String
        let durationText: String
        let costValue: Double
        let costText: String
        let deltaText: String
        let isCheaper: Bool
        let detailLines: [String]
    }

    struct Model {
        let title: String
        let estimatedCostText: String
        let distanceText: String
        let costPerDistanceText: String
        let costPerDistanceSourceText: String
        let unitText: String
        let dateTimeText: String
        let notesText: String
        let periodLabel: String
        let confidenceLevel: String
        let confidenceSource: String
        let dataSource: String
        let comparableCosts: [ComparableCost]
        let onOpenLedger: () -> Void
        let onOpenComparableInCompare: (UUID) -> Void
    }

    let model: Model
    @State private var selectedComparableCost: ComparableCost?
    @State private var comparableSheetHeight: CGFloat = 560

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            hero
            analytics
            metadata
            ledgerButton
        }
        .sheet(item: $selectedComparableCost) { item in
            ComparableCostDetailSheet(
                item: item,
                confidenceLevel: model.confidenceLevel,
                dataSource: model.dataSource,
                onOpenCompare: {
                    selectedComparableCost = nil
                    model.onOpenComparableInCompare(item.id)
                }
            )
            .onPreferenceChange(ComparableSheetHeightPreferenceKey.self) { contentHeight in
                let maxHeight = UIScreen.main.bounds.height * 0.88
                let nextHeight = min(max(contentHeight + 28, 360), maxHeight)
                guard abs(nextHeight - comparableSheetHeight) > 1 else { return }
                comparableSheetHeight = nextHeight
            }
            .presentationDetents([.height(comparableSheetHeight)])
            .presentationDragIndicator(.visible)
            .presentationBackground(WorthItColor.surfaceContainerLow)
            .presentationCornerRadius(WorthItRadius.xxl)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                Text(model.title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.75)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .semibold))

                    Text(model.dateTimeText)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .foregroundStyle(WorthItColor.textSecondary)
            }

            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                Text(model.estimatedCostText)
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .tracking(-1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text("Estimated for this trip")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.6)
                    .textCase(.uppercase)
            }
        }
    }

    private var analytics: some View {
        VStack(spacing: WorthItSpacing.xxl) {
            calculationCard
            comparisonCard
            MileageTripDetailSourceCard(model: model)
        }
    }

    @ViewBuilder
    private var comparisonCard: some View {
        if !model.comparableCosts.isEmpty {
            WIIsland(title: i18n.t("Efficiency Comparison"), systemIcon: "arrow.left.arrow.right") {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(model.comparableCosts) { item in
                        comparableRow(item)
                    }
                }
            }
        }
    }

    private func comparableRow(_ item: ComparableCost) -> some View {
        Button {
            selectedComparableCost = item
        } label: {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: item.iconSystemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary.opacity(0.78))
                    .frame(width: 48, height: 48)
                    .background(WorthItColor.primaryContainer.opacity(0.22), in: Circle())

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(item.durationText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: WorthItSpacing.xs) {
                    Text(item.costText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(item.deltaText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(item.isCheaper ? Color(hex: 0xFFB4AB) : WorthItColor.primaryContainer)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle.opacity(0.46), lineWidth: 1)
        }
        .shadow(color: WorthItColor.surfaceLowest.opacity(0.12), radius: 10, y: 4)
        .buttonStyle(.plain)
    }

    private var calculationCard: some View {
        WIIsland(title: i18n.t("Calculation Basis"), systemIcon: "sum") {
            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                formula

                Text(model.costPerDistanceSourceText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WorthItColor.textTertiary)
            }
        }
    }

    private var formula: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                Text(model.distanceText)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("×")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(WorthItColor.textTertiary.opacity(0.45))

                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(model.costPerDistanceText)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(WorthItColor.accentGold)

                    Text("/\(model.unitText)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                Text("=")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(WorthItColor.textTertiary.opacity(0.45))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.62)

            Text(model.estimatedCostText)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)
        }
    }

    private var metadata: some View {
        MileageTripDetailMetadataCard(model: model)
    }

    private var ledgerButton: some View {
        WIButton(title: i18n.t("View in Monthly Ledger"), iconSystemName: "list.bullet.rectangle", style: .secondary, height: 56, action: model.onOpenLedger)
            .shadow(color: WorthItColor.primaryContainer.opacity(0.16), radius: 18)
            .padding(.horizontal, WorthItSpacing.xxxl)
            .padding(.bottom, WorthItSpacing.xxxxl)
    }

}

private struct ComparableCostDetailSheet: View {
    let item: MileageTripDetailScreen.ComparableCost
    let confidenceLevel: String
    let dataSource: String
    let onOpenCompare: () -> Void

    var body: some View {
        ZStack {
            WorthItColor.surfaceContainerLow.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
                    header
                    calculation
                    source
                    WIButton(title: i18n.t("Open in Compare"), iconSystemName: "arrow.left.arrow.right", height: 56, action: onOpenCompare)
                        .shadow(color: WorthItColor.primaryContainer.opacity(0.18), radius: 18)
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.top, 40)
                .padding(.bottom, WorthItSpacing.xxxxl)
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(key: ComparableSheetHeightPreferenceKey.self, value: proxy.size.height)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: item.iconSystemName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary.opacity(0.82))
                    .frame(width: 58, height: 58)
                    .background(WorthItColor.primaryContainer.opacity(0.22), in: RoundedRectangle(cornerRadius: WorthItRadius.l))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Comparable Detail")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(1.4)
                        .textCase(.uppercase)

                    Text(item.name)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-0.7)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(item.durationText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .trailing, spacing: WorthItSpacing.xs) {
                Text(item.costText)
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(item.deltaText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(item.isCheaper ? Color(hex: 0xFFB4AB) : WorthItColor.primaryContainer)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var calculation: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text("Calculation")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            VStack(spacing: WorthItSpacing.s) {
                ForEach(Array(item.detailLines.enumerated()), id: \.offset) { index, line in
                    calculationRow(label: index == 0 ? "Base" : "Inherited", value: line, badge: "\(index + 1)")
                }

                calculationRow(label: i18n.t("Comparable total"), value: "Final estimated alternative cost", badge: "Σ", trailing: item.costText)
            }
        }
        .padding(WorthItSpacing.xl)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xl)
                .stroke(WorthItColor.outlineSubtle.opacity(0.42), lineWidth: 1)
        }
    }

    private func calculationRow(label: String, value: String, badge: String, trailing: String? = nil) -> some View {
        HStack(alignment: .center, spacing: WorthItSpacing.m) {
            Text(badge)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 30, height: 30)
                .background(WorthItColor.primaryContainer.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let trailing {
                Text(trailing)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(WorthItSpacing.m)
        .background(WorthItColor.surfaceLowest.opacity(0.46), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
    }

    private var source: some View {
        HStack(spacing: WorthItSpacing.m) {
            sourceTile(label: i18n.t("Source"), value: dataSource)
            sourceTile(label: i18n.t("Confidence"), value: confidenceLevel)
        }
    }

    private func sourceTile(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(1.0)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}

private struct ComparableSheetHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 560

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
