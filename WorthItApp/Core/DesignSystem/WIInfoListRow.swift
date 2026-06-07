import SwiftUI

struct WIInfoListRow: View {
    let title: String
    let subtitle: String
    let value: String
    var detail: String?
    var systemIcon: String
    var accentColor: Color = WorthItColor.primaryContainer
    var valueColor: Color = WorthItColor.textPrimary
    var detailColor: Color?
    var action: (() -> Void)?

    var body: some View {
        if let action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }

    private var rowContent: some View {
        HStack(spacing: WorthItSpacing.m) {
            icon

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: WorthItSpacing.s)

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if let detail {
                    Text(detail)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(detailColor ?? WorthItColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
        }
        .padding(.horizontal, WorthItSpacing.m)
        .padding(.vertical, WorthItSpacing.s)
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
    }

    private var icon: some View {
        Image(systemName: systemIcon)
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(accentColor)
            .frame(width: 40, height: 40)
            .background(WorthItColor.surfaceLowest, in: Circle())
            .overlay {
                Circle()
                    .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
            }
    }
}
