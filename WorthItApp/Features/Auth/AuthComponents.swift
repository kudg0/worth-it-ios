import SwiftUI

enum AuthCapabilities {
    // Keep the Apple entry point visible while the backend provider is being wired so the
    // auth surface does not unexpectedly change between builds.
    static let isAppleSignInEnabled = true
}

struct AuthActionButton: View {
    enum Style {
        case apple
        case primary
        case secondary
    }

    let title: String
    var systemName: String?
    var style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.s) {
                if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 17, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
        .background(background, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(borderColor, lineWidth: 1)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .apple:
            .white
        case .primary:
            Color(hex: 0x385283)
        case .secondary:
            WorthItColor.textPrimary
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .apple:
            Color.black
        case .primary:
            WorthItColor.primaryContainer
        case .secondary:
            WorthItColor.surfaceContainerHigh
        }
    }

    private var borderColor: Color {
        switch style {
        case .apple:
            Color.white.opacity(0.08)
        case .primary:
            Color.clear
        case .secondary:
            WorthItColor.outlineInput
        }
    }
}

struct AuthTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var submitLabel: SubmitLabel = .next

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            fieldLabel(label)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 54)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}

struct AuthWordmark: View {
    @Environment(\.i18n) private var i18n

    var body: some View {
        Text(i18n.t(.brand.name))
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(WorthItColor.textPrimary)
    }
}

struct AuthFooterNote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(WorthItColor.textTertiary.opacity(0.82))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}
