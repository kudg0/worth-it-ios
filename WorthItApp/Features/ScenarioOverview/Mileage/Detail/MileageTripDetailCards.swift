import SwiftUI

struct MileageTripDetailSourceCard: View {
    let model: MileageTripDetailScreen.Model

    var body: some View {
        WIIsland(title: "Confidence Level", systemIcon: "circle.fill") {
            VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                HStack(spacing: WorthItSpacing.m) {
                    Circle()
                        .fill(WorthItColor.primaryContainer)
                        .frame(width: 10, height: 10)
                        .shadow(color: WorthItColor.primaryContainer.opacity(0.35), radius: 8)

                    Text(model.confidenceLevel)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(WorthItColor.textPrimary)
                }

                Text(model.confidenceSource)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textTertiary)

                divider

                VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                    Text("Data Source")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(0.6)
                        .textCase(.uppercase)

                    HStack(spacing: WorthItSpacing.s) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text(model.dataSource)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(WorthItColor.textPrimary)
                    }
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(WorthItColor.outlineSubtle)
            .frame(height: 1)
    }
}

struct MileageTripDetailMetadataCard: View {
    let model: MileageTripDetailScreen.Model

    var body: some View {
        WIIsland(title: "Trip Metadata", systemIcon: "list.bullet.rectangle") {
            VStack(spacing: WorthItSpacing.m) {
                metadataRow(icon: "calendar", value: model.dateTimeText, label: "Date & Time")
                metadataRow(icon: "point.topleft.down.curvedto.point.bottomright.up", value: model.distanceText, label: "Distance")
                notesBlock
            }
        }
    }

    private func metadataRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 40, height: 40)
                .background(WorthItColor.surfaceContainer, in: Circle())

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: WorthItSpacing.s)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.6)
                .textCase(.uppercase)
        }
    }

    private var notesBlock: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Notes")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.6)
                .textCase(.uppercase)

            Text("\"\(model.notesText)\"")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceLowest.opacity(0.50), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(WorthItColor.primaryContainer.opacity(0.35))
                .frame(width: 2)
        }
    }
}
