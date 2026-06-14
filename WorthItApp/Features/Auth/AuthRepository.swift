import Foundation

struct AuthRepository {
    let baseURL: URL

    func signIn(email: String, password: String) async throws -> AuthSession {
        let client = HTTPAPIClient(baseURL: baseURL)
        let response: AuthResponse = try await client.post(
            "/api/auth/sign-in/email",
            body: EmailSignInRequest(email: email, password: password)
        )

        return response.session
    }

    func signUp(name: String, email: String, password: String, region: String) async throws -> AuthSession {
        let client = HTTPAPIClient(baseURL: baseURL)
        let response: AuthResponse = try await client.post(
            "/api/auth/sign-up/email",
            body: EmailSignUpRequest(email: email, password: password, name: name)
        )

        // The account is already created once Better Auth returns a token. Defaults sync should
        // not turn a successful signup into a fake "account creation failed" state.
        try? await updateDefaults(for: region, token: response.token)
        return response.session
    }

    func signInWithApple(_ credential: AppleSignInCredential) async throws -> AuthSession {
        let client = HTTPAPIClient(baseURL: baseURL)
        let response: AuthResponse = try await client.post(
            "/api/auth/sign-in/social",
            body: AppleSocialSignInRequest(
                idToken: AppleIDTokenRequest(
                    token: credential.identityToken,
                    nonce: credential.nonce,
                    user: AppleIDTokenUserRequest(
                        name: AppleIDTokenNameRequest(
                            firstName: credential.givenName,
                            lastName: credential.familyName
                        ),
                        email: credential.email
                    )
                )
            )
        )

        return response.session
    }

    private func updateDefaults(for region: String, token: String) async throws {
        let defaults = RegionDefaults(regionName: region)
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let _: UserSettingsResponse = try await client.patch(
            "/me/settings",
            body: UpdateUserSettingsRequest(
                distanceUnit: defaults.distanceUnit,
                currency: defaults.currency,
                locale: defaults.locale
            )
        )
    }
}

private struct EmailSignInRequest: Encodable {
    let email: String
    let password: String
}

private struct EmailSignUpRequest: Encodable {
    let email: String
    let password: String
    let name: String
}

private struct AppleSocialSignInRequest: Encodable {
    let provider = "apple"
    let idToken: AppleIDTokenRequest
}

private struct AppleIDTokenRequest: Encodable {
    let token: String
    let nonce: String
    let user: AppleIDTokenUserRequest
}

private struct AppleIDTokenUserRequest: Encodable {
    let name: AppleIDTokenNameRequest
    let email: String?
}

private struct AppleIDTokenNameRequest: Encodable {
    let firstName: String?
    let lastName: String?
}

private struct AuthResponse: Decodable {
    let redirect: Bool?
    let token: String
    let user: AuthResponseUser

    var session: AuthSession {
        AuthSession(
            token: token,
            user: AuthUser(
                id: user.id,
                name: user.name,
                email: user.email
            )
        )
    }
}

private struct AuthResponseUser: Decodable {
    let id: UUID
    let name: String
    let email: String
}

private struct UpdateUserSettingsRequest: Encodable {
    let distanceUnit: String
    let currency: String
    let locale: String
}

private struct UserSettingsResponse: Decodable {
    let userId: UUID
    let distanceUnit: String
    let currency: String
    let locale: String
}

private struct RegionDefaults {
    let currency: String
    let distanceUnit: String
    let locale: String

    init(regionName: String) {
        switch regionName {
        case "United States":
            currency = "USD"
            distanceUnit = "mi"
            locale = "en-US"
        case "United Kingdom":
            currency = "GBP"
            distanceUnit = "mi"
            locale = "en-GB"
        case "Cyprus":
            currency = "EUR"
            distanceUnit = "km"
            locale = "en-CY"
        default:
            currency = "EUR"
            distanceUnit = "km"
            locale = Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
        }
    }
}
