import Foundation

extension ScenarioOverviewView {
    func serviceDueSubtitle(_ item: ScheduledServiceDisplayItem) -> String {
        let datePart: String
        if let date = item.date {
            if item.isEstimatedDate {
                datePart = "≈ " + Self.serviceDateFormatter.string(from: date)
            } else {
                datePart = Self.serviceDateFormatter.string(from: date)
            }
        } else if let daysRemaining = item.daysRemaining {
            datePart = daysRemaining <= 0 ? "Due now" : "in \(daysRemaining) days"
        } else {
            datePart = "Mileage estimate pending"
        }

        var parts = [datePart]

        if let distanceRemaining = item.distanceRemaining {
            parts.append("in \(formatDouble(max(distanceRemaining, 0), fractionDigits: 0)) \(item.distanceUnit)")
        }

        if let note = item.note {
            parts.append(note)
        }

        return parts.joined(separator: " • ")
    }
}
