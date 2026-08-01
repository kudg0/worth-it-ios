import Foundation

enum AchievementPercentFormatter {
    static func percentText(_ progress: Double) -> String {
        formatter.string(from: NSNumber(value: min(max(progress, 0), 1))) ?? "\(Int(progress * 100))%"
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()
}
