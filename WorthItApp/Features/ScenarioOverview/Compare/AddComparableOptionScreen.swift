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
    let currencyCode: String
    let isIncluded: Binding<Bool>
    let onRemove: () -> Void

    private let editablePricingOptions: [AlternativePricingMode] = [.perDistance, .mixed, .distanceCurve, .perPeriod, .manualEquivalent]

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            hero
            identityFields
            costParametersSection
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
            WITextField(label: "Comparable Name", placeholder: "Local Taxi Service", text: name)

            WISelectField(
                label: "Pricing Model",
                options: editablePricingOptions.map(\.title),
                selection: pricingSelection
            )
        }
    }

    private var costParametersSection: some View {
        ComparableEditorIsland(title: "Cost Parameters", systemName: "sum") {
            VStack(spacing: WorthItSpacing.xxl) {
                switch pricingModel.wrappedValue {
                case .perDistance:
                    WITextField(
                        label: "Cost per KM",
                        placeholder: "0.00",
                        text: pricePerKm,
                        leadingText: currencySymbol,
                        trailingText: "/ km",
                        keyboardType: .decimalPad
                    )
                case .mixed:
                    VStack(spacing: WorthItSpacing.xxl) {
                        WITextField(
                            label: "Cost per KM",
                            placeholder: "0.00",
                            text: pricePerKm,
                            leadingText: currencySymbol,
                            trailingText: "/ km",
                            keyboardType: .decimalPad
                        )

                        WITextField(
                            label: "Cost per Minute",
                            placeholder: "0.00",
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
                                point: Binding(
                                    get: { curvePoints.wrappedValue[index] },
                                    set: { curvePoints.wrappedValue[index] = $0 }
                                ),
                                canRemove: curvePoints.wrappedValue.count > 2
                            ) {
                                curvePoints.wrappedValue.remove(at: index)
                            }
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
                        label: "Cost per Month",
                        placeholder: "0.00",
                        text: pricePerMonth,
                        leadingText: currencySymbol,
                        trailingText: "/ mo",
                        keyboardType: .decimalPad
                    )
                case .manualEquivalent, .perTime:
                    WITextField(
                        label: "Total Equivalent Cost",
                        placeholder: "0.00",
                        text: manualTotal,
                        leadingText: currencySymbol,
                        keyboardType: .decimalPad
                    )
                }

                if pricingModel.wrappedValue == .distanceCurve {
                    distanceCurveBreakdown
                } else {
                    WITextField(label: "Note", placeholder: "City taxi, car share, rental...", text: note)
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
        ComparableEditorIsland(title: "Also Applies", systemName: "plus.circle") {
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
        point: Binding<ComparableCurveInputPoint>,
        canRemove: Bool,
        onRemove: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .bottom, spacing: WorthItSpacing.m) {
            WITextField(
                label: "Distance",
                placeholder: "12",
                text: Binding(
                    get: { point.wrappedValue.distanceKm },
                    set: { point.wrappedValue.distanceKm = $0 }
                ),
                trailingText: "km",
                keyboardType: .decimalPad
            )
            .frame(width: 112)

            WITextField(
                label: "Trip price",
                placeholder: "0.00",
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
    }

    private func addCurvePoint() {
        curvePoints.wrappedValue.append(ComparableCurveInputPoint())
    }

    private var distanceCurveBreakdown: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Curve Average")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(1.2)
                        .textCase(.uppercase)

                    Text("Average of known point €/km rates.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textTertiary)
                }

                Spacer(minLength: WorthItSpacing.m)

                Text(distanceCurveAverageLabel)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                ForEach(distanceCurvePointRows, id: \.self) { row in
                    Text(row)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !distanceCurveSegmentRows.isEmpty {
                Divider()
                    .overlay(WorthItColor.outlineSubtle.opacity(0.45))

                VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                    Text("Between known distances")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .tracking(1.1)
                        .textCase(.uppercase)

                    ForEach(distanceCurveSegmentRows, id: \.self) { row in
                        Text(row)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle.opacity(0.7), lineWidth: 1)
        }
    }

    private var distanceCurveAverageLabel: String {
        guard let average = distanceCurveAverageRate else { return "—/km" }
        return "\(currencySymbol)\(formatCurveRate(average))/km"
    }

    private var distanceCurveAverageRate: Double? {
        let rates = validCurvePoints.map(\.rate)
        guard !rates.isEmpty else { return nil }
        return rates.reduce(0, +) / Double(rates.count)
    }

    private var distanceCurvePointRows: [String] {
        guard !validCurvePoints.isEmpty else {
            return ["Add at least 2 distance points to see the curve average."]
        }

        return validCurvePoints.map { point in
            "\(formatCurveNumber(point.distanceKm)) km → \(currencySymbol)\(formatCurveNumber(point.totalPrice)) total → \(currencySymbol)\(formatCurveRate(point.rate))/km"
        }
    }

    private var distanceCurveSegmentRows: [String] {
        let points = validCurvePoints
        guard points.count >= 2 else { return [] }

        return points.indices.dropFirst().compactMap { index in
            let previous = points[index - 1]
            let current = points[index]
            let distanceDelta = current.distanceKm - previous.distanceKm
            guard distanceDelta > 0 else { return nil }

            let segmentRate = (previous.rate + current.rate) / 2
            return "\(formatCurveNumber(previous.distanceKm))–\(formatCurveNumber(current.distanceKm)) km: \(currencySymbol)\(formatCurveRate(segmentRate))/km"
        }
    }

    private var validCurvePoints: [CurvePointPreview] {
        curvePoints.wrappedValue.compactMap { point in
            guard let distance = curveDouble(point.distanceKm), distance > 0 else { return nil }
            guard let total = curveDouble(point.totalPrice) else { return nil }
            return CurvePointPreview(distanceKm: distance, totalPrice: total)
        }
        .sorted { $0.distanceKm < $1.distanceKm }
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
