import SwiftUI

extension ScenarioOverviewView {
    func logExpensePickerSheet(_ picker: LogExpensePicker) -> some View {
        NavigationStack {
            ZStack {
                WorthItColor.pageBackground.ignoresSafeArea()

                Group {
                    switch picker {
                    case .date:
                        DatePicker(
                            "Transaction Date",
                            selection: $expenseDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(WorthItSpacing.xl)
                    case .time:
                        DatePicker(
                            "Time",
                            selection: $expenseDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding(WorthItSpacing.xl)
                    }
                }
                .tint(WorthItColor.primaryContainer)
            }
            .navigationTitle(picker == .date ? "Transaction Date" : "Time")
            .toolbarBackground(WorthItColor.pageBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        activeLogExpensePicker = nil
                    }
                    .foregroundStyle(WorthItColor.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        activeLogExpensePicker = nil
                    }
                    .foregroundStyle(WorthItColor.primaryContainer)
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .preferredColorScheme(.dark)
    }
}
