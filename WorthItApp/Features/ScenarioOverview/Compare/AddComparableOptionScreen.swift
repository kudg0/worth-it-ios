import SwiftUI

struct AddComparableOptionScreen: View {
    let name: Binding<String>
    let pricingModel: Binding<String>
    let currency: Binding<String>
    let baseFare: Binding<String>
    let costPerKm: Binding<String>
    let monthlyKm: Binding<Double>
    let monthlyNote: Binding<String>
    let isIncluded: Binding<Bool>
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            hero
            identityFields
            costParametersSection
            usageAssumptionsSection
            controlsSection
        }
        .padding(.bottom, 104)
    }

    private var hero: some View {
        HStack(spacing: WorthItSpacing.m) {
            Image(systemName: "car.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(width: 48, height: 48)
                .background(WorthItColor.primaryContainer.opacity(0.10), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

            VStack(alignment: .leading, spacing: 2) {
                Text("Comparable Type")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text("Taxi")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.6)
            }
        }
    }

    private var identityFields: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            WITextField(label: "Comparable Name", placeholder: "Local Taxi Service", text: name)

            VStack(spacing: WorthItSpacing.l) {
                WISelectField(
                    label: "Pricing Model",
                    options: ["Per KM + Base Fare", "Per KM Only", "Fixed Monthly", "Manual Estimate"],
                    selection: pricingModel
                )

                WISelectField(
                    label: "Currency",
                    options: ["USD ($)", "EUR (€)", "GBP (£)"],
                    selection: currency
                )
            }
        }
    }

    private var costParametersSection: some View {
        ComparableEditorIsland(title: "Cost Parameters") {
            VStack(spacing: WorthItSpacing.xxl) {
                WITextField(label: "Base Fare", placeholder: "0.00", text: baseFare, leadingText: "$", keyboardType: .decimalPad)
                WITextField(label: "Cost per KM", placeholder: "0.00", text: costPerKm, leadingText: "$", keyboardType: .decimalPad)
            }
        }
    }

    private var usageAssumptionsSection: some View {
        ComparableEditorIsland(title: "Usage Assumptions", systemName: "speedometer") {
            VStack(alignment: .leading, spacing: WorthItSpacing.xxxl) {
                monthlyKmSlider
                monthlyNoteField
            }
        }
    }

    private var monthlyKmSlider: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            HStack(alignment: .lastTextBaseline) {
                Text("Total KM per Month")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.5)
                    .textCase(.uppercase)

                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(Int(monthlyKm.wrappedValue))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(WorthItColor.primaryContainer)

                    Text("km")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WorthItColor.primaryContainer.opacity(0.70))
                }
            }

            Slider(value: monthlyKm, in: 0...1200, step: 10)
                .tint(WorthItColor.primaryContainer)
        }
    }

    private var monthlyNoteField: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.s) {
            Text("Monthly Note")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(0.55)
                .textCase(.uppercase)

            ZStack(alignment: .topLeading) {
                if monthlyNote.wrappedValue.isEmpty {
                    Text("Additional details about service fluctuations...")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WorthItColor.textTertiary.opacity(0.72))
                        .lineSpacing(3)
                        .padding(WorthItSpacing.l)
                }

                TextEditor(text: monthlyNote)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, WorthItSpacing.m)
                    .padding(.vertical, WorthItSpacing.s)
                    .frame(minHeight: 96)
            }
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.m))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.m)
                    .stroke(WorthItColor.outlineInput, lineWidth: 1)
            }
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 32) {
            HStack(alignment: .center, spacing: WorthItSpacing.l) {
                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text("Include in Comparison Analysis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text("Toggle visibility of this comparable in the primary ownership dashboard charts.")
                        .font(.system(size: 12, weight: .regular))
                        .lineSpacing(3)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Toggle("", isOn: isIncluded)
                    .labelsHidden()
                    .tint(WorthItColor.primaryContainer)
            }

            Button(role: .destructive, action: onRemove) {
                Text("Remove comparable")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFFB4AB))
                    .frame(width: 202, height: 34)
                    .background(Color(hex: 0x3A0F18), in: RoundedRectangle(cornerRadius: WorthItRadius.s))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, WorthItSpacing.xxl)
    }
}
