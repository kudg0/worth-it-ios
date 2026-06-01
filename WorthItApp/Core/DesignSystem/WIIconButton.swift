import SwiftUI

struct WIIconButton: View {
    enum Style {
        case plain
        case circular
    }

    let systemName: String
    let accessibilityLabel: String
    var style: Style = .plain
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundStyle(foregroundColor)
                .frame(width: 40, height: 40)
                .background(background)
                .overlay(overlay)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var iconSize: CGFloat {
        switch style {
        case .plain:
            24
        case .circular:
            18
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .plain:
            WorthItColor.primaryContainer
        case .circular:
            WorthItColor.accentGold
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .plain:
            Color.clear
        case .circular:
            WorthItColor.surfaceContainer.clipShape(Circle())
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch style {
        case .plain:
            EmptyView()
        case .circular:
            Circle().stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}
