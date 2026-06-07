import SwiftUI

struct LogExpenseAmountField: View {
    let currencySymbol: String
    let amount: Binding<String>
    let sanitizeAmount: (String) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Total Amount")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(currencySymbol)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(WorthItColor.textPrimary)

                ZStack(alignment: .leading) {
                    if amount.wrappedValue.isEmpty {
                        Text("0.00")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(WorthItColor.textPrimary)
                    }

                    TextField("", text: amount)
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)
                        .keyboardType(.decimalPad)
                        .onChange(of: amount.wrappedValue) { _, newValue in
                            amount.wrappedValue = sanitizeAmount(newValue)
                        }
                }
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
            .background(WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }
}
