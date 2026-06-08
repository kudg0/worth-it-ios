import SwiftUI

enum ScenarioOverviewExpenseCategory: String, CaseIterable, Identifiable {
    case fuel
    case repair
    case tires
    case wash
    case insurance
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fuel: "Fuel"
        case .repair: "Repair"
        case .tires: "Tires"
        case .wash: "Wash"
        case .insurance: "Insurance"
        case .other: "Other"
        }
    }

    var systemName: String {
        switch self {
        case .fuel: "fuelpump"
        case .repair: "wrench"
        case .tires: "gearshape.2"
        case .wash: "shower"
        case .insurance: "shield"
        case .other: "receipt"
        }
    }

    var costCategory: String {
        switch self {
        case .fuel: "fuel"
        case .repair: "repair"
        case .tires: "tires"
        case .wash: "wash"
        case .insurance: "insurance"
        case .other: "other"
        }
    }
}

enum ScenarioOverviewMetric: String, CaseIterable, Identifiable {
    case monthlyCost
    case costPerKm
    case currentMonthCostPerKm
    case totalExpenses
    case totalOwnership
    case projectedGain
    case expectedResale
    case loanInterest

    var id: String { rawValue }
}

enum ScenarioOverviewExpenseHistoryFilter: String, CaseIterable, Identifiable {
    case all
    case fuel
    case service
    case insurance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .fuel: "Fuel"
        case .service: "Service"
        case .insurance: "Insurance"
        }
    }

    func contains(_ event: CostEvent) -> Bool {
        switch self {
        case .all:
            true
        case .fuel:
            event.category == "fuel"
        case .service:
            ["maintenance", "repair", "tires", "wash"].contains(event.category)
        case .insurance:
            event.category == "insurance"
        }
    }
}

struct ScenarioMetricSlide: Identifiable {
    let id: ScenarioOverviewMetric
    let title: String
    let value: String
    let subtitle: String?
    let footer: String?
    let footerIcon: String
    let footerColor: Color
    let progress: CGFloat
    let accentColor: Color
}

struct ScenarioMetricTrend {
    let label: String
    let iconName: String
    let color: Color
}

struct ScenarioMetricTrendPoint: Identifiable {
    let date: Date
    let value: Double
    let isProjected: Bool

    var id: Date { date }

    init(date: Date, value: Double, isProjected: Bool = false) {
        self.date = date
        self.value = value
        self.isProjected = isProjected
    }
}

struct ScenarioCostPerKmBreakdownSource: Identifiable {
    enum Target {
        case expense(UUID)
        case mileage(UUID)
    }

    let id: String
    let date: Date
    let title: String
    let subtitle: String
    let value: String
    let status: String
    let systemName: String
    let accentColor: Color
    let target: Target?
}
