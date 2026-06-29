import Foundation

struct ScenarioListItem: Decodable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: String?
    let scenarioType: String
    let baseUnit: String
    let currency: String
    let region: String
    let startDate: Date
    let purchasePrice: String
    let purchaseOdometer: Int?
    let expectedResaleValue: String?
    let acquisitionType: String
    let loanAmount: String?
    let loanTermMonths: Int?
    let loanAnnualInterestRate: String?
    let isFavorite: Bool
    let analyticsEnabledMetricIds: [String]?
    let analyticsDefaultMetricId: String
    let analyticsCostPerKmBasis: String
    let analyticsIncludesResidualValue: Bool
    let analyticsDeltaDisplay: String
    let analyticsSavingsAlternativeId: UUID?
    let currentOdometerKm: Double?
    let costPerKm: Double?
}

extension ScenarioListItem {
    func applying(settings: ScenarioSettings) -> ScenarioListItem {
        ScenarioListItem(
            id: id,
            name: name,
            category: category,
            scenarioType: scenarioType,
            baseUnit: settings.distanceUnit,
            currency: settings.currency,
            region: settings.region,
            startDate: startDate,
            purchasePrice: purchasePrice,
            purchaseOdometer: purchaseOdometer,
            expectedResaleValue: expectedResaleValue,
            acquisitionType: acquisitionType,
            loanAmount: loanAmount,
            loanTermMonths: loanTermMonths,
            loanAnnualInterestRate: loanAnnualInterestRate,
            isFavorite: isFavorite,
            analyticsEnabledMetricIds: settings.analytics.enabledMetricIds,
            analyticsDefaultMetricId: settings.analytics.defaultMetricId,
            analyticsCostPerKmBasis: settings.analytics.costPerKmBasis,
            analyticsIncludesResidualValue: settings.analytics.includesResidualValue,
            analyticsDeltaDisplay: settings.analytics.deltaDisplay,
            analyticsSavingsAlternativeId: settings.analytics.savingsAlternativeId,
            currentOdometerKm: currentOdometerKm,
            costPerKm: costPerKm
        )
    }
}

struct CreateScenarioRequest: Encodable {
    let name: String
    let category: String
    let scenarioType: String
    let baseUnit: String
    let currency: String
    let region: String
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
    let baseUnit: String?
    let currency: String?
    let region: String?
    let startDate: Date?
    let purchasePrice: Decimal?
    let purchaseOdometer: Int?
    let expectedResaleValue: Decimal?
    let acquisitionType: String?
    let loanAmount: Decimal?
    let loanTermMonths: Int?
    let loanAnnualInterestRate: Decimal?
    let isFavorite: Bool?
    let analytics: ScenarioAnalyticsSettingsPatch?
}

extension UpdateScenarioRequest {
    static func favorite(_ isFavorite: Bool) -> UpdateScenarioRequest {
        UpdateScenarioRequest(
            name: nil,
            category: nil,
            scenarioType: nil,
            baseUnit: nil,
            currency: nil,
            region: nil,
            startDate: nil,
            purchasePrice: nil,
            purchaseOdometer: nil,
            expectedResaleValue: nil,
            acquisitionType: nil,
            loanAmount: nil,
            loanTermMonths: nil,
            loanAnnualInterestRate: nil,
            isFavorite: isFavorite,
            analytics: nil
        )
    }
}

struct ScenarioSettings: Decodable, Equatable {
    let scenarioId: UUID
    let currency: String
    let region: String
    let distanceUnit: String
    let currencyChangeAllowed: Bool
    let currencyChangeBlockedReason: String?
    let analytics: ScenarioAnalyticsSettings
}

struct ScenarioAnalyticsSettings: Codable, Equatable {
    let enabledMetricIds: [String]
    let defaultMetricId: String
    let costPerKmBasis: String
    let includesResidualValue: Bool
    let deltaDisplay: String
    let savingsAlternativeId: UUID?
}

struct ScenarioSettingsPatch: Encodable {
    let currency: String?
    let region: String?
    let distanceUnit: String?
    let analytics: ScenarioAnalyticsSettingsPatch?

    init(
        currency: String? = nil,
        region: String? = nil,
        distanceUnit: String? = nil,
        analytics: ScenarioAnalyticsSettingsPatch? = nil
    ) {
        self.currency = currency
        self.region = region
        self.distanceUnit = distanceUnit
        self.analytics = analytics
    }
}

struct ScenarioAnalyticsSettingsPatch: Encodable {
    let enabledMetricIds: [String]?
    let defaultMetricId: String?
    let costPerKmBasis: String?
    let includesResidualValue: Bool?
    let deltaDisplay: String?
    let savingsAlternativeId: UUID?

    init(
        enabledMetricIds: [String]? = nil,
        defaultMetricId: String? = nil,
        costPerKmBasis: String? = nil,
        includesResidualValue: Bool? = nil,
        deltaDisplay: String? = nil,
        savingsAlternativeId: UUID? = nil
    ) {
        self.enabledMetricIds = enabledMetricIds
        self.defaultMetricId = defaultMetricId
        self.costPerKmBasis = costPerKmBasis
        self.includesResidualValue = includesResidualValue
        self.deltaDisplay = deltaDisplay
        self.savingsAlternativeId = savingsAlternativeId
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

enum AlternativeCategory: String, Codable, CaseIterable, Identifiable {
    case taxi
    case carSharing = "car_sharing"
    case rentalCar = "rental_car"
    case publicTransport = "public_transport"
    case bicycle
    case motorcycle
    case electricScooter = "electric_scooter"
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .taxi: "Taxi"
        case .carSharing: "Carsharing"
        case .rentalCar: "Rental Car"
        case .publicTransport: "Transport"
        case .bicycle: "Bicycle"
        case .motorcycle: "Motorcycle"
        case .electricScooter: "E-Scooter"
        case .custom: "Custom"
        }
    }

    var iconName: String {
        switch self {
        case .taxi: "car.fill"
        case .carSharing: "car.2.fill"
        case .rentalCar: "key.fill"
        case .publicTransport: "bus.fill"
        case .bicycle: "bicycle"
        case .motorcycle: "motorcycle"
        case .electricScooter: "scooter"
        case .custom: "slider.horizontal.3"
        }
    }

    var categoryDescription: String {
        switch self {
        case .taxi: "Point-to-point paid rides."
        case .carSharing: "Shared cars with distance or minute pricing."
        case .rentalCar: "Rental plans for days or months."
        case .publicTransport: "Passes, buses, trains, and transit."
        case .bicycle: "Bike ownership, rental, or maintenance."
        case .motorcycle: "Motorbike ownership, rental, or running costs."
        case .electricScooter: "Minute-based electric micromobility."
        case .custom: "Anything that needs manual assumptions."
        }
    }

    var defaultComparableName: String {
        switch self {
        case .taxi: "Taxi"
        case .carSharing: "Carsharing"
        case .rentalCar: "Car Rental"
        case .publicTransport: "Public Transport"
        case .bicycle: "Bicycle"
        case .motorcycle: "Motorcycle"
        case .electricScooter: "Electric Scooter"
        case .custom: "Custom Alternative"
        }
    }

    var defaultPricingMode: AlternativePricingMode {
        switch self {
        case .taxi:
            .distanceCurve
        case .carSharing:
            .mixed
        case .rentalCar, .publicTransport:
            .perPeriod
        case .electricScooter:
            .perTime
        case .bicycle, .motorcycle, .custom:
            .manualEquivalent
        }
    }

    var allowedPricingModes: [AlternativePricingMode] {
        switch self {
        case .taxi:
            [.distanceCurve, .perDistance, .perTime]
        case .carSharing:
            [.mixed, .perDistance, .perTime]
        case .rentalCar:
            [.perPeriod, .perDistance]
        case .publicTransport:
            [.perPeriod]
        case .bicycle:
            [.manualEquivalent, .perPeriod, .perDistance, .perTime]
        case .motorcycle:
            [.manualEquivalent, .perPeriod, .perDistance]
        case .electricScooter:
            [.perTime, .perDistance]
        case .custom:
            [.manualEquivalent, .perDistance, .mixed, .perTime, .distanceCurve, .perPeriod]
        }
    }

    var defaultPricePerKm: String {
        switch self {
        case .carSharing:
            "0.35"
        default:
            ""
        }
    }

    var defaultPricePerMinute: String {
        switch self {
        case .carSharing:
            "0.25"
        case .bicycle, .electricScooter:
            "0.22"
        default:
            ""
        }
    }

    var defaultPricePerMonth: String {
        switch self {
        case .rentalCar:
            "500"
        case .publicTransport:
            "60"
        default:
            ""
        }
    }

    var defaultManualTotal: String {
        switch self {
        case .bicycle, .motorcycle, .custom:
            "0"
        default:
            ""
        }
    }

    var defaultCurvePoints: [ComparableCurveInputPoint] {
        switch self {
        case .taxi:
            [
                ComparableCurveInputPoint(distanceKm: "3", totalPrice: "9"),
                ComparableCurveInputPoint(distanceKm: "8", totalPrice: "18"),
                ComparableCurveInputPoint(distanceKm: "25", totalPrice: "42"),
            ]
        default:
            [
                ComparableCurveInputPoint(),
                ComparableCurveInputPoint(),
            ]
        }
    }

    var defaultInheritedCostCategories: Set<String> {
        switch self {
        case .rentalCar:
            ["fuel", "wash"]
        default:
            []
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
    let averageSpeedKmh: Double?
    let fixedPerMonth: Double?
    let kind: String?
    let value: Double?
    let includedCostCategories: [String]?

    init(
        pricePerKm: Double? = nil,
        pricePoints: [AlternativePricePoint]? = nil,
        pricePerMonth: Double? = nil,
        pricePerMinute: Double? = nil,
        averageSpeedKmh: Double? = nil,
        fixedPerMonth: Double? = nil,
        kind: String? = nil,
        value: Double? = nil,
        includedCostCategories: [String]? = nil
    ) {
        self.pricePerKm = pricePerKm
        self.pricePoints = pricePoints
        self.pricePerMonth = pricePerMonth
        self.pricePerMinute = pricePerMinute
        self.averageSpeedKmh = averageSpeedKmh
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
        try container.encodeIfPresent(averageSpeedKmh, forKey: .averageSpeedKmh)
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
    let category: AlternativeCategory
    let presetKey: String?
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isIncluded: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct AlternativePreset: Decodable, Identifiable, Hashable {
    let key: String
    let category: AlternativeCategory
    let title: String
    let subtitle: String
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isRecommended: Bool

    var id: String { key }
}

struct CreateAlternativeRequest: Encodable {
    let name: String
    let category: AlternativeCategory
    let presetKey: String?
    let pricingMode: AlternativePricingMode
    let paramsJson: AlternativeParams
    let note: String?
    let isIncluded: Bool
}

struct UpdateAlternativeRequest: Encodable {
    let name: String
    let category: AlternativeCategory
    let presetKey: String?
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
        let dynamicTripSavings: DynamicTripSavings?

        var id: UUID { alternativeId }

        enum Status: String, Decodable, Hashable {
            case reachable
            case alreadyReached = "already_reached"
            case unreachable
            case insufficientData = "insufficient_data"
        }
    }

    struct DynamicTripSavings: Decodable, Hashable {
        let carTotalCost: Double
        let alternativeTotalCost: Double
        let savingsAmount: Double
        let distanceKm: Double
        let tripCount: Int
        let items: [DynamicTripSavingsItem]
    }

    struct DynamicTripSavingsItem: Decodable, Identifiable, Hashable {
        let usageEventId: UUID
        let date: Date
        let distanceKm: Double
        let carCostPerKm: Double?
        let carTripCost: Double?
        let alternativeCostPerKm: Double?
        let alternativeTripCost: Double?
        let savingsAmount: Double?

        var id: UUID { usageEventId }
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
        let pricePerKm: Double?
        let pricePerMonth: Double?
        let pricePerMinute: Double?
        let averageSpeedKmh: Double?
        let effectiveMinutePricePerKm: Double?
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

enum ScenarioAnalyticsMetricId: String, Decodable, Hashable, CaseIterable {
    case monthlyCost
    case costPerKm
    case currentMonthCostPerKm
    case totalExpenses
    case totalOwnership
    case paybackDistance
    case projectedGain
    case expectedResale
    case loanInterest
    case efficiencyComparison

    var overviewMetric: ScenarioOverviewMetric? {
        ScenarioOverviewMetric(rawValue: rawValue)
    }
}

struct ScenarioAnalyticsOverview: Decodable, Hashable {
    let scenarioId: UUID
    let enabledMetricIds: [ScenarioAnalyticsMetricId]
    let defaultMetricId: ScenarioAnalyticsMetricId
    let generatedAt: Date
    let asOfDate: Date
    let metrics: [ScenarioAnalyticsMetricPayload]
}

struct ScenarioAnalyticsMetricPayload: Decodable, Hashable {
    struct Availability: Decodable, Hashable {
        let isAvailable: Bool
        let reason: String?
    }

    struct EntityRef: Decodable, Hashable {
        let type: String
        let id: String
    }

    struct Card: Decodable, Hashable {
        let title: String
        let value: String
        let numericValue: Double?
        let unit: String?
        let subtitle: String?
        let footer: String?
        let trend: Trend?
        let progress: Double?
        let tone: String?
        let entityRef: EntityRef?
    }

    struct Trend: Decodable, Hashable {
        let label: String
        let direction: String
        let delta: Double?
        let deltaPercent: Double?
        let lowerIsBetter: Bool
        let tone: String
        let comparisonLabel: String?
    }

    struct Chart: Decodable, Hashable {
        struct Point: Decodable, Hashable {
            let date: Date
            let value: Double
            let isProjected: Bool?
        }

        struct Range: Decodable, Hashable {
            let period: String
            let points: [Point]
        }

        struct Series: Decodable, Hashable {
            let id: String
            let title: String
            let role: String
            let points: [Point]
        }

        struct SeriesRange: Decodable, Hashable {
            let period: String
            let series: [Series]
        }

        struct Axis: Decodable, Hashable {
            let max: Double
            let values: [Double]
        }

        let chartType: String
        let ranges: [String: Range]?
        let seriesRanges: [String: SeriesRange]?
        let series: [Series]?
        let yAxis: Axis?
    }

    struct Detail: Decodable, Hashable {
        struct Summary: Decodable, Hashable, Identifiable {
            let id: String
            let title: String
            let value: String
            let numericValue: Double?
            let unit: String?
        }

        struct Item: Decodable, Hashable, Identifiable {
            let id: String
            let title: String
            let subtitle: String?
            let value: String?
            let numericValue: Double?
            let date: Date?
            let category: String?
            let status: String?
            let entityRef: EntityRef?
        }

        struct Section: Decodable, Hashable, Identifiable {
            struct Total: Decodable, Hashable {
                let value: String
                let numericValue: Double
            }

            let id: String
            let title: String
            let subtitle: String?
            let total: Total?
            let items: [Item]
        }

        let title: String
        let summary: [Summary]?
        let sections: [Section]
    }

    let metricId: ScenarioAnalyticsMetricId
    let calculationVersion: String
    let generatedAt: Date
    let asOfDate: Date
    let availability: Availability
    let card: Card?
    let chart: Chart?
    let detail: Detail?
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
    let attachments: [ResourceAttachment]?
    let links: [ResourceLink]?
    let locations: [ResourceLocation]?
    let createdAt: Date
    let updatedAt: Date
}

struct ResourceAttachment: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let ownerType: String
    let costEventId: UUID?
    let scheduledServiceId: UUID?
    let usageEventId: UUID?
    let storageProvider: String
    let storageBucket: String
    let storageKey: String
    let optimizedStorageKey: String?
    let thumbnailStorageKey: String?
    let originalFileName: String
    let contentType: String
    let byteSize: Int
    let checksumSha256: String?
    let status: String
    let createdAt: Date
    let updatedAt: Date
}

struct ResourceLink: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let ownerType: String
    let costEventId: UUID?
    let scheduledServiceId: UUID?
    let usageEventId: UUID?
    let label: String?
    let url: URL
    let createdAt: Date
    let updatedAt: Date
}

struct ResourceLocation: Decodable, Identifiable, Hashable {
    let id: UUID
    let scenarioId: UUID
    let ownerType: String
    let costEventId: UUID?
    let scheduledServiceId: UUID?
    let label: String?
    let address: String?
    let latitude: String?
    let longitude: String?
    let providerPlaceId: String?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateAttachmentUploadIntentRequest: Encodable {
    let fileName: String
    let contentType: String
    let byteSize: Int
    let checksumSha256: String?
}

struct AttachmentUploadIntentResponse: Decodable, Hashable {
    let attachment: ResourceAttachment
    let uploadUrl: URL
    let uploadHeaders: [String: String]
    let expiresInSeconds: Int
}

struct AttachmentDownloadURLResponse: Decodable, Hashable {
    let attachment: ResourceAttachment
    let downloadUrl: URL
    let expiresInSeconds: Int
}

struct UpdateAttachmentRequest: Encodable {
    let originalFileName: String?
    let status: String?
}

struct CreateResourceLinkRequest: Encodable {
    let label: String?
    let url: URL
}

struct UpdateResourceLinkRequest: Encodable {
    let label: String?
    let url: URL?
}

struct CreateResourceLocationRequest: Encodable {
    let label: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let providerPlaceId: String?
}

struct UpdateResourceLocationRequest: Encodable {
    let label: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let providerPlaceId: String?
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
    let note: String?
    let attachments: [ResourceAttachment]?
    let links: [ResourceLink]?
    let createdAt: Date
    let updatedAt: Date
}

struct CreateUsageEventRequest: Encodable {
    let eventType: String
    let date: Date
    let distanceValue: Double?
    let odometerValue: Double?
    let note: String?
}

struct UpdateUsageEventRequest: Encodable {
    let eventType: String?
    let date: Date?
    let distanceValue: Double?
    let odometerValue: Double?
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
    let attachments: [ResourceAttachment]?
    let links: [ResourceLink]?
    let locations: [ResourceLocation]?
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
