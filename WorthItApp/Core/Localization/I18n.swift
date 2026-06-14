import Foundation
import SwiftUI

struct I18n: Equatable {
    let locale: Locale

    init(localeIdentifier: String = "en") {
        locale = Locale(identifier: localeIdentifier)
    }

    func t(_ key: I18nKey) -> String {
        String(localized: String.LocalizationValue(key.value), locale: locale)
    }

    // Legacy bridge for screens that have not been migrated to typed keys yet.
    func t(_ key: String.LocalizationValue) -> String {
        String(localized: key, locale: locale)
    }
}

private struct I18nEnvironmentKey: EnvironmentKey {
    static let defaultValue = I18n(localeIdentifier: "en")
}

extension EnvironmentValues {
    var i18n: I18n {
        get { self[I18nEnvironmentKey.self] }
        set { self[I18nEnvironmentKey.self] = newValue }
    }
}

// Transitional fallback for call sites that are not yet environment-aware.
// New or touched SwiftUI views should prefer @Environment(\.i18n).
enum i18n {
    static func t(_ key: I18nKey) -> String {
        I18n(localeIdentifier: "en").t(key)
    }

    // Legacy bridge for screens that have not been migrated to typed keys yet.
    static func t(_ key: String.LocalizationValue) -> String {
        I18n(localeIdentifier: "en").t(key)
    }
}
