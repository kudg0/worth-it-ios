import Foundation

extension ScenarioOverviewView {
    var metricInsightWideTitle: String {
        switch selectedDetailMetric {
        case .paybackDistance:
            "Savings"
        case .totalOwnership:
            "Resale Buffer"
        case .expectedResale, .projectedGain:
            "Market Timing"
        default:
            "Signal Quality"
        }
    }

    var metricDetailSubtitle: String {
        switch selectedDetailMetric {
        case .monthlyCost:
            "Shows the current monthly ownership load from loan interest and logged costs."
        case .costPerKm:
            "Shows effective cost since purchase from logged costs, depreciation, accrued interest, and usage."
        case .currentMonthCostPerKm:
            "Shows this month's logged costs divided by this month's tracked distance."
        case .totalExpenses:
            "Shows every logged car expense across the full ownership period."
        case .totalOwnership:
            "Net ownership cost after expected resale. The trend below shows accumulated logged costs, loan interest, and depreciation from the first logged expense month."
        case .paybackDistance:
            "Shows how much money this car saved or lost against the selected comparison option for the same distance."
        case .projectedGain:
            "Shows potential upside after resale value exceeds purchase, interest, and non-daily costs."
        case .expectedResale:
            "Valuation estimate based on your scenario inputs and the latest resale assumptions."
        case .loanInterest:
            "Shows the projected interest paid across the loan term, separate from the vehicle value."
        }
    }

    var metricSeasonalText: String {
        switch selectedDetailMetric {
        case .paybackDistance:
            "Savings changes when tracked distance, ownership cost, resale basis, or selected alternative pricing changes."
        case .expectedResale, .projectedGain:
            "Market timing can move this metric. Seasonal demand may improve resale assumptions when the car remains in good condition."
        case .monthlyCost, .loanInterest:
            "Loan terms make this metric predictable, while logged maintenance can still create short-term spikes."
        case .costPerKm, .currentMonthCostPerKm, .totalExpenses:
            "More usage data will make this trajectory more reliable and reduce noise from one-off expenses."
        case .totalOwnership:
            "The hero value subtracts expected resale, while the chart shows the cost inputs building up over time. This keeps early expenses visible instead of hiding them behind resale value."
        }
    }

    var metricMissingDataText: String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm, .paybackDistance:
            "Mileage history is needed for a precise trend."
        case .expectedResale, .projectedGain:
            "Condition and market comps will improve accuracy."
        default:
            "More monthly history will improve comparison."
        }
    }

    var metricActionValue: String {
        switch selectedDetailMetric {
        case .costPerKm, .currentMonthCostPerKm, .paybackDistance:
            "Mileage"
        case .expectedResale, .projectedGain:
            "Market"
        default:
            "History"
        }
    }

    var metricVolatilityValue: String {
        switch selectedDetailMetric {
        case .monthlyCost, .loanInterest:
            "Low"
        case .costPerKm, .currentMonthCostPerKm, .totalExpenses, .totalOwnership, .paybackDistance:
            "Medium"
        case .projectedGain, .expectedResale:
            "Low"
        }
    }

    var metricRecommendationText: String {
        switch selectedDetailMetric {
        case .monthlyCost:
            "Your monthly cost is mostly shaped by fixed payments and this month’s logged expenses. Keep logging maintenance so spikes are visible instead of hidden."
        case .costPerKm:
            "Add mileage history next. Once usage is known, this metric becomes one of the clearest signals for whether ownership is still worth it."
        case .currentMonthCostPerKm:
            "Use this as a month-to-month trip-cost signal. It reflects current spending and current usage, so it can spike before the long-term ownership economics move."
        case .totalExpenses:
            "Open expense history to inspect which entries make up the total. This metric is pure logged spend, without resale or vehicle value assumptions."
        case .totalOwnership:
            "Keep resale and large maintenance entries fresh. The headline is net cost after resale; the chart is the accumulated cost base behind it."
        case .paybackDistance:
            "Use this as a comparison signal. Positive means owning the car cost less than the selected alternative for your tracked distance; negative means the alternative would have been cheaper."
        case .projectedGain:
            "Projected gain should stay conservative. Daily running costs are excluded, but loan interest and non-daily maintenance still matter."
        case .expectedResale:
            "Keep the resale estimate fresh. Small valuation shifts can meaningfully change whether this ownership scenario still looks attractive."
        case .loanInterest:
            "Loan interest is predictable but real. Keeping it visible prevents the financed purchase from looking cheaper than it actually is."
        }
    }
}
