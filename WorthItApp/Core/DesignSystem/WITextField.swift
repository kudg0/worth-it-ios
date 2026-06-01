import SwiftUI

struct WITextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var leadingText: String?
    var trailingSystemName: String?
    var trailingText: String?
    var keyboardType: UIKeyboardType = .default
    var errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            fieldLabel(label)

            HStack(spacing: WorthItSpacing.s) {
                if let leadingText {
                    Text(leadingText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                            .lineLimit(1)
                    }

                    TextField("", text: $text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .onChange(of: text) { _, newValue in
                            let sanitizedValue = sanitizedInput(newValue)
                            if sanitizedValue != newValue {
                                text = sanitizedValue
                            }
                        }
                }

                if let trailingSystemName {
                    Image(systemName: trailingSystemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }

                if let trailingText {
                    Text(trailingText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                }
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 52)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(borderColor, lineWidth: 1)
            }

            if let errorText {
                fieldError(errorText)
            }
        }
    }

    private var borderColor: Color {
        errorText == nil ? WorthItColor.outlineInput : Color(hex: 0xFCA5A5).opacity(0.85)
    }

    private func sanitizedInput(_ value: String) -> String {
        switch keyboardType {
        case .numberPad:
            value.filter(\.isNumber)
        case .decimalPad:
            sanitizedDecimal(value)
        default:
            value
        }
    }

    private func sanitizedDecimal(_ value: String) -> String {
        var result = ""
        var hasSeparator = false

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasSeparator else { continue }
                result.append(".")
                hasSeparator = true
            }
        }

        return result
    }
}
