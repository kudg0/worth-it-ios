import SwiftUI
import UIKit

struct ScenarioPendingResourcePhoto: Identifiable, Hashable {
    let id: UUID
    let data: Data
    let fileName: String
    let contentType: String
}

struct ScenarioPhotoUploadInput: View {
    @State private var showsAttachmentSourcePicker = false

    let title: String
    let attachments: [ResourceAttachment]
    let pendingPhotos: [ScenarioPendingResourcePhoto]
    let links: [ResourceLink]
    let linkDraft: Binding<String>
    let linkValidationMessage: String?
    var isEditable = true
    var onAddPhoto: () -> Void = {}
    var onAddFile: (() -> Void)?
    var onLinkDraftChange: () -> Void = {}
    var onOpenAttachment: (ResourceAttachment) -> Void = { _ in }
    var onRemoveAttachment: (ResourceAttachment) -> Void = { _ in }
    var onRemovePendingPhoto: (ScenarioPendingResourcePhoto) -> Void = { _ in }
    var onOpenLink: (ResourceLink) -> Void = { _ in }
    var onRemoveLink: (ResourceLink) -> Void = { _ in }

    private var imageAttachments: [ResourceAttachment] {
        attachments.filter { $0.contentType.hasPrefix("image/") && $0.status != "deleted" }
    }

    private var fileAttachments: [ResourceAttachment] {
        attachments.filter { !$0.contentType.hasPrefix("image/") && $0.status != "deleted" }
    }

    private var pendingImagePhotos: [ScenarioPendingResourcePhoto] {
        pendingPhotos.filter { $0.contentType.hasPrefix("image/") }
    }

    private var pendingFiles: [ScenarioPendingResourcePhoto] {
        pendingPhotos.filter { !$0.contentType.hasPrefix("image/") }
    }

    private var showsOverflowHint: Bool {
        imageAttachments.count + fileAttachments.count + pendingPhotos.count > 4
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            attachmentsSection
            linksSection
        }
        .confirmationDialog(i18n.t("Add attachment"), isPresented: $showsAttachmentSourcePicker, titleVisibility: .visible) {
            Button(i18n.t("Photo")) {
                onAddPhoto()
            }

            if let onAddFile {
                Button(i18n.t("File")) {
                    onAddFile()
                }
            }
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.1)
                    .textCase(.uppercase)
            }

            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: WorthItSpacing.l) {
                        ForEach(imageAttachments) { attachment in
                            existingPhotoTile(attachment)
                        }

                        ForEach(fileAttachments) { attachment in
                            existingFileTile(attachment)
                        }

                        ForEach(pendingImagePhotos) { photo in
                            pendingPhotoTile(photo)
                        }

                        ForEach(pendingFiles) { file in
                            pendingFileTile(file)
                        }

                        if isEditable {
                            addAttachmentTile
                        }
                    }
                    .padding(.vertical, WorthItSpacing.xs)
                }
                .scrollIndicators(.hidden)

                if showsOverflowHint {
                    overflowFade(edge: .leading)
                    overflowFade(edge: .trailing)
                }
            }
            .frame(height: 64)
        }
    }

    private var linksSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text(i18n.t("Links"))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.1)
                .textCase(.uppercase)

            if isEditable {
                VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                    HStack(spacing: WorthItSpacing.m) {
                        Image(systemName: "link")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(WorthItColor.primaryContainer)
                            .frame(width: 18)

                        ZStack(alignment: .leading) {
                            if linkDraft.wrappedValue.isEmpty {
                                Text(i18n.t("https://"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(WorthItColor.textSecondary)
                            }

                            TextField("", text: linkDraft)
                                .keyboardType(.URL)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(WorthItColor.textPrimary)
                                .onChange(of: linkDraft.wrappedValue) { _, _ in
                                    onLinkDraftChange()
                                }
                        }
                    }
                    .padding(.horizontal, WorthItSpacing.xl)
                    .frame(height: 54)
                    .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                    .overlay {
                        RoundedRectangle(cornerRadius: WorthItRadius.l)
                            .stroke(
                                linkValidationMessage == nil
                                    ? WorthItColor.outlineSubtle.opacity(0.62)
                                    : WorthItColor.danger.opacity(0.78),
                                lineWidth: 1
                            )
                    }

                    if let linkValidationMessage {
                        Text(linkValidationMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WorthItColor.danger)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            ForEach(links) { link in
                linkRow(link)
            }
        }
    }

    private func existingPhotoTile(_ attachment: ResourceAttachment) -> some View {
        Button { onOpenAttachment(attachment) } label: {
            ZStack(alignment: .topTrailing) {
                photoTileBase

                Image(systemName: "photo.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)

                if isEditable {
                    removeButton { onRemoveAttachment(attachment) }
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func pendingPhotoTile(_ photo: ScenarioPendingResourcePhoto) -> some View {
        ZStack(alignment: .topTrailing) {
            if let image = UIImage(data: photo.data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
            } else {
                photoTileBase
            }

            removeButton { onRemovePendingPhoto(photo) }
                .offset(x: 6, y: -6)
        }
        .frame(width: 56, height: 56)
    }

    private func existingFileTile(_ attachment: ResourceAttachment) -> some View {
        Button { onOpenAttachment(attachment) } label: {
            ZStack(alignment: .topTrailing) {
                fileTileContent(
                    icon: attachment.contentType == "application/pdf" ? "doc.richtext.fill" : "doc.fill",
                    title: attachment.originalFileName,
                    subtitle: byteSizeText(attachment.byteSize)
                )

                if isEditable {
                    removeButton { onRemoveAttachment(attachment) }
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func pendingFileTile(_ file: ScenarioPendingResourcePhoto) -> some View {
        ZStack(alignment: .topTrailing) {
            fileTileContent(
                icon: file.contentType == "application/pdf" ? "doc.richtext.fill" : "doc.fill",
                title: file.fileName,
                subtitle: i18n.t("Pending upload")
            )

            removeButton { onRemovePendingPhoto(file) }
                .offset(x: 6, y: -6)
        }
    }

    private var addAttachmentTile: some View {
        Button(action: addAttachment) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .frame(width: 56, height: 56)
                .background(WorthItColor.surfaceContainerLow.opacity(0.38), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                        .foregroundStyle(WorthItColor.outlineSubtle)
                }
        }
        .buttonStyle(.plain)
    }

    private func fileTileContent(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .frame(width: 56, height: 56)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(WorthItColor.outlineSubtle.opacity(0.62), lineWidth: 1)
        }
    }

    private var photoTileBase: some View {
        RoundedRectangle(cornerRadius: WorthItRadius.m)
            .fill(WorthItColor.surfaceContainerLow)
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(WorthItColor.outlineSubtle.opacity(0.62), lineWidth: 1)
            }
            .frame(width: 56, height: 56)
    }

    private func removeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(WorthItColor.textPrimary)
                .frame(width: 18, height: 18)
                .background(WorthItColor.surfaceLowest.opacity(0.92), in: Circle())
                .overlay {
                    Circle().stroke(WorthItColor.outlineSubtle.opacity(0.7), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func linkRow(_ link: ResourceLink) -> some View {
        HStack(spacing: WorthItSpacing.m) {
            Button { onOpenLink(link) } label: {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: "link")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)

                    Text(link.label ?? link.url.host ?? link.url.absoluteString)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            if isEditable {
                removeButton { onRemoveLink(link) }
            }
        }
        .padding(.horizontal, WorthItSpacing.l)
        .frame(height: 46)
        .background(WorthItColor.surfaceContainerLow.opacity(0.48), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
    }

    private func overflowFade(edge: Alignment) -> some View {
        LinearGradient(
            colors: [
                WorthItColor.surfaceLowest.opacity(edge == .leading ? 0.94 : 0),
                WorthItColor.surfaceLowest.opacity(edge == .leading ? 0 : 0.94),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: 38)
        .frame(maxWidth: .infinity, alignment: edge)
        .allowsHitTesting(false)
    }

    private func byteSizeText(_ byteSize: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(byteSize), countStyle: .file)
    }

    private func addAttachment() {
        guard onAddFile != nil else {
            onAddPhoto()
            return
        }

        showsAttachmentSourcePicker = true
    }
}
