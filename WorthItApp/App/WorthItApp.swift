import SwiftUI

@main
struct WorthItApp: App {
    @StateObject private var authSessionStore = AuthSessionStore()

    var body: some Scene {
        WindowGroup {
            appContent
        }
    }

    @ViewBuilder
    private var appContent: some View {
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-widgetEditorQA") {
            WidgetEditorQAHarness()
        } else {
            rootView
        }
#else
        rootView
#endif
    }

    private var rootView: some View {
        RootView(
            apiBaseURL: APIEnvironment.development.baseURL,
            authSessionStore: authSessionStore
        )
    }
}
