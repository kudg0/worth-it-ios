import SwiftUI

struct WIToastBanner: View {
    let message: String
    var systemName: String = "checkmark.circle.fill"
    var tint: Color = WorthItColor.accentGold
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)

            Text(message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: WorthItSpacing.s)

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.leading, WorthItSpacing.l)
        .padding(.trailing, onDismiss == nil ? WorthItSpacing.l : WorthItSpacing.s)
        .frame(minHeight: 52)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: Capsule())
        .background(WorthItColor.surfaceContainerHigh.opacity(0.92), in: Capsule())
        .overlay {
            Capsule()
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.28), radius: 18, y: 10)
    }
}
