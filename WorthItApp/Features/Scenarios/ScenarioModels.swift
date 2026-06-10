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

enum AlternativePricingMode: String, Codable, CaseIterable, Identifiable {
    case perDistance = "per_distance"
    case distanceCurve = "distance_curve"
    case perPeriod = "per_period"
    case perTime = "per_time"
    case mixed
    case manualEquivalent = "manual_equivalent"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .perDistance: "Per KM"
        case .distanceCurve: "Distance Curve"
        case .perPeriod: "Per Month"
        case .perTime: "Per Minute"
        case .mixed: "Per KM + Per Minute"
        case .manualEquivalent: "Manual Total"
        }
    }
}

struct AlternativePricePoint: Codable, Hashable, Identifiable {
    var id: Double { distanceKm }

    let distanceKm: Double
    let totalPrice: Double
}

struct ComparableCurveInputPoint: Identifiable, Hashable {
    let id: UUID
    var distanceKm: String
    var totalPrice: String

    init(id: UUID = UUID(), distanceKm: String = "", totalPrice: String = "") {
        self.id = id
        self.distanceKm = distanceKm
        self.totalPrice = totalPrice
    }
}

struct AlternativeParams: Codable, Hashable {
    let pricePerKm: Double?
    let pricePoints: [AlternativePricePoint]?
    let pricePerMonth: Double?
    let pricePerMinute: Double?
    let fixedPerMonth: Double?
    let kind: String?
    let value: Double?
    let includedCostCategories: [String]?

    init(
        pricePerKm: Double? = nil,
        pricePoints: [AlternativePricePoint]? = nil,
        pricePerMonth: Double? = nil,
        pricePerMinute: Double? = nil,
        fixedPerMonth: Double? = nil,
        kind: String? = nil,
        value: Double? = nil,
        includedCostCategories: [String]? = nil
    ) {
        self.pricePerKm = pricePerKm
        self.pricePoints = pricePoints
        self.pricePerMonth = pricePerMonth
        self.pricePerMinute = pricePerMinute
        self.fixedPerMonth = fixedPerMonth
        self.kind = kind
        self.value = value
        self.includedCostCategories = includedCostCategories
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pricePerKm, forKey: .pricePerKm)
        try container.encodeIfPresent(pricePoints, forKey: .pricePoints)
        try container.encodeIfPresent(pricePerMonth, forKey: .pricePerMonth)
        try container.encodeIfPresent(pricePerMinute, forKey: .pricePerMinute)
        try container.encodeIfPresent(fixedPerMonth, forKey: .fixedPerMonth)
        try container.encodeIfPresent(kind, forKey: .kind)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(includedCostCategories, forKey: .includedCostCategories)
    }
}

struct AlternativeOption: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let name: String
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isIncluded: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct CreateAlternativeRequest: Encodable {
    let name: String
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isIncluded: Bool
}

struct UpdateAlternativeRequest: Encodable {
    let name: String
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isIncluded: Bool
}

struct ScenarioComparison: Decodable, Hashable {
    struct AlternativeResult: Decodable, Identifiable, Hashable {
        let id: UUID
        let name: String
        let pricingMode: AlternativePricingMode
        let isIncluded: Bool
        let estimatedTotalCost: Double
        let costBreakdown: CostBreakdown
        let deltaVsOwnership: Double
    }

    struct AlternativeBreakEven: Decodable, Identifiable, Hashable {
        let alternativeId: UUID
        let alternativeName: String
        let status: Status
        let reason: String?
        let currentDistanceKm: Double
        let breakEvenDistanceKm: Double?
        let remainingDistanceKm: Double?
        let progress: Double
        let fixedOwnershipCost: Double
        let carRunningCostPerKm: Double?
        let alternativeCostPerKm: Double?
        let alternativeCostPerKmMin: Double?
        let alternativeCostPerKmMax: Double?
        let carTotalCost: Double?
        let alternativeTotalCost: Double?
        let savingsAmount: Double?

        var id: UUID { alternativeId }

        enum Status: String, Decodable, Hashable {
            case reachable
            case alreadyReached = "already_reached"
            case unreachable
            case insufficientData = "insufficient_data"
        }
    }

    struct CostBreakdown: Decodable, Hashable {
        let pricingTotal: Double
        let inheritedCostsTotal: Double
        let total: Double
        let perKm: Double?
        let perMonth: Double?
        let inputs: CostBreakdownInputs
    }

    struct CostBreakdownInputs: Decodable, Hashable {
        let totalDistanceKm: Double
        let monthsOwned: Double
        let totalDurationMinutes: Double
        let pricePerKm: Double?
        let pricePerMonth: Double?
        let pricePerMinute: Double?
        let fixedPerMonth: Double?
        let averageCurvePricePerKm: Double?
        let curvePointRates: [Double]?
        let curveUsedMinPricePerKm: Double?
        let curveUsedMaxPricePerKm: Double?
        let curveTripCount: Double?
        let manualKind: String?
        let manualValue: Double?
    }

    struct Series: Decodable, Hashable {
        struct Point: Decodable, Identifiable, Hashable {
            let date: Date
            let total: Double
            let perKm: Double?
            let perMonth: Double?

            var id: Date { date }
        }

        struct Alternative: Decodable, Identifiable, Hashable {
            let id: UUID
            let name: String
            let pricingMode: AlternativePricingMode
            let isIncluded: Bool
            let points: [Point]
        }

        let period: String
        let ownership: [Point]
        let alternatives: [Alternative]
    }

    let summary: ScenarioSummary
    let alternatives: [AlternativeResult]
    let alternativeBreakEvens: [AlternativeBreakEven]
    let series: Series?
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
    let scheduledServiceId: UUID?
    let isSharedCost: Bool
    let note: String?
}

struct UpdateCostEventRequest: Encodable {
    let date: Date?
    let amount: Decimal?
    let currency: String?
    let category: String?
    let kind: String?
    let scheduledServiceId: UUID?
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
    let baselineDate: Date?
    let baselineOdometerValue: Double?
    let baselineOdometerUnit: String?
    let baselineOdometerKm: String?
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

struct ScheduledServicesDueResponse: Decodable, Hashable {
    let asOfDate: Date
    let items: [ScheduledServiceDueItem]
}

struct ScheduledServiceDueItem: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let title: String
    let category: String
    let status: String
    let triggerType: String
    let dueState: String
    let dueDate: Date?
    let dueOdometerValue: Double?
    let dueOdometerUnit: String
    let dueOdometerKm: String?
    let currentOdometerValue: Double?
    let currentOdometerUnit: String
    let currentOdometerKm: String?
    let distanceRemainingValue: Double?
    let distanceRemainingUnit: String
    let kmRemaining: String?
    let daysRemaining: Int?
    let predictedDueDate: Date?
    let predictionConfidence: String
    let predictionBasis: String
    let calendarEligible: Bool
    let calendarSuggestedDate: Date?
    let calendarTitle: String?
    let calendarNotes: String?
}

struct CreateScheduledServiceRequest: Encodable {
    let title: String
    let category: String
    let triggerType: String
    let baselineDate: Date?
    let baselineOdometerValue: Double?
    let dueDate: Date?
    let dueOdometerValue: Double?
    let repeatIntervalMonths: Int?
    let repeatIntervalValue: Double?
    let leadTimeDays: Int
    let note: String?
}

struct UpdateScheduledServiceRequest: Encodable {
    let title: String?
    let category: String?
    let status: String?
    let triggerType: String?
    let baselineDate: Date?
    let baselineOdometerValue: Double?
    let dueDate: Date?
    let dueOdometerValue: Double?
    let repeatIntervalMonths: Int?
    let repeatIntervalValue: Double?
    let leadTimeDays: Int?
    let lastCompletedAt: Date?
    let completedExpenseId: UUID?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case title
        case category
        case status
        case triggerType
        case baselineDate
        case baselineOdometerValue
        case dueDate
        case dueOdometerValue
        case repeatIntervalMonths
        case repeatIntervalValue
        case leadTimeDays
        case lastCompletedAt
        case completedExpenseId
        case note
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(triggerType, forKey: .triggerType)
        try container.encode(baselineDate, forKey: .baselineDate)
        try container.encode(baselineOdometerValue, forKey: .baselineOdometerValue)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(dueOdometerValue, forKey: .dueOdometerValue)
        try container.encodeIfPresent(repeatIntervalMonths, forKey: .repeatIntervalMonths)
        try container.encodeIfPresent(repeatIntervalValue, forKey: .repeatIntervalValue)
        try container.encodeIfPresent(leadTimeDays, forKey: .leadTimeDays)
        try container.encode(lastCompletedAt, forKey: .lastCompletedAt)
        try container.encode(completedExpenseId, forKey: .completedExpenseId)
        try container.encode(note, forKey: .note)
    }
}

struct UpdateScheduledServiceCompletionRequest: Encodable {
    let status: String
    let lastCompletedAt: Date?
    let completedExpenseId: UUID?

    enum CodingKeys: String, CodingKey {
        case status
        case lastCompletedAt
        case completedExpenseId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(lastCompletedAt, forKey: .lastCompletedAt)
        try container.encode(completedExpenseId, forKey: .completedExpenseId)
    }
}
