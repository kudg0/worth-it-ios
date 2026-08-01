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

final class OverviewMetricEditorInteractionTests: XCTestCase {
    func testLongPressEntryBlocksMetricNavigation() {
        var state = OverviewMetricEditorInteractionState()

        state.enterEditing()

        XCTAssertTrue(state.isEditing)
        XCTAssertFalse(state.canOpenMetric, "A long press must enter edit mode without opening the metric")
    }

    func testDoneConsumesFinishingTouchBeforeMetricCanOpen() {
        var state = OverviewMetricEditorInteractionState()

        state.enterEditing()
        XCTAssertFalse(state.canOpenMetric)

        state.finishEditing()
        XCTAssertFalse(state.isEditing)
        XCTAssertFalse(state.canOpenMetric, "Done touch must not open the metric underneath")

        state.releaseFinishingTouch()
        XCTAssertTrue(state.canOpenMetric)
    }

    func testInteractionTargetsMeetWorthItStandard() {
        XCTAssertGreaterThanOrEqual(
            WorthItInteraction.iconButtonTarget,
            WorthItInteraction.minimumTouchTarget
        )
        XCTAssertEqual(WorthItInteraction.minimumTouchTarget, 44)
        XCTAssertEqual(WorthItInteraction.iconButtonTarget, 48)
    }
}

final class ScenarioOverviewTransitionDirectionTests: XCTestCase {
    func testMetricDetailAndOverviewUseOppositeDirections() {
        XCTAssertEqual(
            ScenarioOverviewContentTransitionDirection.metricDetailPresentation,
            .backward
        )
        XCTAssertEqual(
            ScenarioOverviewContentTransitionDirection.metricDetailDismissal,
            .forward
        )
    }
}
