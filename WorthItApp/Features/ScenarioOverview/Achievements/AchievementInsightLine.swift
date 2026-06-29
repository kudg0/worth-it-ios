import SwiftUI

struct AchievementInsightLine: View {
    let text: String

    var body: some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WorthItColor.accentGold)

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .padding(.horizontal, WorthItSpacing.l)
        .frame(maxWidth: .infinity, minHeight: 42)
        .background(WorthItColor.surfaceIsland, in: Capsule())
        .overlay {
            Capsule().stroke(WorthItColor.outlineSelected, lineWidth: 1)
        }
    }
}
