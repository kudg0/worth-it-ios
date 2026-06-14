import SwiftUI

enum ScenarioAnalyticsCostPerKmBasis: String, CaseIterable, Identifiable {
    case sincePurchase
    case currentMonth

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sincePurchase: "Since Purchase"
        case .currentMonth: "Current Month"
        }
    }

    var subtitle: String {
        switch self {
        case .sincePurchase: "All ownership costs and distance from day one."
        case .currentMonth: "This month usage and running costs."
        }
    }

    var badgeTitle: String {
        switch self {
        case .sincePurchase: "Since purchase"
        case .currentMonth: "Current month"
        }
    }

    var overviewMetric: ScenarioOverviewMetric {
        switch self {
        case .sincePurchase: .costPerKm
        case .currentMonth: .currentMonthCostPerKm
        }
    }

    static func fromOverviewMetricId(_ id: String) -> ScenarioAnalyticsCostPerKmBasis? {
        switch ScenarioOverviewMetric(rawValue: id) {
        case .costPerKm:
            return .sincePurchase
        case .currentMonthCostPerKm:
            return .currentMonth
        default:
            return nil
        }
    }
}

enum ScenarioAnalyticsDefaultMetric: String, CaseIterable, Identifiable {
    case perKm
    case perMonth
    case lifetimeTotal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .perKm: "Per KM"
        case .perMonth: "Per Month"
        case .lifetimeTotal: "Lifetime"
        }
    }

    var overviewMetric: ScenarioOverviewMetric {
        switch self {
        case .perKm: .costPerKm
        case .perMonth: .monthlyCost
        case .lifetimeTotal: .totalOwnership
        }
    }

    static func fromOverviewMetricId(_ id: String) -> ScenarioAnalyticsDefaultMetric {
        switch ScenarioOverviewMetric(rawValue: id) {
        case .monthlyCost:
            return .perMonth
        case .totalOwnership:
            return .lifetimeTotal
        default:
            return .perKm
        }
    }
}

struct ScenarioAnalyticsModelScreen: View {
    let perKmValue: String
    let monthlyValue: String
    let lifetimeValue: String
    @Binding var includesResidualValue: Bool
    @Binding var defaultMetric: ScenarioAnalyticsDefaultMetric
    @Binding var costPerKmBasis: ScenarioAnalyticsCostPerKmBasis
    @Binding var deltaDisplay: ScenarioAnalyticsDeltaDisplay
    let onReset: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            modelPreviewSection
            costBasisSection
            trendDifferenceSection
            calculationModelSection
        }
    }

    var footer: some View {
        AnalyticsModelFooter(onReset: onReset, onSave: onSave)
    }

    private var modelPreviewSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            previewCard
            defaultMetricPicker
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("MODEL PREVIEW")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(1.6)

                    Text(previewTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                }

                Spacer(minLength: WorthItSpacing.m)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            }

            Text(previewValue)
                .font(.system(size: 38, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-0.8)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            HStack(spacing: WorthItSpacing.s) {
                modelBadge(includesResidualValue ? "Vehicle value included" : "Operating costs only")
                modelBadge(defaultMetric.title)
                if defaultMetric == .perKm {
                    modelBadge(costPerKmBasis.badgeTitle)
                }
                modelBadge(deltaDisplay.title)
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineSubtle.opacity(0.65), lineWidth: 1)
        }
    }

    private var defaultMetricPicker: some View {
        WISegmentedControl(
            items: ScenarioAnalyticsDefaultMetric.allCases.map { ($0.title, $0) },
            selection: $defaultMetric
        )
    }

    private var costBasisSection: some View {
        settingsSection(title: i18n.t("Cost Per KM Basis"), subtitle: i18n.t("Which ownership data should be used as the car baseline.")) {
            HStack(spacing: WorthItSpacing.l) {
                ForEach(ScenarioAnalyticsCostPerKmBasis.allCases) { basis in
                    AnalyticsCostBasisTile(
                        basis: basis,
                        isSelected: costPerKmBasis == basis
                    ) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            costPerKmBasis = basis
                        }
                    }
                }
            }
        }
    }

    private var trendDifferenceSection: some View {
        settingsSection(title: i18n.t("Trend Difference"), subtitle: i18n.t("How trend pills show change against the previous period.")) {
            WISegmentedControl(
                items: ScenarioAnalyticsDeltaDisplay.allCases.map { ($0.title, $0) },
                selection: $deltaDisplay
            )
        }
    }

    private var calculationModelSection: some View {
        settingsSection(title: i18n.t("Calculation Model"), subtitle: i18n.t("Controls what affects ownership cost.")) {
            HStack(alignment: .center, spacing: WorthItSpacing.l) {
                Image(systemName: includesResidualValue ? "car.fill" : "car")
                    .font(.system(size: 18, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Include vehicle residual value")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text("Purchase price minus current or sale value affects cost per km and monthly cost.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Toggle("", isOn: $includesResidualValue)
                    .labelsHidden()
                    .tint(WorthItColor.primaryContainer)
            }
            .padding(WorthItSpacing.l)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
    }

    private func settingsSection<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.4)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.textTertiary)
            }

            content()
        }
    }

    private func modelBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(WorthItColor.primaryContainer)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .padding(.horizontal, WorthItSpacing.m)
            .frame(height: 28)
            .background(WorthItColor.primaryContainer.opacity(0.10), in: Capsule())
    }

    private var previewTitle: String {
        switch defaultMetric {
        case .perKm:
            switch costPerKmBasis {
            case .sincePurchase: "Cost per distance since purchase"
            case .currentMonth: "Cost per distance this month"
            }
        case .perMonth: "Default monthly cost"
        case .lifetimeTotal: "Default lifetime ownership"
        }
    }

    private var previewValue: String {
        switch defaultMetric {
        case .perKm: perKmValue
        case .perMonth: monthlyValue
        case .lifetimeTotal: lifetimeValue
        }
    }
}

private struct AnalyticsCostBasisTile: View {
    let basis: ScenarioAnalyticsCostPerKmBasis
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                HStack {
                    Image(systemName: iconName)
                        .font(.system(size: 15, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(iconColor)

                    Spacer(minLength: 0)

                    Circle()
                        .fill(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary.opacity(0.24))
                        .frame(width: 8, height: 8)
                }

                Text(basis.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(titleColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(basis.subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(subtitleColor)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(borderColor, lineWidth: isSelected ? 1.2 : 1)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var iconName: String {
        switch basis {
        case .sincePurchase: "calendar.badge.clock"
        case .currentMonth: "calendar"
        }
    }

    private var backgroundColor: Color {
        isSelected ? WorthItColor.primaryContainer.opacity(0.16) : WorthItColor.surfaceContainerLow
    }

    private var borderColor: Color {
        isSelected ? WorthItColor.primaryContainer.opacity(0.42) : WorthItColor.outlineSubtle
    }

    private var titleColor: Color {
        isSelected ? WorthItColor.primaryContainer : WorthItColor.textPrimary
    }

    private var subtitleColor: Color {
        isSelected ? WorthItColor.primaryContainer.opacity(0.78) : WorthItColor.textSecondary
    }

    private var iconColor: Color {
        isSelected ? WorthItColor.primaryContainer : WorthItColor.textSecondary
    }
}
