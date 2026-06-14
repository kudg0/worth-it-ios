import SwiftUI

struct RootView: View {
    let apiBaseURL: URL
    @ObservedObject var authSessionStore: AuthSessionStore
    @AppStorage("root.lastOpenScenarioId") private var lastOpenScenarioId = ""
    @State private var path: [Route] = []
    @State private var scenarioListRefreshToken = 0
    @State private var didAttemptLastScenarioRestore = false

    var body: some View {
        Group {
            if authSessionStore.isAuthenticated {
                appShell
            } else {
                AuthFlowView(
                    authRepository: AuthRepository(baseURL: apiBaseURL),
                    authSessionStore: authSessionStore
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .apiUnauthorized)) { _ in
            handleUnauthorized()
        }
    }

    private var appShell: some View {
        NavigationStack(path: $path) {
            ScenariosListView(
                repository: repository,
                refreshToken: scenarioListRefreshToken,
                profileUser: authSessionStore.session?.user,
                onCreateScenario: {
                    path.append(.createScenario)
                },
                onOpenScenario: { scenario in
                    openScenario(scenario)
                },
                onScenariosLoaded: { scenarios in
                    restoreLastOpenScenarioIfNeeded(from: scenarios)
                },
                onProfileUpdated: { draft in
                    let token = authSessionStore.session?.token ?? ""
                    let user = try await AuthRepository(baseURL: apiBaseURL).updateProfile(draft, token: token)
                    authSessionStore.updateUser(user)
                    return user
                },
                onLoadUserSettings: {
                    let token = authSessionStore.session?.token ?? ""
                    return try await AuthRepository(baseURL: apiBaseURL).getSettings(token: token)
                },
                onLoadUserSettingsOptions: {
                    let token = authSessionStore.session?.token ?? ""
                    return try await AuthRepository(baseURL: apiBaseURL).getSettingsOptions(token: token)
                },
                onUpdateUserSettings: { patch in
                    let token = authSessionStore.session?.token ?? ""
                    return try await AuthRepository(baseURL: apiBaseURL).updateSettings(patch, token: token)
                },
                onLogout: {
                    handleLogout()
                }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .createScenario:
                    CreateScenarioFlowView(
                        repository: repository,
                        onScenarioCreated: { _ in
                            scenarioListRefreshToken += 1
                        },
                        onScenarioUpdated: { _ in },
                        onOpenOverview: { scenario in
                            openScenario(scenario, replacingStack: true)
                        }
                    )
                case .scenarioOverview(let scenario):
                    ScenarioOverviewView(
                        repository: repository,
                        scenario: scenario,
                        onScenarioChanged: { _ in
                            scenarioListRefreshToken += 1
                        },
                        onScenarioDeleted: {
                            clearLastOpenScenarioIfNeeded(scenario)
                            scenarioListRefreshToken += 1
                        },
                        onEditScenario: { scenario in
                            path.append(.editScenario(scenario))
                        },
                        onExitScenario: {
                            path = []
                        }
                    )
                case .editScenario(let scenario):
                    CreateScenarioFlowView(
                        repository: repository,
                        editingScenario: scenario,
                        onScenarioCreated: { _ in },
                        onScenarioUpdated: { _ in
                            scenarioListRefreshToken += 1
                        },
                        onOpenOverview: { scenario in
                            openScenario(scenario, replacingStack: true)
                        }
                    )
                }
            }
        }
        .tint(WorthItColor.primaryContainer)
        .background(WorthItColor.pageBackground)
    }

    private var repository: ScenarioRepository {
        ScenarioRepository(
            client: HTTPAPIClient(
                baseURL: apiBaseURL,
                authToken: authSessionStore.session?.token
            )
        )
    }

    @MainActor
    private func handleUnauthorized() {
        authSessionStore.clear()
        path = []
        didAttemptLastScenarioRestore = false
    }

    @MainActor
    private func handleLogout() {
        authSessionStore.clear()
        path = []
        didAttemptLastScenarioRestore = false
    }

    private func openScenario(_ scenario: ScenarioListItem, replacingStack: Bool = false) {
        lastOpenScenarioId = scenario.id.uuidString

        if replacingStack {
            path = [.scenarioOverview(scenario)]
        } else {
            path.append(.scenarioOverview(scenario))
        }
    }

    private func restoreLastOpenScenarioIfNeeded(from scenarios: [ScenarioListItem]) {
        guard !didAttemptLastScenarioRestore else { return }
        didAttemptLastScenarioRestore = true

        guard path.isEmpty, let id = UUID(uuidString: lastOpenScenarioId) else { return }

        guard let scenario = scenarios.first(where: { $0.id == id }) else {
            lastOpenScenarioId = ""
            return
        }

        path = [.scenarioOverview(scenario)]
    }

    private func clearLastOpenScenarioIfNeeded(_ scenario: ScenarioListItem) {
        if lastOpenScenarioId == scenario.id.uuidString {
            lastOpenScenarioId = ""
        }
    }
}

private enum Route: Hashable {
    case createScenario
    case editScenario(ScenarioListItem)
    case scenarioOverview(ScenarioListItem)
}
