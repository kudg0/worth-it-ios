import SwiftUI

struct WIDateField: View {
    let label: String
    let placeholder: String
    @Binding var date: Date?
    var errorText: String?

    @State private var isPickerPresented = false
    @State private var draftDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            fieldLabel(label)

            Button {
                draftDate = date ?? Date()
                isPickerPresented = true
            } label: {
                HStack(spacing: WorthItSpacing.s) {
                    Text(displayText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(date == nil ? WorthItColor.textTertiary.opacity(0.72) : WorthItColor.textPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 52)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(borderColor, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(label)

            if let errorText {
                fieldError(errorText)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            datePickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var borderColor: Color {
        errorText == nil ? WorthItColor.outlineInput : Color(hex: 0xFCA5A5).opacity(0.85)
    }

    private var displayText: String {
        guard let date else { return placeholder }
        return Self.formatter.string(from: date)
    }

    private var datePickerSheet: some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                DatePicker(
                    label,
                    selection: $draftDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(WorthItColor.primaryContainer)
                .padding(WorthItSpacing.xl)
            }
            .navigationTitle(label)
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPickerPresented = false
                    }
                    .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        date = draftDate
                        isPickerPresented = false
                    }
                    .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
}
