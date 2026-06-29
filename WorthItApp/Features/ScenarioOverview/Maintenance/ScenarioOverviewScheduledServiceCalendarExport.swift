import SwiftUI

extension ScenarioOverviewView {
    func addScheduledServiceToCalendar(_ item: ScheduledServiceDisplayItem) {
        guard item.calendarExportDate != nil else {
            withAnimation(.easeInOut(duration: 0.18)) {
                actionSuccess = nil
                actionError = i18n.t(.scenarios.maintenance.calendar.errors.noDate)
            }
            return
        }

        let request = ServiceCalendarExportRequest(
            title: item.calendarTitle,
            fallbackTitle: item.title,
            startDate: item.calendarSuggestedDate,
            fallbackDate: item.date,
            notes: item.calendarNotes
        )

        withAnimation(.easeInOut(duration: 0.18)) {
            actionError = nil
            actionSuccess = nil
        }

        Task {
            let result = await ServiceCalendarExporter().export(request)

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.18)) {
                    switch result {
                    case .success:
                        actionError = nil
                        actionSuccess = i18n.t(.scenarios.maintenance.calendar.successMessage)
                    case .failure(let failure):
                        actionSuccess = nil
                        actionError = calendarExportErrorMessage(for: failure)
                    }
                }
            }
        }
    }

    private func calendarExportErrorMessage(for failure: ServiceCalendarExportFailure) -> String {
        switch failure {
        case .missingDate:
            i18n.t(.scenarios.maintenance.calendar.errors.noDate)
        case .accessDenied:
            i18n.t(.scenarios.maintenance.calendar.errors.accessDenied)
        case .calendarUnavailable:
            i18n.t(.scenarios.maintenance.calendar.errors.calendarUnavailable)
        case .saveFailed:
            i18n.t(.scenarios.maintenance.calendar.errors.saveFailed)
        }
    }
}
