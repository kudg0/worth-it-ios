import SwiftUI

struct ComparisonVisibilityFooter: View {
    let selectedCount: Int
    let isSaving: Bool
    let onClear: () -> Void
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
                    HStack(spacing: WorthItSpacing.s) {
                        selectedBadge

                        Text("\(selectedCount) options selected")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(WorthItColor.textPrimary)
                    }

                    Spacer()

                    Button("Clear All", action: onClear)
                        .buttonStyle(.plain)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, WorthItSpacing.xs)

                WIButton(
                    title: isSaving ? "Saving..." : "Save Comparison",
                    height: 56,
                    action: onSave
                )
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

    private var selectedBadge: some View {
        ZStack {
            Circle()
                .fill(WorthItColor.primaryContainer)
                .frame(width: 24, height: 24)

            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: 0x385283))
        }
    }
}

