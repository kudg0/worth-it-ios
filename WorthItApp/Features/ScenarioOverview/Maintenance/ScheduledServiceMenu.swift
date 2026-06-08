import SwiftUI

struct ScheduledServiceMenu: View {
    let serviceId: UUID
    let onOpenActions: (UUID) -> Void

    var body: some View {
        Button {
            onOpenActions(serviceId)
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Service actions")
    }
}
