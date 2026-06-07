import SwiftUI

struct OverviewQuickActions: View {
    let onAddExpense: () -> Void
    let onOpenUsage: () -> Void
    let onOpenCompare: () -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: WorthItSpacing.m), count: 3),
            spacing: WorthItSpacing.m
        ) {
            OverviewQuickAction(title: "Expense", systemName: "plus", action: onAddExpense)
            OverviewQuickAction(title: "Usage", systemName: "speedometer", action: onOpenUsage)
            OverviewQuickAction(title: "Compare", systemName: "arrow.left.arrow.right", action: onOpenCompare)
        }
    }
}

private struct OverviewQuickAction: View {
    let title: String
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 21, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 32, height: 28)

                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.3)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 82)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
