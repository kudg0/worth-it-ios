import SwiftUI

struct ScheduledServiceActionOverlay: View {
    let onDismiss: () -> Void
    let onEdit: () -> Void
    let onCompleteWithExpense: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.42)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: WorthItSpacing.m) {
                Capsule()
                    .fill(WorthItColor.outlineInput)
                    .frame(width: 36, height: 4)
                    .padding(.top, WorthItSpacing.s)

                actionButton(title: "Edit", systemName: "pencil", action: onEdit)
                actionButton(title: "Complete with expense", systemName: "checkmark.circle", action: onCompleteWithExpense)
            }
            .padding(WorthItSpacing.xl)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
            .background(WorthItColor.surfaceContainerLow, in: UnevenRoundedRectangle(topLeadingRadius: WorthItRadius.xxl, topTrailingRadius: WorthItRadius.xxl))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(WorthItColor.outlineSubtle)
                    .frame(height: 1)
            }
            .shadow(color: .black.opacity(0.34), radius: 24, y: -8)
        }
        .zIndex(20)
    }

    private func actionButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }
}
