import Foundation
import CoreTransferable
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ScenarioResourcePhotoData: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            ScenarioResourcePhotoData(data: data)
        }
    }
}

extension ScenarioOverviewView {
    var resourceAttachmentMaxBytes: Int {
        512_000
    }

    var resourceAttachmentTooLargeMessage: String {
        "Attachment must be 500 KB or smaller."
    }

    func resourceManagementModel(for event: CostEvent?) -> ScenarioResourceManagementSectionModel? {
        guard let event else { return nil }

        return ScenarioResourceManagementSectionModel(
            attachments: event.attachments ?? [],
            links: event.links ?? [],
            locations: event.locations ?? [],
            onAddAttachment: {
                activeResourceUploadSource = .owner(.costEvent(event.id))
            },
            onAddLink: {
                openResourceLinkEditor(.create(.costEvent(event.id)))
            },
            onAddLocation: {
                openResourceLocationEditor(.create(.costEvent(event.id)))
            },
            onOpenAttachment: { activeResourceAction = .attachment($0) },
            onOpenLink: { activeResourceAction = .link($0) },
            onOpenLocation: { activeResourceAction = .location($0) }
        )
    }

    func resourceManagementModel(for service: ScheduledService?) -> ScenarioResourceManagementSectionModel? {
        guard let service else { return nil }

        return ScenarioResourceManagementSectionModel(
            attachments: service.attachments ?? [],
            links: service.links ?? [],
            locations: service.locations ?? [],
            onAddAttachment: {
                activeResourceUploadSource = .owner(.scheduledService(service.id))
            },
            onAddLink: {
                openResourceLinkEditor(.create(.scheduledService(service.id)))
            },
            onAddLocation: {
                openResourceLocationEditor(.create(.scheduledService(service.id)))
            },
            onOpenAttachment: { activeResourceAction = .attachment($0) },
            onOpenLink: { activeResourceAction = .link($0) },
            onOpenLocation: { activeResourceAction = .location($0) }
        )
    }

    func owner(from source: ScenarioResourceUploadSource) -> ScenarioResourceOwner {
        switch source {
        case .owner(let owner):
            owner
        }
    }

    func openResourceLinkEditor(_ editor: ScenarioResourceLinkEditor) {
        switch editor {
        case .create:
            resourceLinkLabel = ""
            resourceLinkURL = ""
        case .edit(let link):
            resourceLinkLabel = link.label ?? ""
            resourceLinkURL = link.url.absoluteString
        }

        activeResourceLinkEditor = editor
    }

    func openResourceLocationEditor(_ editor: ScenarioResourceLocationEditor) {
        switch editor {
        case .create:
            resourceLocationLabel = ""
            resourceLocationAddress = ""
            resourceLocationLatitude = ""
            resourceLocationLongitude = ""
        case .edit(let location):
            resourceLocationLabel = location.label ?? ""
            resourceLocationAddress = location.address ?? ""
            resourceLocationLatitude = location.latitude ?? ""
            resourceLocationLongitude = location.longitude ?? ""
        }

        activeResourceLocationEditor = editor
    }

    func resourceLinkEditorTitle(_ editor: ScenarioResourceLinkEditor) -> String {
        switch editor {
        case .create:
            "Add Link"
        case .edit:
            "Edit Link"
        }
    }

    func resourceLocationEditorTitle(_ editor: ScenarioResourceLocationEditor) -> String {
        switch editor {
        case .create:
            "Add Location"
        case .edit:
            "Edit Location"
        }
    }

    func resourceLinkDeleteAction(_ editor: ScenarioResourceLinkEditor) -> (() -> Void)? {
        guard case .edit(let link) = editor else { return nil }
        return { Task { await deleteResource(.link(link)) } }
    }

    func resourceLocationDeleteAction(_ editor: ScenarioResourceLocationEditor) -> (() -> Void)? {
        guard case .edit(let location) = editor else { return nil }
        return { Task { await deleteResource(.location(location)) } }
    }

    func editResource(_ action: ScenarioResourceAction) {
        activeResourceAction = nil

        switch action {
        case .attachment:
            return
        case .link(let link):
            openResourceLinkEditor(.edit(link))
        case .location(let location):
            openResourceLocationEditor(.edit(location))
        }
    }

    func openResource(_ action: ScenarioResourceAction) {
        switch action {
        case .attachment(let attachment):
            Task { await openAttachment(attachment) }
        case .link(let link):
            UIApplication.shared.open(link.url)
            activeResourceAction = nil
        case .location:
            activeResourceAction = nil
        }
    }

    func openAttachment(_ attachment: ResourceAttachment) async {
        do {
            let response = try await repository.getAttachmentDownloadURL(attachmentId: attachment.id)
            activeResourceAction = nil
            await UIApplication.shared.open(response.downloadUrl)
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not open this attachment.")
        }
    }

    func saveResourceLink(_ editor: ScenarioResourceLinkEditor) async {
        guard !isSavingEntry else { return }

        let trimmedURL = resourceLinkURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = ScenarioResourceLinkValidator.normalizedURL(from: trimmedURL) else {
            actionError = ScenarioResourceLinkValidator.errorMessage
            return
        }

        let label = nilIfBlank(resourceLinkLabel)
        isSavingEntry = true
        defer { isSavingEntry = false }

        do {
            switch editor {
            case .create(let owner):
                let request = CreateResourceLinkRequest(label: label, url: url)
                switch owner {
                case .costEvent(let id):
                    _ = try await repository.createCostEventLink(costEventId: id, request: request)
                case .scheduledService(let id):
                    _ = try await repository.createScheduledServiceLink(scheduledServiceId: id, request: request)
                case .usageEvent(let id):
                    _ = try await repository.createUsageEventLink(usageEventId: id, request: request)
                }
            case .edit(let link):
                _ = try await repository.updateResourceLink(
                    linkId: link.id,
                    request: UpdateResourceLinkRequest(label: label, url: url)
                )
            }

            activeResourceLinkEditor = nil
            await loadSummary()
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not save this link.")
        }
    }

    func saveResourceLocation(_ editor: ScenarioResourceLocationEditor) async {
        guard !isSavingEntry else { return }

        let label = nilIfBlank(resourceLocationLabel)
        let address = nilIfBlank(resourceLocationAddress)
        let latitude = decimalCoordinate(resourceLocationLatitude)
        let longitude = decimalCoordinate(resourceLocationLongitude)
        let hasCoordinatePair = latitude != nil && longitude != nil

        guard address != nil || hasCoordinatePair else {
            actionError = "Add address or both coordinates."
            return
        }

        isSavingEntry = true
        defer { isSavingEntry = false }

        do {
            switch editor {
            case .create(let owner):
                let request = CreateResourceLocationRequest(
                    label: label,
                    address: address,
                    latitude: latitude,
                    longitude: longitude,
                    providerPlaceId: nil
                )

                switch owner {
                case .costEvent(let id):
                    _ = try await repository.createCostEventLocation(costEventId: id, request: request)
                case .scheduledService(let id):
                    _ = try await repository.createScheduledServiceLocation(scheduledServiceId: id, request: request)
                case .usageEvent:
                    actionError = "Locations are not available for mileage entries."
                    return
                }
            case .edit(let location):
                _ = try await repository.updateResourceLocation(
                    locationId: location.id,
                    request: UpdateResourceLocationRequest(
                        label: label,
                        address: address,
                        latitude: latitude,
                        longitude: longitude,
                        providerPlaceId: nil
                    )
                )
            }

            activeResourceLocationEditor = nil
            await loadSummary()
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not save this location.")
        }
    }

    func uploadResourcePhoto(_ item: PhotosPickerItem) async {
        guard let owner = pendingResourceFileOwner else { return }

        let contentType = item.supportedContentTypes.first(where: { $0.conforms(to: .image) }) ?? .jpeg
        let fileExtension = contentType.preferredFilenameExtension ?? "jpg"
        let fileName = "photo-\(UUID().uuidString).\(fileExtension)"
        let mimeType = contentType.preferredMIMEType ?? "image/jpeg"

        do {
            guard let photoData = try await item.loadTransferable(type: ScenarioResourcePhotoData.self) else {
                actionError = "Could not read this photo. Try another photo or pick it from Files."
                return
            }

            try await uploadResourceData(photoData.data, fileName: fileName, contentType: mimeType, owner: owner)
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not read this photo. Try another photo or pick it from Files.")
        }

        selectedResourcePhotoItem = nil
        pendingResourceFileOwner = nil
    }

    func handleResourceFileImport(_ result: Result<[URL], Error>) async {
        guard let owner = pendingResourceFileOwner else { return }
        defer { pendingResourceFileOwner = nil }

        do {
            guard let url = try result.get().first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let contentType = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
            try await uploadResourceData(data, fileName: fileName, contentType: contentType, owner: owner)
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not import this file.")
        }
    }

    func uploadResourceData(
        _ data: Data,
        fileName: String,
        contentType: String,
        owner: ScenarioResourceOwner
    ) async throws {
        guard data.count <= resourceAttachmentMaxBytes else {
            actionError = resourceAttachmentTooLargeMessage
            return
        }

        let wasAlreadySaving = isSavingEntry
        isSavingEntry = true
        defer {
            if !wasAlreadySaving {
                isSavingEntry = false
            }
        }

        let request = CreateAttachmentUploadIntentRequest(
            fileName: fileName,
            contentType: contentType,
            byteSize: data.count,
            checksumSha256: nil
        )

        let intent: AttachmentUploadIntentResponse
        switch owner {
        case .costEvent(let id):
            intent = try await repository.createCostEventAttachmentUploadIntent(costEventId: id, request: request)
        case .scheduledService(let id):
            intent = try await repository.createScheduledServiceAttachmentUploadIntent(scheduledServiceId: id, request: request)
        case .usageEvent(let id):
            intent = try await repository.createUsageEventAttachmentUploadIntent(usageEventId: id, request: request)
        }

        try await repository.uploadAttachmentData(data, intent: intent)
        _ = try await repository.updateAttachment(
            attachmentId: intent.attachment.id,
            request: UpdateAttachmentRequest(originalFileName: nil, status: "ready")
        )
        await loadSummary()
    }

    func deleteResource(_ action: ScenarioResourceAction) async {
        guard !isSavingEntry else { return }

        isSavingEntry = true
        defer { isSavingEntry = false }

        do {
            switch action {
            case .attachment(let attachment):
                try await repository.deleteAttachment(attachmentId: attachment.id)
            case .link(let link):
                try await repository.deleteResourceLink(linkId: link.id)
            case .location(let location):
                try await repository.deleteResourceLocation(locationId: location.id)
            }

            activeResourceAction = nil
            activeResourceLinkEditor = nil
            activeResourceLocationEditor = nil
            await loadSummary()
        } catch {
            actionError = friendlyResourceError(error, fallback: "Could not delete this item.")
        }
    }

    func nilIfBlank(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func decimalCoordinate(_ value: String) -> Double? {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    func friendlyResourceError(_ error: Error, fallback: String) -> String {
        let description = String(describing: error)
        if description.contains("CoreTransferable") || description.contains("Transferable") {
            return fallback
        }

        return WIUpdateErrorText.message(for: error, fallback: fallback)
    }
}
