import SwiftUI

struct BreakEvenDetailScreen: View {
    private struct TripRowsSheet: Identifiable {
        let id = "tripRows"
        let rows: [TripRow]
    }

    struct Option: Identifiable {
        let id: UUID
        let title: String
    }

    struct CalculationRow: Identifiable {
        let id: String
        let title: String
        let value: String
        let accentColor: Color
        let showsDot: Bool
    }

    struct BenchmarkRow: Identifiable {
        let id: UUID
        let title: String
        let status: String
        let color: Color
        let magnitude: Double
        let isSaving: Bool
    }

    struct TripRow: Identifiable {
        let id: UUID
        let title: String
        let subtitle: String
        let value: String
        let valueColor: Color
    }

    struct Model {
        let eyebrow: String
        let value: String
        let valueColor: Color
        let subtitle: String
        let statusPill: String
        let statusColor: Color
        let selectedOptionId: UUID?
        let options: [Option]
        let calculationRows: [CalculationRow]
        let tripRows: [TripRow]
        let benchmarkRows: [BenchmarkRow]
        let explanationTitle: String
        let explanationBody: String
        let onSelectOption: (UUID) -> Void
        let onOpenTrip: (UUID) -> Void
    }

    let model: Model
    @State private var tripRowsSheet: TripRowsSheet?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            hero
            optionSelector
            calculation
            otherBenchmarks
            tripBreakdown
            explanation
        }
        .sheet(item: $tripRowsSheet) { sheet in
            BreakEvenTripRowsScreen(rows: sheet.rows, onOpenTrip: openTrip)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(model.eyebrow)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.5)
                .textCase(.uppercase)

            Text(model.value)
                .font(.system(size: 56, weight: .heavy))
                .foregroundStyle(model.valueColor)
                .tracking(-1.2)
                .lineLimit(1)
                .minimumScaleFactor(0.50)

            Text(model.subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.90))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            ScenarioMetricPill(
                text: model.statusPill,
                iconName: "flag.checkered",
                color: model.statusColor
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, WorthItSpacing.xxl)
    }

    private var optionSelector: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            sectionLabel("Compare against")

            WISelectControl(
                title: i18n.t("Compare against"),
                options: selectOptions,
                selectedId: selectedOptionIdBinding
            ) {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .frame(width: 36, height: 36)
                        .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                    Text(selectedOptionTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                }
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 56)
                .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.l)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
        }
    }

    private var selectOptions: [WISelectSheetOption] {
        model.options.map {
            WISelectSheetOption(id: $0.id.uuidString, title: $0.title, systemName: "arrow.left.arrow.right")
        }
    }

    private var selectedOptionTitle: String {
        model.options.first { $0.id == model.selectedOptionId }?.title ?? "Select benchmark"
    }

    private var selectedOptionIdBinding: Binding<String> {
        Binding(
            get: { model.selectedOptionId?.uuidString ?? "" },
            set: { newValue in
                guard let id = UUID(uuidString: newValue) else { return }
                model.onSelectOption(id)
            }
        )
    }

    private var calculation: some View {
        WIIsland(title: i18n.t("Calculation"), systemIcon: "sum", spacing: WorthItSpacing.l, padding: WorthItSpacing.xl) {
            VStack(spacing: 0) {
                ForEach(Array(model.calculationRows.enumerated()), id: \.element.id) { index, row in
                    calculationRow(row)

                    if index == 1 || index == 3 {
                        Divider()
                            .overlay(WorthItColor.outlineInput.opacity(0.5))
                            .padding(.vertical, WorthItSpacing.s)
                    } else if index < model.calculationRows.count - 1 {
                        Spacer()
                            .frame(height: WorthItSpacing.m)
                    }
                }
            }
        }
    }

    private func calculationRow(_ row: CalculationRow) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: WorthItSpacing.m) {
            HStack(spacing: WorthItSpacing.s) {
                if row.showsDot {
                    Circle()
                        .fill(WorthItColor.primaryContainer)
                        .frame(width: 5, height: 5)
                }

                Text(row.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: WorthItSpacing.m)

            Text(row.value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(row.accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            }
        .frame(maxWidth: .infinity)
    }

    private var otherBenchmarks: some View {
        WIIsland(title: i18n.t("Other Benchmarks"), systemIcon: "arrow.left.arrow.right", spacing: WorthItSpacing.l, padding: WorthItSpacing.xl) {
            VStack(spacing: WorthItSpacing.s) {
                ForEach(model.benchmarkRows) { row in
                    benchmarkBarRow(row)
                }
            }
        }
    }

    @ViewBuilder
    private var tripBreakdown: some View {
        if !model.tripRows.isEmpty {
            WIIsland(title: i18n.t("Mileage Entries"), systemIcon: "road.lanes", spacing: WorthItSpacing.l, padding: WorthItSpacing.xl) {
                VStack(spacing: WorthItSpacing.m) {
                    HStack(alignment: .center, spacing: WorthItSpacing.m) {
                        Text("Latest \(tripPreviewRows.count) of \(model.tripRows.count)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .tracking(0.7)
                            .textCase(.uppercase)

                        Spacer(minLength: WorthItSpacing.m)

                        if model.tripRows.count > tripPreviewRows.count {
                            Button {
                                tripRowsSheet = TripRowsSheet(rows: model.tripRows)
                            } label: {
                                Text(i18n.t("View All"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(WorthItColor.primaryContainer)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ForEach(tripPreviewRows) { row in
                        BreakEvenTripRow(row: row) {
                            openTrip(row.id)
                        }
                    }
                }
            }
        }
    }

    private var tripPreviewRows: [TripRow] {
        Array(model.tripRows.prefix(4))
    }

    private func openTrip(_ id: UUID) {
        tripRowsSheet = nil
        model.onOpenTrip(id)
    }

    private var largestBenchmarkMagnitude: Double {
        max(model.benchmarkRows.map(\.magnitude).max() ?? 0, 1)
    }

    private func benchmarkBarRow(_ row: BenchmarkRow) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            HStack(alignment: .firstTextBaseline, spacing: WorthItSpacing.m) {
                Text(row.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: WorthItSpacing.m)

                Text(row.status)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(row.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            GeometryReader { proxy in
                let progress = min(max(row.magnitude / largestBenchmarkMagnitude, 0), 1)
                let halfWidth = proxy.size.width / 2
                let fillWidth = max(halfWidth * progress, row.magnitude > 0 ? 8 : 0)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WorthItColor.surfaceContainerHigh.opacity(0.65))

                    Rectangle()
                        .fill(WorthItColor.textTertiary.opacity(0.45))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: 0) {
                        ZStack(alignment: .trailing) {
                            if !row.isSaving {
                                Capsule()
                                    .fill(row.color.opacity(0.82))
                                    .frame(width: fillWidth)
                            }
                        }
                        .frame(width: halfWidth, alignment: .trailing)

                        ZStack(alignment: .leading) {
                            if row.isSaving {
                                Capsule()
                                    .fill(row.color.opacity(0.88))
                                    .frame(width: fillWidth)
                            }
                        }
                        .frame(width: halfWidth, alignment: .leading)
                    }
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, WorthItSpacing.l)
        .padding(.vertical, WorthItSpacing.m)
        .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var explanation: some View {
        WIIsland(title: model.explanationTitle, systemIcon: "info.circle", spacing: WorthItSpacing.s, padding: WorthItSpacing.xl) {
            Text(model.explanationBody)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(WorthItColor.textTertiary)
            .tracking(1.2)
            .textCase(.uppercase)
    }
}
