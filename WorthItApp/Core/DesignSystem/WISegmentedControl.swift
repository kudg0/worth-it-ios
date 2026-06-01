import SwiftUI

struct WISegmentedControl<Selection: Hashable>: View {
    let items: [(title: String, value: Selection)]
    @Binding var selection: Selection

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.value) { item in
                Button {
                    selection = item.value
                } label: {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selection == item.value ? Color(hex: 0x385283) : WorthItColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(segmentBackground(for: item.value), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .frame(height: 44)
        .background(WorthItColor.pageBackground, in: Capsule())
    }

    private func segmentBackground(for value: Selection) -> Color {
        selection == value ? WorthItColor.primaryContainer : WorthItColor.surfaceContainer
    }
}
