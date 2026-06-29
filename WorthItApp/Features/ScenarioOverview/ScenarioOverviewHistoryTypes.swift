import Foundation

struct ScenarioExpenseMonthGroup: Identifiable {
    struct SyntheticItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let value: Double
        let valueText: String
        let detail: String
        let systemIcon: String
        let accentColor: String
    }

    let monthStart: Date
    let events: [CostEvent]
    let syntheticItems: [SyntheticItem]

    var id: Date { monthStart }
}

struct ScenarioExpenseHistoryBar: Identifiable {
    let monthStart: Date
    let selectionId: String
    let label: String
    let total: Double
    let previousTotal: Double?
    let count: Int
    let isCurrentMonth: Bool

    var id: String { selectionId }
}

struct ScenarioMileageHistoryBar: Identifiable {
    let monthStart: Date
    let selectionId: String
    let label: String
    let total: Double
    let previousTotal: Double?
    let count: Int
    let isCurrentMonth: Bool

    var id: String { selectionId }
}

struct ScenarioMileageLogItem: Identifiable {
    enum Kind {
        case odometer
        case trip
    }

    let id: UUID
    let kind: Kind
    let title: String
    let subtitle: String
    let previousOdometer: Int?
    let currentOdometer: Int?
    let distance: Double?
    let estimatedCostLabel: String?
    let unit: String
    let date: Date
}

struct ScenarioMileageMonthGroup: Identifiable {
    let monthStart: Date
    let items: [ScenarioMileageLogItem]

    var id: Date { monthStart }
}

struct ScenarioScheduledServiceDisplayItem: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let dueState: String
    let date: Date?
    let isEstimatedDate: Bool
    let distanceRemaining: Double?
    let distanceUnit: String
    let daysRemaining: Int?
    let note: String?
    let calendarEligible: Bool
    let calendarSuggestedDate: Date?
    let calendarTitle: String?
    let calendarNotes: String?

    var calendarExportDate: Date? {
        calendarSuggestedDate ?? date
    }

    var canExportToCalendar: Bool {
        calendarExportDate != nil
    }
}
