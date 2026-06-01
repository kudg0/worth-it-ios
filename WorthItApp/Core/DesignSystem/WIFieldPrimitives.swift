import SwiftUI

func fieldLabel(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(WorthItColor.textSecondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
}

func fieldError(_ text: String) -> some View {
    Text(text)
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(Color(hex: 0xFCA5A5))
        .fixedSize(horizontal: false, vertical: true)
}
