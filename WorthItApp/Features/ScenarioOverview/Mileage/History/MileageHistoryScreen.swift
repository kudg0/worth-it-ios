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
        let onRetry: () -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            MileageHistoryHero(model: model.hero)

            if let usageEventsError = model.hero.usageEventsError {
                ScenarioLoadErrorCard(
                    title: i18n.t("Mileage unavailable"),
                    message: usageEventsError,
                    onRetry: model.onRetry
                )
            } else if model.groups.isEmpty {
                WITipInfo(
                    title: i18n.t("No mileage found"),
                    bodyText: i18n.t("No mileage entries have been logged yet.")
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
