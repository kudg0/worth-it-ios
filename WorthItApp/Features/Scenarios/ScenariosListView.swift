import SwiftUI

struct ScenariosListView: View {
    enum Tab: Hashable {
        case scenarios
        case profile
    }

    @Environment(\.i18n) private var i18n

    let repository: ScenarioRepository
    let refreshToken: Int
    let profileUser: AuthUser?
    let onCreateScenario: () -> Void
    let onOpenScenario: (ScenarioListItem) -> Void
    let onScenariosLoaded: ([ScenarioListItem]) -> Void
    let onProfileUpdated: (EditProfileDraft) async throws -> AuthUser
    let onLoadUserSettings: () async throws -> UserSettings
    let onLoadUserSettingsOptions: () async throws -> UserSettingsOptions
    let onUpdateUserSettings: (UserSettingsPatch) async throws -> UserSettings
    let onLogout: () -> Void
    private let stickyHeaderHeight: CGFloat = 154
    private let stickyFadeHeight: CGFloat = 42

    @State private var scenarios: [ScenarioListItem] = []
    @State private var selectedTab: Tab = .scenarios
    @State private var isEditingProfile = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()
            WITopSpotlight()

            if isEditingProfile {
                EditProfileScreen(
                    user: profileUser,
                    onSave: { draft in
                        let updatedUser = try await onProfileUpdated(draft)
                        isEditingProfile = false
                        return updatedUser
                    },
                    onDiscard: {
                        isEditingProfile = false
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                        content
                    }
                    .padding(WorthItSpacing.xl)
                    .padding(.top, selectedTab == .scenarios ? stickyHeaderHeight : WorthItSpacing.xl)
                    .padding(.bottom, 132)
                }

                if selectedTab == .scenarios {
                    VStack(spacing: 0) {
                        stickyHeader
                        stickyFade
                        Spacer(minLength: 0)
                    }
                    .zIndex(1)
                }

                bottomNav
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .task(id: refreshToken) {
            await load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .scenarios:
            scenariosContent
        case .profile:
            ProfileView(
                user: profileUser,
                onLoadSettings: onLoadUserSettings,
                onLoadSettingsOptions: onLoadUserSettingsOptions,
                onUpdateSettings: onUpdateUserSettings,
                onEditProfile: {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isEditingProfile = true
                    }
                },
                onLogout: onLogout
            )
        }
    }

    @ViewBuilder
    private var scenariosContent: some View {
        if isLoading {
            ProgressView()
                .tint(WorthItColor.primaryContainer)
                .frame(maxWidth: .infinity, minHeight: 180)
        } else if let errorMessage {
            ErrorStateView(message: errorMessage) {
                Task { await load() }
            }
        } else if scenarios.isEmpty {
            emptyState
        } else {
            scenarioList
        }
    }

    private var stickyHeader: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            ZStack {
                Text(i18n.t(.brand.name))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                HStack {
                    Spacer()
                    WIIconButton(systemName: "plus", accessibilityLabel: i18n.t(.scenarios.actions.create.accessibilityLabel), style: .plain) {
                        onCreateScenario()
                    }
                }
            }

            header
        }
        .padding(.horizontal, WorthItSpacing.xl)
        .padding(.top, WorthItSpacing.m)
        .padding(.bottom, WorthItSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            WorthItColor.pageBackground.opacity(0.86)
                .ignoresSafeArea(edges: .top)
        }
    }

    private var stickyFade: some View {
        LinearGradient(
            colors: [
                WorthItColor.pageBackground,
                WorthItColor.pageBackground.opacity(0.80),
                WorthItColor.pageBackground.opacity(0.36),
                WorthItColor.pageBackground.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: stickyFadeHeight)
        .allowsHitTesting(false)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(i18n.t(.scenarios.title))
                .font(WorthItTypography.headline)
                .foregroundStyle(WorthItColor.textPrimary)
            Text(i18n.t(.scenarios.subtitle))
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            Button {
                onCreateScenario()
            } label: {
                WIScenarioCard(
                    mode: .create,
                    title: i18n.t(.scenarios.cards.create.title)
                )
            }
            .buttonStyle(.plain)

            WIButton(title: i18n.t(.scenarios.actions.create.title), iconSystemName: "plus") {
                onCreateScenario()
            }
        }
    }

    private var scenarioList: some View {
        LazyVStack(spacing: WorthItSpacing.m) {
            ForEach(scenarios) { scenario in
                Button {
                    onOpenScenario(scenario)
                } label: {
                    WIScenarioCard(
                        title: scenario.name,
                        subtitle: i18n.t(.scenarios.card.type.carOwnership),
                        metric1: WIScenarioMetric(label: i18n.t(.scenarios.metrics.purchase), value: scenario.formattedPurchasePrice),
                        metric2: WIScenarioMetric(label: i18n.t(.scenarios.metrics.odometer), value: scenario.formattedOdometer)
                    )
                }
                .buttonStyle(.plain)
            }

            Button {
                onCreateScenario()
            } label: {
                WIScenarioCard(
                    mode: .create,
                    title: i18n.t(.scenarios.cards.create.title)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            scenarios = try await repository.listScenarios()
            onScenariosLoaded(scenarios)
        } catch {
            errorMessage = String(describing: error)
        }
    }

    private func createScenario() async {
        do {
            let scenario = try await repository.createSmokeScenario()
            scenarios.insert(scenario, at: 0)
        } catch {
            errorMessage = String(describing: error)
        }
    }

    private var bottomNav: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    WorthItColor.pageBackground.opacity(0),
                    WorthItColor.pageBackground.opacity(0.92),
                    WorthItColor.pageBackground
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)

            HStack {
                bottomNavItem(tab: .scenarios, systemName: "list.bullet.rectangle.fill", accessibilityLabel: i18n.t(.tabs.scenarios))
                bottomNavItem(tab: .profile, systemName: "person.fill", accessibilityLabel: i18n.t(.tabs.profile))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.top, WorthItSpacing.l)
            .padding(.bottom, 28)
            .background {
                WorthItColor.pageBackground
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: WorthItRadius.l, topTrailingRadius: WorthItRadius.l))
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(WorthItColor.outlineSubtle)
                            .frame(height: 1)
                    }
                    .shadow(color: .black.opacity(0.30), radius: 24, y: -8)
            }
        }
    }

    private func bottomNavItem(tab: Tab, systemName: String, accessibilityLabel: String) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.20)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: WorthItSpacing.xs) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.82))
                    .frame(width: 34, height: 28)

                Circle()
                    .fill(isSelected ? WorthItColor.primaryContainer : Color.clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: isSelected ? WorthItColor.primaryContainer.opacity(0.80) : Color.clear, radius: 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct ErrorStateView: View {
    @Environment(\.i18n) private var i18n

    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            HStack(alignment: .top, spacing: WorthItSpacing.m) {
                ZStack {
                    Circle()
                        .fill(WorthItColor.surfaceContainerHigh)
                        .frame(width: 52, height: 52)

                    Image(systemName: "wifi.slash")
                        .font(.system(size: 22, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(WorthItColor.primaryContainer)
                }

                VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                    Text(i18n.t(.scenarios.offline.title))
                        .font(WorthItTypography.cardTitle)
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(i18n.t(.scenarios.offline.body))
                        .font(WorthItTypography.bodySmall)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            WIButton(title: i18n.t(.common.actions.retry), iconSystemName: "arrow.clockwise", action: retry)
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}

private extension ScenarioListItem {
    var formattedPurchasePrice: String {
        let decimal = Decimal(string: purchasePrice) ?? 0
        return "\(currency) \(Self.formatDecimal(decimal, fractionDigits: 0))"
    }

    var formattedOdometer: String {
        guard let purchaseOdometer else { return "—" }
        return "\(Self.formatInt(purchaseOdometer)) km"
    }

    private static func formatDecimal(_ value: Decimal, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumFractionDigits = fractionDigits
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0"
    }

    private static func formatInt(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
