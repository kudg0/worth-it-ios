import SwiftUI

enum ScenarioOverviewChartRange: Hashable {
    case day
    case week
    case month

    var title: String { trendTitle }

    var analyticsRangeKey: String {
        switch self {
        case .day: "day"
        case .week: "week"
        case .month: "month"
        }
    }

    var trendTitle: String {
        switch self {
        case .day: "Daily"
        case .week: "Weekly"
        case .month: "Monthly"
        }
    }
}

enum ScenarioOverviewMetricTrendRange: Hashable {
    case oneYear
    case all
}

enum ScenarioOverviewCostPerKmTrendScope: Hashable {
    case day
    case week
    case month
    case all

    var trendTitle: String {
        switch self {
        case .day: "Daily"
        case .week: "Weekly"
        case .month: "Monthly"
        case .all: "All-time"
        }
    }
}

enum ScenarioOverviewCompareMetric: String, CaseIterable, Identifiable {
    case perKm
    case perMonth
    case totalCost

    var id: String { rawValue }

    static let compareVisibleCases: [ScenarioOverviewCompareMetric] = [.perKm, .perMonth]

    var title: String {
        switch self {
        case .perKm: "Per KM"
        case .perMonth: "Per Month"
        case .totalCost: "Total Cost"
        }
    }
}

enum ScenarioOverviewMetricTrendSwipeDirection {
    case older
    case newer
}

enum ScenarioOverviewMetricTrendDeltaDisplay {
    case percent
    case currency
}

enum ScenarioAnalyticsDeltaDisplay: String, CaseIterable, Identifiable {
    case absolute
    case percent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .absolute: "Absolute"
        case .percent: "Percent"
        }
    }

    var metricTrendDisplay: ScenarioOverviewMetricTrendDeltaDisplay {
        switch self {
        case .absolute: .currency
        case .percent: .percent
        }
    }
}

enum ScenarioOverviewTab: Hashable {
    case overview
    case expenses
    case mileage
    case insights
    case compare
    case addComparableOption
    case analyticsSettings
    case comparisonSettings
    case addEntryChooser
    case logExpense
    case scheduleService
    case scheduledServices
    case scheduledServiceDetail
    case expenseDetail
    case expenseHistory
    case mileageHistory
    case mileageDetail
    case metricDetail
    case logMileage
    case settings
}

enum ScenarioResourceOwner: Identifiable, Hashable {
    case costEvent(UUID)
    case scheduledService(UUID)

    var id: String {
        switch self {
        case .costEvent(let id): "costEvent-\(id.uuidString)"
        case .scheduledService(let id): "scheduledService-\(id.uuidString)"
        }
    }
}

enum ScenarioResourceUploadSource: Identifiable, Hashable {
    case owner(ScenarioResourceOwner)

    var id: String {
        switch self {
        case .owner(let owner): owner.id
        }
    }
}

enum ScenarioResourceLinkEditor: Identifiable, Hashable {
    case create(ScenarioResourceOwner)
    case edit(ResourceLink)

    var id: String {
        switch self {
        case .create(let owner): "create-link-\(owner.id)"
        case .edit(let link): "edit-link-\(link.id.uuidString)"
        }
    }
}

enum ScenarioResourceLocationEditor: Identifiable, Hashable {
    case create(ScenarioResourceOwner)
    case edit(ResourceLocation)

    var id: String {
        switch self {
        case .create(let owner): "create-location-\(owner.id)"
        case .edit(let location): "edit-location-\(location.id.uuidString)"
        }
    }
}

enum ScenarioResourceAction: Identifiable, Hashable {
    case attachment(ResourceAttachment)
    case link(ResourceLink)
    case location(ResourceLocation)

    var id: String {
        switch self {
        case .attachment(let attachment): "attachment-\(attachment.id.uuidString)"
        case .link(let link): "link-\(link.id.uuidString)"
        case .location(let location): "location-\(location.id.uuidString)"
        }
    }
}

enum ScenarioOverviewEntryKind: Hashable {
    case expense
    case service
}

enum ScenarioOverviewScheduleTrigger: Hashable {
    case date
    case mileage

    var apiValue: String {
        switch self {
        case .date: "date"
        case .mileage: "mileage"
        }
    }
}

enum ScenarioOverviewServiceMileageInputMode: Hashable {
    case interval
    case odometer
}

enum ScenarioOverviewRecurringFrequency: String, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }
}

enum ScenarioOverviewLogExpensePicker: String, Identifiable {
    case date
    case time

    var id: String { rawValue }
}

enum ScenarioOverviewMileageMode: String, Hashable {
    case odometer
    case trip

    var eventType: String {
        switch self {
        case .odometer: "odometer_update"
        case .trip: "trip"
        }
    }
}

enum ScenarioOverviewMileagePicker: String, Identifiable {
    case date
    case time

    var id: String { rawValue }
}
