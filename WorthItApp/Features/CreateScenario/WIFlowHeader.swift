import SwiftUI

struct WIFlowHeader: View {
    let title: String
    let currentStep: Int
    let totalSteps: Int
    var showsProgress = true
    let backAction: () -> Void

    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Button(action: backAction) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 20, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text(title)
                .font(WorthItTypography.cardTitle)
                .foregroundStyle(WorthItColor.textPrimary)

            Spacer()

            if showsProgress {
                VStack(alignment: .trailing, spacing: WorthItSpacing.s) {
                    Text("STEP \(currentStep) OF \(totalSteps)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                        .tracking(1)

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                        Capsule()
                            .fill(Color(hex: 0xD8E2FF))
                            .frame(width: progressWidth)
                            .animation(.easeInOut(duration: 0.24), value: progressWidth)
                    }
                    .frame(width: 64, height: 4)
                }
            }
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground.opacity(0.80))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
    }

    private var progressWidth: CGFloat {
        guard totalSteps > 0 else { return 0 }
        return 64 * min(CGFloat(currentStep) / CGFloat(totalSteps), 1)
    }
}
