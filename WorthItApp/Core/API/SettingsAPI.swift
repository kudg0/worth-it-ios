import Foundation
import WorthItAPI
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

/// Keeps the generated wire types at the API boundary.
struct SettingsAPI {
    private let generated: WorthItAPI.Client

    init(client: HTTPAPIClient) {
        generated = WorthItAPI.Client(
            serverURL: client.baseURL,
            transport: URLSessionTransport(configuration: .init(session: client.session)),
            middlewares: [SettingsMiddleware(baseURL: client.baseURL, token: client.authToken)]
        )
    }

    func getSettings() async throws -> UserSettings {
        do {
            switch try await generated.getCurrentUserSettings() {
            case .ok(let response):
                let value = try response.body.json
                return UserSettings(distanceUnit: value.distanceUnit.rawValue, currency: value.currency.rawValue, locale: value.locale.rawValue)
            case .undocumented: throw APIError.invalidResponse
            }
        } catch { throw unwrap(error) }
    }

    func getOptions() async throws -> UserSettingsOptions {
        do {
            switch try await generated.getCurrentUserSettingsOptions() {
            case .ok(let response):
                let value = try response.body.json
                return UserSettingsOptions(
                    regions: value.regions.map { UserSettingsOption(id: $0.id, title: $0.label, groupId: $0.groupId, groupTitle: $0.groupLabel) },
                    currencies: value.currencies.map { UserSettingsOption(id: $0.id, title: $0.label, groupId: $0.groupId, groupTitle: $0.groupLabel) },
                    distanceUnits: value.distanceUnits.map { UserSettingsOption(id: $0.id, title: $0.label, groupId: $0.groupId, groupTitle: $0.groupLabel) }
                )
            case .undocumented: throw APIError.invalidResponse
            }
        } catch { throw unwrap(error) }
    }

    func update(_ patch: UserSettingsPatch) async throws -> UserSettings {
        typealias Payload = Operations.updateCurrentUserSettings.Input.Body.jsonPayload
        let distance = try parse(patch.distanceUnit, as: Payload.distanceUnitPayload.self)
        let currency = try parse(patch.currency, as: Payload.currencyPayload.self)
        let locale = try parse(patch.locale, as: Payload.localePayload.self)
        do {
            switch try await generated.updateCurrentUserSettings(body: .json(.init(distanceUnit: distance, currency: currency, locale: locale))) {
            case .ok(let response):
                let value = try response.body.json
                return UserSettings(distanceUnit: value.distanceUnit.rawValue, currency: value.currency.rawValue, locale: value.locale.rawValue)
            case .undocumented: throw APIError.invalidResponse
            }
        } catch { throw unwrap(error) }
    }

    private func parse<T: RawRepresentable>(_ value: String?, as type: T.Type) throws -> T? where T.RawValue == String {
        guard let value else { return nil }
        guard let parsed = T(rawValue: value) else { throw SettingsValidationError.invalidValue(value) }
        return parsed
    }

    private func unwrap(_ error: Error) -> Error {
        if let clientError = error as? ClientError { return unwrap(clientError.underlyingError) }
        return error
    }
}

enum SettingsValidationError: Error {
    case invalidValue(String)
}

private struct SettingsMiddleware: ClientMiddleware {
    let baseURL: URL
    let token: String?

    func intercept(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String,
                   next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let scheme = self.baseURL.scheme, let host = self.baseURL.host {
            var origin = "\(scheme)://\(host)"
            if let port = self.baseURL.port { origin += ":\(port)" }
            request.headerFields[.origin] = origin
        } else {
            request.headerFields[.origin] = self.baseURL.absoluteString
        }
        if let token, !token.isEmpty { request.headerFields[.authorization] = "Bearer \(token)" }
        let (response, responseBody) = try await next(request, body, baseURL)
        guard (200..<300).contains(response.status.code) else {
            let data: Data
            if let responseBody { data = try await Data(collecting: responseBody, upTo: .max) }
            else { data = Data() }
            if response.status.code == 401 {
                await MainActor.run { NotificationCenter.default.post(name: .apiUnauthorized, object: nil) }
            }
            throw APIError.requestFailed(statusCode: response.status.code, body: String(data: data, encoding: .utf8) ?? "")
        }
        return (response, responseBody)
    }
}
