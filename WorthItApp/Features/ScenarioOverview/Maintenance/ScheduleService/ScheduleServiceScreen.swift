import SwiftUI

struct ScheduleServiceScreen: View {
    struct Model {
        let serviceTypeOptions: [String]
        let selectedServiceType: Binding<String>
        let basis: ScheduleServiceBasisSection.Model
        let trigger: ScheduleServiceTriggerSection.Model
        let details: Binding<String>
        let resources: ScenarioResourceManagementSectionModel?
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            header

            WISelectField(
                label: i18n.t("Service type"),
                options: model.serviceTypeOptions,
                selection: model.selectedServiceType
            )

            ScheduleServiceBasisSection(model: model.basis)
            ScheduleServiceTriggerSection(model: model.trigger)

            LogExpenseNotesField(
                title: i18n.t("Details"),
                placeholder: i18n.t("Add specific instructions, part numbers, or preferred mechanic..."),
                text: model.details
            )

            if let resources = model.resources {
                ScenarioResourceManagementSection(model: resources)
            }

            WITipInfo(
                title: i18n.t("Smart Insight"),
                bodyText: i18n.t("Based on your driving history, your brake pads usually require attention around this time of year. Consider an inspection to be safe."),
                size: .medium,
                tone: .primary
            )
        }
        .padding(.bottom, 120)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("What service is due?")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)
                .tracking(-1)

            Text("Select the required maintenance to keep your asset performing optimally.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
