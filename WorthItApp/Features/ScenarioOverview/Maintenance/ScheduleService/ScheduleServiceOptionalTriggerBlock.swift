import SwiftUI

struct ScheduleServiceOptionalTriggerBlock<Content: View>: View {
    let title: String
    let subtitle: String
    let isEnabled: Binding<Bool>
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isEnabled.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: isEnabled.wrappedValue ? "minus.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)

                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text(title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text(subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            if isEnabled.wrappedValue {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}
