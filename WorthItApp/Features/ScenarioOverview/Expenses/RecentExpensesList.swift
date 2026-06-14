import SwiftUI

struct RecentExpenseItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let value: String
    let detail: String?
    let systemIcon: String
    let accentColor: Color
    let action: (() -> Void)?
}

struct RecentExpensesList: View {
    let items: [RecentExpenseItem]
    let onOpenHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .firstTextBaseline) {
                ScenarioSectionTitle(title: i18n.t("Recent expenses"))

                Button(action: onOpenHistory) {
                    Text("View all")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .buttonStyle(.plain)
            }

            if items.isEmpty {
                CurrentMonthNoExpensesState()
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(items) { item in
                        WIInfoListRow(
                            title: item.title,
                            subtitle: item.subtitle,
                            value: item.value,
                            detail: item.detail,
                            systemIcon: item.systemIcon,
                            accentColor: item.accentColor,
                            action: item.action
                        )
                    }
                }
            }
        }
    }
}

private struct CurrentMonthNoExpensesState: View {
    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("No expenses this month")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("You have older entries. Open the full history to review them.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
