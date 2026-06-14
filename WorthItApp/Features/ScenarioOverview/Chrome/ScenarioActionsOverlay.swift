import SwiftUI

struct ScenarioActionsOverlay: View {
    let scenario: ScenarioListItem
    let isUpdatingFavorite: Bool
    let isDeleting: Bool
    let onDismiss: () -> Void
    let onToggleFavorite: () -> Void
    let onEditScenario: () -> Void
    let onDeleteScenario: () -> Void

    var body: some View {
        ScenarioBottomActionSheet(onDismiss: onDismiss) {
            actionButton(
                title: scenario.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                systemName: scenario.isFavorite ? "star.slash" : "star",
                isDisabled: isUpdatingFavorite || isDeleting,
                action: onToggleFavorite
            )

            actionButton(
                title: i18n.t("Edit Scenario"),
                systemName: "pencil",
                isDisabled: isDeleting,
                action: onEditScenario
            )

            actionButton(
                title: i18n.t("Delete Scenario"),
                systemName: "trash",
                foregroundColor: WorthItColor.danger,
                iconForegroundColor: WorthItColor.danger,
                iconBackgroundColor: WorthItColor.danger.opacity(0.14),
                isDisabled: isDeleting,
                action: onDeleteScenario
            )
        }
    }

    private func actionButton(
        title: String,
        systemName: String,
        foregroundColor: Color = WorthItColor.textPrimary,
        iconForegroundColor: Color = WorthItColor.primaryContainer,
        iconBackgroundColor: Color = WorthItColor.primaryContainer.opacity(0.10),
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconForegroundColor)
                    .frame(width: 34, height: 34)
                    .background(iconBackgroundColor, in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(foregroundColor)

                Spacer()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .opacity(isDisabled ? 0.52 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
