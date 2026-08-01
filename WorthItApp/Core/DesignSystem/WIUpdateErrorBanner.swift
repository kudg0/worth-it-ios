import SwiftUI

struct WIUpdateErrorBanner: View {
    let message: String
    var title: String = "Changes not saved"
    var onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(WorthItColor.danger)
                .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .lineSpacing(3)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(.vertical, WorthItSpacing.m)
        .padding(.leading, WorthItSpacing.l)
        .padding(.trailing, WorthItSpacing.s)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.danger.opacity(0.42), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.34), radius: 18, y: 8)
        .padding(.horizontal, WorthItSpacing.xxl)
        .task(id: message) {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                onDismiss()
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
