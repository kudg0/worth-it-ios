import SwiftUI

struct GenericMetricChartPanel: View {
    struct Model {
        let title: String
        let selectedRange: Binding<ScenarioOverviewView.MetricTrendRange>
        let selectedReadout: String?
        let selectedAxisLabel: String?
        let chart: AnyView
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack {
                Text(model.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(0.6)
                    .textCase(.uppercase)

                Spacer()

                HStack(spacing: WorthItSpacing.s) {
                    rangePill("1Y", range: .oneYear)
                    rangePill("ALL", range: .all)
                }
            }

            readout
            model.chart
        }
        .padding(WorthItSpacing.xxl)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var readout: some View {
        HStack(spacing: WorthItSpacing.s) {
            if let selectedReadout = model.selectedReadout, let selectedAxisLabel = model.selectedAxisLabel {
                Text(selectedReadout)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)

                Text(selectedAxisLabel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .textCase(.uppercase)
            } else {
                Text("No data")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 18)
    }

    private func rangePill(_ title: String, range: ScenarioOverviewView.MetricTrendRange) -> some View {
        let selected = model.selectedRange.wrappedValue == range

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                model.selectedRange.wrappedValue = range
            }
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(selected ? WorthItColor.primaryContainer : WorthItColor.textTertiary)
                .padding(.horizontal, WorthItSpacing.s)
                .frame(height: 24)
                .background(selected ? WorthItColor.surfaceContainerHigh : Color.clear, in: RoundedRectangle(cornerRadius: WorthItRadius.s))
        }
        .buttonStyle(.plain)
    }
}
