import SwiftUI

struct WIIsland<Content: View>: View {
    let title: String
    var systemIcon: String = "car.fill"
    var spacing: CGFloat = WorthItSpacing.xxl
    var padding: CGFloat = WorthItSpacing.xxl
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemIcon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary.opacity(0.90))

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary.opacity(0.90))
                    .tracking(1.8)
                    .textCase(.uppercase)
            }

            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }
}
