import SwiftUI

struct ScheduledServicesScreen: View {
    @State private var activeMonthPicker: MonthPickerPresentation?

    @Binding var month: Date
    @Binding var selectedDate: Date?

    let ownershipStartDate: Date
    let items: [ScenarioOverviewView.ScheduledServiceDisplayItem]
    let dueSubtitle: (ScenarioOverviewView.ScheduledServiceDisplayItem) -> String
    let serviceStateTitle: (String) -> String
    let serviceStateColor: (String) -> Color
    let serviceIconName: (String) -> String
    let onOpenScheduledService: (UUID) -> Void
    let onOpenScheduledServiceActions: (UUID) -> Void

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }()
    private let columns = Array(repeating: GridItem(.flexible(), spacing: WorthItSpacing.xs), count: 7)

    var body: some View {
        VStack(spacing: WorthItSpacing.xxxxl) {
            hero
            calendarIsland
            servicesSection
        }
        .sheet(item: $activeMonthPicker) { _ in
            monthPickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(items.count)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(items.count == 1 ? "scheduled item" : "scheduled items")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)

                Spacer()
            }

            Text(heroSubtitle)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }

    private var calendarIsland: some View {
        WIIsland(title: "Service Calendar", systemIcon: "calendar") {
            VStack(spacing: WorthItSpacing.xl) {
                monthHeader
                selectedDayReset
                weekdayHeader
                LazyVGrid(columns: columns, spacing: WorthItSpacing.s) {
                    ForEach(calendarDays) { day in
                        dayCell(day)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var selectedDayReset: some View {
        if selectedDate != nil {
            HStack {
                Text("Day filter active")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedDate = nil
                    }
                } label: {
                    HStack(spacing: WorthItSpacing.xs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .bold))

                        Text("Reset")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .padding(.horizontal, WorthItSpacing.m)
                    .frame(height: 28)
                    .background(WorthItColor.primaryContainer.opacity(0.10), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background(WorthItColor.surfaceContainer, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canMoveToPreviousMonth)
            .opacity(canMoveToPreviousMonth ? 1 : 0.36)

            Spacer()

            Button {
                activeMonthPicker = MonthPickerPresentation()
            } label: {
                HStack(spacing: WorthItSpacing.s) {
                    Text(Self.monthTitleFormatter.string(from: month))
                        .font(.system(size: 17, weight: .bold))

                    Image(systemName: "calendar")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(WorthItColor.textPrimary)
                .padding(.horizontal, WorthItSpacing.m)
                .frame(height: 34)
                .background(WorthItColor.surfaceContainer.opacity(0.72), in: Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 34, height: 34)
                    .background(WorthItColor.surfaceContainer, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var monthPickerSheet: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("Jump to month")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(.label))

                Text("Calendar starts at ownership start.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(.secondaryLabel))
            }

            DatePicker(
                "Service calendar month",
                selection: monthPickerBinding,
                in: ownershipStartDate...Date.distantFuture,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(WorthItColor.primaryContainer)
        }
        .padding(WorthItSpacing.xxl)
        .background(Color(.systemBackground))
        .presentationBackground(Color(.systemBackground))
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: WorthItSpacing.xs) {
            ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            servicesSectionHeader

            if filteredItems.isEmpty {
                emptyState
            } else {
                VStack(spacing: WorthItSpacing.m) {
                    ForEach(filteredItems) { item in
                        ScheduledServiceRow(
                            item: item,
                            dueSubtitle: dueSubtitle,
                            serviceStateTitle: serviceStateTitle,
                            serviceStateColor: serviceStateColor,
                            serviceIconName: serviceIconName,
                            onOpen: onOpenScheduledService,
                            onOpenActions: onOpenScheduledServiceActions
                        )
                    }
                }
            }
        }
    }

    private var servicesSectionHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: WorthItSpacing.m) {
            Text(selectedDate == nil ? "All Services" : "Selected Day")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            Spacer()

            if let selectedDate {
                Text(Self.serviceDateFormatter.string(from: selectedDate))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }
        }
        .padding(.horizontal, WorthItSpacing.xs)
    }

    private var emptyState: some View {
        ScenarioWideAction(
            title: "No service on this day",
            subtitle: "Choose another marked date or show the full schedule.",
            systemName: "calendar"
        ) {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedDate = nil
            }
        }
    }

    private func dayCell(_ day: CalendarDay) -> some View {
        let hasEvents = !items(on: day.date).isEmpty
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: day.date) } ?? false
        let isToday = calendar.isDateInToday(day.date)

        return Button {
            guard day.isCurrentMonth else { return }
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedDate = hasEvents ? day.date : nil
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: day.date))")
                    .font(.system(size: 13, weight: isSelected || isToday ? .bold : .semibold))
                    .foregroundStyle(dayTitleColor(day: day, isSelected: isSelected, isToday: isToday))

                HStack(spacing: 2) {
                    ForEach(Array(items(on: day.date).prefix(3))) { item in
                        Circle()
                            .fill(serviceStateColor(item.dueState))
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(dayBackground(isSelected: isSelected, hasEvents: hasEvents), in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            .overlay {
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: WorthItRadius.s)
                        .stroke(WorthItColor.primaryContainer.opacity(0.45), lineWidth: 1)
                }
            }
            .opacity(day.isCurrentMonth ? 1 : 0.32)
        }
        .buttonStyle(.plain)
        .disabled(!day.isCurrentMonth)
    }

    private func dayTitleColor(day: CalendarDay, isSelected: Bool, isToday: Bool) -> Color {
        if isSelected {
            return WorthItColor.surfaceLowest
        }

        if isToday {
            return WorthItColor.primaryContainer
        }

        return day.isCurrentMonth ? WorthItColor.textPrimary : WorthItColor.textTertiary
    }

    private func dayBackground(isSelected: Bool, hasEvents: Bool) -> Color {
        if isSelected {
            return WorthItColor.primaryContainer
        }

        return hasEvents ? WorthItColor.surfaceContainerHigh.opacity(0.70) : Color.clear
    }

    private var heroSubtitle: String {
        guard let nextItem = items.first else {
            return "Scheduled reminders will appear here once you add service dates or mileage triggers."
        }

        return "Next: \(nextItem.title) • \(dueSubtitle(nextItem))"
    }

    private var filteredItems: [ScenarioOverviewView.ScheduledServiceDisplayItem] {
        guard let selectedDate else { return items }

        return items.filter { item in
            guard let date = item.date else { return false }
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
    }

    private var calendarDays: [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let gridStart = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)?.start,
              let gridEnd = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))?.end else {
            return []
        }

        var days: [CalendarDay] = []
        var cursor = gridStart

        while cursor < gridEnd {
            days.append(
                CalendarDay(
                    date: cursor,
                    isCurrentMonth: calendar.isDate(cursor, equalTo: monthInterval.start, toGranularity: .month)
                )
            )
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? gridEnd
        }

        return days
    }

    private func moveMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.20)) {
            let nextMonth = calendar.date(byAdding: .month, value: value, to: month) ?? month
            month = maxMonthStart(nextMonth)
            selectedDate = nil
        }
    }

    private var monthPickerBinding: Binding<Date> {
        Binding(
            get: { month },
            set: { newDate in
                withAnimation(.easeInOut(duration: 0.20)) {
                    month = maxMonthStart(newDate)
                    selectedDate = nil
                }
            }
        )
    }

    private var canMoveToPreviousMonth: Bool {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: month) else { return false }
        return calendar.compare(monthStart(for: previousMonth), to: ownershipStartMonth, toGranularity: .month) != .orderedAscending
    }

    private var ownershipStartMonth: Date {
        monthStart(for: ownershipStartDate)
    }

    private func maxMonthStart(_ date: Date) -> Date {
        max(monthStart(for: date), ownershipStartMonth)
    }

    private func monthStart(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func items(on date: Date) -> [ScenarioOverviewView.ScheduledServiceDisplayItem] {
        items.filter { item in
            guard let itemDate = item.date else { return false }
            return calendar.isDate(itemDate, inSameDayAs: date)
        }
    }

    private struct CalendarDay: Identifiable {
        let date: Date
        let isCurrentMonth: Bool

        var id: Date { date }
    }

    private struct MonthPickerPresentation: Identifiable {
        let id = UUID()
    }

    private static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let serviceDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]
}
