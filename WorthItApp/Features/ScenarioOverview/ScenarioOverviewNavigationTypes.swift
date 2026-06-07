import SwiftUI

enum ScenarioOverviewChartRange: Hashable {
    case day
    case week
    case month

    var title: String { "Trend" }

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

enum ScenarioOverviewCostPerKmMode: String, Hashable {
    case effective
    case period

    var title: String {
        switch self {
        case .effective: "Effective"
        case .period: "Period"
        }
    }
}

enum ScenarioOverviewCompareMetric: String, CaseIterable, Identifiable {
    case perKm
    case perMonth
    case totalCost

    var id: String { rawValue }

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

enum ScenarioOverviewTab: Hashable {
    case overview
    case expenses
    case mileage
    case insights
    case compare
    case addComparableOption
    case addEntryChooser
    case logExpense
    case scheduleService
    case expenseHistory
    case mileageHistory
    case metricDetail
    case logMileage
    case profile
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
