import SwiftUI

struct ScenarioTopBar: View {
    let title: String
    let titleColor: Color
    let usesEntryTitleStyle: Bool
    let canGoBack: Bool
    let selectedTab: ScenarioOverviewView.ScenarioTab
    let activeScenario: ScenarioListItem
    let isUpdatingFavorite: Bool
    let isDeleting: Bool
    let onBack: () -> Void
    let onToggleFavorite: () -> Void
    let onEditScenario: (ScenarioListItem) -> Void
    let onDeleteScenario: () -> Void
    let onAddEntry: () -> Void
    let onAddMileage: () -> Void
    let onAddComparable: () -> Void
    let onRemoveComparable: () -> Void
    let onEditMileageDetail: () -> Void

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            if canGoBack {
                backButton
            } else {
                titleText
            }

            Spacer()
            trailingAction
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground.opacity(0.70))
        .shadow(color: WorthItColor.primaryContainer.opacity(0.08), radius: 8)
    }

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 28, height: 40)

                titleText
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back from \(title)")
    }

    private var titleText: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(titleColor)
            .tracking(usesEntryTitleStyle ? -0.4 : 1.2)
            .textCase(usesEntryTitleStyle ? nil : .uppercase)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    @ViewBuilder
    private var trailingAction: some View {
        if selectedTab == .addComparableOption {
            iconButton(systemName: "trash", accessibilityLabel: "Remove comparable", action: onRemoveComparable)
        } else if selectedTab == .mileageDetail {
            iconButton(systemName: "pencil", accessibilityLabel: "Edit trip", action: onEditMileageDetail)
        } else if usesEntryTitleStyle {
            Color.clear.frame(width: 28, height: 40)
        } else {
            switch selectedTab {
            case .overview:
                scenarioMenu
            case .expenses:
                iconButton(systemName: "plus", accessibilityLabel: "Add entry", action: onAddEntry)
            case .mileage:
                iconButton(systemName: "plus", accessibilityLabel: "Add mileage history", action: onAddMileage)
            case .compare:
                iconButton(systemName: "plus", accessibilityLabel: "Add comparable option", action: onAddComparable)
            default:
                Color.clear.frame(width: 28, height: 40)
            }
        }
    }

    private var scenarioMenu: some View {
        Menu {
            Button {
                onToggleFavorite()
            } label: {
                Label(
                    activeScenario.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                    systemImage: activeScenario.isFavorite ? "star.slash.fill" : "star.fill"
                )
            }
            .disabled(isUpdatingFavorite || isDeleting)

            Button {
                onEditScenario(activeScenario)
            } label: {
                Label("Edit Scenario", systemImage: "pencil.circle.fill")
            }
            .disabled(isDeleting)

            Divider()

            Button(role: .destructive, action: onDeleteScenario) {
                Label("Delete Scenario", systemImage: "trash.fill")
            }
            .disabled(isDeleting)
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .frame(width: 28, height: 40)
        }
        .tint(Color(hex: 0x26324A))
        .accessibilityLabel("More")
    }

    private func iconButton(
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 28, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
