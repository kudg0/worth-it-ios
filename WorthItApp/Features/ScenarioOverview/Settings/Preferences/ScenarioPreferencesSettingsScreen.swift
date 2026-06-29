import SwiftUI

struct ScenarioPreferencesSettingsScreen: View {
    let currencyOptions: [WISelectSheetOption]
    let regionOptions: [WISelectSheetOption]
    let distanceOptions: [WISelectSheetOption]
    let currencyChangeAllowed: Bool
    let currencyChangeBlockedReason: String?
    let isLoading: Bool
    let isSaving: Bool
    let errorText: String?
    @Binding var currency: String
    @Binding var region: String
    @Binding var distanceUnit: String
    let onRetry: () -> Void
    let onSave: () -> Void
    let onDismissError: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            header

            if isLoading {
                loadingCard
            } else {
                preferencesCard
                explanationCard
            }

            if let errorText {
                WITipInfo(
                    title: i18n.t("Settings not saved"),
                    bodyText: errorText,
                    size: .small,
                    tone: .danger,
                    onDismiss: onDismissError
                )
                .task(id: errorText) {
                    try? await Task.sleep(for: .seconds(3))
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        onDismissError()
                    }
                }
            }
        }
    }

    var footer: some View {
        VStack(spacing: WorthItSpacing.m) {
            WIButton(title: isSaving ? i18n.t("Saving") : i18n.t("Save Settings"), height: 56) {
                onSave()
            }
            .opacity(isSaving || isLoading ? 0.62 : 1)
            .allowsHitTesting(!isSaving && !isLoading)
        }
        .padding(.horizontal, WorthItSpacing.xxl)
        .padding(.bottom, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(i18n.t("Scenario Preferences"))
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            Text(i18n.t("Display currency, region, and distance unit for this car."))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var loadingCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            ProgressView()
                .tint(WorthItColor.primaryContainer)
            Text(i18n.t("Loading scenario settings"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var preferencesCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            selectRow(
                title: i18n.t("Region"),
                subtitle: i18n.t("Used for scenario defaults and future regional assumptions."),
                icon: "globe.europe.africa.fill",
                options: regionOptions,
                selection: $region
            )

            selectRow(
                title: i18n.t("Currency"),
                subtitle: currencyChangeAllowed
                    ? i18n.t("Used for scenario amounts and analytics display.")
                    : (currencyChangeBlockedReason ?? i18n.t("Currency is locked after money records exist.")),
                icon: "banknote.fill",
                options: currencyOptions,
                selection: $currency,
                isEnabled: currencyChangeAllowed
            )

            selectRow(
                title: i18n.t("Distance Unit"),
                subtitle: i18n.t("Controls mileage entry and service distance display."),
                icon: "ruler.fill",
                options: distanceOptions,
                selection: $distanceUnit
            )
        }
        .padding(WorthItSpacing.xxl)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineSubtle.opacity(0.60), lineWidth: 1)
        }
    }

    private var explanationCard: some View {
        WITipInfo(
            title: i18n.t("Scenario override"),
            bodyText: i18n.t("These settings affect this scenario only. Profile defaults still apply to new cars."),
            size: .small,
            tone: .info
        )
    }

    private func selectRow(
        title: String,
        subtitle: String,
        icon: String,
        options: [WISelectSheetOption],
        selection: Binding<String>,
        isEnabled: Bool = true
    ) -> some View {
        WISelectControl(title: title, options: options, selectedId: selection) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isEnabled ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                    .frame(width: 42, height: 42)
                    .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: WorthItSpacing.s)

                Text(optionTitle(selection.wrappedValue, in: options))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isEnabled ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }
            .padding(WorthItSpacing.l)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .opacity(isEnabled ? 1 : 0.62)
        }
        .allowsHitTesting(isEnabled)
    }

    private func optionTitle(_ id: String, in options: [WISelectSheetOption]) -> String {
        options.first(where: { $0.id == id })?.title ?? id
    }
}
