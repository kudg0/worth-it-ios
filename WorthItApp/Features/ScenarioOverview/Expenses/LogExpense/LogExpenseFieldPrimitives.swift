import SwiftUI

struct LogExpensePickerField: View {
    let label: String
    let value: String
    let systemName: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            Button(action: action) {
                HStack {
                    Text(value)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Spacer()

                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 52)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)
        }
    }
}

struct LogExpenseNotesField: View {
    let title: String
    let placeholder: String
    let text: Binding<String>

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: WorthItSpacing.m) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.top, 2)

                    ZStack(alignment: .topLeading) {
                        if text.wrappedValue.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: text)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(WorthItColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                }
                .padding(17)
            }
            .frame(minHeight: 110)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.s)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}
