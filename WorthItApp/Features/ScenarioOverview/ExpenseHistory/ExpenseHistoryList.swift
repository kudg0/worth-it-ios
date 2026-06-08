import SwiftUI

struct ExpenseHistoryList: View {
    struct Model {
        let groups: [ScenarioOverviewView.ExpenseMonthGroup]
        let focusedExpenseId: UUID?
        let currentMonthStart: Date
        let groupTotal: (ScenarioOverviewView.ExpenseMonthGroup) -> String
        let rowTitle: (CostEvent) -> String
        let rowSubtitle: (CostEvent) -> String
        let rowValue: (CostEvent) -> String
        let rowDetail: (CostEvent) -> String
        let rowIcon: (CostEvent) -> String
        let rowAccentColor: (CostEvent) -> Color
        let onEditExpense: (CostEvent) -> Void
    }

    let model: Model

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 40) {
                ForEach(model.groups) { group in
                    VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                        monthHeader(group)
                        rows(group)
                    }
                }
            }
            .onAppear {
                scrollToFocusedExpense(proxy)
            }
            .onChange(of: model.focusedExpenseId) { _, _ in
                scrollToFocusedExpense(proxy)
            }
        }
    }

    private func rows(_ group: ScenarioOverviewView.ExpenseMonthGroup) -> some View {
        VStack(spacing: WorthItSpacing.m) {
            ForEach(group.syntheticItems) { item in
                syntheticRow(item)
            }

            ForEach(group.events) { event in
                row(event)
                    .id(rowId(event.id))
            }
        }
    }

    private func monthHeader(_ group: ScenarioOverviewView.ExpenseMonthGroup) -> some View {
        HStack {
            Text(Self.monthYearFormatter.string(from: group.monthStart))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            Spacer()

            Text("Total: \(model.groupTotal(group))")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WorthItColor.textTertiary)
        }
        .padding(.leading, WorthItSpacing.l)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(group.monthStart == model.currentMonthStart ? WorthItColor.primaryContainer.opacity(0.32) : WorthItColor.outlineInput.opacity(0.60))
                .frame(width: 2)
        }
    }

    private func row(_ event: CostEvent) -> some View {
        let accentColor = model.rowAccentColor(event)

        return WIInfoListRow(
            title: model.rowTitle(event),
            subtitle: model.rowSubtitle(event),
            value: model.rowValue(event),
            detail: model.rowDetail(event),
            systemIcon: model.rowIcon(event),
            accentColor: accentColor,
            detailColor: accentColor,
            action: { model.onEditExpense(event) }
        )
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(model.focusedExpenseId == event.id ? WorthItColor.primaryContainer.opacity(0.55) : Color.clear, lineWidth: 1)
        }
    }

    private func syntheticRow(_ item: ScenarioOverviewView.ExpenseMonthGroup.SyntheticItem) -> some View {
        let accentColor = Color(hex: 0xBAC6EC)

        return WIInfoListRow(
            title: item.title,
            subtitle: item.subtitle,
            value: item.valueText,
            detail: item.detail,
            systemIcon: item.systemIcon,
            accentColor: accentColor,
            detailColor: accentColor,
            action: {}
        )
        .allowsHitTesting(false)
    }

    private func rowId(_ id: UUID) -> String {
        "expense-history-\(id.uuidString)"
    }

    private func scrollToFocusedExpense(_ proxy: ScrollViewProxy) {
        guard let focusedExpenseId = model.focusedExpenseId else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.24)) {
                proxy.scrollTo(rowId(focusedExpenseId), anchor: .center)
            }
        }
    }

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

}
