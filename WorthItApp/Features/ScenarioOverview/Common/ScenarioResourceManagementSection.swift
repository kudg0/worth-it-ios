import SwiftUI

struct ScenarioResourceManagementSectionModel {
    let attachments: [ResourceAttachment]
    let links: [ResourceLink]
    let locations: [ResourceLocation]
    let onAddAttachment: () -> Void
    let onAddLink: () -> Void
    let onAddLocation: () -> Void
    let onOpenAttachment: (ResourceAttachment) -> Void
    let onOpenLink: (ResourceLink) -> Void
    let onOpenLocation: (ResourceLocation) -> Void
}

struct ScenarioResourceManagementSection: View {
    let attachments: [ResourceAttachment]
    let links: [ResourceLink]
    let locations: [ResourceLocation]
    let onAddAttachment: () -> Void
    let onAddLink: () -> Void
    let onAddLocation: () -> Void
    let onOpenAttachment: (ResourceAttachment) -> Void
    let onOpenLink: (ResourceLink) -> Void
    let onOpenLocation: (ResourceLocation) -> Void

    init(model: ScenarioResourceManagementSectionModel) {
        attachments = model.attachments
        links = model.links
        locations = model.locations
        onAddAttachment = model.onAddAttachment
        onAddLink = model.onAddLink
        onAddLocation = model.onAddLocation
        onOpenAttachment = model.onOpenAttachment
        onOpenLink = model.onOpenLink
        onOpenLocation = model.onOpenLocation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
            sectionHeader

            VStack(spacing: WorthItSpacing.l) {
                LogExpensePickerField(
                    label: i18n.t("Files & photos"),
                    value: "Add file or photo",
                    systemName: "paperclip",
                    action: onAddAttachment
                )

                LogExpensePickerField(
                    label: i18n.t("Links"),
                    value: "Add link",
                    systemName: "link",
                    action: onAddLink
                )

                LogExpensePickerField(
                    label: i18n.t("Location"),
                    value: "Add location",
                    systemName: "location",
                    action: onAddLocation
                )
            }

            ScenarioResourceMetadataCard(
                attachments: attachments,
                links: links,
                locations: locations,
                onOpenAttachment: onOpenAttachment,
                onOpenLink: onOpenLink,
                onOpenLocation: onOpenLocation
            )
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: "paperclip")
                .font(.system(size: 12, weight: .bold))

            Text("Attachments & context")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.1)
                .textCase(.uppercase)
        }
        .foregroundStyle(WorthItColor.textSecondary)
    }
}
