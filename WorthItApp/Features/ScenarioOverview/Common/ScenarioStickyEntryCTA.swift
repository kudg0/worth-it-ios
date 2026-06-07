import SwiftUI

extension ScenarioOverviewView {
    func stickyEntryCTA(title: String, bottomPadding: CGFloat = 40, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground,
                    WorthItColor.surfaceLowest
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 48)
            .allowsHitTesting(false)

            WIButton(title: title, action: action)
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.bottom, bottomPadding)
                .background(WorthItColor.surfaceLowest)
        }
    }
}
