import SwiftUI

struct ExpenseWeekRail: View {
    struct Model {
        let title: String
        let days: [Day]
    }

    struct Day: Identifiable {
        let id: String
        let date: Date
        let weekday: String
        let dayNumber: String
        let eventCount: Int
        let isSelected: Bool
    }

    let model: Model
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let onSelectDay: (Date) -> Void
    private let selectedTextColor = Color(hex: 0x385283)

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(spacing: WorthItSpacing.m) {
                Button(action: onPreviousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .frame(width: 36, height: 36)
                        .background(WorthItColor.surfaceContainerLow.opacity(0.78), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous week")

                Text(model.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity)

                Button(action: onNextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .frame(width: 36, height: 36)
                        .background(WorthItColor.surfaceContainerLow.opacity(0.78), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next week")
            }

            HStack(spacing: WorthItSpacing.s) {
                ForEach(model.days) { day in
                    dayButton(day)
                }
            }
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private func dayButton(_ day: Day) -> some View {
        Button {
            onSelectDay(day.date)
        } label: {
            VStack(spacing: WorthItSpacing.xs) {
                Text(day.weekday)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(day.isSelected ? selectedTextColor : WorthItColor.textTertiary)
                    .tracking(0.8)
                    .textCase(.uppercase)

                Text(day.dayNumber)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(day.isSelected ? selectedTextColor : WorthItColor.textPrimary)
                    .monospacedDigit()

                eventMarker(for: day)
                    .frame(height: 14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(dayBackground(day), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
        .disabled(day.eventCount == 0)
        .opacity(day.eventCount == 0 ? 0.54 : 1)
        .accessibilityLabel(accessibilityLabel(for: day))
    }

    @ViewBuilder
    private func eventMarker(for day: Day) -> some View {
        if day.eventCount > 1 {
            Text("\(day.eventCount)")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(day.isSelected ? selectedTextColor : WorthItColor.primaryContainer)
                .padding(.horizontal, WorthItSpacing.xs)
                .frame(height: 14)
                .background((day.isSelected ? selectedTextColor : WorthItColor.primaryContainer).opacity(0.16), in: Capsule())
        } else if day.eventCount == 1 {
            Circle()
                .fill(day.isSelected ? selectedTextColor : WorthItColor.primaryContainer)
                .frame(width: 5, height: 5)
        }
    }

    private func dayBackground(_ day: Day) -> Color {
        if day.isSelected {
            return WorthItColor.primaryContainer
        }
        if day.eventCount > 0 {
            return WorthItColor.surfaceContainerLow.opacity(0.82)
        }
        return Color.clear
    }

    private func accessibilityLabel(for day: Day) -> String {
        if day.eventCount == 0 {
            return "\(day.weekday) \(day.dayNumber), no expenses"
        }
        if day.eventCount == 1 {
            return "\(day.weekday) \(day.dayNumber), one expense"
        }
        return "\(day.weekday) \(day.dayNumber), \(day.eventCount) expenses"
    }
}
