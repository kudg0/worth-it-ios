import SwiftUI

struct WIButton: View {
    enum Style {
        case primary
        case secondary
        case outline
    }

    let title: String
    var iconSystemName: String?
    var style: Style = .primary
    var height: CGFloat = 64
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.s) {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: max(height, WorthItInteraction.minimumTouchTarget))
            .contentShape(Rectangle())
        }
        .buttonStyle(WIButtonPressStyle())
        .foregroundStyle(foregroundColor)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(borderColor, lineWidth: 1)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            Color(hex: 0x385283)
        case .secondary:
            WorthItColor.textPrimary
        case .outline:
            WorthItColor.textPrimary
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            WorthItColor.primaryContainer
        case .secondary:
            WorthItColor.surfaceContainerHigh
        case .outline:
            Color.clear
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            Color.clear
        case .secondary:
            WorthItColor.outlineSubtle
        case .outline:
            WorthItColor.outlineInput
        }
    }
}

private struct WIButtonPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.80 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

typealias PrimaryButton = WIButton
