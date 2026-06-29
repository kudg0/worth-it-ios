import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

extension ScenarioOverviewView {
    func beginCompletingScheduledService(_ serviceId: UUID) {
        guard let service = scheduledServices.first(where: { $0.id == serviceId }) else { return }

        resetExpenseForm()
        expenseCategory = expenseCategory(forScheduledServiceCategory: service.category)
        expenseNotes = service.note ?? service.title
        selectedExpenseScheduledServiceId = service.id
        shouldCompleteLinkedScheduledService = true
        isExpenseServiceLinkExpanded = true

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.expenses]
            selectedTab = .logExpense
        }
    }

    func saveExpense() async {
        guard !isSavingEntry else { return }
        guard let amount = Decimal(string: expenseAmount), amount > 0 else {
            actionError = "Enter expense amount."
            return
        }

        let linkValidation = validatedExpenseLinkURL()
        guard linkValidation.isValid else { return }

        let savedExpenseDate = expenseDate

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            let savedEvent: CostEvent
            if let editingCostEvent {
                savedEvent = try await repository.updateCostEvent(
                    costEventId: editingCostEvent.id,
                    request: UpdateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        scheduledServiceId: selectedExpenseScheduledServiceId,
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? "" : trimmedExpenseNotes
                    )
                )
            } else {
                savedEvent = try await repository.createCostEvent(
                    scenarioId: activeScenario.id,
                    request: CreateCostEventRequest(
                        date: expenseDate,
                        amount: amount,
                        currency: activeScenario.currency,
                        category: expenseCategory.costCategory,
                        kind: isRecurringExpense ? "recurring" : "one_off",
                        scheduledServiceId: selectedExpenseScheduledServiceId,
                        isSharedCost: false,
                        note: trimmedExpenseNotes.isEmpty ? nil : trimmedExpenseNotes
                    )
                )
            }

            try await syncLinkedServiceCompletion(for: savedEvent)
            try await syncExpenseResources(for: savedEvent.id, draftURL: linkValidation.url)
            await loadSummary()
            navigateAfterEntrySave(savedExpenseDate: savedExpenseDate)
            resetExpenseForm()
        } catch {
            actionError = WIUpdateErrorText.message(for: error)
        }
    }

    func syncLinkedServiceCompletion(for event: CostEvent) async throws {
        if let selectedExpenseScheduledServiceId, shouldCompleteLinkedScheduledService {
            _ = try await repository.updateScheduledServiceCompletion(
                scheduledServiceId: selectedExpenseScheduledServiceId,
                request: UpdateScheduledServiceCompletionRequest(
                    status: "completed",
                    lastCompletedAt: event.date,
                    completedExpenseId: event.id
                )
            )
        }

        if let editingCostEvent,
           let oldServiceId = editingCostEvent.scheduledServiceId,
           oldServiceId != selectedExpenseScheduledServiceId,
           let oldService = scheduledServices.first(where: { $0.id == oldServiceId }),
           oldService.completedExpenseId == editingCostEvent.id {
            try await resetCompletedService(oldServiceId)
        }

        if let editingCostEvent,
           !shouldCompleteLinkedScheduledService,
           let serviceId = selectedExpenseScheduledServiceId,
           let service = scheduledServices.first(where: { $0.id == serviceId }),
           service.completedExpenseId == editingCostEvent.id {
            try await resetCompletedService(serviceId)
        }
    }

    func deleteEditingExpense() async {
        guard !isSavingEntry, let editingCostEvent else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteCostEvent(costEventId: editingCostEvent.id)
            await loadSummary()
            navigateAfterEntrySave()
            resetExpenseForm()
        } catch {
            actionError = WIUpdateErrorText.message(for: error, fallbackKey: .common.errors.update.deleteExpense)
        }
    }

    var trimmedExpenseNotes: String {
        expenseNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetExpenseForm() {
        editingCostEvent = nil
        expenseAmount = ""
        expenseDate = Date()
        expenseNotes = ""
        expenseCategory = .fuel
        isRecurringExpense = false
        expensePendingResources = []
        expenseRemovedAttachmentIds = []
        expenseRemovedLinkIds = []
        expenseLinkDraft = ""
        expenseLinkError = nil
        selectedExpensePhotoItem = nil
        showsExpenseFileImporter = false
        isExpenseServiceLinkExpanded = false
        selectedExpenseScheduledServiceId = nil
        shouldCompleteLinkedScheduledService = false
    }

    var visibleExpenseAttachments: [ResourceAttachment] {
        (editingCostEvent?.attachments ?? []).filter { !expenseRemovedAttachmentIds.contains($0.id) }
    }

    var visibleExpenseLinks: [ResourceLink] {
        (editingCostEvent?.links ?? []).filter { !expenseRemovedLinkIds.contains($0.id) }
    }

    func stageExpensePhoto(_ item: PhotosPickerItem) async {
        defer { selectedExpensePhotoItem = nil }

        let contentType = item.supportedContentTypes.first(where: { $0.conforms(to: .image) }) ?? .jpeg
        let fileExtension = contentType.preferredFilenameExtension ?? "jpg"
        let fileName = "expense-photo-\(UUID().uuidString).\(fileExtension)"
        let mimeType = contentType.preferredMIMEType ?? "image/jpeg"

        guard isSupportedResourceContentType(mimeType) else {
            actionError = "Add a JPG, PNG, WebP, or PDF file."
            return
        }

        do {
            guard let photoData = try await item.loadTransferable(type: ScenarioResourcePhotoData.self) else {
                actionError = "Could not read this photo. Try another photo."
                return
            }

            guard photoData.data.count <= resourceAttachmentMaxBytes else {
                actionError = resourceAttachmentTooLargeMessage
                return
            }

            expensePendingResources.append(
                ScenarioPendingResourcePhoto(
                    id: UUID(),
                    data: photoData.data,
                    fileName: fileName,
                    contentType: mimeType
                )
            )
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not read this photo. Try another photo.")
        }
    }

    func stageExpenseFileImport(_ result: Result<[URL], Error>) async {
        do {
            guard let url = try result.get().first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let contentType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
            guard isSupportedResourceContentType(contentType) else {
                actionError = "Add a JPG, PNG, WebP, or PDF file."
                return
            }

            let data = try Data(contentsOf: url)
            guard data.count <= resourceAttachmentMaxBytes else {
                actionError = resourceAttachmentTooLargeMessage
                return
            }

            expensePendingResources.append(
                ScenarioPendingResourcePhoto(
                    id: UUID(),
                    data: data,
                    fileName: url.lastPathComponent,
                    contentType: contentType
                )
            )
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not import this file.")
        }
    }

    func validatedExpenseLinkURL() -> (isValid: Bool, url: URL?) {
        let trimmedLink = expenseLinkDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLink.isEmpty else {
            expenseLinkError = nil
            return (true, nil)
        }

        guard let url = ScenarioResourceLinkValidator.normalizedURL(from: trimmedLink) else {
            expenseLinkError = ScenarioResourceLinkValidator.errorMessage
            return (false, nil)
        }

        expenseLinkError = nil
        return (true, url)
    }

    func syncExpenseResources(for costEventId: UUID, draftURL: URL?) async throws {
        for attachmentId in expenseRemovedAttachmentIds {
            try await repository.deleteAttachment(attachmentId: attachmentId)
        }

        for linkId in expenseRemovedLinkIds {
            try await repository.deleteResourceLink(linkId: linkId)
        }

        for resource in expensePendingResources {
            try await uploadResourceData(
                resource.data,
                fileName: resource.fileName,
                contentType: resource.contentType,
                owner: .costEvent(costEventId)
            )
        }

        if let draftURL {
            _ = try await repository.createCostEventLink(
                costEventId: costEventId,
                request: CreateResourceLinkRequest(label: nil, url: draftURL)
            )
        }
    }

    func isSupportedResourceContentType(_ contentType: String) -> Bool {
        ["image/jpeg", "image/png", "image/webp", "application/pdf"].contains(contentType)
    }

    func navigateAfterEntrySave(savedExpenseDate: Date? = nil) {
        let savedMonthStart = savedExpenseDate.map { expenseHistoryMonthStart(for: $0) }
        let opensHistoryForSavedMonth = savedMonthStart.map { !expenseHistoryIsSameMonth($0, currentMonthStart) } ?? false
        let destination: ScenarioTab = scenarioTabPath.contains(.expenseHistory) || opensHistoryForSavedMonth ? .expenseHistory : .expenses

        if let savedMonthStart {
            focusedExpenseHistoryMonthStart = savedMonthStart
            selectedExpenseHistoryBarLabel = expenseHistoryMonthIdentifier(for: savedMonthStart)
            expenseHistoryFilter = .all
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = destination == .expenseHistory ? [.expenses] : []
            selectedTab = destination
        }
    }
}
