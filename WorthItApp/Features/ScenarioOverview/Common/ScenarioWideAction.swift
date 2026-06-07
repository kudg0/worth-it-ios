import SwiftUI

struct ScenarioWideAction: View {
    let title: String
    let subtitle: String
    let systemName: String
    let action: () -> Void

    init(
        title: String,
        subtitle: String,
        systemName: String,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemName = systemName
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: WorthItSpacing.l) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(WorthItSpacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorthItColor.surfaceContainer, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        }
        .buttonStyle(.plain)
    }
}
