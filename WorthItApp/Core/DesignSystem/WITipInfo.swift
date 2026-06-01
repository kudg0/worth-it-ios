import SwiftUI

struct WITipInfo: View {
    enum Size {
        case small
        case medium
    }

    enum Tone {
        case info
        case primary
    }

    let title: String
    let bodyText: String
    var size: Size = .small
    var tone: Tone = .info

    var body: some View {
        Group {
            switch tone {
            case .info:
                infoBody
            case .primary:
                primaryBody
            }
        }
    }

    private var infoBody: some View {
        HStack(alignment: .top, spacing: size == .medium ? WorthItSpacing.l : WorthItSpacing.m) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: size == .medium ? 24 : 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text(bodyText)
                .font(size == .medium ? WorthItTypography.caption.weight(.bold) : WorthItTypography.caption)
                .lineSpacing(4)
                .foregroundStyle(size == .medium ? WorthItColor.textPrimary : WorthItColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(size == .medium ? 21 : 17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.neutralContainerSubtle, in: RoundedRectangle(cornerRadius: size == .medium ? WorthItRadius.l : WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: size == .medium ? WorthItRadius.l : WorthItRadius.m)
                .stroke(WorthItColor.neutralBorderSubtle, lineWidth: 1)
        }
    }

    private var primaryBody: some View {
        HStack(spacing: 0) {
            WorthItColor.accentGold
                .frame(width: 3)

            HStack(alignment: .top, spacing: size == .medium ? WorthItSpacing.xl : 14) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: size == .medium ? 32 : 24, weight: .semibold))
                    .foregroundStyle(WorthItColor.accentGold)

                VStack(alignment: .leading, spacing: size == .medium ? 10 : WorthItSpacing.xs) {
                    Text(title)
                        .font(size == .medium ? WorthItTypography.title.weight(.semibold) : WorthItTypography.bodySmall.weight(.semibold))
                        .foregroundStyle(WorthItColor.accentGold)

                    Text(bodyText)
                        .font(size == .medium ? WorthItTypography.body : WorthItTypography.caption)
                        .lineSpacing(size == .medium ? 4 : 3)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(size == .medium ? EdgeInsets(top: 28, leading: 28, bottom: 28, trailing: 24) : EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18))
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, minHeight: size == .medium ? 146 : 122, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: size == .medium ? WorthItRadius.l : WorthItRadius.m))
        .clipShape(RoundedRectangle(cornerRadius: size == .medium ? WorthItRadius.l : WorthItRadius.m))
        .shadow(color: Color.black.opacity(0.20), radius: 20, y: 4)
    }
}
