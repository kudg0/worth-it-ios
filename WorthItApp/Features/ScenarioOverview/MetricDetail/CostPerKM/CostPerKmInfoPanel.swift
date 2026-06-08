import SwiftUI

struct CostPerKmInfoPanel: View {
    struct Model {
        let usesEffectiveOwnership: Bool
        let hasActiveFinancing: Bool
        let includesFinancing: Binding<Bool>
        let mileageUnit: String
    }

    let model: Model

    var body: some View {
        if model.usesEffectiveOwnership {
            infoRow(
                title: "Vehicle value included",
                body: "Effective cost uses depreciation and accrued interest. Loan principal is excluded so vehicle value is not counted twice.",
                systemName: "car.fill",
                color: WorthItColor.primaryContainer
            )
        } else {
            infoRow(
                title: "Month-only cost",
                body: "This metric uses logged costs and tracked distance inside the selected month only.",
                systemName: "calendar",
                color: Color(hex: 0x2DD4BF)
            )
        }
    }

    private var financingToggle: some View {
        HStack(spacing: WorthItSpacing.l) {
            Image(systemName: model.includesFinancing.wrappedValue ? "creditcard.fill" : "creditcard")
                .font(.system(size: 18, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 44, height: 44)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("Include loan / lease")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("Add financing payments into cost per \(model.mileageUnit). Turn off to see operating costs only.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Toggle("", isOn: model.includesFinancing)
                .labelsHidden()
                .tint(WorthItColor.primaryContainer)
        }
        .padding(WorthItSpacing.xl)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private func infoRow(title: String, body: String, systemName: String, color: Color) -> some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(body)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }
}
