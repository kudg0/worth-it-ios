import SwiftUI

struct ScenarioMileageScreen: View {
    let currentOdometerValue: Int
    let mileageUnit: String
    let heroDateText: String
    let lastUpdateText: String
    let thisMonthText: String
    let averagePerDayText: String
    let usageEventsError: String?
    let logItems: [ScenarioOverviewView.MileageLogItem]
    let currentMonthItems: [ScenarioOverviewView.MileageLogItem]
    let onOpenHistory: () -> Void
    let onEditMileage: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            heroCard
            activitySection
        }
    }

    private var heroCard: some View {
        Button(action: onOpenHistory) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    HStack(spacing: WorthItSpacing.s) {
                        Text("CURRENT ODOMETER").tracking(2.4)
                        Circle().fill(WorthItColor.textSecondary.opacity(0.72)).frame(width: 3, height: 3)
                        Text(heroDateText).tracking(1.2)
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)

                    HStack(alignment: .lastTextBaseline, spacing: WorthItSpacing.s) {
                        Text(ScenarioMileageLogRow.formatInt(currentOdometerValue))
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(WorthItColor.textPrimary)
                            .tracking(-2.4)
                            .lineLimit(1)
                            .minimumScaleFactor(0.56)

                        Text(mileageUnit)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(WorthItColor.primaryContainer)
                    }
                }

                metrics
            }
            .padding(WorthItSpacing.xxxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { heroBackground }
            .clipShape(RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .shadow(color: .black.opacity(0.30), radius: 50, y: 20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open mileage history")
    }

    private var metrics: some View {
        HStack(spacing: WorthItSpacing.l) {
            metric(title: "Last Update", value: lastUpdateText, color: WorthItColor.textPrimary)
            metric(title: "This Month", value: thisMonthText, color: WorthItColor.accentGold)
            metric(title: "Avg / Day", value: averagePerDayText, color: WorthItColor.textPrimary)
        }
        .padding(.top, WorthItSpacing.xl)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
    }

    private var heroBackground: some View {
        ZStack(alignment: .topTrailing) {
            WorthItColor.surfaceContainer

            Circle()
                .fill(WorthItColor.primaryContainer.opacity(0.05))
                .frame(width: 256, height: 256)
                .blur(radius: 32)
                .offset(x: 80, y: -80)
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack {
                Text("Log Activity")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.45)

                Spacer()

                Button(action: onOpenHistory) {
                    Text("View all")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }
                .buttonStyle(.plain)
            }

            activityContent
        }
    }

    @ViewBuilder
    private var activityContent: some View {
        if let usageEventsError {
            WITipInfo(title: "Mileage unavailable", bodyText: usageEventsError)
        } else if logItems.isEmpty {
            WITipInfo(
                title: "No mileage logged",
                bodyText: "No mileage logged yet. Log odometer updates or trips to make mileage history and cost per distance real."
            )
        } else if currentMonthItems.isEmpty {
            currentMonthNoMileageState
        } else {
            VStack(spacing: WorthItSpacing.l) {
                ForEach(currentMonthItems) { item in
                    ScenarioMileageLogRow(item: item, onEditMileage: onEditMileage)
                }
            }
        }
    }

    private var currentMonthNoMileageState: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("No mileage this month")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("You have older entries. Open the full history to review them.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func metric(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
