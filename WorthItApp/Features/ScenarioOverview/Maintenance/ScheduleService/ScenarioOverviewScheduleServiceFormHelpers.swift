import Foundation

extension ScenarioOverviewView {
    var serviceTypeSelectOptions: [String] {
        ["Select a service..."] + Self.defaultServiceTypeOptions
    }

    var scheduleBasisTitle: String {
        if let editingScheduledService {
            return "Created \(Self.serviceDateFormatter.string(from: editingScheduledService.createdAt))"
        }

        return "Set schedule basis"
    }

    var scheduleBasisSubtitle: String {
        let date = serviceBaselineDate.map { Self.serviceDateFormatter.string(from: $0) } ?? "date not set"
        let odometer = Double(serviceBaselineOdometer).map { "\(formatDouble($0, fractionDigits: 0)) \(mileageDisplayUnit)" } ?? "odometer not set"
        return "Counting from \(date) at \(odometer)."
    }

    var serviceBaselineOdometerValue: Double? {
        Double(serviceBaselineOdometer)
    }

    var serviceIntervalValue: Double? {
        Double(serviceMileage)
    }

    var serviceDueOdometerValue: Double? {
        guard let mileageValue = serviceIntervalValue else { return nil }

        switch serviceMileageInputMode {
        case .interval:
            return (serviceBaselineOdometerValue ?? 0) + mileageValue
        case .odometer:
            return mileageValue
        }
    }

    func toggleServiceMileageInputMode() {
        let nextMode: ServiceMileageInputMode = serviceMileageInputMode == .interval ? .odometer : .interval

        if let mileageValue = serviceIntervalValue {
            let basisOdometer = serviceBaselineOdometerValue ?? Double(currentOdometerValue)

            switch (serviceMileageInputMode, nextMode) {
            case (.interval, .odometer):
                serviceMileage = formatEditableNumber(basisOdometer + mileageValue)
            case (.odometer, .interval):
                serviceMileage = formatEditableNumber(max(mileageValue - basisOdometer, 0))
            default:
                break
            }
        }

        serviceMileageInputMode = nextMode
    }

    var serviceMileageFieldLabel: String {
        switch serviceMileageInputMode {
        case .interval:
            "Service interval"
        case .odometer:
            "Due odometer"
        }
    }

    var trimmedServiceDetails: String {
        serviceDetails.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resetScheduledServiceForm() {
        editingScheduledService = nil
        selectedServiceType = "Select a service..."
        scheduleTrigger = .date
        isScheduleBasisExpanded = false
        serviceBaselineDate = Date()
        serviceBaselineOdometer = currentOdometerValue > 0 ? formatEditableNumber(Double(currentOdometerValue)) : ""
        serviceDate = nil
        serviceMileage = ""
        serviceMileageInputMode = .interval
        isOptionalServiceDateEnabled = false
        isOptionalServiceMileageEnabled = false
        serviceDetails = ""
    }

    func scheduledServiceCategory(for title: String) -> String {
        switch title {
        case "Brake Pads":
            "repair"
        case "Inspection":
            "inspection"
        case "Other":
            "other"
        default:
            "maintenance"
        }
    }

    func expenseCategory(forScheduledServiceCategory category: String) -> ExpenseCategory {
        switch category {
        case "wash":
            .wash
        case "insurance":
            .insurance
        case "repair", "maintenance", "inspection":
            .repair
        default:
            .repair
        }
    }

    static let defaultServiceTypeOptions = [
        "Oil Change",
        "Brake Pads",
        "Tires",
        "Inspection",
        "Battery",
        "Other",
    ]
}
