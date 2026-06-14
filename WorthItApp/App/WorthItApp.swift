import SwiftUI

@main
struct WorthItApp: App {
    @StateObject private var authSessionStore = AuthSessionStore()

    var body: some Scene {
        WindowGroup {
            RootView(
                apiBaseURL: APIEnvironment.development.baseURL,
                authSessionStore: authSessionStore
            )
        }
    }
}
