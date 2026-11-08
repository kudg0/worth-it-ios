import XCTest
@testable import WorthIt

final class SettingsAPITests: XCTestCase {
    private let settings = #"{"userId":"11111111-1111-4111-8111-111111111111","distanceUnit":"km","currency":"EUR","locale":"en-CY","future":true}"#
    private let options = #"{"regions":[{"id":"en-CY","label":"Cyprus","future":1}],"currencies":[{"id":"EUR","label":"Euro","groupId":null,"groupLabel":null,"future":1}],"distanceUnits":[{"id":"km","label":"Kilometres","groupId":"a","groupLabel":"A","future":1}],"future":true}"#

    private func api() -> SettingsAPI {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SettingsURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return SettingsAPI(client: HTTPAPIClient(baseURL: URL(string: "https://example.test:8443")!, authToken: "token", session: session))
    }

    override func tearDown() {
        SettingsURLProtocol.handler = nil
        super.tearDown()
    }

    func testSettingsAndOptionsAndPatchUseGeneratedTransport() async throws {
        let settings = self.settings
        let options = self.options
        SettingsURLProtocol.handler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Origin"), "https://example.test:8443")
            switch (request.httpMethod, request.url?.path) {
            case ("GET", "/me/settings"): return (200, settings)
            case ("GET", "/me/settings/options"): return (200, options)
            case ("PATCH", "/me/settings"):
                let data = try Self.body(request)
                let body = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])
                XCTAssertEqual(body, ["currency": "USD"])
                return (200, settings)
            default: throw URLError(.badURL)
            }
        }
        let api = api()
        let actual = try await api.getSettings()
        XCTAssertEqual(actual, UserSettings(distanceUnit: "km", currency: "EUR", locale: "en-CY"))
        let values = try await api.getOptions()
        XCTAssertEqual(values, UserSettingsOptions(
            regions: [UserSettingsOption(id: "en-CY", title: "Cyprus", groupId: nil, groupTitle: nil)],
            currencies: [UserSettingsOption(id: "EUR", title: "Euro", groupId: nil, groupTitle: nil)],
            distanceUnits: [UserSettingsOption(id: "km", title: "Kilometres", groupId: "a", groupTitle: "A")]
        ))
        let updated = try await api.update(UserSettingsPatch(currency: "USD"))
        XCTAssertEqual(updated, actual)
    }

    func testMissingRequiredSettingsFieldIsTypedFailure() async throws {
        let fixture = #"{"userId":"11111111-1111-4111-8111-111111111111","currency":"EUR","locale":"en-CY"}"#
        SettingsURLProtocol.handler = { _ in (200, fixture) }
        do {
            _ = try await api().getSettings()
            XCTFail("Expected missing distanceUnit")
        } catch DecodingError.keyNotFound(let key, _) {
            XCTAssertEqual(key.stringValue, "distanceUnit")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testUnknownResponseEnumsAreTypedFailures() async throws {
        for (field, invalidValue) in [("distanceUnit", "parsec"), ("currency", "INVALID"), ("locale", "xx-XX")] {
            var fixture = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(settings.utf8)) as? [String: Any])
            fixture[field] = invalidValue
            let payload = try XCTUnwrap(String(data: JSONSerialization.data(withJSONObject: fixture), encoding: .utf8))
            SettingsURLProtocol.handler = { _ in (200, payload) }
            do {
                _ = try await api().getSettings()
                XCTFail("Expected unknown enum failure for \(field)")
            } catch DecodingError.dataCorrupted(let context) {
                XCTAssertEqual(context.codingPath.last?.stringValue, field)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testMissingRequiredOptionsArrayIsTypedFailure() async throws {
        SettingsURLProtocol.handler = { _ in (200, #"{"regions":[],"currencies":[]}"#) }
        do {
            _ = try await api().getOptions()
            XCTFail("Expected missing distanceUnits")
        } catch DecodingError.keyNotFound(let key, _) {
            XCTAssertEqual(key.stringValue, "distanceUnits")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testNullRequiredSettingsFieldIsTypedFailure() async throws {
        let fixture = #"{"userId":"11111111-1111-4111-8111-111111111111","distanceUnit":null,"currency":"EUR","locale":"en-CY"}"#
        SettingsURLProtocol.handler = { _ in (200, fixture) }
        do {
            _ = try await api().getSettings()
            XCTFail("Expected null required field failure")
        } catch DecodingError.valueNotFound(_, let context) {
            XCTAssertEqual(context.codingPath.last?.stringValue, "distanceUnit")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testScenarioRepositoryOptionsUseProductionAdapter() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SettingsURLProtocol.self]
        let client = HTTPAPIClient(
            baseURL: URL(string: "https://example.test")!,
            authToken: "scenario-token",
            session: URLSession(configuration: configuration)
        )
        let fixture = options
        SettingsURLProtocol.handler = { request in
            XCTAssertEqual(request.url?.path, "/me/settings/options")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer scenario-token")
            return (200, fixture)
        }
        let options = try await ScenarioRepository(client: client).getSettingsOptions()
        XCTAssertEqual(options.regions.first?.id, "en-CY")
        XCTAssertEqual(options.currencies.first?.id, "EUR")
        XCTAssertEqual(options.distanceUnits.first?.id, "km")
    }

    func testInvalidPatchIsRejectedBeforeSending() async throws {
        SettingsURLProtocol.handler = { _ in XCTFail("Invalid values must not be sent"); throw URLError(.badURL) }
        for patch in [UserSettingsPatch(distanceUnit: "bad"), UserSettingsPatch(currency: "bad"), UserSettingsPatch(locale: "bad")] {
            do { _ = try await api().update(patch); XCTFail("Expected validation failure") }
            catch is SettingsValidationError {} catch { XCTFail("Unexpected error: \(error)") }
        }
    }

    func testHTTPFailuresPreserveBodyAndUnauthorizedNotification() async throws {
        let notified = expectation(forNotification: .apiUnauthorized, object: nil)
        SettingsURLProtocol.handler = { _ in (401, "denied") }
        do { _ = try await api().getSettings(); XCTFail("Expected HTTP failure") }
        catch APIError.requestFailed(let status, let body) { XCTAssertEqual(status, 401); XCTAssertEqual(body, "denied") }
        catch { XCTFail("Unexpected error: \(error)") }
        await fulfillment(of: [notified], timeout: 2)
        for status in [400, 403, 422, 503] {
            let payload = #"{"error":"SETTINGS_REJECTED"}"#
            SettingsURLProtocol.handler = { _ in (status, payload) }
            do { _ = try await api().update(UserSettingsPatch(currency: "EUR")); XCTFail("Expected HTTP failure") }
            catch APIError.requestFailed(let code, let body) {
                XCTAssertEqual(code, status)
                XCTAssertEqual(body, payload)
            } catch { XCTFail("Unexpected error: \(error)") }
        }
    }

    func testTransportErrorIsUnwrapped() async throws {
        SettingsURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
        do { _ = try await api().getSettings(); XCTFail("Expected transport failure") }
        catch let error as URLError { XCTAssertEqual(error.code, .notConnectedToInternet) }
        catch { XCTFail("Unexpected error: \(error)") }
    }

    private static func body(_ request: URLRequest) throws -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open(); defer { stream.close() }
        var data = Data(), buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count < 0 { throw stream.streamError ?? URLError(.cannotDecodeContentData) }
            if count == 0 { break }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }
}

private final class SettingsURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, String))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, body) = try XCTUnwrap(Self.handler)(request)
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data(body.utf8))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}
