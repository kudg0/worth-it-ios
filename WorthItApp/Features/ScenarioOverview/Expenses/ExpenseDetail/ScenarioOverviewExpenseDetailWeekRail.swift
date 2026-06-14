import SwiftUI

struct ScenarioExpenseDaySelection: Identifiable {
    let date: Date
    let eventIds: [UUID]

    var id: String {
        let ids = eventIds.map(\.uuidString).joined(separator: "-")
        return "\(date.timeIntervalSince1970)-\(ids)"
    }
}

extension ScenarioOverviewView {
    func expenseWeekRailModel(for event: CostEvent) -> ExpenseWeekRail.Model {
        let calendar = expenseDetailCalendar
        let weekStart = displayedExpenseDetailWeekStart ?? expenseDetailWeekStart(for: event.date)
        let eventsByDay = Dictionary(grouping: costEvents) { event in
            calendar.startOfDay(for: event.date)
        }

        let days = (0..<7).compactMap { offset -> ExpenseWeekRail.Day? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }

            let dayStart = calendar.startOfDay(for: date)
            return ExpenseWeekRail.Day(
                id: expenseDetailDayIdentifier(dayStart),
                date: dayStart,
                weekday: Self.expenseDetailWeekdayFormatter.string(from: dayStart),
                dayNumber: Self.expenseDetailDayFormatter.string(from: dayStart),
                eventCount: eventsByDay[dayStart]?.count ?? 0,
                isSelected: calendar.isDate(event.date, inSameDayAs: dayStart)
            )
        }

        return ExpenseWeekRail.Model(
            title: expenseDetailWeekTitle(for: weekStart),
            days: days
        )
    }

    func moveExpenseDetailWeek(_ direction: Int) {
        let base = displayedExpenseDetailWeekStart
            ?? selectedExpenseDetailId.flatMap { id in costEvents.first(where: { $0.id == id })?.date }.map(expenseDetailWeekStart)
            ?? Date()

        let calendar = expenseDetailCalendar
        let next = calendar.date(byAdding: .day, value: direction * 7, to: base) ?? base

        withAnimation(.easeInOut(duration: 0.18)) {
            displayedExpenseDetailWeekStart = expenseDetailWeekStart(for: next)
        }
    }

    func selectExpenseDetailDay(_ date: Date) {
        let events = expenseEvents(on: date)
        guard !events.isEmpty else { return }

        if events.count == 1, let event = events.first {
            selectExpenseDetailEvent(event.id, preserveDisplayedWeek: true)
            return
        }

        activeExpenseDaySelection = ScenarioExpenseDaySelection(
            date: expenseDetailCalendar.startOfDay(for: date),
            eventIds: events.map(\.id)
        )
    }

    func selectExpenseDetailEvent(_ eventId: UUID, preserveDisplayedWeek: Bool = false) {
        guard let event = costEvents.first(where: { $0.id == eventId }) else { return }

        withAnimation(.easeInOut(duration: 0.18)) {
            selectedExpenseDetailId = event.id
            activeExpenseActionId = nil
            activeExpenseDaySelection = nil
            if !preserveDisplayedWeek {
                displayedExpenseDetailWeekStart = expenseDetailWeekStart(for: event.date)
            }
        }
    }

    func expenseDaySelectionSheet(_ selection: ScenarioExpenseDaySelection) -> some View {
        let events = selection.eventIds.compactMap { id in
            costEvents.first(where: { $0.id == id })
        }
        let options = events.map { event in
            WISelectSheetOption(
                id: event.id.uuidString,
                title: expenseDaySelectionTitle(for: event),
                subtitle: i18n.t("\(expenseCategoryTitle(for: event.category)) • \(Self.shortDateFormatter.string(from: event.date))"),
                systemName: expenseIconName(for: event.category),
                textBadge: expenseAmountPrecise(event)
            )
        }

        return WISelectSheet(
            title: Self.expenseDetailSelectionTitleFormatter.string(from: selection.date),
            options: options,
            selectedId: selectedExpenseDetailId?.uuidString ?? ""
        ) { option in
            guard let id = UUID(uuidString: option.id) else { return }
            selectExpenseDetailEvent(id, preserveDisplayedWeek: true)
        }
    }

    func expenseDetailWeekStart(for date: Date) -> Date {
        let calendar = expenseDetailCalendar
        let dayStart = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: dayStart)
        let distanceFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -distanceFromMonday, to: dayStart) ?? dayStart
    }

    private var expenseDetailCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }

    private func expenseEvents(on date: Date) -> [CostEvent] {
        let calendar = expenseDetailCalendar
        return costEvents
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { lhs, rhs in
                if lhs.date == rhs.date {
                    return lhs.createdAt > rhs.createdAt
                }
                return lhs.date > rhs.date
            }
    }

    private func expenseDetailWeekTitle(for weekStart: Date) -> String {
        let calendar = expenseDetailCalendar
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let sameMonth = calendar.isDate(weekStart, equalTo: weekEnd, toGranularity: .month)

        if sameMonth {
            let month = Self.expenseDetailWeekMonthFormatter.string(from: weekStart)
            let startDay = Self.expenseDetailDayFormatter.string(from: weekStart)
            let endDay = Self.expenseDetailDayFormatter.string(from: weekEnd)
            return "\(month) \(startDay)-\(endDay)"
        }

        let start = Self.expenseDetailShortDateFormatter.string(from: weekStart)
        let end = Self.expenseDetailShortDateFormatter.string(from: weekEnd)
        return "\(start)-\(end)"
    }

    private func expenseDaySelectionTitle(for event: CostEvent) -> String {
        expenseTitle(for: event)
    }

    private func expenseDetailDayIdentifier(_ date: Date) -> String {
        Self.expenseDetailDayIdentifierFormatter.string(from: date)
    }

    private static let expenseDetailWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let expenseDetailDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d"
        return formatter
    }()

    private static let expenseDetailWeekMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter
    }()

    private static let expenseDetailShortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let expenseDetailSelectionTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let expenseDetailDayIdentifierFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
