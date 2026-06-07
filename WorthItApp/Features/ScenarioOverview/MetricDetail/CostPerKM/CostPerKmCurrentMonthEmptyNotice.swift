import SwiftUI

struct CostPerKmCurrentMonthEmptyNotice: View {
    let mileageUnit: String

    var body: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.m) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 28, height: 28)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.s))

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text("No current month inputs yet")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text("No expenses or mileage entries have been logged this month, so cost per \(mileageUnit) is shown as the average from the previous 3 months.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(WorthItSpacing.l)
        .background(WorthItColor.primaryContainer.opacity(0.07), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.primaryContainer.opacity(0.14), lineWidth: 1)
        }
    }
}
