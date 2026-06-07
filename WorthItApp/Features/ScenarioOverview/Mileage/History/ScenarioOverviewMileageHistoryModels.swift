import SwiftUI

extension ScenarioOverviewView {
    var mileageHistoryScreenModel: MileageHistoryScreen.Model {
        MileageHistoryScreen.Model(
            hero: mileageHistoryHeroModel,
            groups: mileageMonthGroups,
            focusedMileageId: focusedMileageId,
            currentMonthStart: currentMonthStart,
            groupTotal: mileageMonthTotalText,
            onEditMileage: beginEditingMileage
        )
    }

    var mileageHistoryHeroModel: MileageHistoryHero.Model {
        MileageHistoryHero.Model(
            title: selectedMileageHistoryBarTitle,
            total: selectedMileageHistoryBarTotalDisplay,
            delta: selectedMileageHistoryBarDeltaPercentDisplay,
            iconName: selectedMileageHistoryBarIconName,
            subtitle: selectedMileageHistoryBarSubtitle,
            isFiltered: isMileageHistoryMonthFiltered,
            usageEventsError: usageEventsError,
            miniBars: AnyView(mileageHistoryMiniBars),
            onReset: resetMileageHistoryMonthSelection
        )
    }
}
