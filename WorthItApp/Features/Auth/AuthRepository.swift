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

    func updateProfile(_ draft: EditProfileDraft, token: String) async throws -> AuthUser {
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let response: UserProfileResponse = try await client.patch(
            "/me/profile",
            body: UpdateUserProfileRequest(
                name: draft.name,
                email: draft.email,
                image: draft.image
            )
        )

        return response.user
    }

    func uploadProfileImage(_ draft: ProfileImageUploadDraft, token: String) async throws -> String {
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let intent: ProfileImageUploadIntentResponse = try await client.post(
            "/me/profile/avatar-upload-intents",
            body: CreateProfileImageUploadIntentRequest(
                fileName: draft.fileName,
                contentType: draft.contentType,
                byteSize: draft.data.count,
                checksumSha256: nil
            )
        )

        if intent.uploadUrl.scheme != "local" {
            try await client.upload(data: draft.data, to: intent.uploadUrl, headers: intent.uploadHeaders)
        }

        return intent.imageUrl
    }

    func getSettings(token: String) async throws -> UserSettings {
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let response: UserSettingsResponse = try await client.get("/me/settings")
        return response.settings
    }

    func getSettingsOptions(token: String) async throws -> UserSettingsOptions {
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let response: UserSettingsOptionsResponse = try await client.get("/me/settings/options")
        return response.options
    }

    func updateSettings(_ patch: UserSettingsPatch, token: String) async throws -> UserSettings {
        let client = HTTPAPIClient(baseURL: baseURL, authToken: token)
        let response: UserSettingsResponse = try await client.patch(
            "/me/settings",
            body: UpdateUserSettingsRequest(
                distanceUnit: patch.distanceUnit,
                currency: patch.currency,
                locale: patch.locale
            )
        )

        return response.settings
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

struct UserSettings: Equatable {
    let distanceUnit: String
    let currency: String
    let locale: String
}

struct UserSettingsPatch {
    var distanceUnit: String? = nil
    var currency: String? = nil
    var locale: String? = nil
}

struct ProfileImageUploadDraft {
    let data: Data
    let fileName: String
    let contentType: String
}

struct UserSettingsOption: Identifiable, Equatable {
    let id: String
    let title: String
    let groupId: String?
    let groupTitle: String?
}

struct UserSettingsOptions: Equatable {
    let regions: [UserSettingsOption]
    let currencies: [UserSettingsOption]
    let distanceUnits: [UserSettingsOption]
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
                email: user.email,
                image: user.image
            )
        )
    }
}

private struct AuthResponseUser: Decodable {
    let id: UUID
    let name: String
    let email: String
    let image: String?
}

private struct UpdateUserProfileRequest: Encodable {
    let name: String
    let email: String
    let image: String?
}

private struct CreateProfileImageUploadIntentRequest: Encodable {
    let fileName: String
    let contentType: String
    let byteSize: Int
    let checksumSha256: String?
}

private struct ProfileImageUploadIntentResponse: Decodable {
    let imageUrl: String
    let uploadUrl: URL
    let uploadHeaders: [String: String]
    let expiresInSeconds: Int
}

private struct UserProfileResponse: Decodable {
    let id: UUID
    let name: String
    let email: String
    let image: String?
    let emailVerified: Bool

    var user: AuthUser {
        AuthUser(
            id: id,
            name: name,
            email: email,
            image: image
        )
    }
}

private struct UpdateUserSettingsRequest: Encodable {
    let distanceUnit: String?
    let currency: String?
    let locale: String?
}

private struct UserSettingsResponse: Decodable {
    let userId: UUID
    let distanceUnit: String
    let currency: String
    let locale: String

    var settings: UserSettings {
        UserSettings(distanceUnit: distanceUnit, currency: currency, locale: locale)
    }
}

private struct UserSettingsOptionsResponse: Decodable {
    let regions: [UserSettingsOptionResponse]
    let currencies: [UserSettingsOptionResponse]
    let distanceUnits: [UserSettingsOptionResponse]

    var options: UserSettingsOptions {
        UserSettingsOptions(
            regions: regions.map(\.option),
            currencies: currencies.map(\.option),
            distanceUnits: distanceUnits.map(\.option)
        )
    }
}

private struct UserSettingsOptionResponse: Decodable {
    let id: String
    let label: String
    let groupId: String?
    let groupLabel: String?

    var option: UserSettingsOption {
        UserSettingsOption(id: id, title: label, groupId: groupId, groupTitle: groupLabel)
    }
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
