import SwiftUI

struct ScenarioLoadErrorCard: View {
    let title: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack(alignment: .top, spacing: WorthItSpacing.l) {
                Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 44, height: 44)
                    .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))

                VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(message)
                        .font(WorthItTypography.caption)
                        .foregroundStyle(WorthItColor.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(action: onRetry) {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                    Text(i18n.t("Retry"))
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(WorthItColor.primaryContainer)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(WorthItColor.primaryContainer.opacity(0.08), in: RoundedRectangle(cornerRadius: WorthItRadius.m))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.m)
                        .stroke(WorthItColor.primaryContainer.opacity(0.22), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(WorthItSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}
