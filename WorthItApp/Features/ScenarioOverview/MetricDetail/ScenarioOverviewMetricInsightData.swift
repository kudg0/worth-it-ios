import Foundation

extension ScenarioOverviewView {
    var metricDetailSubtitle: String {
        switch selectedDetailMetric {
        case .monthlyCost:
            "Shows the current monthly ownership load from loan payments and logged costs."
        case .costPerKm:
            costPerKmMode == .effective
                ? "Shows effective cost since purchase from logged costs, depreciation, accrued interest, and usage."
                : "Shows period cost per kilometer from costs and usage inside the selected period."
        case .totalOwnership:
            "Shows the net cost of owning this car after purchase, known costs, and expected resale."
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
        case .expectedResale, .projectedGain:
            "Market timing can move this metric. Seasonal demand may improve resale assumptions when the car remains in good condition."
        case .monthlyCost, .loanInterest:
            "Loan terms make this metric predictable, while logged maintenance can still create short-term spikes."
        case .costPerKm, .totalOwnership:
            "More usage data will make this trajectory more reliable and reduce noise from one-off expenses."
        }
    }

    var metricMissingDataText: String {
        switch selectedDetailMetric {
        case .costPerKm:
            "Mileage history is needed for a precise trend."
        case .expectedResale, .projectedGain:
            "Condition and market comps will improve accuracy."
        default:
            "More monthly history will improve comparison."
        }
    }

    var metricActionValue: String {
        switch selectedDetailMetric {
        case .costPerKm:
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
        case .costPerKm, .totalOwnership:
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
        case .totalOwnership:
            "Track resale and non-daily maintenance separately. This gives the cleanest view of real ownership cost over time."
        case .projectedGain:
            "Projected gain should stay conservative. Daily running costs are excluded, but loan interest and non-daily maintenance still matter."
        case .expectedResale:
            "Keep the resale estimate fresh. Small valuation shifts can meaningfully change whether this ownership scenario still looks attractive."
        case .loanInterest:
            "Loan interest is predictable but real. Keeping it visible prevents the financed purchase from looking cheaper than it actually is."
        }
    }
}
