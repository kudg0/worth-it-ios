import SwiftUI

struct ScheduleServiceTriggerSection: View {
    struct Model {
        let trigger: Binding<ScenarioOverviewView.ScheduleTrigger>
        let serviceDate: Binding<Date?>
        let minimumServiceDate: Date
        let serviceMileage: Binding<String>
        let mileageUnit: String
        let mileageMode: ScenarioOverviewView.ServiceMileageInputMode
        let mileageFieldLabel: String
        let isOptionalDateEnabled: Binding<Bool>
        let isOptionalMileageEnabled: Binding<Bool>
        let onToggleMileageMode: () -> Void
    }

    let model: Model

    var body: some View {
        VStack(spacing: WorthItSpacing.xl) {
            ScheduleServiceDivider(title: i18n.t("Triggered by"))

            WISegmentedControl(
                items: [
                    (title: i18n.t("Date"), value: ScenarioOverviewView.ScheduleTrigger.date),
                    (title: i18n.t("Mileage"), value: ScenarioOverviewView.ScheduleTrigger.mileage),
                ],
                selection: model.trigger
            )
            .onChange(of: model.trigger.wrappedValue) { _, _ in
                withAnimation(.easeInOut(duration: 0.18)) {
                    model.isOptionalDateEnabled.wrappedValue = false
                    model.isOptionalMileageEnabled.wrappedValue = false
                }
            }

            if model.trigger.wrappedValue == .date {
                WIDateField(label: i18n.t("Service date"), placeholder: i18n.t("MM/DD/YY"), date: model.serviceDate, allowedRange: model.minimumServiceDate...Date.distantFuture)
                optionalMileageBlock
            } else {
                mileageInputBlock
                optionalDateBlock
            }
        }
    }

    private var optionalMileageBlock: some View {
        ScheduleServiceOptionalTriggerBlock(
            title: i18n.t("Add mileage trigger"),
            subtitle: i18n.t("Use odometer too, so the reminder fires by date or mileage, whichever comes first."),
            isEnabled: model.isOptionalMileageEnabled
        ) {
            mileageInputBlock
        }
    }

    private var optionalDateBlock: some View {
        ScheduleServiceOptionalTriggerBlock(
            title: i18n.t("Add date trigger"),
            subtitle: i18n.t("Use a date too, so the reminder fires by mileage or date, whichever comes first."),
            isEnabled: model.isOptionalDateEnabled
        ) {
            WIDateField(label: i18n.t("Service date"), placeholder: i18n.t("MM/DD/YY"), date: model.serviceDate, allowedRange: model.minimumServiceDate...Date.distantFuture)
        }
    }

    private var mileageInputBlock: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .center) {
                Text(model.mileageMode == .interval ? "Enter distance until service" : "Enter target odometer")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)

                Spacer(minLength: WorthItSpacing.m)

                Button(action: model.onToggleMileageMode) {
                    Text(model.mileageMode == .interval ? "Due in" : "Odometer")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.horizontal, WorthItSpacing.m)
                        .frame(height: 28)
                        .background(WorthItColor.primaryContainer.opacity(0.10), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            WITextField(
                label: model.mileageFieldLabel,
                placeholder: i18n.t("0"),
                text: model.serviceMileage,
                trailingText: model.mileageUnit,
                keyboardType: .numberPad
            )
        }
    }
}
