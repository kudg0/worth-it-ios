import SwiftUI

struct WISelectSheetOption: Identifiable, Hashable {
    let id: String
    let title: String
    var systemName: String?

    init(id: String? = nil, title: String, systemName: String? = nil) {
        self.id = id ?? title
        self.title = title
        self.systemName = systemName
    }
}

struct WISelectSheet: View {
    let title: String
    let options: [WISelectSheetOption]
    let selectedId: String
    let onSelect: (WISelectSheetOption) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: WorthItSpacing.s) {
                        ForEach(options) { option in
                            selectOptionRow(option)
                        }
                    }
                    .padding(WorthItSpacing.xxl)
                }
            }
            .navigationTitle(title)
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    private func selectOptionRow(_ option: WISelectSheetOption) -> some View {
        let isSelected = selectedId == option.id

        return Button {
            onSelect(option)
            dismiss()
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: option.systemName ?? (isSelected ? "checkmark.circle.fill" : "circle"))
                    .font(.system(size: 18, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                    .frame(width: 24)

                Text(option.title)
                    .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.textPrimary : WorthItColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected, option.systemName != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(isSelected ? WorthItColor.primaryContainer.opacity(0.12) : WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(isSelected ? WorthItColor.primaryContainer.opacity(0.55) : WorthItColor.outlineInput, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct WISelectControl<Label: View>: View {
    let title: String
    let options: [WISelectSheetOption]
    @Binding var selectedId: String
    @ViewBuilder let label: () -> Label

    @State private var isPickerPresented = false

    var body: some View {
        Button {
            isPickerPresented = true
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .sheet(isPresented: $isPickerPresented) {
            WISelectSheet(
                title: title,
                options: options,
                selectedId: selectedId
            ) { option in
                selectedId = option.id
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

struct WISelectField: View {
    let label: String
    let options: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary.opacity(0.60))
                .tracking(1)
                .textCase(.uppercase)
                .lineLimit(1)

            WISelectControl(
                title: label,
                options: options.map { WISelectSheetOption(title: $0) },
                selectedId: $selection
            ) {
                HStack(spacing: WorthItSpacing.m) {
                    Text(selection)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)
                }
                .padding(.horizontal, WorthItSpacing.l)
                .frame(height: 52)
                .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
        }
    }
}
