import SwiftUI

struct ScenarioTabsBar: View {
    let selectedTab: ScenarioOverviewView.ScenarioTab
    let onSelect: (ScenarioOverviewView.ScenarioTab) -> Void

    @State private var visibleTab: ScenarioOverviewView.ScenarioTab?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                chip("Overview", tab: .overview)
                chip("Maintenance", tab: .expenses)
                chip("Mileage", tab: .mileage)
                chip("Insights", tab: .insights)
                chip("Compare", tab: .compare)
                chip("Achievements", tab: .achievements)
            }
            .scrollTargetLayout()
            .padding(.horizontal, WorthItSpacing.xxl)
            .padding(.vertical, WorthItSpacing.l)
        }
        .scrollIndicators(.hidden)
        .scrollPosition(id: $visibleTab, anchor: .center)
        .background(WorthItColor.pageBackground.opacity(0.46))
        .task(id: selectedTab) {
            syncVisibleTab(animated: false)
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }
            syncVisibleTab(animated: true)
        }
        .onChange(of: selectedTab) { _, _ in
            syncVisibleTab(animated: true)
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

    private func syncVisibleTab(animated: Bool) {
        guard selectedTab != .settings else { return }
        if animated {
            withAnimation(.easeInOut(duration: 0.20)) {
                visibleTab = selectedTab
            }
        } else {
            visibleTab = selectedTab
        }
    }
}
