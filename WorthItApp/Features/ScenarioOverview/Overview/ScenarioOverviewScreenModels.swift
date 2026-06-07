import SwiftUI

extension ScenarioOverviewView {
    var overviewEfficiencyModel: CostPerKmEfficiencyCard.Model {
        CostPerKmEfficiencyCard.Model(
            mileageUnit: mileageDisplayUnit,
            chartRange: $chartRange,
            selectedDate: selectedEfficiencyChartDateBinding,
            selectedPoint: selectedEfficiencyChartPoint,
            points: efficiencyChartPoints,
            yAxisMax: efficiencyChartYAxisMax,
            yAxisValues: efficiencyChartYAxisValues,
            axisDates: efficiencyChartAxisDates,
            currencySymbol: currencySymbol,
            valueLabel: efficiencyPointValueLabel,
            axisLabel: efficiencyAxisLabel,
            formatDouble: formatDouble
        )
    }
}
