import SwiftUI

extension ScenarioOverviewView {
    func costPerKmDetailModel(_ metric: MetricSlide?) -> CostPerKmDetailScreen.Model {
        CostPerKmDetailScreen.Model(
            hero: CostPerKmDetailHero.Model(
                periodTitle: costPerKmBreakdownPeriodTitle,
                value: costPerKmBreakdownDisplayValue,
                mileageUnit: mileageDisplayUnit,
                isProjected: selectedMetricTrendPoint?.isProjected == true,
                trend: costPerKmBreakdownTrend,
                fallbackTrend: costPerKmHeroFallbackTrend(metric)
            ),
            efficiencyComparison: costPerKmDetailEfficiencyModel,
            summary: CostPerKmSummaryGrid.Model(
                cost: CostPerKmSummaryGrid.Stat(
                    title: i18n.t("Total Costs"),
                    value: "\(currencySymbol)\(formatDouble(costPerKmBreakdownCost, fractionDigits: 0))",
                    unit: nil,
                    subtitle: costPerKmBreakdownCostSubtitle,
                    systemName: "receipt",
                    accentColor: WorthItColor.accentGold,
                    progress: costPerKmBreakdownCostProgress,
                    action: openExpensesPage
                ),
                distance: CostPerKmSummaryGrid.Stat(
                    title: i18n.t("Tracked Dist"),
                    value: "\(formatDouble(costPerKmBreakdownDistance, fractionDigits: 0))",
                    unit: mileageDisplayUnit,
                    subtitle: costPerKmMileageBasisLabel,
                    systemName: "point.topleft.down.curvedto.point.bottomright.up",
                    accentColor: WorthItColor.primaryContainer,
                    progress: costPerKmBreakdownDistanceProgress,
                    action: openMileagePage
                )
            ),
            showsEmptyNotice: usesThreeMonthAverageCostPerKm,
            emptyNoticeUnit: mileageDisplayUnit,
            formula: CostPerKmFormulaCard.Model(
                mileageUnit: mileageDisplayUnit,
                value: costPerKmFormulaValue,
                prefix: costPerKmFormulaPrefix,
                currencySymbol: currencySymbol,
                cost: formatDouble(costPerKmBreakdownCost, fractionDigits: 0),
                distance: formatDouble(costPerKmBreakdownDistance, fractionDigits: 0),
                formulaText: costPerKmFormulaText
            ),
            timeline: CostPerKmSourceTimeline.Model(
                periodTitle: costPerKmBreakdownPeriodTitle,
                sources: costPerKmBreakdownSources,
                onOpenSource: openBreakdownSource
            ),
            info: CostPerKmInfoPanel.Model(
                usesEffectiveOwnership: usesEffectiveCostPerKmBreakdown,
                hasActiveFinancing: hasActiveFinancing,
                includesFinancing: costPerKmFinancingBinding,
                mileageUnit: mileageDisplayUnit
            )
        )
    }

    func costPerKmHeroFallbackTrend(_ metric: MetricSlide?) -> MetricTrend? {
        guard let metric, let footer = metric.footer else { return nil }
        return MetricTrend(label: footer, iconName: metric.footerIcon, color: metric.footerColor)
    }

    var costPerKmDetailEfficiencyModel: CostPerKmEfficiencyCard.Model {
        CostPerKmEfficiencyCard.Model(
            mileageUnit: mileageDisplayUnit,
            chartRange: $chartRange,
            selectedDate: costPerKmDetailEfficiencyDateBinding,
            selectedPoint: selectedCostPerKmDetailEfficiencyPoint,
            points: costPerKmDetailEfficiencyPoints,
            comparisonSeries: costPerKmDetailEfficiencyComparisonSeries,
            yAxisMax: costPerKmDetailEfficiencyYAxisMax,
            yAxisValues: costPerKmDetailEfficiencyYAxisValues,
            axisDates: costPerKmDetailEfficiencyAxisDates,
            currencySymbol: currencySymbol,
            valueLabel: efficiencyPointValueLabel,
            axisLabel: efficiencyAxisLabel,
            formatDouble: formatDouble
        )
    }

    var costPerKmDetailEfficiencyPoints: [MetricTrendPoint] {
        guard selectedDetailMetric == .currentMonthCostPerKm else {
            return efficiencyChartPoints
        }

        let points: [MetricTrendPoint] = switch chartRange {
        case .day:
            currentMonthToDateEfficiencyPoints(period: .day)
        case .week:
            currentMonthToDateEfficiencyPoints(period: .weekOfYear)
        case .month:
            monthlyEfficiencyTrendPoints(maxMonths: activeCostPerKmTrendRange == .oneYear ? 12 : nil)
        }

        return sortedTrendPoints(points)
    }

    func currentMonthToDateEfficiencyPoints(period: Calendar.Component) -> [MetricTrendPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let dayStep = period == .weekOfYear ? 7 : 1
        let elapsedDays = calendar.dateComponents([.day], from: currentMonthStart, to: now).day ?? 0
        let periodCount = elapsedDays / dayStep

        return (0...max(periodCount, 0)).compactMap { offset in
            guard let bucketStart = calendar.date(byAdding: .day, value: offset * dayStep, to: currentMonthStart) else {
                return nil
            }

            let bucketEnd = calendar.date(byAdding: .day, value: dayStep, to: bucketStart) ?? bucketStart
            let end = min(bucketEnd, now)
            let cost = ownershipCost(
                from: currentMonthStart,
                to: end,
                includeFinancing: shouldIncludeFinancingInCostPerKm
            )
            let mileage = mileageDistance(from: currentMonthStart, to: end)

            guard bucketStart < end, cost >= 0, mileage > 0 else {
                return nil
            }

            return MetricTrendPoint(date: bucketStart, value: cost / mileage)
        }
    }

    var costPerKmDetailEfficiencyDateBinding: Binding<Date?> {
        Binding {
            selectedEfficiencyChartDate ?? latestFactualCostPerKmDetailEfficiencyPoint?.date
        } set: { newValue in
            guard let newValue else {
                return
            }

            selectedEfficiencyChartDate = nearestCostPerKmDetailEfficiencyPoint(to: newValue)?.date
        }
    }

    var selectedCostPerKmDetailEfficiencyPoint: MetricTrendPoint? {
        guard let selectedEfficiencyChartDate else {
            return latestFactualCostPerKmDetailEfficiencyPoint
        }

        return nearestCostPerKmDetailEfficiencyPoint(to: selectedEfficiencyChartDate)
    }

    var latestFactualCostPerKmDetailEfficiencyPoint: MetricTrendPoint? {
        costPerKmDetailEfficiencyPoints.last(where: { !$0.isProjected }) ?? costPerKmDetailEfficiencyPoints.last
    }

    func nearestCostPerKmDetailEfficiencyPoint(to date: Date) -> MetricTrendPoint? {
        costPerKmDetailEfficiencyPoints.min { lhs, rhs in
            abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
        }
    }

    var costPerKmDetailEfficiencyComparisonSeries: [ScenarioCompareChartSeries] {
        overviewEfficiencyComparisonSeries.map { series in
            ScenarioCompareChartSeries(
                id: series.id,
                title: series.title,
                color: series.color,
                points: series.points
                    .filter { point in
                        guard let firstDate = costPerKmDetailEfficiencyPoints.first?.date,
                              let lastDate = costPerKmDetailEfficiencyPoints.last?.date
                        else { return true }
                        return point.date >= firstDate && point.date <= lastDate
                    }
                    .prolongated(
                        from: costPerKmDetailEfficiencyPoints.first?.date,
                        to: costPerKmDetailEfficiencyPoints.last?.date
                    ),
                isBenchmark: series.isBenchmark
            )
        }
    }

    var costPerKmDetailEfficiencyYAxisMax: Double {
        let comparisonMax = costPerKmDetailEfficiencyComparisonSeries
            .flatMap { $0.points.map(\.value) }
            .max() ?? 0
        let pointMax = costPerKmDetailEfficiencyPoints.map(\.value).max() ?? 0
        return max(pointMax, comparisonMax * 1.08, 1)
    }

    var costPerKmDetailEfficiencyYAxisValues: [Double] {
        [costPerKmDetailEfficiencyYAxisMax, costPerKmDetailEfficiencyYAxisMax / 2, 0]
    }

    var costPerKmDetailEfficiencyAxisDates: [Date] {
        let points = costPerKmDetailEfficiencyPoints
        guard points.count > 2 else { return points.map(\.date) }

        return [
            points.first?.date,
            points[points.count / 2].date,
            points.last?.date
        ].compactMap(\.self)
    }

    func openBreakdownSource(_ source: CostPerKmBreakdownSource) {
        guard let target = source.target else { return }

        switch target {
        case let .expense(id):
            openExpenseHistory(focusedOn: id)
        case let .mileage(id):
            openMileageHistory(focusedOn: id)
        }
    }
}
