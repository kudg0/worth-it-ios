import SwiftUI

struct ExpenseHistoryScreen: View {
    struct Model {
        let hero: ExpenseHistoryHero.Model
        let groups: [ScenarioOverviewView.ExpenseMonthGroup]
        let focusedExpenseId: UUID?
        let filter: Binding<ScenarioOverviewView.ExpenseHistoryFilter>
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
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            ExpenseHistoryHero(model: model.hero)
            filters

            if model.groups.isEmpty {
                WITipInfo(
                    title: "No expenses found",
                    bodyText: "There are no matching expenses for this filter yet.",
                    size: .medium,
                    tone: .info
                )
            } else {
                ExpenseHistoryList(model: listModel)
            }
        }
    }

    private var filters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: WorthItSpacing.s) {
                ForEach(ScenarioOverviewView.ExpenseHistoryFilter.allCases) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
    }

    private var listModel: ExpenseHistoryList.Model {
        ExpenseHistoryList.Model(
            groups: model.groups,
            focusedExpenseId: model.focusedExpenseId,
            currentMonthStart: model.currentMonthStart,
            groupTotal: model.groupTotal,
            rowTitle: model.rowTitle,
            rowSubtitle: model.rowSubtitle,
            rowValue: model.rowValue,
            rowDetail: model.rowDetail,
            rowIcon: model.rowIcon,
            rowAccentColor: model.rowAccentColor,
            onEditExpense: model.onEditExpense
        )
    }

    private func filterChip(_ filter: ScenarioOverviewView.ExpenseHistoryFilter) -> some View {
        let isSelected = model.filter.wrappedValue == filter

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.filter.wrappedValue = filter
            }
        } label: {
            HStack(spacing: WorthItSpacing.s) {
                if isSelected {
                    Circle()
                        .fill(Color(hex: 0x122F5F))
                        .frame(width: 8, height: 8)
                }

                Text(filter.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(height: 40)
            .background(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
