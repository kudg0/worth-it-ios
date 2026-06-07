import SwiftUI

extension ScenarioOverviewView {
    func costPerKmDetailModel(_ metric: MetricSlide?) -> CostPerKmDetailScreen.Model {
        CostPerKmDetailScreen.Model(
            hero: CostPerKmDetailHero.Model(
                periodTitle: costPerKmBreakdownPeriodTitle,
                value: costPerKmBreakdownDisplayValue,
                mileageUnit: mileageDisplayUnit,
                trend: costPerKmBreakdownTrend,
                fallbackTrend: costPerKmHeroFallbackTrend(metric)
            ),
            mode: costPerKmModeBinding,
            modeDescription: costPerKmModeDescription,
            trend: CostPerKmTrendPanel.Model(
                rangeLabel: costPerKmBreakdownRangeLabel,
                chart: AnyView(metricTrendChart(
                    metric: metric,
                    height: 136,
                    xValueName: "Period",
                    selectedRuleName: "Selected period",
                    selectedValueName: "Selected value",
                    selectedSymbolSize: 78,
                    areaOpacity: 0.20
                )),
                showsRangeToggle: showsCostPerKmYearRangeToggle,
                selectedRange: metricTrendRangeBinding,
                onMovePeriod: moveCostPerKmTrendPeriod
            ),
            summary: CostPerKmSummaryGrid.Model(
                cost: CostPerKmSummaryGrid.Stat(
                    title: "Total Costs",
                    value: "\(currencySymbol)\(formatDouble(costPerKmBreakdownCost, fractionDigits: 0))",
                    unit: nil,
                    subtitle: "\(costPerKmIncludedCostEvents.count) expenses",
                    systemName: "receipt",
                    accentColor: WorthItColor.accentGold,
                    progress: costPerKmBreakdownCostProgress,
                    action: openExpensesPage
                ),
                distance: CostPerKmSummaryGrid.Stat(
                    title: "Tracked Dist",
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
                distance: formatDouble(costPerKmBreakdownDistance, fractionDigits: 0)
            ),
            timeline: CostPerKmSourceTimeline.Model(
                periodTitle: costPerKmBreakdownPeriodTitle,
                sources: costPerKmBreakdownSources,
                onOpenSource: openBreakdownSource
            ),
            info: CostPerKmInfoPanel.Model(
                mode: costPerKmMode,
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

    var costPerKmModeDescription: String {
        switch costPerKmMode {
        case .effective:
            "Effective since purchase: logged costs, depreciation, accrued interest, and all tracked distance."
        case .period:
            "Period view: only costs and distance from the selected period."
        }
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
