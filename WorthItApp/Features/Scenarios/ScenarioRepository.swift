import Foundation

struct ScenarioRepository: Sendable {
    let client: HTTPAPIClient

    func listScenarios() async throws -> [ScenarioListItem] {
        try await client.get("/scenarios")
    }

    func createScenario(_ request: CreateScenarioRequest) async throws -> ScenarioListItem {
        try await client.post("/scenarios", body: request)
    }

    func updateScenario(scenarioId: UUID, request: UpdateScenarioRequest) async throws -> ScenarioListItem {
        try await client.patch("/scenarios/\(apiId(scenarioId))", body: request)
    }

    func deleteScenario(scenarioId: UUID) async throws {
        try await client.delete("/scenarios/\(apiId(scenarioId))")
    }

    func getSummary(scenarioId: UUID, asOfDate: Date? = nil) async throws -> ScenarioSummary {
        var queryItems: [URLQueryItem] = []

        if let asOfDate {
            queryItems.append(URLQueryItem(name: "asOfDate", value: ISO8601DateFormatter.api.string(from: asOfDate)))
        }

        if queryItems.isEmpty {
            return try await client.get("/scenarios/\(apiId(scenarioId))/summary")
        }

        return try await client.get("/scenarios/\(apiId(scenarioId))/summary", queryItems: queryItems)
    }

    func getComparison(scenarioId: UUID, asOfDate: Date? = nil) async throws -> ScenarioComparison {
        var queryItems: [URLQueryItem] = []

        if let asOfDate {
            queryItems.append(URLQueryItem(name: "asOfDate", value: ISO8601DateFormatter.api.string(from: asOfDate)))
        }

        if queryItems.isEmpty {
            return try await client.get("/scenarios/\(apiId(scenarioId))/comparison")
        }

        return try await client.get("/scenarios/\(apiId(scenarioId))/comparison", queryItems: queryItems)
    }

    func getAnalyticsOverview(scenarioId: UUID, asOfDate: Date? = nil) async throws -> ScenarioAnalyticsOverview {
        var queryItems: [URLQueryItem] = []

        if let asOfDate {
            queryItems.append(URLQueryItem(name: "asOfDate", value: ISO8601DateFormatter.api.string(from: asOfDate)))
        }

        if queryItems.isEmpty {
            return try await client.get("/scenarios/\(apiId(scenarioId))/analytics/overview")
        }

        return try await client.get("/scenarios/\(apiId(scenarioId))/analytics/overview", queryItems: queryItems)
    }

    func getAnalyticsMetric(
        scenarioId: UUID,
        metricId: ScenarioOverviewMetric,
        asOfDate: Date? = nil
    ) async throws -> ScenarioAnalyticsMetricPayload {
        var queryItems: [URLQueryItem] = []

        if let asOfDate {
            queryItems.append(URLQueryItem(name: "asOfDate", value: ISO8601DateFormatter.api.string(from: asOfDate)))
        }

        let path = "/scenarios/\(apiId(scenarioId))/analytics/metrics/\(metricId.rawValue)"
        if queryItems.isEmpty {
            return try await client.get(path)
        }

        return try await client.get(path, queryItems: queryItems)
    }

    func listAlternatives(scenarioId: UUID) async throws -> [AlternativeOption] {
        try await client.get("/scenarios/\(apiId(scenarioId))/alternatives")
    }

    func createAlternative(scenarioId: UUID, request: CreateAlternativeRequest) async throws -> AlternativeOption {
        try await client.post("/scenarios/\(apiId(scenarioId))/alternatives", body: request)
    }

    func updateAlternative(alternativeId: UUID, request: UpdateAlternativeRequest) async throws -> AlternativeOption {
        try await client.patch("/alternatives/\(apiId(alternativeId))", body: request)
    }

    func deleteAlternative(alternativeId: UUID) async throws {
        try await client.delete("/alternatives/\(apiId(alternativeId))")
    }

    func listCostEvents(scenarioId: UUID) async throws -> [CostEvent] {
        try await client.get("/scenarios/\(apiId(scenarioId))/cost-events")
    }

    func listUsageEvents(scenarioId: UUID) async throws -> [UsageEvent] {
        try await client.get("/scenarios/\(apiId(scenarioId))/usage-events")
    }

    func createUsageEvent(scenarioId: UUID, request: CreateUsageEventRequest) async throws -> UsageEvent {
        try await client.post("/scenarios/\(apiId(scenarioId))/usage-events", body: request)
    }

    func updateUsageEvent(usageEventId: UUID, request: UpdateUsageEventRequest) async throws -> UsageEvent {
        try await client.patch("/usage-events/\(apiId(usageEventId))", body: request)
    }

    func deleteUsageEvent(usageEventId: UUID) async throws {
        try await client.delete("/usage-events/\(apiId(usageEventId))")
    }

    func createCostEvent(scenarioId: UUID, request: CreateCostEventRequest) async throws -> CostEvent {
        try await client.post("/scenarios/\(apiId(scenarioId))/cost-events", body: request)
    }

    func updateCostEvent(costEventId: UUID, request: UpdateCostEventRequest) async throws -> CostEvent {
        try await client.patch("/cost-events/\(apiId(costEventId))", body: request)
    }

    func deleteCostEvent(costEventId: UUID) async throws {
        try await client.delete("/cost-events/\(apiId(costEventId))")
    }

    func createCostEventAttachmentUploadIntent(
        costEventId: UUID,
        request: CreateAttachmentUploadIntentRequest
    ) async throws -> AttachmentUploadIntentResponse {
        try await client.post("/cost-events/\(apiId(costEventId))/attachments/upload-intents", body: request)
    }

    func createCostEventLink(costEventId: UUID, request: CreateResourceLinkRequest) async throws -> ResourceLink {
        try await client.post("/cost-events/\(apiId(costEventId))/links", body: request)
    }

    func createCostEventLocation(
        costEventId: UUID,
        request: CreateResourceLocationRequest
    ) async throws -> ResourceLocation {
        try await client.post("/cost-events/\(apiId(costEventId))/locations", body: request)
    }

    func createScheduledService(
        scenarioId: UUID,
        request: CreateScheduledServiceRequest
    ) async throws -> ScheduledService {
        try await client.post("/scenarios/\(apiId(scenarioId))/scheduled-services", body: request)
    }

    func updateScheduledService(
        scheduledServiceId: UUID,
        request: UpdateScheduledServiceRequest
    ) async throws -> ScheduledService {
        try await client.patch("/scheduled-services/\(apiId(scheduledServiceId))", body: request)
    }

    func updateScheduledServiceCompletion(
        scheduledServiceId: UUID,
        request: UpdateScheduledServiceCompletionRequest
    ) async throws -> ScheduledService {
        try await client.patch("/scheduled-services/\(apiId(scheduledServiceId))", body: request)
    }

    func listScheduledServices(scenarioId: UUID) async throws -> [ScheduledService] {
        try await client.get("/scenarios/\(apiId(scenarioId))/scheduled-services")
    }

    func listScheduledServiceDueStates(scenarioId: UUID) async throws -> ScheduledServicesDueResponse {
        try await client.get("/scenarios/\(apiId(scenarioId))/scheduled-services/due")
    }

    func createScheduledServiceAttachmentUploadIntent(
        scheduledServiceId: UUID,
        request: CreateAttachmentUploadIntentRequest
    ) async throws -> AttachmentUploadIntentResponse {
        try await client.post(
            "/scheduled-services/\(apiId(scheduledServiceId))/attachments/upload-intents",
            body: request
        )
    }

    func createScheduledServiceLink(
        scheduledServiceId: UUID,
        request: CreateResourceLinkRequest
    ) async throws -> ResourceLink {
        try await client.post("/scheduled-services/\(apiId(scheduledServiceId))/links", body: request)
    }

    func createScheduledServiceLocation(
        scheduledServiceId: UUID,
        request: CreateResourceLocationRequest
    ) async throws -> ResourceLocation {
        try await client.post("/scheduled-services/\(apiId(scheduledServiceId))/locations", body: request)
    }

    func updateAttachment(attachmentId: UUID, request: UpdateAttachmentRequest) async throws -> ResourceAttachment {
        try await client.patch("/attachments/\(apiId(attachmentId))", body: request)
    }

    func getAttachmentDownloadURL(attachmentId: UUID) async throws -> AttachmentDownloadURLResponse {
        try await client.get("/attachments/\(apiId(attachmentId))/download-url")
    }

    func uploadAttachmentData(_ data: Data, intent: AttachmentUploadIntentResponse) async throws {
        guard intent.uploadUrl.scheme != "local" else { return }
        try await client.upload(data: data, to: intent.uploadUrl, headers: intent.uploadHeaders)
    }

    func deleteAttachment(attachmentId: UUID) async throws {
        try await client.delete("/attachments/\(apiId(attachmentId))")
    }

    func updateResourceLink(linkId: UUID, request: UpdateResourceLinkRequest) async throws -> ResourceLink {
        try await client.patch("/links/\(apiId(linkId))", body: request)
    }

    func deleteResourceLink(linkId: UUID) async throws {
        try await client.delete("/links/\(apiId(linkId))")
    }

    func updateResourceLocation(
        locationId: UUID,
        request: UpdateResourceLocationRequest
    ) async throws -> ResourceLocation {
        try await client.patch("/locations/\(apiId(locationId))", body: request)
    }

    func deleteResourceLocation(locationId: UUID) async throws {
        try await client.delete("/locations/\(apiId(locationId))")
    }

    func createSmokeScenario() async throws -> ScenarioListItem {
        try await client.post(
            "/scenarios",
            body: CreateScenarioRequest(
                name: "My Car",
                category: "car",
                scenarioType: "car_ownership",
                currency: "EUR",
                startDate: Date(),
                purchasePrice: 20_000,
                purchaseOdometer: nil,
                expectedResaleValue: nil,
                acquisitionType: "cash",
                loanAmount: nil,
                loanTermMonths: nil,
                loanAnnualInterestRate: nil
            )
        )
    }

    private func apiId(_ id: UUID) -> String {
        id.uuidString.lowercased()
    }
}

private extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
