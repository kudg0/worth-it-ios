import SwiftUI

struct ScheduledServiceDetailScreen: View {
    @Environment(\.i18n) private var i18n

    let item: ScenarioOverviewView.ScheduledServiceDisplayItem
    let service: ScheduledService?
    let dueSubtitle: (ScenarioOverviewView.ScheduledServiceDisplayItem) -> String
    let serviceStateTitle: (String) -> String
    let serviceStateColor: (String) -> Color
    let serviceIconName: (String) -> String
    let onEdit: (UUID) -> Void
    let onCompleteWithExpense: (UUID) -> Void
    let onAddToCalendar: (ScenarioOverviewView.ScheduledServiceDisplayItem) -> Void
    let onOpenActions: (UUID) -> Void
    let onOpenResourceAction: (ScenarioResourceAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            hero
            nextTriggerCard
            if let note = item.note {
                noteCard(note)
            }
            ScenarioResourceMetadataCard(
                attachments: service?.attachments ?? [],
                links: service?.links ?? [],
                locations: service?.locations ?? [],
                onOpenAttachment: { onOpenResourceAction(.attachment($0)) },
                onOpenLink: { onOpenResourceAction(.link($0)) },
                onOpenLocation: { onOpenResourceAction(.location($0)) }
            )
            serviceDetailsCard
            actionButtons
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: serviceIconName(item.category))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(serviceStateColor(item.dueState))
                    .frame(width: 56, height: 56)
                    .background(serviceStateColor(item.dueState).opacity(0.12), in: RoundedRectangle(cornerRadius: WorthItRadius.l))

                VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                    Text(item.title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(dueSubtitle(item))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                }
                .layoutPriority(1)
                .padding(.trailing, 44)
            }

            HStack(spacing: WorthItSpacing.s) {
                statusPill
                if item.isEstimatedDate {
                    detailPill(title: i18n.t("Estimated"), systemName: "sparkles")
                }
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay(alignment: .topTrailing) {
            Button {
                onOpenActions(item.id)
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceContainerLow.opacity(0.72), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Service actions")
            .padding(.top, WorthItSpacing.xxl)
            .padding(.trailing, WorthItSpacing.xxl)
        }
    }

    private var statusPill: some View {
        HStack(spacing: WorthItSpacing.xs) {
            Circle()
                .fill(serviceStateColor(item.dueState))
                .frame(width: 6, height: 6)

            Text(serviceStateTitle(item.dueState))
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .textCase(.uppercase)
        }
        .foregroundStyle(serviceStateColor(item.dueState))
        .padding(.horizontal, WorthItSpacing.m)
        .frame(height: 30)
        .background(serviceStateColor(item.dueState).opacity(0.10), in: Capsule())
    }

    private var nextTriggerCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: i18n.t("Next Trigger"), systemName: "calendar.badge.clock")

            HStack(spacing: WorthItSpacing.m) {
                triggerMetric(
                    title: i18n.t("Date"),
                    value: dateCounterValue,
                    subtitle: dateValue,
                    progress: dateProgress
                )
                triggerMetric(
                    title: i18n.t("Mileage"),
                    value: mileageCounterValue,
                    subtitle: mileageValue,
                    progress: mileageProgress
                )
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private func triggerMetric(title: String, value: String, subtitle: String, progress: Double?) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.9)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)

            progressBar(progress)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
        .background(WorthItColor.surfaceLowest.opacity(0.52), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func progressBar(_ progress: Double?) -> some View {
        GeometryReader { proxy in
            let normalized = min(max(progress ?? 0, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(WorthItColor.primaryContainer.opacity(0.14))

                Capsule()
                    .fill(WorthItColor.primaryContainer)
                    .frame(width: max(proxy.size.width * normalized, normalized > 0 ? 6 : 0))
            }
        }
        .frame(height: 6)
        .opacity(progress == nil ? 0.38 : 1)
    }

    private func noteCard(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            sectionHeader(title: i18n.t("Notes"), systemName: "note.text")

            Text(note)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var serviceDetailsCard: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: i18n.t("Schedule Basis"), systemName: "point.3.connected.trianglepath.dotted")

            detailRow(title: i18n.t("Created"), value: createdValue)
            detailRow(title: i18n.t("Baseline"), value: baselineValue)
            detailRow(title: i18n.t("Repeats"), value: repeatValue)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: WorthItSpacing.l) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textTertiary)
                .frame(width: 74, alignment: .leading)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func sectionHeader(title: String, systemName: String) -> some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.1)
                .textCase(.uppercase)
        }
        .foregroundStyle(WorthItColor.textSecondary)
    }

    private func detailPill(title: String, systemName: String) -> some View {
        HStack(spacing: WorthItSpacing.xs) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))

            Text(title)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(WorthItColor.textSecondary)
        .padding(.horizontal, WorthItSpacing.m)
        .frame(height: 30)
        .background(WorthItColor.surfaceContainerLow, in: Capsule())
    }

    private var actionButtons: some View {
        VStack(spacing: WorthItSpacing.m) {
            Button {
                onCompleteWithExpense(item.id)
            } label: {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold))

                    Text("Complete with expense")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(WorthItColor.surfaceLowest)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(WorthItColor.primaryContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xl))
            }
            .buttonStyle(.plain)

            Button {
                onEdit(item.id)
            } label: {
                HStack(spacing: WorthItSpacing.m) {
                    Image(systemName: "pencil")
                        .font(.system(size: 15, weight: .bold))

                    Text("Edit schedule")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            }
            .buttonStyle(.plain)

            if item.canExportToCalendar {
                Button {
                    onAddToCalendar(item)
                } label: {
                    HStack(spacing: WorthItSpacing.m) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 15, weight: .bold))

                        Text(i18n.t(.scenarios.maintenance.calendar.addAction))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(WorthItColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                    .overlay {
                        RoundedRectangle(cornerRadius: WorthItRadius.l)
                            .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dateValue: String {
        guard let date = item.date else { return "Not set" }
        let label = item.isEstimatedDate ? "Estimated" : "Due"
        return "\(label) \(Self.serviceDateFormatter.string(from: date))"
    }

    private var dateCounterValue: String {
        guard let date = item.date else {
            if let daysRemaining = item.daysRemaining {
                return "≈ \(Self.daysRemainingTitle(daysRemaining))"
            }

            return "Date pending"
        }

        let calendar = Calendar.current
        let startToday = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startToday, to: dueDay).day ?? 0
        let title = Self.daysRemainingTitle(days)
        return item.isEstimatedDate ? "≈ \(title)" : title
    }

    private var dateProgress: Double? {
        guard let dueDate = item.date else { return nil }

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: service?.baselineDate ?? service?.createdAt ?? Date())
        let due = calendar.startOfDay(for: dueDate)
        let today = calendar.startOfDay(for: Date())
        let totalDays = calendar.dateComponents([.day], from: start, to: due).day ?? 0
        let elapsedDays = calendar.dateComponents([.day], from: start, to: today).day ?? 0

        guard totalDays > 0 else { return nil }
        return Double(elapsedDays) / Double(totalDays)
    }

    private var mileageValue: String {
        if let dueOdometer = service?.dueOdometerValue {
            let unit = service?.dueOdometerUnit ?? item.distanceUnit
            return "Due at \(ScenarioOverviewFormatting.formatDouble(dueOdometer, fractionDigits: 0)) \(unit)"
        }

        if item.distanceRemaining != nil {
            return "Estimated from current mileage"
        }

        return "Not set"
    }

    private var mileageCounterValue: String {
        guard let distanceRemaining = item.distanceRemaining else { return "Mileage pending" }
        return "\(ScenarioOverviewFormatting.formatDouble(max(distanceRemaining, 0), fractionDigits: 0)) \(item.distanceUnit) left"
    }

    private var mileageProgress: Double? {
        guard let service,
              let baseline = service.baselineOdometerValue,
              let due = service.dueOdometerValue,
              let distanceRemaining = item.distanceRemaining else {
            return nil
        }

        let interval = due - baseline
        guard interval > 0 else { return nil }
        return 1 - (distanceRemaining / interval)
    }

    private var createdValue: String {
        guard let service else { return "Not available" }
        return Self.serviceDateFormatter.string(from: service.createdAt)
    }

    private var baselineValue: String {
        guard let service else { return "Not available" }

        let date = service.baselineDate.map { Self.serviceDateFormatter.string(from: $0) }
        let odometer = service.baselineOdometerValue.map {
            "\(ScenarioOverviewFormatting.formatDouble($0, fractionDigits: 0)) \(service.baselineOdometerUnit ?? service.dueOdometerUnit)"
        }

        let parts = [date, odometer].compactMap { $0 }
        return parts.isEmpty ? "Not set" : parts.joined(separator: " • ")
    }

    private var repeatValue: String {
        guard let service else { return "Not available" }

        if let months = service.repeatIntervalMonths, months > 0 {
            return months == 1 ? "Every month" : "Every \(months) months"
        }

        if let value = service.repeatIntervalValue, value > 0 {
            return "Every \(ScenarioOverviewFormatting.formatDouble(value, fractionDigits: 0)) \(service.repeatIntervalUnit)"
        }

        return "One-time reminder"
    }

    private static let serviceDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static func daysRemainingTitle(_ days: Int) -> String {
        if days < 0 {
            let overdueDays = abs(days)
            return overdueDays == 1 ? "1 day overdue" : "\(overdueDays) days overdue"
        }

        if days == 0 {
            return "Due today"
        }

        return days == 1 ? "1 day left" : "\(days) days left"
    }
}
