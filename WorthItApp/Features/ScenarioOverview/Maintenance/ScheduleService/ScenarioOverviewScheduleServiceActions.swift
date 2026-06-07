import SwiftUI

extension ScenarioOverviewView {
    func beginEditingScheduledService(_ serviceId: UUID) {
        guard let service = scheduledServices.first(where: { $0.id == serviceId }) else { return }

        editingScheduledService = service
        isScheduleBasisExpanded = false
        selectedServiceType = service.title
        serviceBaselineDate = service.baselineDate ?? service.createdAt
        serviceBaselineOdometer = service.baselineOdometerValue.map { formatEditableNumber($0) } ?? formatEditableNumber(Double(currentOdometerValue))
        serviceDate = service.dueDate
        if let dueOdometer = service.dueOdometerValue, let baselineOdometer = service.baselineOdometerValue {
            serviceMileageInputMode = .interval
            serviceMileage = formatEditableNumber(max(dueOdometer - baselineOdometer, 0))
        } else {
            serviceMileageInputMode = .odometer
            serviceMileage = service.dueOdometerValue.map { formatEditableNumber($0) } ?? ""
        }
        serviceDetails = service.note ?? ""
        isOptionalServiceDateEnabled = false
        isOptionalServiceMileageEnabled = false

        switch service.triggerType {
        case "mileage":
            scheduleTrigger = .mileage
        case "date_or_mileage":
            if service.dueDate != nil {
                scheduleTrigger = .date
                isOptionalServiceMileageEnabled = service.dueOdometerValue != nil
            } else {
                scheduleTrigger = .mileage
                isOptionalServiceDateEnabled = service.dueDate != nil
            }
        default:
            scheduleTrigger = .date
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.expenses]
            selectedTab = .scheduleService
        }
    }

    func resetCompletedService(_ serviceId: UUID) async throws {
        _ = try await repository.updateScheduledServiceCompletion(
            scheduledServiceId: serviceId,
            request: UpdateScheduledServiceCompletionRequest(
                status: "active",
                lastCompletedAt: nil,
                completedExpenseId: nil
            )
        )
    }

    func saveScheduledService() async {
        guard !isSavingEntry else { return }
        let title = selectedServiceType
        let note = trimmedServiceDetails

        guard title != "Select a service..." else {
            actionError = "Select service type."
            return
        }

        guard title != "Other" || !note.isEmpty else {
            actionError = "Add details for Other service type."
            return
        }

        let dueOdometer = serviceDueOdometerValue
        let hasDate = serviceDate != nil
        let hasMileage = dueOdometer != nil
        let shouldSendDate = scheduleTrigger == .date || isOptionalServiceDateEnabled
        let shouldSendMileage = scheduleTrigger == .mileage || isOptionalServiceMileageEnabled

        if shouldSendDate && !hasDate {
            actionError = "Select service date."
            return
        }

        if shouldSendMileage && !hasMileage {
            actionError = serviceMileageInputMode == .interval ? "Enter service interval." : "Enter due odometer."
            return
        }

        if shouldSendMileage && serviceBaselineDate == nil {
            actionError = "Select basis date."
            return
        }

        if shouldSendMileage && serviceBaselineOdometerValue == nil {
            actionError = "Enter basis odometer."
            return
        }

        if shouldSendMileage,
           serviceMileageInputMode == .odometer,
           let dueOdometer,
           let serviceBaselineOdometerValue,
           dueOdometer < serviceBaselineOdometerValue {
            actionError = "Due odometer cannot be lower than basis odometer."
            return
        }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            let triggerType = shouldSendDate && shouldSendMileage ? "date_or_mileage" : scheduleTrigger.apiValue

            if let editingScheduledService {
                _ = try await repository.updateScheduledService(
                    scheduledServiceId: editingScheduledService.id,
                    request: UpdateScheduledServiceRequest(
                        title: title,
                        category: scheduledServiceCategory(for: title),
                        status: editingScheduledService.status,
                        triggerType: triggerType,
                        baselineDate: serviceBaselineDate,
                        baselineOdometerValue: serviceBaselineOdometerValue,
                        dueDate: shouldSendDate ? serviceDate : nil,
                        dueOdometerValue: shouldSendMileage ? dueOdometer : nil,
                        repeatIntervalMonths: editingScheduledService.repeatIntervalMonths,
                        repeatIntervalValue: editingScheduledService.repeatIntervalValue,
                        leadTimeDays: editingScheduledService.leadTimeDays,
                        lastCompletedAt: editingScheduledService.lastCompletedAt,
                        completedExpenseId: editingScheduledService.completedExpenseId,
                        note: note.isEmpty ? "" : note
                    )
                )
            } else {
                _ = try await repository.createScheduledService(
                    scenarioId: activeScenario.id,
                    request: CreateScheduledServiceRequest(
                        title: title,
                        category: scheduledServiceCategory(for: title),
                        triggerType: triggerType,
                        baselineDate: serviceBaselineDate,
                        baselineOdometerValue: serviceBaselineOdometerValue,
                        dueDate: shouldSendDate ? serviceDate : nil,
                        dueOdometerValue: shouldSendMileage ? dueOdometer : nil,
                        repeatIntervalMonths: nil,
                        repeatIntervalValue: nil,
                        leadTimeDays: 30,
                        note: note.isEmpty ? nil : note
                    )
                )
            }

            await loadSummary()
            navigateAfterEntrySave()
            resetScheduledServiceForm()
        } catch {
            actionError = String(describing: error)
        }
    }

}
