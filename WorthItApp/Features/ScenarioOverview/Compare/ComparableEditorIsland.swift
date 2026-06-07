import SwiftUI

struct ComparableEditorIsland<Content: View>: View {
    let title: String
    let systemName: String?
    let content: Content

    init(
        title: String,
        systemName: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemName = systemName
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xxl) {
            HStack(spacing: WorthItSpacing.s) {
                if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorthItColor.primaryContainer)
                }

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .tracking(-0.45)
            }

            content
        }
        .padding(WorthItSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceIsland, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
    }
}
