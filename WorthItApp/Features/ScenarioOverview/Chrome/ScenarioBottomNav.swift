import SwiftUI

struct ScenarioBottomNav: View {
    let selectedTab: ScenarioOverviewView.ScenarioTab
    let onExit: () -> Void
    let onHome: () -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground.opacity(0.92),
                    WorthItColor.pageBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)

            HStack {
                navItem(
                    systemName: "rectangle.portrait.and.arrow.right",
                    accessibilityLabel: "Exit scenario",
                    isSelected: false,
                    isMirrored: true,
                    action: onExit
                )
                navItem(
                    systemName: "house.fill",
                    accessibilityLabel: "Scenario home",
                    isSelected: selectedTab != .settings,
                    action: onHome
                )
                navItem(
                    systemName: "gearshape.fill",
                    accessibilityLabel: "Scenario settings",
                    isSelected: selectedTab == .settings,
                    action: onSettings
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, WorthItSpacing.l)
            .padding(.bottom, 28)
            .background { background }
        }
    }

    private var background: some View {
        WorthItColor.pageBackground
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: WorthItRadius.l, topTrailingRadius: WorthItRadius.l))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(WorthItColor.outlineSubtle)
                    .frame(height: 1)
            }
            .shadow(color: .black.opacity(0.30), radius: 24, y: -8)
    }

    private func navItem(
        systemName: String,
        accessibilityLabel: String,
        isSelected: Bool,
        isMirrored: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: WorthItSpacing.xs) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.82))
                    .frame(width: 34, height: 28)
                    .scaleEffect(x: isMirrored ? -1 : 1, y: 1)

                Circle()
                    .fill(isSelected ? WorthItColor.primaryContainer : Color.clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: isSelected ? WorthItColor.primaryContainer.opacity(0.80) : Color.clear, radius: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
