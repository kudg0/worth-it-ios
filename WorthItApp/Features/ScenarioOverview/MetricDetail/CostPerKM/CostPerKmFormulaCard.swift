import SwiftUI

struct CostPerKmFormulaCard: View {
    struct Model {
        let mileageUnit: String
        let value: String
        let prefix: String
        let currencySymbol: String
        let cost: String
        let distance: String
        let formulaText: String?
    }

    let model: Model

    var body: some View {
        HStack(spacing: WorthItSpacing.s) {
            Image(systemName: "sum")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text("Cost/\(model.mileageUnit.uppercased())")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(WorthItColor.primaryContainer)

            Text(model.formulaText ?? "\(model.value) = \(model.prefix)\(model.currencySymbol)\(model.cost) costs ÷ \(model.distance) \(model.mileageUnit)")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(WorthItColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .padding(.horizontal, WorthItSpacing.l)
        .padding(.vertical, WorthItSpacing.m)
        .frame(maxWidth: .infinity)
        .background(WorthItColor.pageBackground, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.m)
                .stroke(WorthItColor.surfaceContainerHigh, lineWidth: 1)
        }
    }
}
