import Foundation

struct APIEnvironment: Sendable {
    let baseURL: URL

    static let development = APIEnvironment(
        baseURL: URL(string: "http://localhost:3000")!
    )
}
