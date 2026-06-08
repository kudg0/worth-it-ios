import SwiftUI

extension ScenarioOverviewView {
    var upcomingServiceItems: [ScheduledServiceDisplayItem] {
        scheduledServiceDueItems
            .filter { $0.status == "active" }
            .map { item in
                let usesEstimatedDate = item.dueDate == nil && item.predictedDueDate != nil
                let effectiveDate = item.dueDate ?? item.predictedDueDate
                let serviceNote = scheduledServices
                    .first(where: { $0.id == item.id })?
                    .note?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                return ScheduledServiceDisplayItem(
                    id: item.id,
                    title: item.title,
                    category: item.category,
                    dueState: item.dueState,
                    date: effectiveDate,
                    isEstimatedDate: usesEstimatedDate,
                    distanceRemaining: item.distanceRemainingValue,
                    distanceUnit: item.distanceRemainingUnit,
                    daysRemaining: item.daysRemaining,
                    note: serviceNote?.isEmpty == false ? serviceNote : nil
                )
            }
            .sorted { lhs, rhs in
                switch (lhs.date, rhs.date) {
                case let (left?, right?):
                    left < right
                case (.some, nil):
                    true
                case (nil, .some):
                    false
                case (nil, nil):
                    lhs.title < rhs.title
                }
            }
    }

    var completedScheduledServices: [ScheduledService] {
        scheduledServices
            .filter { $0.status == "completed" }
            .sorted {
                ($0.lastCompletedAt ?? $0.updatedAt) > ($1.lastCompletedAt ?? $1.updatedAt)
            }
    }

    func completedServiceSubtitle(_ service: ScheduledService) -> String {
        let dateText = service.lastCompletedAt.map { Self.serviceDateFormatter.string(from: $0) } ?? "Completed"

        if service.completedExpenseId != nil {
            return "\(dateText) • linked expense"
        }

        return dateText
    }

    func serviceStateTitle(_ state: String) -> String {
        switch state {
        case "overdue":
            "Overdue"
        case "due":
            "Due"
        case "due_soon":
            "Soon"
        case "unknown":
            "Estimate"
        default:
            "Scheduled"
        }
    }

    func serviceStateColor(_ state: String) -> Color {
        switch state {
        case "overdue":
            Color(hex: 0xF97373)
        case "due", "due_soon":
            Color(hex: 0xFBBF24)
        case "unknown":
            WorthItColor.textTertiary
        default:
            WorthItColor.primaryContainer
        }
    }

    func serviceIconName(for category: String) -> String {
        switch category {
        case "repair":
            "wrench.adjustable"
        case "inspection":
            "checkmark.seal"
        case "tires":
            "circle.hexagongrid"
        default:
            "calendar.badge.clock"
        }
    }
}
