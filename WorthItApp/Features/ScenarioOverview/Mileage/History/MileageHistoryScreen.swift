import SwiftUI

struct MileageHistoryScreen: View {
    struct Model {
        let hero: MileageHistoryHero.Model
        let groups: [ScenarioOverviewView.MileageMonthGroup]
        let focusedMileageId: UUID?
        let currentMonthStart: Date
        let groupTotal: (ScenarioOverviewView.MileageMonthGroup) -> String
        let onOpenMileage: (UUID) -> Void
        let onEditMileage: (UUID) -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            MileageHistoryHero(model: model.hero)

            if let usageEventsError = model.hero.usageEventsError {
                WITipInfo(title: "Mileage unavailable", bodyText: usageEventsError)
            } else if model.groups.isEmpty {
                WITipInfo(
                    title: "No mileage found",
                    bodyText: "No mileage entries have been logged yet."
                )
            } else {
                MileageHistoryList(model: listModel)
            }
        }
    }

    private var listModel: MileageHistoryList.Model {
        MileageHistoryList.Model(
            groups: model.groups,
            focusedMileageId: model.focusedMileageId,
            currentMonthStart: model.currentMonthStart,
            groupTotal: model.groupTotal,
            onOpenMileage: model.onOpenMileage,
            onEditMileage: model.onEditMileage
        )
    }
}
