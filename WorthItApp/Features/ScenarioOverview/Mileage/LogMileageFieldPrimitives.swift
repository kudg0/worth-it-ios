import SwiftUI

struct LogMileageHeroInput: View {
    let label: String
    let placeholder: String
    let value: Binding<String>
    let sanitizeValue: (String) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            ZStack(alignment: .leading) {
                if value.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                }

                TextField("", text: value)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: value.wrappedValue) { _, newValue in
                        value.wrappedValue = sanitizeValue(newValue)
                    }
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}

struct LogMileageStatTile: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}

struct LogMileageResultRow: View {
    let title: String
    let value: String
    let systemName: String

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
        }
        .padding(21)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}

struct LogMileagePickerField: View {
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
                HStack(spacing: WorthItSpacing.s) {
                    Text(value)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    Spacer(minLength: WorthItSpacing.xs)

                    Image(systemName: systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .padding(.horizontal, 14)
                .frame(height: 40)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.s)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LogMileageNotesField: View {
    let notes: Binding<String>

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Notes (optional)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                if notes.wrappedValue.isEmpty {
                    Text("Add a description...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                        .padding(.top, 17)
                        .padding(.leading, 17)
                }

                TextEditor(text: notes)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(12)
            }
            .frame(minHeight: 120)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}
