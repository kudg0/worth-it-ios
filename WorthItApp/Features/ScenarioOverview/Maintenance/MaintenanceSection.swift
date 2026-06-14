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
        let onOpenScheduledServices: () -> Void
        let onOpenScheduledService: (UUID) -> Void
        let onOpenScheduledServiceActions: (UUID) -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            ScenarioSectionTitle(title: i18n.t("Maintenance"))

            if let error = model.error {
                WITipInfo(title: i18n.t("Service schedule unavailable"), bodyText: error, size: .medium, tone: .info)
            } else {
                scheduledServicesSection
                completedServicesSection
            }
        }
    }

    private var scheduledServicesSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            MaintenanceSectionHeader(
                title: i18n.t("Scheduled Services"),
                showsViewAll: !model.upcomingItems.isEmpty,
                action: model.onOpenScheduledServices
            )

            if model.upcomingItems.isEmpty {
                ScenarioWideAction(title: i18n.t("Scheduled Services"), subtitle: i18n.t("Upcoming service reminders will live here."), systemName: "calendar.badge.clock")
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(Array(model.upcomingItems.prefix(5))) { item in
                        ScheduledServiceRow(
                            item: item,
                            dueSubtitle: model.dueSubtitle,
                            serviceStateTitle: model.serviceStateTitle,
                            serviceStateColor: model.serviceStateColor,
                            serviceIconName: model.serviceIconName,
                            onOpen: model.onOpenScheduledService,
                            onOpenActions: model.onOpenScheduledServiceActions
                        )
                    }
                }
            }
        }
    }

    private var completedServicesSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            MaintenanceSectionHeader(title: i18n.t("Completed Work"))

            if model.completedServices.isEmpty {
                ScenarioWideAction(title: i18n.t("Completed Work"), subtitle: i18n.t("Finished services can be linked back to expenses."), systemName: "checkmark.seal.fill")
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
    var showsViewAll = false
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            Spacer()

            if showsViewAll {
                Button(action: action) {
                    Text("View All")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, WorthItSpacing.xs)
    }
}
