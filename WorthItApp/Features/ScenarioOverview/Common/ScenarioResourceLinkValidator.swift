import Foundation

enum ScenarioResourceLinkValidator {
    static let errorMessage = "Enter a valid http or https link."

    static func normalizedURL(from value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        guard
            let url = URL(string: trimmed),
            let scheme = url.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            let host = url.host?.lowercased(),
            host.contains(".")
        else {
            return nil
        }

        return url
    }
}
