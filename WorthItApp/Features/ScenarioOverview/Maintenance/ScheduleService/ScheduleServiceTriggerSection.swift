import SwiftUI

struct ScheduleServiceTriggerSection: View {
    struct Model {
        let trigger: Binding<ScenarioOverviewView.ScheduleTrigger>
        let serviceDate: Binding<Date?>
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
            ScheduleServiceDivider(title: "Triggered by")

            WISegmentedControl(
                items: [
                    (title: "Date", value: ScenarioOverviewView.ScheduleTrigger.date),
                    (title: "Mileage", value: ScenarioOverviewView.ScheduleTrigger.mileage),
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
                WIDateField(label: "Service date", placeholder: "MM/DD/YY", date: model.serviceDate)
                optionalMileageBlock
            } else {
                mileageInputBlock
                optionalDateBlock
            }
        }
    }

    private var optionalMileageBlock: some View {
        ScheduleServiceOptionalTriggerBlock(
            title: "Add mileage trigger",
            subtitle: "Use odometer too, so the reminder fires by date or mileage, whichever comes first.",
            isEnabled: model.isOptionalMileageEnabled
        ) {
            mileageInputBlock
        }
    }

    private var optionalDateBlock: some View {
        ScheduleServiceOptionalTriggerBlock(
            title: "Add date trigger",
            subtitle: "Use a date too, so the reminder fires by mileage or date, whichever comes first.",
            isEnabled: model.isOptionalDateEnabled
        ) {
            WIDateField(label: "Service date", placeholder: "MM/DD/YY", date: model.serviceDate)
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
                placeholder: "0",
                text: model.serviceMileage,
                trailingText: model.mileageUnit,
                keyboardType: .numberPad
            )
        }
    }
}
