import SwiftUI

struct CompletedServiceRow: View {
    let service: ScheduledService
    let subtitle: (ScheduledService) -> String
    let onOpenActions: (UUID) -> Void

    var body: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: 0x2DD4BF))
                .frame(width: 44, height: 44)
                .background(Color(hex: 0x2DD4BF).opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(service.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)

                Text(subtitle(service))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: WorthItSpacing.m)

            Text("Done")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: 0x2DD4BF))
                .tracking(0.4)
                .textCase(.uppercase)
                .padding(.horizontal, WorthItSpacing.s)
                .frame(height: 24)
                .background(Color(hex: 0x2DD4BF).opacity(0.10), in: Capsule())
                .padding(.trailing, 40)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay(alignment: .trailing) {
            ScheduledServiceMenu(serviceId: service.id, onOpenActions: onOpenActions)
                .padding(.trailing, WorthItSpacing.m)
        }
    }
}
