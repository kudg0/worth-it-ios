import SwiftUI

struct ScenarioResourceMetadataCard: View {
    let attachments: [ResourceAttachment]
    let links: [ResourceLink]
    let locations: [ResourceLocation]
    var onOpenAttachment: (ResourceAttachment) -> Void = { _ in }
    var onOpenLink: (ResourceLink) -> Void = { _ in }
    var onOpenLocation: (ResourceLocation) -> Void = { _ in }

    var body: some View {
        if !attachments.isEmpty || !links.isEmpty || !locations.isEmpty {
            VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                sectionHeader

                VStack(spacing: WorthItSpacing.s) {
                    ForEach(attachments) { attachment in
                        resourceRow(
                            title: attachment.originalFileName,
                            subtitle: attachmentSubtitle(attachment),
                            value: attachment.status == "ready" ? "Ready" : "Pending",
                            systemIcon: attachmentIcon(for: attachment.contentType),
                            action: { onOpenAttachment(attachment) }
                        )
                    }

                    ForEach(locations) { location in
                        resourceRow(
                            title: location.label ?? "Location",
                            subtitle: locationSubtitle(location),
                            value: "Map",
                            systemIcon: "location.fill",
                            action: { onOpenLocation(location) }
                        )
                    }

                    ForEach(links) { link in
                        resourceRow(
                            title: link.label ?? link.url.host ?? "Link",
                            subtitle: link.url.absoluteString,
                            value: "Open",
                            systemIcon: "link",
                            action: { onOpenLink(link) }
                        )
                    }
                }
            }
            .padding(WorthItSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: "paperclip")
                .font(.system(size: 12, weight: .bold))

            Text("Attachments & Links")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.1)
                .textCase(.uppercase)
        }
        .foregroundStyle(WorthItColor.textSecondary)
    }

    private func resourceRow(
        title: String,
        subtitle: String,
        value: String,
        systemIcon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: systemIcon)
                    .font(.system(size: 15, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceLowest, in: Circle())
                    .overlay {
                        Circle()
                            .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: WorthItSpacing.s)

                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .lineLimit(1)
            }
            .padding(.horizontal, WorthItSpacing.m)
            .padding(.vertical, WorthItSpacing.s)
            .frame(maxWidth: .infinity, minHeight: 66, alignment: .leading)
            .background(WorthItColor.surfaceLowest.opacity(0.52), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .contentShape(RoundedRectangle(cornerRadius: WorthItRadius.m))
        }
        .buttonStyle(.plain)
    }

    private func attachmentSubtitle(_ attachment: ResourceAttachment) -> String {
        "\(attachment.contentType) • \(Self.byteFormatter.string(fromByteCount: Int64(attachment.byteSize)))"
    }

    private func locationSubtitle(_ location: ResourceLocation) -> String {
        if let address = location.address, !address.isEmpty {
            return address
        }

        if let latitude = location.latitude, let longitude = location.longitude {
            return "\(latitude), \(longitude)"
        }

        return "Saved place"
    }

    private func attachmentIcon(for contentType: String) -> String {
        if contentType.hasPrefix("image/") {
            return "photo.fill"
        }

        if contentType == "application/pdf" {
            return "doc.richtext.fill"
        }

        return "doc.fill"
    }

    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter
    }()
}
