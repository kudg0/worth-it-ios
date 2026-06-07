import SwiftUI

struct MileageHistoryList: View {
    struct Model {
        let groups: [ScenarioOverviewView.MileageMonthGroup]
        let focusedMileageId: UUID?
        let currentMonthStart: Date
        let groupTotal: (ScenarioOverviewView.MileageMonthGroup) -> String
        let onEditMileage: (UUID) -> Void
    }

    let model: Model

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 40) {
                ForEach(model.groups) { group in
                    VStack(alignment: .leading, spacing: WorthItSpacing.l) {
                        monthHeader(group)
                        rows(group)
                    }
                }
            }
            .onAppear {
                scrollToFocusedMileage(proxy)
            }
            .onChange(of: model.focusedMileageId) { _, _ in
                scrollToFocusedMileage(proxy)
            }
        }
    }

    private func rows(_ group: ScenarioOverviewView.MileageMonthGroup) -> some View {
        VStack(spacing: WorthItSpacing.l) {
            ForEach(group.items) { item in
                ScenarioMileageLogRow(item: item, onEditMileage: model.onEditMileage)
                    .id(rowId(item.id))
                    .overlay {
                        RoundedRectangle(cornerRadius: WorthItRadius.l)
                            .stroke(model.focusedMileageId == item.id ? WorthItColor.primaryContainer.opacity(0.55) : Color.clear, lineWidth: 1)
                    }
            }
        }
    }

    private func monthHeader(_ group: ScenarioOverviewView.MileageMonthGroup) -> some View {
        HStack {
            Text(Self.monthYearFormatter.string(from: group.monthStart))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)

            Spacer()

            Text(model.groupTotal(group))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WorthItColor.textTertiary)
        }
        .padding(.leading, WorthItSpacing.l)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isCurrentMonth(group.monthStart) ? WorthItColor.primaryContainer.opacity(0.32) : WorthItColor.outlineInput.opacity(0.60))
                .frame(width: 2)
        }
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        Calendar(identifier: .gregorian).isDate(date, equalTo: model.currentMonthStart, toGranularity: .month)
    }

    private func rowId(_ id: UUID) -> String {
        "mileage-history-\(id.uuidString)"
    }

    private func scrollToFocusedMileage(_ proxy: ScrollViewProxy) {
        guard let focusedMileageId = model.focusedMileageId else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.24)) {
                proxy.scrollTo(rowId(focusedMileageId), anchor: .center)
            }
        }
    }

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}
