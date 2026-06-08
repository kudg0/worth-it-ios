import SwiftUI

struct AddComparableOptionFooter: View {
    var title = "Save Changes"
    var isLoading = false
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.surfaceLowest.opacity(0),
                    WorthItColor.pageBackground.opacity(0.90),
                    WorthItColor.surfaceLowest
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 48)
            .allowsHitTesting(false)

            WIButton(title: isLoading ? "Saving..." : title, height: 60, action: onSave)
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.bottom, 32)
                .background {
                    WorthItColor.pageBackground.opacity(0.96)
                        .shadow(color: WorthItColor.surfaceLowest.opacity(0.50), radius: 40, y: -10)
                }
        }
    }
}
