import SwiftUI

extension ScenarioOverviewView {
    var scheduleServiceScreenModel: ScheduleServiceScreen.Model {
        ScheduleServiceScreen.Model(
            serviceTypeOptions: serviceTypeSelectOptions,
            selectedServiceType: $selectedServiceType,
            basis: ScheduleServiceBasisSection.Model(
                isExpanded: $isScheduleBasisExpanded,
                title: scheduleBasisTitle,
                subtitle: scheduleBasisSubtitle,
                baselineDate: $serviceBaselineDate,
                baselineOdometer: $serviceBaselineOdometer,
                mileageUnit: mileageDisplayUnit
            ),
            trigger: ScheduleServiceTriggerSection.Model(
                trigger: $scheduleTrigger,
                serviceDate: $serviceDate,
                serviceMileage: $serviceMileage,
                mileageUnit: mileageDisplayUnit,
                mileageMode: serviceMileageInputMode,
                mileageFieldLabel: serviceMileageFieldLabel,
                isOptionalDateEnabled: $isOptionalServiceDateEnabled,
                isOptionalMileageEnabled: $isOptionalServiceMileageEnabled,
                onToggleMileageMode: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        toggleServiceMileageInputMode()
                    }
                }
            ),
            details: $serviceDetails
        )
    }
}
