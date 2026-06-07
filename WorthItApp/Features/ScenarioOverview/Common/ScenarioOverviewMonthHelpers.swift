import Foundation

extension ScenarioOverviewView {
    var currentMonthStart: Date {
        expenseHistoryMonthStart(for: Date())
    }

    func expenseHistoryMonthStart(for date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    func expenseHistoryMonthIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: expenseHistoryMonthStart(for: date))
    }

    func expenseHistoryMonthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    func expenseHistoryIsSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.isDate(lhs, equalTo: rhs, toGranularity: .month)
            && calendar.isDate(lhs, equalTo: rhs, toGranularity: .year)
    }
}
