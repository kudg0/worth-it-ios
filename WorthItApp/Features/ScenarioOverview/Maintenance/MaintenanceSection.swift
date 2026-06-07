import SwiftUI

struct MaintenanceSection: View {
    struct Model {
        let error: String?
        let upcomingItems: [ScenarioOverviewView.ScheduledServiceDisplayItem]
        let completedServices: [ScheduledService]
        let dueSubtitle: (ScenarioOverviewView.ScheduledServiceDisplayItem) -> String
        let completedSubtitle: (ScheduledService) -> String
        let serviceStateTitle: (String) -> String
        let serviceStateColor: (String) -> Color
        let serviceIconName: (String) -> String
        let onEditScheduledService: (UUID) -> Void
        let onOpenScheduledServiceActions: (UUID) -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: "Maintenance")

            if let error = model.error {
                WITipInfo(title: "Service schedule unavailable", bodyText: error, size: .medium, tone: .info)
            } else {
                scheduledServicesSection
                completedServicesSection
            }
        }
    }

    private var scheduledServicesSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            MaintenanceSectionHeader(title: "Scheduled Services")

            if model.upcomingItems.isEmpty {
                ScenarioWideAction(title: "Scheduled Services", subtitle: "Upcoming service reminders will live here.", systemName: "calendar.badge.clock")
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(model.upcomingItems) { item in
                        ScheduledServiceRow(
                            item: item,
                            dueSubtitle: model.dueSubtitle,
                            serviceStateTitle: model.serviceStateTitle,
                            serviceStateColor: model.serviceStateColor,
                            serviceIconName: model.serviceIconName,
                            onEdit: model.onEditScheduledService,
                            onOpenActions: model.onOpenScheduledServiceActions
                        )
                    }
                }
            }
        }
    }

    private var completedServicesSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            MaintenanceSectionHeader(title: "Completed Work")

            if model.completedServices.isEmpty {
                ScenarioWideAction(title: "Completed Work", subtitle: "Finished services can be linked back to expenses.", systemName: "checkmark.seal.fill")
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(model.completedServices) { service in
                        CompletedServiceRow(
                            service: service,
                            subtitle: model.completedSubtitle,
                            onOpenActions: model.onOpenScheduledServiceActions
                        )
                    }
                }
            }
        }
    }
}

private struct MaintenanceSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(WorthItColor.textSecondary)
            .tracking(1.2)
            .textCase(.uppercase)
            .padding(.horizontal, WorthItSpacing.xs)
    }
}
