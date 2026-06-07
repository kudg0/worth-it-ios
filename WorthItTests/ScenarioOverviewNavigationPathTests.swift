import XCTest
@testable import WorthIt

final class ScenarioOverviewNavigationPathTests: XCTestCase {
    func testPushPreservesExistingPathForNestedEditingFlow() {
        let openedHistory = ScenarioOverviewNavigationPath.pushed(["metricDetail"], tab: "expenseHistory")
        let openedEditor = ScenarioOverviewNavigationPath.pushed(openedHistory, tab: "expenseHistory")

        XCTAssertEqual(openedEditor, ["metricDetail", "expenseHistory"])
    }

    func testPopReturnsPreviousTabAndKeepsParentPath() {
        let firstPop = ScenarioOverviewNavigationPath.popped(["metricDetail", "expenseHistory"])
        XCTAssertEqual(firstPop.tab, "expenseHistory")
        XCTAssertEqual(firstPop.path, ["metricDetail"])

        let secondPop = ScenarioOverviewNavigationPath.popped(firstPop.path)
        XCTAssertEqual(secondPop.tab, "metricDetail")
        XCTAssertEqual(secondPop.path, [])
    }

    func testPushDoesNotDuplicateCurrentTopTab() {
        let path = ScenarioOverviewNavigationPath.pushed(["metricDetail"], tab: "metricDetail")

        XCTAssertEqual(path, ["metricDetail"])
    }
}
