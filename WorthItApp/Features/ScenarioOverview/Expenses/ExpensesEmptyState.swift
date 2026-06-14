import SwiftUI

struct ExpensesEmptyState: View {
    var body: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            VStack(spacing: WorthItSpacing.xxl) {
                ZStack {
                    Circle()
                        .fill(WorthItColor.primaryContainer.opacity(0.10))
                        .frame(width: 144, height: 144)
                        .blur(radius: 32)

                    RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                        .fill(WorthItColor.surfaceContainer)
                        .frame(width: 96, height: 96)
                        .overlay {
                            Image(systemName: "receipt")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(WorthItColor.primaryContainer)
                        }
                }

                VStack(spacing: WorthItSpacing.m) {
                    Text("No expenses logged")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .tracking(-0.6)

                    Text("Start tracking fuel, maintenance, and other\ncosts to see your true ownership story.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: WorthItSpacing.l),
                    GridItem(.flexible(), spacing: WorthItSpacing.l),
                ],
                spacing: WorthItSpacing.l
            ) {
                ExpenseEducationCard(title: i18n.t("Fuel Costs"), subtitle: i18n.t("Track efficiency and\nrange over time."), systemName: "fuelpump")
                ExpenseEducationCard(title: i18n.t("Service"), subtitle: i18n.t("Keep your car in peak\ncondition."), systemName: "wrench.fill")
            }
        }
    }
}

private struct ExpenseEducationCard: View {
    let title: String
    let subtitle: String
    let systemName: String

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Spacer()

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(1)
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
