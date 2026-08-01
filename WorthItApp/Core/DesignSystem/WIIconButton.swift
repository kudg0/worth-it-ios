import SwiftUI

enum WorthItInteraction {
    static let minimumTouchTarget: CGFloat = 44
    static let iconButtonTarget: CGFloat = 48
    static let compactVisualSize: CGFloat = 34
}

struct WIIconButton: View {
    enum Style {
        case plain
        case circular
        case toolbar
        case primary
        case destructive
    }

    let systemName: String
    let accessibilityLabel: String
    var style: Style = .plain
    var visualSize: CGFloat = WorthItInteraction.compactVisualSize
    var hitTargetSize: CGFloat = WorthItInteraction.iconButtonTarget
    var accessibilityHint: String?
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                background

                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(foregroundColor)
            }
            .frame(width: visualSize, height: visualSize)
            .contentShape(Circle())
            .frame(
                width: max(hitTargetSize, WorthItInteraction.minimumTouchTarget),
                height: max(hitTargetSize, WorthItInteraction.minimumTouchTarget)
            )
            .contentShape(.interaction, Rectangle())
        }
        .buttonStyle(WIIconButtonPressStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
    }

    private var iconSize: CGFloat {
        switch style {
        case .plain:
            24
        case .circular, .toolbar, .primary, .destructive:
            18
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .plain:
            WorthItColor.primaryContainer
        case .circular:
            WorthItColor.accentGold
        case .toolbar:
            WorthItColor.primaryContainer
        case .primary:
            WorthItColor.surfaceLowest
        case .destructive:
            WorthItColor.danger
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .plain:
            Color.clear
        case .circular:
            WorthItColor.surfaceContainer.clipShape(Circle())
        case .toolbar:
            WorthItColor.surfaceContainerLow.clipShape(Circle())
        case .primary:
            WorthItColor.primaryContainer.clipShape(Circle())
        case .destructive:
            WorthItColor.surfaceLowest.clipShape(Circle())
        }
    }

    @ViewBuilder
    private var overlay: some View {
        switch style {
        case .plain:
            EmptyView()
        case .circular:
            Circle().stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        case .toolbar:
            Circle().stroke(WorthItColor.outlineSubtle.opacity(0.5), lineWidth: 1)
        case .primary:
            EmptyView()
        case .destructive:
            Circle().stroke(WorthItColor.danger.opacity(0.28), lineWidth: 1)
        }
    }
}

private struct WIIconButtonPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
