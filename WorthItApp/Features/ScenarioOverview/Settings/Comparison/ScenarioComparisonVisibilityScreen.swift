import SwiftUI

struct ScenarioComparisonVisibilityScreen: View {
    let alternatives: [AlternativeOption]
    let isSaving: Bool
    @Binding var selectedIds: Set<UUID>
    let onSave: (Set<UUID>) -> Void

    private let columns = [
        GridItem(.flexible(minimum: 0), spacing: WorthItSpacing.l),
        GridItem(.flexible(minimum: 0), spacing: WorthItSpacing.l)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            helperText
            primaryOptions
        }
        .onAppear(perform: syncSelection)
        .onChange(of: alternatives) { _, _ in syncSelection() }
    }

    var footer: some View {
        ComparisonVisibilityFooter(
            selectedCount: selectedIds.count,
            isSaving: isSaving,
            onClear: { selectedIds.removeAll() },
            onSave: { onSave(selectedIds) }
        )
    }

    private var helperText: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Manage Comparison")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-0.6)

            Text("Choose which comparable options are visible in ownership benchmarks and trip-level efficiency checks.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 304, alignment: .leading)
        }
    }

    private var primaryOptions: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader("Comparable Options")

            if alternatives.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: WorthItSpacing.l) {
                    ForEach(alternatives) { alternative in
                        ComparisonVisibilityTile(
                            title: alternative.name,
                            subtitle: pricingSubtitle(for: alternative),
                            systemIcon: iconName(for: alternative),
                            isSelected: selectedIds.contains(alternative.id)
                        ) {
                            toggle(alternative.id)
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text("No comparable options yet")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            Text("Add taxi, car sharing, rental, or public transport from the Compare screen first.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(2)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xl))
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: WorthItSpacing.l) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.0)

            Rectangle()
                .fill(WorthItColor.outlineInput.opacity(0.65))
                .frame(height: 1)
        }
    }

    private func syncSelection() {
        selectedIds = Set(alternatives.filter(\.isIncluded).map(\.id))
    }

    private func toggle(_ id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    private func iconName(for alternative: AlternativeOption) -> String {
        let name = alternative.name.lowercased()
        if name.contains("taxi") { return "car.fill" }
        if name.contains("share") { return "car.2.fill" }
        if name.contains("rental") { return "key.fill" }
        if name.contains("transport") || name.contains("bus") || name.contains("transit") { return "bus.fill" }
        return "arrow.triangle.branch"
    }

    private func pricingSubtitle(for alternative: AlternativeOption) -> String {
        switch alternative.pricingMode {
        case .perDistance:
            "Per km"
        case .distanceCurve:
            "Distance curve"
        case .perPeriod:
            "Monthly plan"
        case .perTime:
            "Per minute"
        case .manualEquivalent:
            "Manual estimate"
        case .mixed:
            "Mixed pricing"
        }
    }
}

private struct ComparisonVisibilityTile: View {
    let title: String
    let subtitle: String
    let systemIcon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: WorthItSpacing.s) {
                Image(systemName: systemIcon)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, minHeight: 154, maxHeight: 154)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: WorthItRadius.xl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xl)
                    .stroke(borderColor, lineWidth: isSelected ? 1.2 : 1)
            }
            .shadow(color: shadowColor, radius: isSelected ? 12 : 0)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundColor: Color {
        isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer
    }

    private var titleColor: Color {
        isSelected ? Color(hex: 0x385283) : WorthItColor.textPrimary
    }

    private var subtitleColor: Color {
        isSelected ? Color(hex: 0x385283).opacity(0.75) : WorthItColor.textSecondary
    }

    private var iconColor: Color {
        isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary
    }

    private var borderColor: Color {
        isSelected ? WorthItColor.primaryContainer : WorthItColor.outlineSubtle
    }

    private var shadowColor: Color {
        WorthItColor.primaryContainer.opacity(0.14)
    }
}
