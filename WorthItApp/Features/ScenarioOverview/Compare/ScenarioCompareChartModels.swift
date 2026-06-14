import Charts
import SwiftUI

struct ScenarioCompareChartPoint: Identifiable {
    let date: Date
    let value: Double

    var id: Date { date }
}

struct ScenarioCompareChartSeries: Identifiable {
    let id: String
    let title: String
    let color: Color
    let points: [ScenarioCompareChartPoint]
    let isBenchmark: Bool
}
