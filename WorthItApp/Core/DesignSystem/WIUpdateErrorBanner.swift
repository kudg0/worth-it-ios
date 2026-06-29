import SwiftUI

struct WIUpdateErrorBanner: View {
    let message: String
    var title: String = "Changes not saved"
    var onDismiss: () -> Void

    var body: some View {
        WITipInfo(
            title: title,
            bodyText: message,
            size: .small,
            tone: .danger,
            onDismiss: onDismiss
        )
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
