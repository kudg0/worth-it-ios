import Foundation

enum APIError: Error {
    case invalidResponse
    case requestFailed(statusCode: Int, body: String)
}

struct HTTPAPIClient: Sendable {
    let baseURL: URL
    var authToken: String?
    var session: URLSession = .shared

    func get<Response: Decodable>(_ path: String) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "GET"
        return try await send(request)
    }

    func get<Response: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem]
    ) async throws -> Response {
        let url = baseURL.appending(path: path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }

        components.queryItems = queryItems

        guard let requestURL = components.url else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        return try await send(request)
    }

    func post<Request: Encodable, Response: Decodable>(
        _ path: String,
        body: Request
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder.api.encode(body)
        return try await send(request)
    }

    func patch<Request: Encodable, Response: Decodable>(
        _ path: String,
        body: Request
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try JSONEncoder.api.encode(body)
        return try await send(request)
    }

    func delete(_ path: String) async throws {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "DELETE"
        try await sendEmpty(request)
    }

    func upload(data: Data, to url: URL, headers: [String: String]) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (responseData, response) = try await session.upload(for: request, from: data)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: responseData, encoding: .utf8) ?? ""
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, body: body)
        }
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: authorized(request))
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            await notifyUnauthorizedIfNeeded(statusCode: httpResponse.statusCode)
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, body: body)
        }

        return try JSONDecoder.api.decode(Response.self, from: data)
    }

    private func sendEmpty(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: authorized(request))
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            await notifyUnauthorizedIfNeeded(statusCode: httpResponse.statusCode)
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, body: body)
        }
    }

    private func authorized(_ request: URLRequest) -> URLRequest {
        var request = request

        // Better Auth validates trusted origins even for native clients. URLSession does not
        // provide an Origin header by default, so we send the API origin explicitly.
        if request.value(forHTTPHeaderField: "origin") == nil {
            request.setValue(baseURL.originHeaderValue, forHTTPHeaderField: "origin")
        }

        guard let authToken, !authToken.isEmpty else { return request }

        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "authorization")
        return request
    }

    private func notifyUnauthorizedIfNeeded(statusCode: Int) async {
        guard statusCode == 401 else { return }

        await MainActor.run {
            NotificationCenter.default.post(name: .apiUnauthorized, object: nil)
        }
    }
}

private extension URL {
    var originHeaderValue: String {
        guard let scheme, let host else {
            return absoluteString
        }

        var origin = "\(scheme)://\(host)"
        if let port {
            origin += ":\(port)"
        }

        return origin
    }
}

extension Notification.Name {
    static let apiUnauthorized = Notification.Name("WorthItAPIUnauthorized")
}

extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = DateFormatter.apiISO8601WithFractionalSeconds.date(from: value) {
                return date
            }

            if let date = DateFormatter.apiISO8601.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO 8601 date: \(value)"
            )
        }
        return decoder
    }()
}

extension JSONEncoder {
    static let api: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

private extension DateFormatter {
    static let apiISO8601WithFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    static let apiISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}
