import SwiftUI

struct AnalyticsModelFooter: View {
    let onReset: () -> Void
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

            VStack(spacing: WorthItSpacing.l) {
                HStack {
                    Text("Analytics defaults")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Spacer()

                    Button("Reset", action: onReset)
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, WorthItSpacing.xs)

                WIButton(title: "Save Changes", height: 56, action: onSave)
            }
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.bottom, 32)
            .padding(.top, WorthItSpacing.s)
            .background {
                WorthItColor.pageBackground.opacity(0.96)
                    .shadow(color: WorthItColor.surfaceLowest.opacity(0.50), radius: 40, y: -10)
            }
        }
    }
}

