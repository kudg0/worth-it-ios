import SwiftUI

struct AddComparableOptionScreen: View {
    let isEditing: Bool
    let name: Binding<String>
    let pricingModel: Binding<AlternativePricingMode>
    let pricePerKm: Binding<String>
    let pricePerMinute: Binding<String>
    let curvePoints: Binding<[ComparableCurveInputPoint]>
    let pricePerMonth: Binding<String>
    let manualTotal: Binding<String>
    let note: Binding<String>
    let inheritedCostCategories: Binding<Set<String>>
    let breakEven: ScenarioComparison.AlternativeBreakEven?
    let currencyCode: String
    let isIncluded: Binding<Bool>
    let onRemove: () -> Void

    private let editablePricingOptions: [AlternativePricingMode] = [.perDistance, .mixed, .distanceCurve, .perPeriod, .manualEquivalent]

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            hero
            identityFields
            costParametersSection
            dynamicTripRatesSection
            inheritedCostsSection
            controlsSection
        }
        .padding(.bottom, 104)
    }

    private var hero: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: 2) {
                Text(isEditing ? "Edit Comparable" : "New Comparable")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(name.wrappedValue.isEmpty ? "Comparable Option" : name.wrappedValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
    }

    private var identityFields: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            WITextField(label: i18n.t("Comparable Name"), placeholder: i18n.t("Local Taxi Service"), text: name)

            WISelectField(
                label: i18n.t("Pricing Model"),
                options: editablePricingOptions.map(\.title),
                selection: pricingSelection
            )
        }
    }

    private var costParametersSection: some View {
        ComparableEditorIsland(title: i18n.t("Cost Parameters"), systemName: "sum") {
            VStack(spacing: WorthItSpacing.xxl) {
                switch pricingModel.wrappedValue {
                case .perDistance:
                    WITextField(
                        label: i18n.t("Cost per KM"),
                        placeholder: i18n.t("0.00"),
                        text: pricePerKm,
                        leadingText: currencySymbol,
                        trailingText: "/ km",
                        keyboardType: .decimalPad
                    )
                case .mixed:
                    VStack(spacing: WorthItSpacing.xxl) {
                        WITextField(
                            label: i18n.t("Cost per KM"),
                            placeholder: i18n.t("0.00"),
                            text: pricePerKm,
                            leadingText: currencySymbol,
                            trailingText: "/ km",
                            keyboardType: .decimalPad
                        )

                        WITextField(
                            label: i18n.t("Cost per Minute"),
                            placeholder: i18n.t("0.00"),
                            text: pricePerMinute,
                            leadingText: currencySymbol,
                            trailingText: "/ min",
                            keyboardType: .decimalPad
                        )
                    }
                case .distanceCurve:
                    VStack(spacing: WorthItSpacing.l) {
                        Text("Add distances you know. General comparison uses the average of point €/km rates; trip detail uses the closest curve point.")
                            .font(WorthItTypography.caption)
                            .lineSpacing(3)
                            .foregroundStyle(WorthItColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        ForEach(curvePoints.wrappedValue.indices, id: \.self) { index in
                            curvePriceField(
                                index: index,
                                point: Binding(
                                    get: { curvePoints.wrappedValue[index] },
                                    set: { curvePoints.wrappedValue[index] = $0 }
                                ),
                                canRemove: curvePoints.wrappedValue.count > 2
                            ) {
                                curvePoints.wrappedValue.remove(at: index)
                            }
                        }

                        if let curveSummaryCaption {
                            Text(curveSummaryCaption)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(WorthItColor.primaryContainer)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, WorthItSpacing.xs)
                        }

                        Button(action: addCurvePoint) {
                            HStack(spacing: WorthItSpacing.s) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Add distance point")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(WorthItColor.primaryContainer)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                        }
                        .buttonStyle(.plain)
                    }
                case .perPeriod:
                    WITextField(
                        label: i18n.t("Cost per Month"),
                        placeholder: i18n.t("0.00"),
                        text: pricePerMonth,
                        leadingText: currencySymbol,
                        trailingText: "/ mo",
                        keyboardType: .decimalPad
                    )
                case .manualEquivalent, .perTime:
                    WITextField(
                        label: i18n.t("Total Equivalent Cost"),
                        placeholder: i18n.t("0.00"),
                        text: manualTotal,
                        leadingText: currencySymbol,
                        keyboardType: .decimalPad
                    )
                }

                if pricingModel.wrappedValue != .distanceCurve {
                    WITextField(label: i18n.t("Note"), placeholder: i18n.t("City taxi, car share, rental..."), text: note)
                }
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 32) {
            HStack(alignment: .center, spacing: WorthItSpacing.l) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Include in Comparison")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text("Hidden options stay saved, but are ignored in ownership comparison.")
                        .font(.system(size: 12, weight: .regular))
                        .lineSpacing(3)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Toggle("", isOn: isIncluded)
                    .labelsHidden()
                    .tint(WorthItColor.primaryContainer)
            }

            if isEditing {
                removeComparableRow
            }
        }
        .padding(.vertical, WorthItSpacing.xxl)
    }

    @ViewBuilder
    private var dynamicTripRatesSection: some View {
        if let dynamicRateSummary {
            ComparableEditorIsland(title: i18n.t("Trip Rate Breakdown"), systemName: "function") {
                VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                    Text("Savings uses dated trip calculations. Each trip gets its own effective rate, then the card shows the min-max range.")
                        .font(WorthItTypography.caption)
                        .lineSpacing(3)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let dynamicRateBasisText {
                        Text(dynamicRateBasisText)
                            .font(WorthItTypography.caption)
                            .lineSpacing(3)
                            .foregroundStyle(WorthItColor.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                        dynamicSummaryRow(label: "Effective range", value: dynamicRateSummary.rangeText)
                        dynamicSummaryRow(label: "Average", value: dynamicRateSummary.averageText)
                        dynamicSummaryRow(label: "Trips", value: "\(dynamicRateSummary.tripCount)")
                    }
                    .padding(WorthItSpacing.l)
                    .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.l))

                    VStack(alignment: .leading, spacing: WorthItSpacing.m) {
                        Text("Examples")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WorthItColor.textTertiary)
                            .tracking(1.2)
                            .textCase(.uppercase)

                        ForEach(dynamicRateSummary.examples) { example in
                            dynamicExampleRow(example)
                        }
                    }
                }
            }
        }
    }

    private func dynamicSummaryRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: WorthItSpacing.m) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            Spacer(minLength: WorthItSpacing.m)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func dynamicExampleRow(_ example: DynamicRateExample) -> some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(example.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(example.subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: WorthItSpacing.m)

            Text(example.rateText)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .multilineTextAlignment(.trailing)
        }
        .padding(WorthItSpacing.m)
        .background(WorthItColor.surfaceLowest.opacity(0.82), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(WorthItColor.outlineSubtle.opacity(0.95), lineWidth: 1)
        }
    }

    private var removeComparableRow: some View {
        Button(action: onRemove) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.danger)
                    .frame(width: 48, height: 48)
                    .background(WorthItColor.danger.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.l))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Remove comparable")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.danger)

                    Text("Delete this option from comparison settings.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Delete")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(WorthItColor.danger)
                    .padding(.horizontal, WorthItSpacing.s)
                    .frame(height: 26)
                    .background(WorthItColor.danger.opacity(0.10), in: Capsule())

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(WorthItColor.danger.opacity(0.18), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var inheritedCostsSection: some View {
        ComparableEditorIsland(title: i18n.t("Also Applies"), systemName: "plus.circle") {
            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                Text("Choose ownership cost categories that would still happen for this option, like fuel or wash for a rental car.")
                    .font(WorthItTypography.caption)
                    .lineSpacing(3)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WorthItSpacing.m) {
                    ForEach(inheritedCostOptions) { category in
                        inheritedCostToggle(category)
                    }
                }
            }
        }
    }

    private var inheritedCostOptions: [ScenarioOverviewExpenseCategory] {
        [.fuel, .wash, .repair, .tires, .insurance, .other]
    }

    private func inheritedCostToggle(_ category: ScenarioOverviewExpenseCategory) -> some View {
        let isSelected = inheritedCostCategories.wrappedValue.contains(category.costCategory)

        return Button {
            if isSelected {
                inheritedCostCategories.wrappedValue.remove(category.costCategory)
            } else {
                inheritedCostCategories.wrappedValue.insert(category.costCategory)
            }
        } label: {
            HStack(spacing: WorthItSpacing.s) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : category.systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textSecondary)
                    .frame(width: 18)

                Text(category.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.textPrimary : WorthItColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, WorthItSpacing.m)
            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
            .background(isSelected ? WorthItColor.primaryContainer.opacity(0.12) : WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(isSelected ? WorthItColor.primaryContainer.opacity(0.45) : WorthItColor.outlineInput, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func curvePriceField(
        index: Int,
        point: Binding<ComparableCurveInputPoint>,
        canRemove: Bool,
        onRemove: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
                WITextField(
                    label: i18n.t("Distance"),
                    placeholder: i18n.t("12"),
                    text: Binding(
                        get: { point.wrappedValue.distanceKm },
                        set: { point.wrappedValue.distanceKm = $0 }
                    ),
                    trailingText: "km",
                    keyboardType: .decimalPad
                )
                .frame(width: 112)

                WITextField(
                    label: i18n.t("Trip price"),
                    placeholder: i18n.t("0.00"),
                    text: Binding(
                        get: { point.wrappedValue.totalPrice },
                        set: { point.wrappedValue.totalPrice = $0 }
                    ),
                    leadingText: currencySymbol,
                    keyboardType: .decimalPad
                )

                if canRemove {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(hex: 0xFFB4AB))
                            .frame(width: 32, height: 52)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove distance point")
                }
            }

            if let caption = curvePointCaption(at: index) {
                Text(caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 2)
            }
        }
    }

    private func addCurvePoint() {
        curvePoints.wrappedValue.append(ComparableCurveInputPoint())
    }

    private func curvePointCaption(at index: Int) -> String? {
        guard curvePoints.wrappedValue.indices.contains(index),
              let current = curvePointPreview(curvePoints.wrappedValue[index])
        else {
            return nil
        }

        var parts = [
            "\(currencySymbol)\(formatCurveRate(current.rate))/km point rate"
        ]

        if index > 0,
           let previous = curvePointPreview(curvePoints.wrappedValue[index - 1]),
           current.distanceKm > previous.distanceKm {
            let segmentRate = (previous.rate + current.rate) / 2
            parts.append(
                "\(formatCurveNumber(previous.distanceKm))-\(formatCurveNumber(current.distanceKm)) km segment \(currencySymbol)\(formatCurveRate(segmentRate))/km"
            )
        }

        return parts.joined(separator: " · ")
    }

    private var curveSummaryCaption: String? {
        let points = curvePointPreviews
        guard points.count >= 2 else { return nil }

        let pointAverage = points.map(\.rate).reduce(0, +) / Double(points.count)
        let segmentRates = curveSegmentRates(from: points)

        if segmentRates.isEmpty {
            return "Summary: \(currencySymbol)\(formatCurveRate(pointAverage))/km point average"
        }

        let segmentAverage = segmentRates.reduce(0, +) / Double(segmentRates.count)
        guard let minSegment = segmentRates.min(), let maxSegment = segmentRates.max() else {
            return "Summary: \(currencySymbol)\(formatCurveRate(pointAverage))/km point average"
        }

        return "Summary: \(currencySymbol)\(formatCurveRate(pointAverage))/km point average · \(currencySymbol)\(formatCurveRate(segmentAverage))/km segment average · range \(currencySymbol)\(formatCurveRate(minSegment))-\(currencySymbol)\(formatCurveRate(maxSegment))/km"
    }

    private var curvePointPreviews: [CurvePointPreview] {
        curvePoints.wrappedValue
            .compactMap(curvePointPreview)
            .sorted { $0.distanceKm < $1.distanceKm }
    }

    private func curveSegmentRates(from points: [CurvePointPreview]) -> [Double] {
        points.indices.dropFirst().compactMap { index in
            let previous = points[index - 1]
            let current = points[index]
            guard current.distanceKm > previous.distanceKm else { return nil }
            return (previous.rate + current.rate) / 2
        }
    }

    private func curvePointPreview(_ point: ComparableCurveInputPoint) -> CurvePointPreview? {
        guard let distance = curveDouble(point.distanceKm), distance > 0 else { return nil }
        guard let total = curveDouble(point.totalPrice) else { return nil }
        return CurvePointPreview(distanceKm: distance, totalPrice: total)
    }

    private func curveDouble(_ value: String) -> Double? {
        Double(value.replacingOccurrences(of: ",", with: "."))
    }

    private func formatCurveNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func formatCurveRate(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private var dynamicRateSummary: DynamicRateSummary? {
        guard let dynamic = breakEven?.dynamicTripSavings else { return nil }

        let ratedItems = dynamic.items.compactMap { item -> DynamicRatedTrip? in
            guard let rate = item.alternativeCostPerKm,
                  let total = item.alternativeTripCost,
                  item.distanceKm > 0
            else {
                return nil
            }

            return DynamicRatedTrip(
                id: item.usageEventId,
                date: item.date,
                distanceKm: item.distanceKm,
                total: total,
                rate: rate
            )
        }

        guard !ratedItems.isEmpty,
              let minRate = ratedItems.map(\.rate).min(),
              let maxRate = ratedItems.map(\.rate).max()
        else {
            return nil
        }

        let average = ratedItems.map(\.rate).reduce(0, +) / Double(ratedItems.count)
        let rangeText = abs(maxRate - minRate) < 0.0001
            ? "\(money(minRate))/km"
            : "\(money(minRate))-\(money(maxRate))/km"

        return DynamicRateSummary(
            rangeText: rangeText,
            averageText: "\(money(average))/km",
            tripCount: dynamic.tripCount,
            examples: dynamicRateExamples(from: ratedItems)
        )
    }

    private var dynamicRateBasisText: String? {
        guard pricingModel.wrappedValue == .perPeriod,
              let monthlyPrice = curveDouble(pricePerMonth.wrappedValue),
              monthlyPrice > 0
        else {
            return nil
        }

        if inheritedCostCategories.wrappedValue.isEmpty {
            return "For this option: monthly plan is allocated over dated trips, then divided by each trip distance."
        }

        let categories = inheritedCostCategories.wrappedValue
            .sorted()
            .joined(separator: ", ")
        return "For this option: monthly plan is allocated over dated trips, inherited costs (\(categories)) are added, then total is divided by trip distance."
    }

    private func dynamicRateExamples(from trips: [DynamicRatedTrip]) -> [DynamicRateExample] {
        let lowest = trips.min { $0.rate < $1.rate }
        let highest = trips.max { $0.rate < $1.rate }
        let latest = trips.max { $0.date < $1.date }

        var examples: [DynamicRateExample] = []
        for (label, trip) in [("Lowest", lowest), ("Highest", highest), ("Latest", latest)] {
            guard let trip, !examples.contains(where: { $0.id == trip.id }) else { continue }
            examples.append(dynamicRateExample(label: label, trip: trip))
        }

        return examples
    }

    private func dynamicRateExample(label: String, trip: DynamicRatedTrip) -> DynamicRateExample {
        DynamicRateExample(
            id: trip.id,
            title: "\(label): \(formatCurveNumber(trip.distanceKm)) km",
            subtitle: "\(Self.dynamicRateDateFormatter.string(from: trip.date)) • \(money(trip.total)) ÷ \(formatCurveNumber(trip.distanceKm)) km",
            rateText: "\(money(trip.rate))/km"
        )
    }

    private func money(_ value: Double) -> String {
        "\(currencySymbol)\(formatCurveRate(value))"
    }

    private static let dynamicRateDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private var pricingSelection: Binding<String> {
        Binding {
            pricingModel.wrappedValue.title
        } set: { title in
            pricingModel.wrappedValue = editablePricingOptions.first(where: { $0.title == title }) ?? .perDistance
        }
    }

    private var iconName: String {
        let lowerName = name.wrappedValue.lowercased()
        if lowerName.contains("taxi") { return "car.fill" }
        if lowerName.contains("transport") || lowerName.contains("bus") { return "bus.fill" }
        if lowerName.contains("share") { return "car.2.fill" }
        if lowerName.contains("rental") { return "key.fill" }
        return "arrow.triangle.branch"
    }

    private var currencySymbol: String {
        switch currencyCode.uppercased() {
        case "EUR": "€"
        case "USD": "$"
        case "GBP": "£"
        default: currencyCode
        }
    }
}

private struct CurvePointPreview: Hashable {
    let distanceKm: Double
    let totalPrice: Double

    var rate: Double {
        totalPrice / distanceKm
    }
}

private struct DynamicRatedTrip: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let distanceKm: Double
    let total: Double
    let rate: Double
}

private struct DynamicRateSummary: Hashable {
    let rangeText: String
    let averageText: String
    let tripCount: Int
    let examples: [DynamicRateExample]
}

private struct DynamicRateExample: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let rateText: String
}
