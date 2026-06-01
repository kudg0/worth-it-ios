import SwiftUI

@main
struct WorthItApp: App {
    private let scenarioRepository = ScenarioRepository(
        client: HTTPAPIClient(baseURL: APIEnvironment.development.baseURL)
    )

    var body: some Scene {
        WindowGroup {
            RootView(repository: scenarioRepository)
        }
    }
}
