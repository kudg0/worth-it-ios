import SwiftUI

struct ScheduleServiceDivider: View {
    let title: String

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)

            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary.opacity(title == "Triggered by" ? 0.60 : 1))
                .tracking(title == "Triggered by" ? 1.4 : 1.8)
                .textCase(title == "Triggered by" ? .uppercase : nil)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
    }
}
