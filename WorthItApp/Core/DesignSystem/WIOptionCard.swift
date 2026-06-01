import SwiftUI

struct WIOptionCard: View {
    enum State {
        case normal
        case selected
        case disabled
    }

    let title: String
    let subtitle: String
    var systemIcon: String = "creditcard.fill"
    var state: State = .normal
    var badge: String?

    var body: some View {
        HStack(alignment: .top, spacing: WorthItSpacing.xl) {
            icon

            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                HStack(alignment: .top, spacing: WorthItSpacing.m) {
                    Text(title)
                        .font(WorthItTypography.title)
                        .foregroundStyle(WorthItColor.textPrimary)
                        .lineLimit(2)

                    Spacer(minLength: WorthItSpacing.s)

                    if let badge {
                        badgeView(badge)
                    }
                }

                Text(subtitle)
                    .font(WorthItTypography.bodySmall)
                    .lineSpacing(3)
                    .foregroundStyle(WorthItColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(WorthItSpacing.xl)
        .padding(.trailing, selectedIndicatorSpace)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(borderColor, lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            if state == .selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .padding(.top, WorthItSpacing.xl)
                    .padding(.trailing, WorthItSpacing.xl)
            }
        }
        .opacity(state == .disabled ? 0.5 : 1)
    }

    private var selectedIndicatorSpace: CGFloat {
        30
    }

    private var icon: some View {
        Image(systemName: systemIcon)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(WorthItColor.primaryContainer)
            .frame(width: 56, height: 56)
            .background(iconBackground, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
    }

    private var iconBackground: Color {
        state == .disabled ? WorthItColor.surfaceContainer : WorthItColor.surfaceContainerHigh
    }

    private var borderColor: Color {
        state == .selected ? WorthItColor.outlineSelected : WorthItColor.outlineSubtle
    }

    private func badgeView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(WorthItColor.textSecondary)
            .tracking(0.45)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6).stroke(WorthItColor.outlineSubtle, lineWidth: 1)
            }
    }
}
