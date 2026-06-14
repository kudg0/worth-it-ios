import Foundation

struct APIEnvironment: Sendable {
    let baseURL: URL

    static let development = APIEnvironment(
        baseURL: URL(string: "http://127.0.0.1:3000")!
    )
}
