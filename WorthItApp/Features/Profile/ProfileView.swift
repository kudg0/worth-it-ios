import SwiftUI

struct ProfileView: View {
    let user: AuthUser?
    let onLoadSettings: () async throws -> UserSettings
    let onLoadSettingsOptions: () async throws -> UserSettingsOptions
    let onUpdateSettings: (UserSettingsPatch) async throws -> UserSettings
    let onEditProfile: () -> Void
    let onLogout: () -> Void

    @State private var settings = UserSettings(distanceUnit: "km", currency: "EUR", locale: "en-CY")
    @State private var settingsOptions: UserSettingsOptions?
    @State private var activeSelect: ProfileSettingsSelect?
    @State private var settingsError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            topBar
            identityHeader

            VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
                ProfileSection(title: "Identity") {
                    ProfileRow(title: "Name", value: displayName, systemIcon: "person")
                    ProfileRow(title: "Email", value: email, systemIcon: "envelope")
                }

                ProfileSection(title: "Localization") {
                    ProfileSelectableRow(
                        title: "Region",
                        value: regionTitle,
                        systemIcon: "globe.europe.africa"
                    ) {
                        openSelect(.region)
                    }
                    ProfileSelectableRow(title: "Currency", value: settings.currency, systemIcon: "banknote") {
                        openSelect(.currency)
                    }
                    ProfileSelectableRow(title: "Distance", value: distanceTitle, systemIcon: "ruler") {
                        openSelect(.distance)
                    }
                }

                if let settingsError {
                    WITipInfo(title: "Settings not saved", bodyText: settingsError, size: .small, tone: .info)
                }

                ProfileSection(title: "Security") {
                    ProfileRow(
                        title: "Sign-in Method",
                        value: "Email connected",
                        systemIcon: "shield.checkered",
                        valueColor: WorthItColor.primaryContainer,
                        isSelectable: true
                    )
                }
            }

            signOutButton
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .task {
            await loadSettings()
        }
        .sheet(isPresented: Binding(
            get: { activeSelect != nil },
            set: { isPresented in
                if !isPresented {
                    activeSelect = nil
                }
            }
        )) {
            if let activeSelect, let settingsOptions {
                ProfileSettingsSelectSheet(
                    title: activeSelect.title,
                    options: activeSelect.options(from: settingsOptions),
                    selectedId: activeSelect.selectedId(from: settings),
                    infoText: activeSelect.infoText,
                    onSave: { selectedId in
                        try await save(activeSelect.patch(selectedId))
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Worth It")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color(hex: 0xD8E2FF))
                .lineLimit(1)

            Spacer(minLength: WorthItSpacing.l)

            avatar
        }
        .frame(height: 48)
    }

    private var identityHeader: some View {
        VStack(spacing: WorthItSpacing.s) {
            Text(displayName)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(email)
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Button(action: onEditProfile) {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(hex: 0xD8E2FF))
                .padding(.horizontal, 34)
                .frame(height: 46)
                .background(WorthItColor.surfaceContainerLow, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, WorthItSpacing.l)
        }
        .frame(maxWidth: .infinity)
    }

    private var signOutButton: some View {
        Button(action: onLogout) {
            HStack(spacing: WorthItSpacing.s) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .semibold))

                Text("Sign Out")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color(hex: 0xFFB4AB))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(Color(hex: 0xFFB4AB).opacity(0.20), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
        .padding(.top, WorthItSpacing.s)
        .accessibilityLabel("Sign out")
    }

    private var avatar: some View {
        Text(initials)
            .font(.system(size: 15, weight: .heavy))
            .foregroundStyle(WorthItColor.primaryContainer)
            .frame(width: 48, height: 48)
            .background(WorthItColor.surfaceContainerHigh, in: Circle())
            .overlay {
                Circle()
                    .stroke(WorthItColor.outlineInput, lineWidth: 2)
            }
            .shadow(color: WorthItColor.primaryContainer.opacity(0.15), radius: 30)
    }

    private var displayName: String {
        let trimmedName = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedName.isEmpty ? "Worth It User" : trimmedName
    }

    private var email: String {
        user?.email ?? "Not connected"
    }

    private var regionTitle: String {
        ProfileSettingsSelect.region.title(for: settings.locale, in: settingsOptions)
    }

    private var distanceTitle: String {
        ProfileSettingsSelect.distance.title(for: settings.distanceUnit, in: settingsOptions)
    }

    private var initials: String {
        let parts = displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }

        let value = String(parts).uppercased()
        return value.isEmpty ? "WI" : value
    }

    private func loadSettings() async {
        do {
            async let loadedSettings = onLoadSettings()
            async let loadedOptions = onLoadSettingsOptions()
            settings = try await loadedSettings
            settingsOptions = try await loadedOptions
            settingsError = nil
        } catch {
            settingsError = "Could not load profile preferences."
        }
    }

    private func openSelect(_ select: ProfileSettingsSelect) {
        guard settingsOptions != nil else {
            settingsError = "Could not load available preference options."
            return
        }

        activeSelect = select
    }

    private func save(_ patch: UserSettingsPatch) async throws {
        do {
            settings = try await onUpdateSettings(patch)
            settingsError = nil
        } catch {
            settingsError = "Could not update this preference. Check connection and try again."
            throw error
        }
    }
}

private enum ProfileSettingsSelect: Identifiable {
    case region
    case currency
    case distance

    var id: String {
        switch self {
        case .region: "region"
        case .currency: "currency"
        case .distance: "distance"
        }
    }

    var title: String {
        switch self {
        case .region: "Region"
        case .currency: "Currency"
        case .distance: "Distance"
        }
    }

    var infoText: String {
        switch self {
        case .region:
            "This changes the default region for new scenarios. Existing scenarios keep their own saved settings and analytics stay based on the scenario configuration."
        case .currency:
            "This changes the default currency for new scenarios. Existing scenarios keep their own currency, so past ownership analytics are not converted here."
        case .distance:
            "This changes your default distance unit for new scenarios. Existing scenarios keep their own distance settings and continue rendering from their scenario configuration."
        }
    }

    func options(from settingsOptions: UserSettingsOptions) -> [WISelectSheetOption] {
        let options: [UserSettingsOption]

        switch self {
        case .region:
            options = settingsOptions.regions
        case .currency:
            options = settingsOptions.currencies
        case .distance:
            options = settingsOptions.distanceUnits
        }

        return options.map { option in
            WISelectSheetOption(
                id: option.id,
                title: option.title,
                systemName: systemName(for: option.id),
                textBadge: textBadge(for: option.id),
                groupId: option.groupId,
                groupTitle: option.groupTitle
            )
        }
    }

    func selectedId(from settings: UserSettings) -> String {
        switch self {
        case .region: settings.locale
        case .currency: settings.currency
        case .distance: settings.distanceUnit
        }
    }

    func patch(_ selectedId: String) -> UserSettingsPatch {
        switch self {
        case .region:
            UserSettingsPatch(locale: selectedId)
        case .currency:
            UserSettingsPatch(currency: selectedId)
        case .distance:
            UserSettingsPatch(distanceUnit: selectedId)
        }
    }

    func title(for id: String, in settingsOptions: UserSettingsOptions?) -> String {
        guard let settingsOptions else { return id }
        return options(from: settingsOptions).first(where: { $0.id == id })?.title ?? id
    }

    private func systemName(for id: String) -> String {
        switch self {
        case .region:
            id == "en-US" ? "globe.americas" : "globe.europe.africa"
        case .currency:
            switch id {
            case "EUR": "eurosign"
            case "USD": "dollarsign"
            case "GBP": "sterlingsign"
            case "JPY", "CNY": "yensign"
            case "CHF": "francsign"
            case "INR": "indianrupeesign"
            case "RUB": "rublesign"
            case "KRW", "KPW": "wonsign"
            case "TRY": "turkishlirasign"
            case "ILS": "shekelsign"
            case "THB": "bahtsign"
            case "UAH": "hryvniasign"
            case "NGN": "nairasign"
            case "PHP", "MXN", "ARS", "CLP", "COP", "CUP", "DOP", "UYU": "pesosign"
            case "VND": "dongsign"
            case "KZT": "tengesign"
            case "GEL": "larisign"
            case "AZN", "TMT": "manatsign"
            case "LAK": "kipsign"
            case "MNT": "tugriksign"
            case "PYG": "guaranisign"
            case "CRC": "coloncurrencysign"
            case "GHS": "cedisign"
            default: ""
            }
        case .distance:
            "ruler"
        }
    }

    private func textBadge(for id: String) -> String? {
        guard case .currency = self else { return nil }
        return systemName(for: id).isEmpty ? id : nil
    }
}

private struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)
                .padding(.horizontal, WorthItSpacing.s)

            VStack(spacing: 0) {
                content
            }
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
            .shadow(color: .black.opacity(0.20), radius: 24, y: 4)
        }
    }
}

private struct ProfileSelectableRow: View {
    let title: String
    let value: String
    let systemIcon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ProfileRow(
                title: title,
                value: value,
                systemIcon: systemIcon,
                isSelectable: true
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ProfileRow: View {
    let title: String
    let value: String
    let systemIcon: String
    var valueColor: Color = WorthItColor.textSecondary
    var isSelectable = false

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemIcon)
                .font(.system(size: 16, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(WorthItColor.textPrimary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textPrimary)

            Spacer(minLength: WorthItSpacing.m)

            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            if isSelectable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)
            }
        }
        .frame(minHeight: 52)
        .padding(.horizontal, WorthItSpacing.l)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: 0x313442).opacity(0.50))
                .frame(height: 1)
                .padding(.leading, 52)
        }
    }
}

private struct ProfileSettingsSelectSheet: View {
    let title: String
    let options: [WISelectSheetOption]
    let selectedId: String
    let infoText: String
    let onSave: (String) async throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftId: String
    @State private var searchText = ""
    @State private var isSaving = false
    @State private var errorText: String?

    init(
        title: String,
        options: [WISelectSheetOption],
        selectedId: String,
        infoText: String,
        onSave: @escaping (String) async throws -> Void
    ) {
        self.title = title
        self.options = options
        self.selectedId = selectedId
        self.infoText = infoText
        self.onSave = onSave
        _draftId = State(initialValue: selectedId)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                WorthItColor.pageBackground.ignoresSafeArea()

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: WorthItSpacing.s) {
                            if shouldShowSearch {
                                searchField
                                    .padding(.bottom, WorthItSpacing.s)
                            }

                            ForEach(filteredSections) { section in
                                if let title = section.title {
                                    sectionHeader(title)
                                        .padding(.top, section.id == filteredSections.first?.id ? 0 : WorthItSpacing.m)
                                }

                                ForEach(section.options) { option in
                                    optionRow(option)
                                        .id(option.id)
                                }
                            }

                            if filteredSections.isEmpty {
                                WITipInfo(title: "No results", bodyText: "Try another search.", size: .small, tone: .info)
                                    .padding(.top, WorthItSpacing.m)
                            }

                            if let errorText {
                                WITipInfo(title: "Not saved", bodyText: errorText, size: .small, tone: .info)
                                    .padding(.top, WorthItSpacing.m)
                            }
                        }
                        .padding(WorthItSpacing.xxl)
                        .padding(.bottom, 92)
                    }
                    .task {
                        await scrollSelectedOptionIntoView(scrollProxy)
                    }
                }

                saveBar
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

        return options.filter { option in
            option.title.localizedCaseInsensitiveContains(query) ||
                option.id.localizedCaseInsensitiveContains(query)
        }
    }

    private var filteredSections: [ProfileSettingsOptionSection] {
        let groupedOptions = filteredOptions.reduce(into: [String: [WISelectSheetOption]]()) { result, option in
            result[option.groupId ?? "options", default: []].append(option)
        }

        return groupedOptions
            .map { groupId, options in
                ProfileSettingsOptionSection(
                    id: groupId,
                    title: options.first?.groupTitle,
                    options: options
                )
            }
            .sorted { left, right in
                sectionPriority(left.id) == sectionPriority(right.id)
                    ? left.id < right.id
                    : sectionPriority(left.id) < sectionPriority(right.id)
            }
            .filter { !$0.options.isEmpty }
    }

    private func sectionPriority(_ id: String) -> Int {
        switch id {
        case "regional": 0
        case "europe": 10
        case "asia": 20
        case "africa": 30
        case "americas": 40
        case "oceania": 50
        case "all": 90
        case "other": 95
        default: 100
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

    @MainActor
    private func scrollSelectedOptionIntoView(_ scrollProxy: ScrollViewProxy) async {
        guard filteredOptions.contains(where: { $0.id == selectedId }) else { return }

        try? await Task.sleep(nanoseconds: 250_000_000)
        withAnimation(.snappy(duration: 0.28)) {
            scrollProxy.scrollTo(selectedId, anchor: .center)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(WorthItColor.textTertiary)
            .tracking(1.2)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, WorthItSpacing.s)
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground.opacity(0.94),
                    WorthItColor.pageBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)

            WITipInfo(title: "Default setting", bodyText: infoText, size: .small, tone: .info)
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.bottom, WorthItSpacing.m)
                .background(WorthItColor.pageBackground)

            WIButton(title: isSaving ? "SAVING..." : "SAVE", height: 56) {
                save()
            }
            .opacity(isSaving ? 0.62 : 1)
            .allowsHitTesting(!isSaving)
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.bottom, WorthItSpacing.xxl)
            .background(WorthItColor.pageBackground)
        }
    }

    private func optionRow(_ option: WISelectSheetOption) -> some View {
        let isSelected = draftId == option.id

        return HStack(spacing: WorthItSpacing.m) {
            optionIcon(option, isSelected: isSelected)

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
        .contentShape(Rectangle())
        .onTapGesture {
            draftId = option.id
            errorText = nil
        }
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func optionIcon(_ option: WISelectSheetOption, isSelected: Bool) -> some View {
        if let textBadge = option.textBadge {
            Text(textBadge)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .frame(width: 34, height: 24)
                .background(
                    (isSelected ? WorthItColor.primaryContainer.opacity(0.14) : WorthItColor.surfaceLowest),
                    in: RoundedRectangle(cornerRadius: WorthItRadius.s)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.s)
                        .stroke(isSelected ? WorthItColor.primaryContainer.opacity(0.45) : WorthItColor.outlineInput, lineWidth: 1)
                }
        } else {
            Image(systemName: option.systemName ?? (isSelected ? "checkmark.circle.fill" : "circle"))
                .font(.system(size: 18, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                .frame(width: 34)
        }
    }

    private func save() {
        isSaving = true
        errorText = nil

        Task {
            do {
                try await onSave(draftId)
                dismiss()
            } catch {
                errorText = "Could not save this setting."
            }

            isSaving = false
        }
    }
}

private struct ProfileSettingsOptionSection: Identifiable {
    let id: String
    let title: String?
    let options: [WISelectSheetOption]
}
