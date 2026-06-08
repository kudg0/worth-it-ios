import SwiftUI

struct ScenarioTabsBar: View {
    let selectedTab: ScenarioOverviewView.ScenarioTab
    let onSelect: (ScenarioOverviewView.ScenarioTab) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    chip("Overview", tab: .overview)
                    chip("Maintenance", tab: .expenses)
                    chip("Mileage", tab: .mileage)
                    chip("Insights", tab: .insights)
                    chip("Compare", tab: .compare)
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.vertical, WorthItSpacing.l)
            }
            .scrollIndicators(.hidden)
            .background(WorthItColor.pageBackground.opacity(0.46))
            .onChange(of: selectedTab) { _, tab in
                guard tab != .settings else { return }

                withAnimation(.easeInOut(duration: 0.20)) {
                    proxy.scrollTo(tab, anchor: .center)
                }
            }
        }
    }

    private func chip(_ title: String, tab: ScenarioOverviewView.ScenarioTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            onSelect(tab)
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textSecondary)
                .padding(.horizontal, WorthItSpacing.xl)
                .frame(height: 36)
                .background(isSelected ? WorthItColor.primaryContainer : Color(hex: 0x3A4666), in: Capsule())
                .overlay {
                    Capsule().stroke(isSelected ? Color.clear : Color(hex: 0x44474F), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .id(tab)
    }
}
