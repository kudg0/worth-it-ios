import Foundation

extension ScenarioOverviewView {
    var scenarioVehicleSummary: String {
        let year = activeScenario.startDate.formatted(.dateTime.year())
        return "\(activeScenario.name) · since \(year)"
    }

    var scenarioAcquisitionSummary: String {
        let price = "\(currencySymbol)\(formatDecimal(decimalValue(activeScenario.purchasePrice), fractionDigits: 0))"
        let type = activeScenario.acquisitionType == "loan" ? "Loan" : "Cash"

        if let odometer = activeScenario.purchaseOdometer {
            return "\(type) · \(price) · \(formatInt(odometer)) \(mileageDisplayUnit)"
        }

        return "\(type) · \(price)"
    }

    var scenarioResaleSummary: String {
        guard let expectedResaleValue = activeScenario.expectedResaleValue else {
            return "Not set"
        }

        return "\(currencySymbol)\(formatDecimal(decimalValue(expectedResaleValue), fractionDigits: 0))"
    }

    var scenarioAnalyticsSummary: String {
        if let costPerKm = analyticsCostPerKmValue {
            return "\(currencySymbol)\(formatDouble(costPerKm, fractionDigits: 2))/\(mileageDisplayUnit) · \(costPerKmBasis.badgeTitle)"
        }

        return costPerKmIncludesFinancing ? "Finance on" : "Base model"
    }

    var scenarioComparisonSummary: String {
        let activeCount = alternatives.filter(\.isIncluded).count
        return "\(activeCount) active"
    }

    var scenarioPreferencesSummary: String {
        let currency = scenarioSettings?.currency ?? activeScenario.currency
        let region = scenarioSettings?.region ?? activeScenario.region
        let distanceUnit = scenarioSettings?.distanceUnit ?? activeScenario.baseUnit
        let regionTitle = scenarioSettingsOptions?.regions.first(where: { $0.id == region })?.title ?? region

        return "\(currency) · \(regionTitle) · \(distanceUnit)"
    }
}
