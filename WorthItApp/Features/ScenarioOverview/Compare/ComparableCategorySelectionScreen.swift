import SwiftUI

struct ComparableCategorySelectionScreen: View {
    let selectedCategory: AlternativeCategory
    let onSelectCategory: (AlternativeCategory) -> Void

    var body: some View {
        presetGrid
        .padding(.bottom, 104)
    }

    private var presetGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: WorthItSpacing.m) {
            ForEach(Self.categories) { category in
                ComparableCategoryTile(
                    category: category,
                    isSelected: selectedCategory == category
                ) {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        onSelectCategory(category)
                    }
                }
            }
        }
    }

    private static let categories: [AlternativeCategory] = [
        .taxi,
        .carSharing,
        .rentalCar,
        .publicTransport,
        .electricScooter,
        .motorcycle,
        .bicycle,
        .custom,
    ]
}

private struct ComparableCategoryTile: View {
    let category: AlternativeCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: WorthItSpacing.s) {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: category.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.primaryContainer)
                        .frame(width: 30, height: 30)
                        .background(
                            isSelected ? WorthItColor.primaryContainer : WorthItColor.primaryContainer.opacity(0.10),
                            in: RoundedRectangle(cornerRadius: WorthItRadius.s)
                        )
                }

                Text(category.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? Color(hex: 0x385283) : WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(category.categoryDescription)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isSelected ? Color(hex: 0x385283).opacity(0.72) : WorthItColor.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(WorthItSpacing.m)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(isSelected ? WorthItColor.primaryContainer : WorthItColor.surfaceLowest, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                RoundedRectangle(cornerRadius: WorthItRadius.l)
                    .stroke(isSelected ? Color.clear : WorthItColor.outlineInput, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
