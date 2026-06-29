import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

extension ScenarioOverviewView {
    func openMileageForm(mode: MileageMode = .odometer) {
        resetMileageForm()
        mileageMode = mode
        if mode == .odometer, currentOdometerValue > 0 {
            mileageValue = "\(currentOdometerValue)"
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            scenarioTabPath = [.mileage]
            selectedTab = .logMileage
        }
    }

    func beginEditingMileage(_ usageEventId: UUID) {
        guard let event = usageEvents.first(where: { $0.id == usageEventId }) else { return }

        let returnTab = selectedTab
        editingUsageEvent = event
        mileageMode = event.eventType == "odometer_update" ? .odometer : .trip
        mileageDate = event.date
        mileageNotes = event.note ?? ""
        mileagePendingPhotos = []
        mileageRemovedAttachmentIds = []
        mileageRemovedLinkIds = []
        mileageLinkDraft = ""

        if mileageMode == .odometer {
            let currentReading = Double(previousOdometerForMileageForm) + usageDistanceInScenarioUnit(event)
            mileageValue = formatEditableNumber(currentReading)
        } else {
            mileageValue = formatEditableNumber(usageDistanceInScenarioUnit(event))
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            pushScenarioTab(returnTab)
            selectedTab = .logMileage
        }
    }

    func mileagePickerSheet(_ picker: MileagePicker) -> some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                Group {
                    switch picker {
                    case .date:
                        DatePicker("Date", selection: $mileageDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding(WorthItSpacing.xl)
                    case .time:
                        DatePicker("Time", selection: $mileageDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(WorthItSpacing.xl)
                    }
                }
                .tint(WorthItColor.primaryContainer)
            }
            .navigationTitle(picker == .date ? "Date" : "Time")
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { activeMileagePicker = nil }
                        .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { activeMileagePicker = nil }
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }

    func saveMileage() async {
        guard !isSavingEntry else { return }
        guard let value = Double(mileageValue), value > 0 else {
            actionError = mileageMode == .trip ? "Enter trip distance." : "Enter odometer reading."
            return
        }

        if mileageMode == .odometer, previousOdometerForMileageForm > 0, value < Double(previousOdometerForMileageForm) {
            actionError = "Odometer reading cannot be lower than previous reading."
            return
        }

        let linkValidation = validatedMileageLinkURL()
        guard linkValidation.isValid else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            let savedEvent: UsageEvent
            if let editingUsageEvent {
                savedEvent = try await repository.updateUsageEvent(
                    usageEventId: editingUsageEvent.id,
                    request: UpdateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        note: trimmedMileageNotes.isEmpty ? "" : trimmedMileageNotes
                    )
                )
            } else {
                savedEvent = try await repository.createUsageEvent(
                    scenarioId: activeScenario.id,
                    request: CreateUsageEventRequest(
                        eventType: mileageMode.eventType,
                        date: mileageDate,
                        distanceValue: mileageMode == .trip ? value : nil,
                        odometerValue: mileageMode == .odometer ? value : nil,
                        note: trimmedMileageNotes.isEmpty ? nil : trimmedMileageNotes
                    )
                )
            }

            try await syncMileageResources(for: savedEvent.id, draftURL: linkValidation.url)
            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = WIUpdateErrorText.message(for: error)
        }
    }

    func deleteEditingMileage() async {
        guard !isSavingEntry, let editingUsageEvent else { return }

        isSavingEntry = true
        actionError = nil
        defer { isSavingEntry = false }

        do {
            try await repository.deleteUsageEvent(usageEventId: editingUsageEvent.id)
            if selectedMileageDetailId == editingUsageEvent.id {
                selectedMileageDetailId = nil
            }
            await loadSummary()
            navigateAfterMileageSave()
            resetMileageForm()
        } catch {
            actionError = WIUpdateErrorText.message(for: error, fallbackKey: .common.errors.update.deleteMileage)
        }
    }

    var trimmedMileageNotes: String {
        mileageNotes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetMileageForm() {
        editingUsageEvent = nil
        mileageMode = .odometer
        mileageValue = ""
        mileageDate = Date()
        mileageNotes = ""
        mileagePendingPhotos = []
        mileageRemovedAttachmentIds = []
        mileageRemovedLinkIds = []
        mileageLinkDraft = ""
        mileageLinkError = nil
        selectedMileagePhotoItem = nil
        activeMileagePicker = nil
    }

    var visibleMileageAttachments: [ResourceAttachment] {
        (editingUsageEvent?.attachments ?? []).filter { !mileageRemovedAttachmentIds.contains($0.id) }
    }

    var visibleMileageLinks: [ResourceLink] {
        (editingUsageEvent?.links ?? []).filter { !mileageRemovedLinkIds.contains($0.id) }
    }

    func stageMileagePhoto(_ item: PhotosPickerItem) async {
        defer { selectedMileagePhotoItem = nil }

        let contentType = item.supportedContentTypes.first(where: { $0.conforms(to: .image) }) ?? .jpeg
        let fileExtension = contentType.preferredFilenameExtension ?? "jpg"
        let fileName = "trip-photo-\(UUID().uuidString).\(fileExtension)"
        let mimeType = contentType.preferredMIMEType ?? "image/jpeg"

        do {
            guard let photoData = try await item.loadTransferable(type: ScenarioResourcePhotoData.self) else {
                actionError = "Could not read this photo. Try another photo."
                return
            }

            guard photoData.data.count <= resourceAttachmentMaxBytes else {
                actionError = resourceAttachmentTooLargeMessage
                return
            }

            mileagePendingPhotos.append(
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

    func validatedMileageLinkURL() -> (isValid: Bool, url: URL?) {
        let trimmedLink = mileageLinkDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLink.isEmpty else {
            mileageLinkError = nil
            return (true, nil)
        }

        guard let url = ScenarioResourceLinkValidator.normalizedURL(from: trimmedLink) else {
            mileageLinkError = ScenarioResourceLinkValidator.errorMessage
            return (false, nil)
        }

        mileageLinkError = nil
        return (true, url)
    }

    func syncMileageResources(for usageEventId: UUID, draftURL: URL?) async throws {
        for attachmentId in mileageRemovedAttachmentIds {
            try await repository.deleteAttachment(attachmentId: attachmentId)
        }

        for linkId in mileageRemovedLinkIds {
            try await repository.deleteResourceLink(linkId: linkId)
        }

        for photo in mileagePendingPhotos {
            try await uploadResourceData(
                photo.data,
                fileName: photo.fileName,
                contentType: photo.contentType,
                owner: .usageEvent(usageEventId)
            )
        }

        if let draftURL {
            _ = try await repository.createUsageEventLink(
                usageEventId: usageEventId,
                request: CreateResourceLinkRequest(label: nil, url: draftURL)
            )
        }
    }

    func navigateAfterMileageSave() {
        let destination: ScenarioTab
        if selectedMileageDetailId != nil, scenarioTabPath.contains(.mileageDetail) {
            destination = .mileageDetail
        } else if scenarioTabPath.contains(.mileageHistory) {
            destination = .mileageHistory
        } else {
            destination = .mileage
        }

        withAnimation(.easeInOut(duration: 0.20)) {
            switch destination {
            case .mileageDetail:
                scenarioTabPath = [.mileage]
            case .mileageHistory:
                scenarioTabPath = [.mileage]
            default:
                scenarioTabPath = []
            }
            selectedTab = destination
        }
    }
}
