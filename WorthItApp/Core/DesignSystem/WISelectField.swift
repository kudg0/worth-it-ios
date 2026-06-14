import SwiftUI

struct WISelectSheetOption: Identifiable, Hashable {
    let id: String
    let title: String
    var subtitle: String?
    var systemName: String?
    var textBadge: String?
    var groupId: String?
    var groupTitle: String?

    init(
        id: String? = nil,
        title: String,
        subtitle: String? = nil,
        systemName: String? = nil,
        textBadge: String? = nil,
        groupId: String? = nil,
        groupTitle: String? = nil
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.systemName = systemName
        self.textBadge = textBadge
        self.groupId = groupId
        self.groupTitle = groupTitle
    }
}

struct WISelectSheet: View {
    let title: String
    let options: [WISelectSheetOption]
    let selectedId: String
    let onSelect: (WISelectSheetOption) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: WorthItSpacing.s) {
                        if shouldShowSearch {
                            searchField
                                .padding(.bottom, WorthItSpacing.s)
                        }

                        ForEach(filteredOptions) { option in
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

    private var shouldShowSearch: Bool {
        options.count > 10
    }

    private var filteredOptions: [WISelectSheetOption] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return options }

        return options.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }

    private var searchField: some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                }

                TextField("", text: $searchText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, WorthItSpacing.l)
        .frame(height: 52)
        .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(WorthItColor.outlineInput, lineWidth: 1)
        }
    }

    private func selectOptionRow(_ option: WISelectSheetOption) -> some View {
        let isSelected = selectedId == option.id
        let subtitle = displaySubtitle(for: option)

        return Button {
            onSelect(option)
            dismiss()
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                selectOptionIcon(option, isSelected: isSelected)

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isSelected ? WorthItColor.textPrimary : WorthItColor.textSecondary)
                        .lineLimit(subtitle == nil ? 2 : 1)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: WorthItSpacing.s) {
                    if let textBadge = option.textBadge {
                        Text(textBadge)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)
                            .lineLimit(1)
                            .monospacedDigit()
                    }

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(WorthItColor.primaryContainer)
                    }
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, WorthItSpacing.m)
            .padding(.vertical, WorthItSpacing.s)
            .frame(maxWidth: .infinity, minHeight: subtitle == nil ? 62 : 72, alignment: .leading)
            .background(isSelected ? WorthItColor.primaryContainer.opacity(0.12) : WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(isSelected ? WorthItColor.primaryContainer.opacity(0.55) : WorthItColor.outlineSubtle, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }

    private func displaySubtitle(for option: WISelectSheetOption) -> String? {
        guard let subtitle = option.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines), !subtitle.isEmpty else {
            return nil
        }

        let title = option.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if subtitle == title {
            return nil
        }

        let repeatedTitlePrefix = "\(title) • "
        if subtitle.hasPrefix(repeatedTitlePrefix) {
            let trimmedSubtitle = String(subtitle.dropFirst(repeatedTitlePrefix.count))
            return trimmedSubtitle.isEmpty ? nil : trimmedSubtitle
        }

        return subtitle
    }

    private func selectOptionIcon(_ option: WISelectSheetOption, isSelected: Bool) -> some View {
        Image(systemName: option.systemName ?? (isSelected ? "checkmark.circle.fill" : "circle"))
            .font(.system(size: 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
            .frame(width: 40, height: 40)
            .background(WorthItColor.surfaceLowest, in: Circle())
            .overlay {
                Circle()
                    .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
            }
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
