import AuthenticationServices
import CryptoKit
import Foundation
import Security
import UIKit

struct AppleSignInCredential: Sendable {
    let identityToken: String
    let nonce: String
    let givenName: String?
    let familyName: String?
    let email: String?
}

final class AppleSignInProvider: NSObject, ObservableObject {
    var onCredential: ((AppleSignInCredential) -> Void)?
    var onFailure: ((String) -> Void)?

    private var currentNonce: String?

    func request() {
        let nonce = Self.randomNonceString()
        currentNonce = nonce

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        // Apple stores the SHA-256 nonce in the identity token. Better Auth can compare it
        // against the raw nonce we send to the backend, so replayed tokens fail verification.
        request.nonce = Self.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

            guard status == errSecSuccess else {
                fatalError("Unable to generate Apple Sign In nonce.")
            }

            for randomByte in randomBytes where remainingLength > 0 {
                if randomByte < charset.count {
                    result.append(charset[Int(randomByte)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

extension AppleSignInProvider: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onFailure?("Apple did not return account credentials.")
            return
        }

        guard let tokenData = appleCredential.identityToken,
              let identityToken = String(data: tokenData, encoding: .utf8),
              let nonce = currentNonce else {
            onFailure?("Apple did not return an identity token.")
            return
        }

        onCredential?(
            AppleSignInCredential(
                identityToken: identityToken,
                nonce: nonce,
                givenName: appleCredential.fullName?.givenName,
                familyName: appleCredential.fullName?.familyName,
                email: appleCredential.email
            )
        )
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authorizationError = error as? ASAuthorizationError,
           authorizationError.code == .canceled {
            return
        }

        onFailure?("Apple authorization failed. Try again.")
    }
}

extension AppleSignInProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
