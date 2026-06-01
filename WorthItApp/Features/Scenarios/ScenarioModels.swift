import Foundation

struct ScenarioListItem: Decodable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String?
    let scenarioType: String
    let currency: String
    let startDate: Date
    let purchasePrice: String
    let purchaseOdometer: Int?
    let expectedResaleValue: String?
    let acquisitionType: String
    let loanAmount: String?
    let loanTermMonths: Int?
    let loanAnnualInterestRate: String?
    let isFavorite: Bool
}

struct CreateScenarioRequest: Encodable {
    let name: String
    let category: String
    let scenarioType: String
    let currency: String
    let startDate: Date
    let purchasePrice: Decimal
    let purchaseOdometer: Int?
    let expectedResaleValue: Decimal?
    let acquisitionType: String
    let loanAmount: Decimal?
    let loanTermMonths: Int?
    let loanAnnualInterestRate: Decimal?
}

struct UpdateScenarioRequest: Encodable {
    let name: String?
    let category: String?
    let scenarioType: String?
    let currency: String?
    let startDate: Date?
    let purchasePrice: Decimal?
    let purchaseOdometer: Int?
    let expectedResaleValue: Decimal?
    let acquisitionType: String?
    let loanAmount: Decimal?
    let loanTermMonths: Int?
    let loanAnnualInterestRate: Decimal?
    let isFavorite: Bool?
}

extension UpdateScenarioRequest {
    static func favorite(_ isFavorite: Bool) -> UpdateScenarioRequest {
        UpdateScenarioRequest(
            name: nil,
            category: nil,
            scenarioType: nil,
            currency: nil,
            startDate: nil,
            purchasePrice: nil,
            purchaseOdometer: nil,
            expectedResaleValue: nil,
            acquisitionType: nil,
            loanAmount: nil,
            loanTermMonths: nil,
            loanAnnualInterestRate: nil,
            isFavorite: isFavorite
        )
    }
}

struct ScenarioSummary: Decodable, Hashable {
    struct OwnershipWindow: Decodable, Hashable {
        let startDate: Date
        let asOfDate: Date
        let monthsOwned: Double
    }

    struct CostBreakdown: Decodable, Hashable {
        let fuel: Double
        let insurance: Double
        let repair: Double
        let tires: Double?
        let maintenance: Double
        let wash: Double
        let parking: Double
        let tax: Double
        let accessories: Double
        let other: Double
    }

    let scenarioId: UUID
    let name: String
    let currency: String
    let ownershipWindow: OwnershipWindow
    let purchasePrice: Double
    let latestResaleEstimate: Double
    let includedCostsTotal: Double
    let excludedSharedCostsTotal: Double
    let netOwnershipCost: Double
    let totalDistanceKm: Double
    let totalDurationMinutes: Double
    let costPerKm: Double?
    let costPerMonth: Double
    let costBreakdownByCategory: CostBreakdown
}

struct CostEvent: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let scheduledServiceId: UUID?
    let date: Date
    let amount: String
    let currency: String
    let category: String
    let kind: String
    let isSharedCost: Bool
    let note: String?
    let createdAt: Date
    let updatedAt: Date
}

struct UsageEvent: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let eventType: String
    let date: Date
    let distanceValue: Double
    let distanceUnit: String
    let distanceKm: String
    let odometerValue: Double?
    let odometerUnit: String
    let odometerKm: String?
    let durationMinutes: Int?
    let note: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateUsageEventRequest: Encodable {
    let eventType: String
    let date: Date
    let distanceValue: Double?
    let odometerValue: Double?
    let durationMinutes: Int?
    let note: String?
}

struct UpdateUsageEventRequest: Encodable {
    let eventType: String?
    let date: Date?
    let distanceValue: Double?
    let odometerValue: Double?
    let durationMinutes: Int?
    let note: String?
}

struct CreateCostEventRequest: Encodable {
    let date: Date
    let amount: Decimal
    let currency: String
    let category: String
    let kind: String
    let isSharedCost: Bool
    let note: String?
}

struct UpdateCostEventRequest: Encodable {
    let date: Date?
    let amount: Decimal?
    let currency: String?
    let category: String?
    let kind: String?
    let isSharedCost: Bool?
    let note: String?
}

struct ScheduledService: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let title: String
    let category: String
    let status: String
    let triggerType: String
    let dueDate: Date?
    let dueOdometerValue: Double?
    let dueOdometerUnit: String
    let dueOdometerKm: String?
    let repeatIntervalMonths: Int?
    let repeatIntervalValue: Double?
    let repeatIntervalUnit: String
    let repeatIntervalKm: String?
    let leadTimeDays: Int
    let lastCompletedAt: Date?
    let lastCompletedOdometerKm: String?
    let completedExpenseId: UUID?
    let note: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateScheduledServiceRequest: Encodable {
    let title: String
    let category: String
    let triggerType: String
    let dueDate: Date?
    let dueOdometerValue: Double?
    let repeatIntervalMonths: Int?
    let repeatIntervalValue: Double?
    let leadTimeDays: Int
    let note: String?
}
