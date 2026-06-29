import EventKit
import Foundation

struct ServiceCalendarExportRequest {
    let title: String?
    let fallbackTitle: String
    let startDate: Date?
    let fallbackDate: Date?
    let notes: String?
}

enum ServiceCalendarExportFailure: Equatable {
    case missingDate
    case accessDenied
    case calendarUnavailable
    case saveFailed
}

enum ServiceCalendarExportResult: Equatable {
    case success
    case failure(ServiceCalendarExportFailure)
}

final class ServiceCalendarExporter {
    private let eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    func export(_ request: ServiceCalendarExportRequest) async -> ServiceCalendarExportResult {
        guard let startDate = request.startDate ?? request.fallbackDate else {
            return .failure(.missingDate)
        }

        let accessGranted: Bool
        do {
            accessGranted = try await requestCalendarAccess()
        } catch {
            return .failure(.accessDenied)
        }

        guard accessGranted else {
            return .failure(.accessDenied)
        }

        guard let calendar = eventStore.defaultCalendarForNewEvents else {
            return .failure(.calendarUnavailable)
        }

        let title = request.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title?.isEmpty == false ? title : request.fallbackTitle
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(60 * 60)
        event.notes = notes(from: request)

        do {
            try eventStore.save(event, span: .thisEvent)
            return .success
        } catch {
            return .failure(.saveFailed)
        }
    }

    private func requestCalendarAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToEvents()
    }

    private func notes(from request: ServiceCalendarExportRequest) -> String {
        let backendNotes = request.notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let context = "Added from Worth It service schedule."

        guard backendNotes?.isEmpty == false else {
            return context
        }

        return [backendNotes, context].compactMap { $0 }.joined(separator: "\n\n")
    }
}
