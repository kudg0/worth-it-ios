import SwiftUI

struct ScheduledServiceRow: View {
    let item: ScenarioOverviewView.ScheduledServiceDisplayItem
    let dueSubtitle: (ScenarioOverviewView.ScheduledServiceDisplayItem) -> String
    let serviceStateTitle: (String) -> String
    let serviceStateColor: (String) -> Color
    let serviceIconName: (String) -> String
    let onOpen: (UUID) -> Void
    let onOpenActions: (UUID) -> Void

    var body: some View {
        Button {
            onOpen(item.id)
        } label: {
            HStack(alignment: .center, spacing: WorthItSpacing.m) {
                Image(systemName: serviceIconName(item.category))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(serviceStateColor(item.dueState))
                    .frame(width: 44, height: 44)
                    .background(serviceStateColor(item.dueState).opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(dueSubtitle(item))
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .allowsTightening(true)

                        if let note = item.note {
                            Text(note)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(WorthItColor.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)

                Spacer(minLength: WorthItSpacing.m)

                Text(serviceStateTitle(item.dueState))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(serviceStateColor(item.dueState))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .padding(.horizontal, WorthItSpacing.s)
                    .frame(height: 24)
                    .background(serviceStateColor(item.dueState).opacity(0.10), in: Capsule())
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.trailing, 40)
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.l))
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay(alignment: .trailing) {
            ScheduledServiceMenu(serviceId: item.id, onOpenActions: onOpenActions)
                .padding(.trailing, WorthItSpacing.m)
                .zIndex(1)
        }
    }
}
