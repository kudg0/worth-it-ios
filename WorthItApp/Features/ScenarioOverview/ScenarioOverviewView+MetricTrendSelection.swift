import SwiftUI

extension ScenarioOverviewView {
    var selectedMetricTrendDateBinding: Binding<Date?> {
        Binding {
            selectedMetricTrendDate ?? defaultMetricTrendPoint?.date
        } set: { newValue in
            guard let newValue else {
                return
            }

            selectedMetricTrendDate = nearestMetricTrendPoint(to: newValue)?.date
        }
    }

    var selectedMetricTrendPoint: MetricTrendPoint? {
        guard let selectedMetricTrendDate else {
            return defaultMetricTrendPoint
        }

        return nearestMetricTrendPoint(to: selectedMetricTrendDate)
    }

    var defaultMetricTrendPoint: MetricTrendPoint? {
        if selectedDetailMetric == .costPerKm || selectedDetailMetric == .currentMonthCostPerKm {
            let calendar = Calendar(identifier: .gregorian)
            let currentBucketStart = calendar.dateInterval(of: metricTrendCalendarComponent, for: Date())?.start ?? Date()
            return nearestMetricTrendPoint(to: currentBucketStart) ?? metricTrendPoints.last
        }

        return metricTrendPoints.last(where: { !$0.isProjected }) ?? metricTrendPoints.last
    }

    func moveMetricTrendSelection(direction: MetricTrendSwipeDirection) {
        if selectedDetailMetric == .costPerKm {
            moveCostPerKmTrendPeriod(direction: direction)
            return
        }

        let points = metricTrendPoints.sorted { $0.date < $1.date }
        guard !points.isEmpty else { return }

        let currentDate = selectedMetricTrendPoint?.date ?? points.last?.date ?? Date()
        let currentIndex = points.enumerated().min { lhs, rhs in
            abs(lhs.element.date.timeIntervalSince(currentDate)) < abs(rhs.element.date.timeIntervalSince(currentDate))
        }?.offset ?? max(points.count - 1, 0)

        let nextIndex: Int
        switch direction {
        case .older:
            nextIndex = max(currentIndex - 1, 0)
        case .newer:
            nextIndex = min(currentIndex + 1, points.count - 1)
        }

        selectedMetricTrendDate = points[nextIndex].date
    }

    func moveCostPerKmTrendPeriod(direction: MetricTrendSwipeDirection) {
        let points = metricTrendPoints.sorted { $0.date < $1.date }
        guard !points.isEmpty else { return }

        let currentDate = selectedMetricTrendPoint?.date ?? defaultMetricTrendPoint?.date ?? points.last?.date ?? Date()
        let currentIndex = points.enumerated().min { lhs, rhs in
            abs(lhs.element.date.timeIntervalSince(currentDate)) < abs(rhs.element.date.timeIntervalSince(currentDate))
        }?.offset ?? max(points.count - 1, 0)

        let nextIndex: Int
        switch direction {
        case .older:
            nextIndex = max(currentIndex - 1, 0)
        case .newer:
            nextIndex = min(currentIndex + 1, points.count - 1)
        }

        selectedMetricTrendDate = points[nextIndex].date
    }

    func nearestMetricTrendPoint(to date: Date) -> MetricTrendPoint? {
        metricTrendPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }
}
