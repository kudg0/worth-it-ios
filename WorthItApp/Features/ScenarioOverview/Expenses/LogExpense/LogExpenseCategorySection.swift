import SwiftUI

struct LogExpenseCategorySection: View {
    let category: Binding<ScenarioOverviewView.ExpenseCategory>

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            header

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: WorthItSpacing.m) {
                        ForEach(ScenarioOverviewView.ExpenseCategory.allCases) { option in
                            categoryButton(option)
                                .id(option.id)
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .scrollIndicators(.hidden)
                .onChange(of: category.wrappedValue) { _, option in
                    withAnimation(.easeInOut(duration: 0.22)) {
                        proxy.scrollTo(option.id, anchor: .center)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Category")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)

            Spacer()

            WISelectControl(
                title: i18n.t("Category"),
                options: ScenarioOverviewView.ExpenseCategory.allCases.map {
                    WISelectSheetOption(id: $0.rawValue, title: $0.title, systemName: $0.systemName)
                },
                selectedId: categorySelection
            ) {
                Text("View All")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorthItColor.primaryContainer)
            }
        }
        .padding(.horizontal, WorthItSpacing.xs)
    }

    private var categorySelection: Binding<String> {
        Binding {
            category.wrappedValue.rawValue
        } set: { selectedId in
            guard let next = ScenarioOverviewView.ExpenseCategory(rawValue: selectedId) else { return }
            category.wrappedValue = next
        }
    }

    private func categoryButton(_ option: ScenarioOverviewView.ExpenseCategory) -> some View {
        let isSelected = category.wrappedValue == option

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                category.wrappedValue = option
            }
        } label: {
            VStack(spacing: WorthItSpacing.s) {
                Image(systemName: option.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)

                Text(option.title)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.25)
            }
            .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
            .frame(width: 96, height: 96)
            .background(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(isSelected ? WorthItColor.primaryContainer : Color.clear, lineWidth: 1)
            }
            .shadow(color: isSelected ? WorthItColor.primaryContainer.opacity(0.15) : Color.clear, radius: 10)
        }
        .buttonStyle(.plain)
    }
}
