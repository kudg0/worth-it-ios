import SwiftUI

struct CostPerKmDetailScreen: View {
    struct Model {
        let hero: CostPerKmDetailHero.Model
        let efficiencyComparison: CostPerKmEfficiencyCard.Model
        let summary: CostPerKmSummaryGrid.Model
        let showsEmptyNotice: Bool
        let emptyNoticeUnit: String
        let formula: CostPerKmFormulaCard.Model
        let timeline: CostPerKmSourceTimeline.Model
        let info: CostPerKmInfoPanel.Model
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
            CostPerKmDetailHero(model: model.hero)
            CostPerKmEfficiencyCard(model: model.efficiencyComparison) {}
            CostPerKmSummaryGrid(model: model.summary)

            if model.showsEmptyNotice {
                CostPerKmCurrentMonthEmptyNotice(mileageUnit: model.emptyNoticeUnit)
            }

            CostPerKmFormulaCard(model: model.formula)
            CostPerKmSourceTimeline(model: model.timeline)
            CostPerKmInfoPanel(model: model.info)

            Text("Only logged expenses and mileage records with valid dates are included.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WorthItColor.textTertiary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
