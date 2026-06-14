import SwiftUI

extension ScenarioOverviewView {
    var scheduledServiceMonthBinding: Binding<Date> {
        Binding(
            get: { displayedScheduledServiceMonth ?? scheduledServicesInitialMonth },
            set: { displayedScheduledServiceMonth = expenseHistoryMonthStart(for: $0) }
        )
    }

    var scheduledServicesInitialMonth: Date {
        let firstDatedService = upcomingServiceItems.first { $0.date != nil }

        if let date = firstDatedService?.date {
            return expenseHistoryMonthStart(for: date)
        }

        return currentMonthStart
    }
}
