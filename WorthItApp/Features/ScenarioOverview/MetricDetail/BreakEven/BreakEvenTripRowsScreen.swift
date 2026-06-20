import SwiftUI

struct BreakEvenTripRowsScreen: View {
    let rows: [BreakEvenDetailScreen.TripRow]
    let onOpenTrip: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(rows) { row in
                        BreakEvenTripRow(row: row) {
                            dismiss()
                            onOpenTrip(row.id)
                        }
                    }
                }
                .padding(.horizontal, WorthItSpacing.l)
                .padding(.vertical, WorthItSpacing.xl)
            }
            .background(WorthItColor.pageBackground.ignoresSafeArea())
            .navigationTitle(i18n.t("Mileage Entries"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(i18n.t("Done")) {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
    }
}

struct BreakEvenTripRow: View {
    let row: BreakEvenDetailScreen.TripRow
    let onOpen: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: WorthItSpacing.m) {
            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(row.subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: WorthItSpacing.m)

            Text(row.value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(row.valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(WorthItSpacing.m)
        .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
        .onTapGesture(perform: onOpen)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("Open trip detail")
    }
}
