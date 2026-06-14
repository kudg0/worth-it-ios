import Foundation
import Security

struct AuthSession: Codable, Equatable {
    let token: String
    let user: AuthUser
}

struct AuthUser: Codable, Equatable {
    let id: UUID
    let name: String
    let email: String
}

@MainActor
final class AuthSessionStore: ObservableObject {
    @Published private(set) var session: AuthSession?

    private let keychain = AuthSessionKeychain()

    init() {
        session = try? keychain.load()
    }

    var isAuthenticated: Bool {
        session?.token.isEmpty == false
    }

    func replace(with session: AuthSession) {
        self.session = session
        try? keychain.save(session)
    }

    func clear() {
        session = nil
        try? keychain.delete()
    }
}

private struct AuthSessionKeychain {
    private let service = "com.worthit.auth"
    private let account = "session"

    func load() throws -> AuthSession? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess, let data = result as? Data else { return nil }

        return try JSONDecoder.api.decode(AuthSession.self, from: data)
    }

    func save(_ session: AuthSession) throws {
        try delete()

        var item = baseQuery
        item[kSecValueData as String] = try JSONEncoder.api.encode(session)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        SecItemAdd(item as CFDictionary, nil)
    }

    func delete() throws {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
