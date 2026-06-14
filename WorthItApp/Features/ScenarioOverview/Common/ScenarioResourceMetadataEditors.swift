import SwiftUI

struct ScenarioResourceUploadSourceSheet: View {
    let onDismiss: () -> Void
    let onPickPhoto: () -> Void
    let onPickFile: () -> Void

    var body: some View {
        ScenarioBottomActionSheet(onDismiss: onDismiss) {
            actionButton(title: i18n.t("Photo Library"), systemName: "photo.on.rectangle", action: onPickPhoto)
            actionButton(title: i18n.t("Files"), systemName: "doc", action: onPickFile)
        }
    }

    private func actionButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }
}

struct ScenarioResourceLinkEditorSheet: View {
    let title: String
    @Binding var label: String
    @Binding var url: String
    let isSaving: Bool
    let onSave: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            WITextField(label: i18n.t("Label"), placeholder: i18n.t("Receipt, mechanic page..."), text: $label)
            WITextField(label: i18n.t("URL"), placeholder: i18n.t("https://..."), text: $url)

            Button(action: onSave) {
                Text(isSaving ? "Saving..." : "Save Link")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.surfaceLowest)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(WorthItColor.primaryContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            }
            .buttonStyle(.plain)
            .disabled(isSaving)

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Text("Delete Link")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.danger)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
        }
        .padding(WorthItSpacing.xxl)
        .presentationBackground(WorthItColor.surfaceLowest)
    }
}

struct ScenarioResourceLocationEditorSheet: View {
    let title: String
    @Binding var label: String
    @Binding var address: String
    @Binding var latitude: String
    @Binding var longitude: String
    let isSaving: Bool
    let onSave: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)

            WITextField(label: i18n.t("Label"), placeholder: i18n.t("Mechanic, fuel station..."), text: $label)
            WITextField(label: i18n.t("Address"), placeholder: i18n.t("Street, city, place name..."), text: $address)

            HStack(spacing: WorthItSpacing.m) {
                WITextField(label: i18n.t("Latitude"), placeholder: i18n.t("Optional"), text: $latitude)
                WITextField(label: i18n.t("Longitude"), placeholder: i18n.t("Optional"), text: $longitude)
            }

            Button(action: onSave) {
                Text(isSaving ? "Saving..." : "Save Location")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.surfaceLowest)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(WorthItColor.primaryContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            }
            .buttonStyle(.plain)
            .disabled(isSaving)

            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Text("Delete Location")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.danger)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
        }
        .padding(WorthItSpacing.xxl)
        .presentationBackground(WorthItColor.surfaceLowest)
    }
}

struct ScenarioResourceActionSheet: View {
    let action: ScenarioResourceAction
    let onDismiss: () -> Void
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ScenarioBottomActionSheet(onDismiss: onDismiss) {
            if canOpen {
                actionButton(title: openTitle, systemName: openIcon, action: onOpen)
            }

            if canEdit {
                actionButton(title: i18n.t("Edit"), systemName: "pencil", action: onEdit)
            }

            actionButton(title: deleteTitle, systemName: "trash", isDestructive: true, action: onDelete)
        }
    }

    private var canOpen: Bool {
        switch action {
        case .attachment, .link:
            true
        case .location:
            false
        }
    }

    private var canEdit: Bool {
        switch action {
        case .attachment:
            false
        case .link, .location:
            true
        }
    }

    private var openTitle: String {
        switch action {
        case .attachment:
            "Get download link"
        case .link:
            "Open Link"
        case .location:
            "Open"
        }
    }

    private var openIcon: String {
        switch action {
        case .attachment:
            "arrow.down.circle"
        case .link:
            "safari"
        case .location:
            "map"
        }
    }

    private var deleteTitle: String {
        switch action {
        case .attachment:
            "Delete Attachment"
        case .link:
            "Delete Link"
        case .location:
            "Delete Location"
        }
    }

    private func actionButton(
        title: String,
        systemName: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isDestructive ? WorthItColor.danger : WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background((isDestructive ? WorthItColor.danger : WorthItColor.primaryContainer).opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isDestructive ? WorthItColor.danger : WorthItColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, WorthItSpacing.l)
            .frame(height: 56)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }
}
