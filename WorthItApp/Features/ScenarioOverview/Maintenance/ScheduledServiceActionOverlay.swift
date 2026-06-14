import SwiftUI

struct ScheduledServiceActionOverlay: View {
    let onDismiss: () -> Void
    let onEdit: () -> Void
    let onCompleteWithExpense: () -> Void

    var body: some View {
        ScenarioBottomActionSheet(onDismiss: onDismiss) {
            actionButton(title: i18n.t("Edit"), systemName: "pencil", action: onEdit)
            actionButton(title: i18n.t("Complete with expense"), systemName: "checkmark.circle", action: onCompleteWithExpense)
        }
    }

    private func actionButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }
}
