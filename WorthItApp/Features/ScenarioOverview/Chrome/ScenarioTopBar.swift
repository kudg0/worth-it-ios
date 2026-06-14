import SwiftUI

struct ScenarioTopBar: View {
    let title: String
    let titleColor: Color
    let usesEntryTitleStyle: Bool
    let canGoBack: Bool
    let selectedTab: ScenarioOverviewView.ScenarioTab
    let isDeleting: Bool
    let onBack: () -> Void
    let onOpenScenarioActions: () -> Void
    let onAddEntry: () -> Void
    let onAddMileage: () -> Void
    let onAddComparable: () -> Void
    let onRemoveComparable: () -> Void
    let onEditMileageDetail: () -> Void

    var body: some View {
        HStack(spacing: WorthItSpacing.m) {
            if canGoBack {
                backButton
            } else {
                titleText
            }

            Spacer()
            trailingAction
        }
        .frame(height: 64)
        .padding(.horizontal, WorthItSpacing.xxl)
        .background(WorthItColor.pageBackground.opacity(0.70))
        .shadow(color: WorthItColor.primaryContainer.opacity(0.08), radius: 8)
    }

    private var backButton: some View {
        Button(action: onBack) {
            HStack(spacing: WorthItSpacing.m) {
                headerIcon(systemName: "arrow.left", size: 18, weight: .semibold)
                    .frame(width: 28, height: 40)

                titleText
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back from \(title)")
    }

    private var titleText: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(titleColor)
            .tracking(usesEntryTitleStyle ? -0.4 : 1.2)
            .textCase(usesEntryTitleStyle ? nil : .uppercase)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    @ViewBuilder
    private var trailingAction: some View {
        if selectedTab == .addComparableOption {
            iconButton(systemName: "trash", accessibilityLabel: "Remove comparable", action: onRemoveComparable)
        } else if selectedTab == .mileageDetail {
            iconButton(systemName: "pencil", accessibilityLabel: "Edit trip", action: onEditMileageDetail)
        } else if usesEntryTitleStyle {
            Color.clear.frame(width: 28, height: 40)
        } else {
            switch selectedTab {
            case .overview:
                iconButton(systemName: "ellipsis", accessibilityLabel: "Scenario actions", action: onOpenScenarioActions)
            case .expenses:
                iconButton(systemName: "plus", accessibilityLabel: "Add entry", action: onAddEntry)
            case .mileage:
                iconButton(systemName: "plus", accessibilityLabel: "Add mileage history", action: onAddMileage)
            case .compare:
                iconButton(systemName: "plus", accessibilityLabel: "Add comparable option", action: onAddComparable)
            default:
                Color.clear.frame(width: 28, height: 40)
            }
        }
    }

    private func iconButton(
        systemName: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            headerIcon(systemName: systemName, size: 19, weight: .bold)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .disabled(isDeleting)
    }

    private func headerIcon(systemName: String, size: CGFloat, weight: Font.Weight) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    WorthItColor.primaryContainer.opacity(0.20),
                    WorthItColor.primaryContainer.opacity(0.07),
                    .clear
                ],
                center: .center,
                startRadius: 1,
                endRadius: 26
            )
            .frame(width: 54, height: 54)
            .blur(radius: 2)

            Image(systemName: systemName)
                .font(.system(size: size, weight: weight))
                .foregroundStyle(WorthItColor.primaryContainer)
                .shadow(color: WorthItColor.primaryContainer.opacity(0.28), radius: 10)
        }
    }
}
