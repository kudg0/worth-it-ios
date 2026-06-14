import SwiftUI

struct ScheduleServiceBasisSection: View {
    struct Model {
        let isExpanded: Binding<Bool>
        let title: String
        let subtitle: String
        let baselineDate: Binding<Date?>
        let baselineOdometer: Binding<String>
        let mileageUnit: String
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            ScheduleServiceDivider(title: i18n.t("SCHEDULE BASIS"))
            basisInfo

            if model.isExpanded.wrappedValue {
                HStack(spacing: WorthItSpacing.l) {
                    WIDateField(label: i18n.t("Basis date"), placeholder: i18n.t("MM/DD/YY"), date: model.baselineDate)

                    WITextField(
                        label: i18n.t("Basis odometer"),
                        placeholder: i18n.t("0"),
                        text: model.baselineOdometer,
                        trailingText: model.mileageUnit,
                        keyboardType: .numberPad
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var basisInfo: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 32, height: 32)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)

                    Text(model.subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: model.isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }
            .padding(WorthItSpacing.l)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
