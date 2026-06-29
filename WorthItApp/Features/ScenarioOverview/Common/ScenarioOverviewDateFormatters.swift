import Foundation

enum ScenarioOverviewDateFormatters {
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    static let mileageDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    static let serviceDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    static let mileageHeroDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    static let mileageTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let relativeMileage: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.unitsStyle = .full
        return formatter
    }()
}

extension ScenarioOverviewView {
    static var fullDateFormatter: DateFormatter { ScenarioOverviewDateFormatters.fullDate }
    static var shortDateFormatter: DateFormatter { ScenarioOverviewDateFormatters.shortDate }
    static var timeFormatter: DateFormatter { ScenarioOverviewDateFormatters.time }
    static var monthYearFormatter: DateFormatter { ScenarioOverviewDateFormatters.monthYear }
    static var mileageDateFormatter: DateFormatter { ScenarioOverviewDateFormatters.mileageDate }
    static var serviceDateFormatter: DateFormatter { ScenarioOverviewDateFormatters.serviceDate }
    static var mileageHeroDateFormatter: DateFormatter { ScenarioOverviewDateFormatters.mileageHeroDate }
    static var mileageTimeFormatter: DateFormatter { ScenarioOverviewDateFormatters.mileageTime }
    static var relativeMileageFormatter: RelativeDateTimeFormatter { ScenarioOverviewDateFormatters.relativeMileage }

    static func displayFullDate(_ date: Date, relativeTo referenceDate: Date = Date()) -> String {
        let calendar = Calendar.autoupdatingCurrent
        let formattedDate = fullDateFormatter.string(from: date)

        if calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Today, \(formattedDate)"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday, \(formattedDate)"
        }

        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: referenceDate),
           calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow, \(formattedDate)"
        }

        return formattedDate
    }
}
