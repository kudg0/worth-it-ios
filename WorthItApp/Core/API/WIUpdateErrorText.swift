import Foundation

enum WIUpdateErrorText {
    static func message(for error: Error, fallback: String? = nil) -> String {
        if case APIError.requestFailed(let statusCode, let body) = error {
            return requestFailedMessage(statusCode: statusCode, body: body, fallback: fallback)
        }

        if case APIError.invalidResponse = error {
            return i18n.t(.common.errors.update.invalidResponse)
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return i18n.t(.common.errors.update.connectionSaveChanges)
        }

        return fallback ?? i18n.t(.common.errors.update.connectionSaveChanges)
    }

    static func message(for error: Error, fallbackKey: I18nKey) -> String {
        message(for: error, fallback: i18n.t(fallbackKey))
    }

    private static func requestFailedMessage(statusCode: Int, body: String, fallback: String?) -> String {
        if statusCode == 400 && body.contains("SCENARIO_CURRENCY_LOCKED") {
            return i18n.t(.common.errors.update.currencyLocked)
        }

        if statusCode == 400 || statusCode == 422 {
            return fallback ?? i18n.t(.common.errors.update.validationSaveChanges)
        }

        if statusCode == 401 || statusCode == 403 {
            return i18n.t(.common.errors.update.sessionExpired)
        }

        if statusCode == 404 {
            return i18n.t(.common.errors.update.notFound)
        }

        if statusCode >= 500 {
            return i18n.t(.common.errors.update.serverSaveChanges)
        }

        return fallback ?? i18n.t(.common.errors.update.connectionSaveChanges)
    }
}
