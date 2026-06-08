import SwiftUI

extension ScenarioOverviewView {
    var selectedEfficiencyChartDateBinding: Binding<Date?> {
        Binding {
            selectedEfficiencyChartDate ?? latestFactualEfficiencyChartPoint?.date
        } set: { newValue in
            guard let newValue else {
                return
            }

            selectedEfficiencyChartDate = nearestEfficiencyChartPoint(to: newValue)?.date
        }
    }

    var selectedEfficiencyChartPoint: MetricTrendPoint? {
        guard let selectedEfficiencyChartDate else {
            return latestFactualEfficiencyChartPoint
        }

        return nearestEfficiencyChartPoint(to: selectedEfficiencyChartDate)
    }

    var latestFactualEfficiencyChartPoint: MetricTrendPoint? {
        efficiencyChartPoints.last(where: { !$0.isProjected }) ?? efficiencyChartPoints.last
    }

    func nearestEfficiencyChartPoint(to date: Date) -> MetricTrendPoint? {
        efficiencyChartPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    var efficiencyChartYAxisMax: Double {
        max(efficiencyChartPoints.map(\.value).max() ?? 0, 1)
    }

    var efficiencyChartYAxisValues: [Double] {
        [efficiencyChartYAxisMax, efficiencyChartYAxisMax / 2, 0]
    }

    var efficiencyChartAxisDates: [Date] {
        let points = efficiencyChartPoints
        guard points.count > 2 else { return points.map(\.date) }

        return [
            points.first?.date,
            points[points.count / 2].date,
            points.last?.date
        ].compactMap(\.self)
    }

    func efficiencyAxisLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        switch chartRange {
        case .day:
            formatter.dateFormat = "d MMM"
        case .week:
            formatter.dateFormat = "d MMM"
        case .month:
            formatter.dateFormat = "MMM"
        }
        return formatter.string(from: date)
    }

    func efficiencyPointValueLabel(_ point: MetricTrendPoint) -> String {
        "\(currencySymbol)\(formatDouble(point.value, fractionDigits: 2)) / \(mileageDisplayUnit)"
    }
}
