import SwiftUI

enum WorthItColor {
    static let pageBackground = Color(hex: 0x0F131F)

    static let surfaceContainerLow = Color(hex: 0x171B28)
    static let surfaceContainer = Color(hex: 0x1B1F2C)
    static let surfaceContainerHigh = Color(hex: 0x262A37)
    static let surfaceLowest = Color(hex: 0x0A0E1A)
    static let surfaceIsland = Color(hex: 0x262A37).opacity(0.40)
    static let surfaceMetric = Color(hex: 0x0A0E1A).opacity(0.40)

    static let textPrimary = Color(hex: 0xDFE2F3)
    static let textSecondary = Color(hex: 0xC4C6D0)
    static let textTertiary = Color(hex: 0x8E909A)

    static let primaryContainer = Color(hex: 0xADC6FF)
    static let projectedBlue = Color(hex: 0x8EA3D1)
    static let accentGold = Color(hex: 0xFFDEA4)
    static let accentGoldBright = Color(hex: 0xF2C879)
    static let danger = Color(hex: 0xFF8A8A)

    static let outlineSubtle = Color.white.opacity(0.05)
    static let outlineInput = Color(hex: 0x8E909A).opacity(0.20)
    static let outlineSelected = Color(hex: 0xD8E2FF).opacity(0.22)
    static let neutralContainerSubtle = primaryContainer.opacity(0.10)
    static let neutralBorderSubtle = primaryContainer.opacity(0.20)
}

enum WorthItSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 28
    static let xxxxl: CGFloat = 32
}

enum WorthItRadius {
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}

enum WorthItTypography {
    static let display = Font.system(size: 34, weight: .bold)
    static let headline = Font.system(size: 28, weight: .bold)
    static let title = Font.system(size: 20, weight: .bold)
    static let cardTitle = Font.system(size: 18, weight: .bold)
    static let body = Font.system(size: 16, weight: .regular)
    static let bodySmall = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let overline = Font.system(size: 10, weight: .bold)
}

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
