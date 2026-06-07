import SwiftUI

struct LogExpenseServiceLink: View {
    struct Model {
        let isExpanded: Binding<Bool>
        let selectedServiceId: Binding<UUID?>
        let shouldCompleteService: Binding<Bool>
        let scheduledServices: [ScheduledService]
        let subtitle: String
        let optionSubtitle: (ScheduledService) -> String
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            header

            if model.isExpanded.wrappedValue {
                options
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(model.isExpanded.wrappedValue ? WorthItSpacing.xl : 0)
        .background { expandedBackground }
    }

    private var header: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: model.selectedServiceId.wrappedValue == nil ? "wrench" : "wrench.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: 0x3A4666), in: Circle())

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Linked Service")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(model.subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: model.isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }

    private var options: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            option(nil)

            ForEach(model.scheduledServices.sorted { $0.title < $1.title }) { service in
                option(service)
            }

            if model.selectedServiceId.wrappedValue != nil {
                Toggle(isOn: model.shouldCompleteService) {
                    VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                        Text("Mark service completed")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(WorthItColor.textPrimary)

                        Text("This expense becomes the completion record. Other expenses can still link to the same service.")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WorthItColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .tint(WorthItColor.primaryContainer)
                .padding(.top, WorthItSpacing.s)
            }
        }
    }

    private func option(_ service: ScheduledService?) -> some View {
        let isSelected = model.selectedServiceId.wrappedValue == service?.id
        let subtitle = service.map { model.optionSubtitle($0) } ?? "Keep this expense independent."

        return Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                model.selectedServiceId.wrappedValue = service?.id
                if service == nil {
                    model.shouldCompleteService.wrappedValue = false
                }
            }
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isSelected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(service?.title ?? "No linked service")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(WorthItSpacing.m)
            .background(isSelected ? WorthItColor.primaryContainer.opacity(0.08) : WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var expandedBackground: some View {
        if model.isExpanded.wrappedValue {
            WorthItColor.surfaceContainerLow
                .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                        .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                }
        }
    }
}
