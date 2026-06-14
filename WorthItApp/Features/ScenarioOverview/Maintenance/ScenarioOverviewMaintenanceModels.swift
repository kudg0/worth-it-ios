import SwiftUI

extension ScenarioOverviewView {
    var maintenanceSectionModel: MaintenanceSection.Model {
        MaintenanceSection.Model(
            error: scheduledServicesError,
            upcomingItems: upcomingServiceItems,
            completedServices: completedScheduledServices,
            dueSubtitle: serviceDueSubtitle,
            completedSubtitle: completedServiceSubtitle,
            serviceStateTitle: serviceStateTitle,
            serviceStateColor: serviceStateColor,
            serviceIconName: serviceIconName,
            onOpenScheduledServices: openScheduledServices,
            onOpenScheduledService: openScheduledServiceDetail,
            onOpenScheduledServiceActions: openScheduledServiceActions
        )
    }

    func openScheduledServiceActions(_ serviceId: UUID) {
        withAnimation(.easeInOut(duration: 0.18)) {
            activeScheduledServiceActionId = serviceId
        }
    }

    func closeScheduledServiceActions() {
        withAnimation(.easeInOut(duration: 0.16)) {
            activeScheduledServiceActionId = nil
        }
    }
}
