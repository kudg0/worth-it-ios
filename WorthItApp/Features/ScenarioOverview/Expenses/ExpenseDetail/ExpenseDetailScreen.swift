import SwiftUI

struct ExpenseDetailScreen: View {
    let event: CostEvent
    let scenarioName: String
    let amountText: String
    let categoryTitle: String
    let categoryIconName: String
    let accentColor: Color
    let dateText: String
    let timeText: String
    let kindText: String
    let monthText: String
    let linkedServiceTitle: String?
    let weekRail: ExpenseWeekRail.Model
    let onMoveWeek: (Int) -> Void
    let onSelectWeekDay: (Date) -> Void
    let onOpenActions: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
            ExpenseWeekRail(
                model: weekRail,
                onPreviousWeek: { onMoveWeek(-1) },
                onNextWeek: { onMoveWeek(1) },
                onSelectDay: onSelectWeekDay
            )
            hero
            costContext
            detailContext
            serviceContext
            odometerContext

            if let note = normalizedNote {
                noteCard(note)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: categoryIconName)
                    .font(.system(size: 22, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(accentColor)
                    .frame(width: 56, height: 56)
                    .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: WorthItRadius.l))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(amountText)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("\(categoryTitle) • \(dateText)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }
                .layoutPriority(1)
                .padding(.trailing, 44)
            }

            HStack(spacing: WorthItSpacing.s) {
                pill(title: categoryTitle, systemName: categoryIconName, color: accentColor)
                pill(title: kindText, systemName: event.kind == "recurring" ? "repeat" : "smallcircle.filled.circle", color: WorthItColor.primaryContainer)
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay(alignment: .topTrailing) {
            Button(action: onOpenActions) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .frame(width: 40, height: 40)
                    .background(WorthItColor.surfaceContainerLow.opacity(0.72), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Expense actions")
            .padding(.top, WorthItSpacing.xxl)
            .padding(.trailing, WorthItSpacing.xxl)
        }
    }

    private var costContext: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: "Cost Context", systemName: "chart.line.uptrend.xyaxis")

            HStack(spacing: WorthItSpacing.m) {
                metricTile(title: "Logged", value: amountText, subtitle: "Included in \(monthText)", progress: 1)
                metricTile(title: "Category", value: categoryTitle, subtitle: kindText, progress: event.kind == "recurring" ? 0.66 : 0.34)
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var detailContext: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: "Expense Details", systemName: "receipt")
            detailRow(title: "Scenario", value: scenarioName)
            detailRow(title: "Date", value: dateText)
            detailRow(title: "Time", value: timeText)
            detailRow(title: "Currency", value: event.currency)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var serviceContext: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: "Linked Service", systemName: "calendar.badge.clock")

            HStack(spacing: WorthItSpacing.m) {
                Image(systemName: linkedServiceTitle == nil ? "link.badge.plus" : "checkmark.circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 42, height: 42)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(linkedServiceTitle ?? "No service linked")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(linkedServiceTitle == nil ? "Can be linked while editing this expense." : "Expense is associated with scheduled maintenance.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var odometerContext: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            sectionHeader(title: "Odometer Context", systemName: "gauge.with.dots.needle.33percent")
            detailRow(title: "Mileage", value: "No odometer linked")
            detailRow(title: "Source", value: "Expense entry has no mileage field")
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private func metricTile(title: String, value: String, subtitle: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(0.9)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(subtitle)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 0)
            progressBar(progress)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, minHeight: 122, alignment: .leading)
        .background(WorthItColor.surfaceLowest.opacity(0.52), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func progressBar(_ progress: Double) -> some View {
        GeometryReader { proxy in
            let normalized = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(WorthItColor.primaryContainer.opacity(0.14))

                Capsule()
                    .fill(WorthItColor.primaryContainer)
                    .frame(width: max(proxy.size.width * normalized, 6))
            }
        }
        .frame(height: 6)
    }

    private func noteCard(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            sectionHeader(title: "Notes", systemName: "note.text")

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

    private func pill(title: String, systemName: String, color: Color) -> some View {
        HStack(spacing: WorthItSpacing.xs) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, WorthItSpacing.m)
        .frame(height: 30)
        .background(color.opacity(0.10), in: Capsule())
    }

    private var normalizedNote: String? {
        let note = event.note?.trimmingCharacters(in: .whitespacesAndNewlines)
        return note?.isEmpty == false ? note : nil
    }
}
