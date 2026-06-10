import SwiftUI

struct WISegmentedControl<Selection: Hashable>: View {
    enum Layout {
        case fill
        case scroll
    }

    let items: [(title: String, value: Selection)]
    @Binding var selection: Selection
    var layout: Layout = .fill

    var body: some View {
        switch layout {
        case .fill:
            segments
                .padding(5)
                .frame(height: 44)
                .background(WorthItColor.pageBackground, in: Capsule())
        case .scroll:
            ScrollView(.horizontal, showsIndicators: false) {
                segments
                    .padding(5)
                    .background(WorthItColor.pageBackground, in: Capsule())
            }
        }
    }

    private var segments: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.value) { item in
                Button {
                    selection = item.value
                } label: {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selection == item.value ? Color(hex: 0x385283) : WorthItColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(layout == .fill ? 0.72 : 1)
                        .allowsTightening(true)
                        .padding(.horizontal, layout == .fill ? 0 : WorthItSpacing.l)
                        .frame(maxWidth: layout == .fill ? .infinity : nil)
                        .frame(minWidth: layout == .fill ? nil : 96)
                        .frame(height: 34)
                        .background(segmentBackground(for: item.value), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func segmentBackground(for value: Selection) -> Color {
        selection == value ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer
    }
}
