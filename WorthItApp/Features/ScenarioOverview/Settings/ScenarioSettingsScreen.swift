import SwiftUI

struct ScenarioSettingsScreen: View {
    struct SettingsItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let status: String
        let systemIcon: String
        var accentColor: Color = WorthItColor.primaryContainer
        var isDestructive = false
        let action: () -> Void
    }

    let scenarioName: String
    let vehicleSummary: String
    let acquisitionSummary: String
    let resaleSummary: String
    let analyticsSummary: String
    let comparisonSummary: String
    let preferencesSummary: String
    let onEditScenario: () -> Void
    let onOpenAnalytics: () -> Void
    let onOpenComparison: () -> Void
    let onOpenPreferences: () -> Void
    let onDeleteScenario: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            header
            editScenarioCard
            settingsGroups
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(scenarioName)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-0.6)

            Text("Scenario controls and analytics model")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
        }
    }

    private var editScenarioCard: some View {
        Button(action: onEditScenario) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                HStack(alignment: .top, spacing: WorthItSpacing.l) {
                    iconTile(systemName: "car.fill", color: WorthItColor.primaryContainer)

                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text("Edit Scenario")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text("Vehicle, acquisition, odometer and resale")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: WorthItSpacing.s)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .padding(.top, 6)
                }

                VStack(spacing: WorthItSpacing.s) {
                    compactInfoRow(title: i18n.t("Vehicle"), value: vehicleSummary)
                    compactInfoRow(title: i18n.t("Acquisition"), value: acquisitionSummary)
                    compactInfoRow(title: i18n.t("Current value"), value: resaleSummary)
                }
            }
            .padding(WorthItSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(WorthItColor.outlineSubtle.opacity(0.50), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var settingsGroups: some View {
        VStack(spacing: WorthItSpacing.m) {
            settingsRow(
                SettingsItem(
                    id: "analytics",
                    title: i18n.t("Analytics Model"),
                    subtitle: i18n.t("Cost per km inputs and calculation switches"),
                    status: analyticsSummary,
                    systemIcon: "slider.horizontal.3",
                    action: onOpenAnalytics
                )
            )

            settingsRow(
                SettingsItem(
                    id: "comparison",
                    title: i18n.t("Comparison"),
                    subtitle: i18n.t("Option pool and efficiency defaults"),
                    status: comparisonSummary,
                    systemIcon: "arrow.left.arrow.right",
                    action: onOpenComparison
                )
            )

            settingsRow(
                SettingsItem(
                    id: "preferences",
                    title: i18n.t("Preferences"),
                    subtitle: i18n.t("Currency, region and distance units"),
                    status: preferencesSummary,
                    systemIcon: "globe.europe.africa.fill",
                    action: onOpenPreferences
                )
            )

            settingsRow(
                SettingsItem(
                    id: "delete",
                    title: i18n.t("Delete Scenario"),
                    subtitle: i18n.t("Remove scenario and related entries"),
                    status: "Delete",
                    systemIcon: "trash.fill",
                    accentColor: WorthItColor.danger,
                    isDestructive: true,
                    action: onDeleteScenario
                )
            )
        }
    }

    private func settingsRow(_ item: SettingsItem) -> some View {
        Button(action: item.action) {
            HStack(spacing: WorthItSpacing.m) {
                iconTile(systemName: item.systemIcon, color: item.accentColor, size: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(item.isDestructive ? WorthItColor.danger : WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer(minLength: WorthItSpacing.s)

                Text(item.status)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(item.isDestructive ? WorthItColor.danger : WorthItColor.primaryContainer)
                    .lineLimit(1)
                    .padding(.horizontal, WorthItSpacing.s)
                    .frame(height: 26)
                    .background(
                        (item.isDestructive ? WorthItColor.danger : WorthItColor.primaryContainer).opacity(0.10),
                        in: Capsule()
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }

    private func compactInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)

            Spacer(minLength: WorthItSpacing.s)

            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .padding(.horizontal, WorthItSpacing.m)
        .frame(height: 34)
        .background(WorthItColor.surfaceLowest.opacity(0.70), in: RoundedRectangle(cornerRadius: WorthItRadius.s))
    }

    private func iconTile(systemName: String, color: Color, size: CGFloat = 52) -> some View {
        Image(systemName: systemName)
            .font(.system(size: size == 52 ? 18 : 15, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
