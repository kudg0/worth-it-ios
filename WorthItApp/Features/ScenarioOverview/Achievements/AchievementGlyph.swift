import SwiftUI

enum AchievementBadgeState {
    case locked
    case inProgress
    case earned
    case maxTier
}

enum AchievementGlyph {
    static func assetName(for medalGlyph: String) -> String {
        let slug: String
        switch medalGlyph {
        case "cost-ring", "multi-segment-cost-ring":
            slug = "cost-segment-ring"
        case "market-tick":
            slug = "value-dial"
        default:
            slug = medalGlyph
        }

        return switch slug {
        case "ignition-ring",
             "car-ring",
             "chassis-check",
             "odometer-tick",
             "road-arc",
             "fuel-drop",
             "water-line",
             "wrench-ring",
             "caliper-mark",
             "shield-ring",
             "parking-pin",
             "toll-gate",
             "tire-tread",
             "plate-stamp",
             "cost-segment-ring",
             "scan-line",
             "monthly-close",
             "key-handoff",
             "goodbye-old-friend",
             "comparison-ring",
             "alternative-challenger",
             "regional-edge",
             "regional-record",
             "compression-bars",
             "stable-operator",
             "value-dial",
             "depreciation-aware",
             "friends-network",
             "trusted-invite":
            "achievement-glyph-\(slug)"
        default:
            "achievement-glyph-car-ring"
        }
    }
}

struct AchievementBadgeImage: View {
    let medalGlyph: String
    let state: AchievementBadgeState
    var size: CGFloat

    var body: some View {
        ZStack {
            if state == .maxTier {
                Circle()
                    .stroke(stateColor.opacity(0.30), style: StrokeStyle(lineWidth: 1, dash: [1.4, 2.8]))
                    .shadow(color: WorthItColor.primaryContainer.opacity(0.65), radius: 4)
            } else {
                Circle()
                    .stroke(stateColor.opacity(dashedRingOpacity), style: StrokeStyle(lineWidth: 1, dash: [1.4, 2.8]))
            }

            Circle()
                .stroke(stateColor.opacity(innerRingOpacity), lineWidth: 1.2)
                .frame(width: size * 0.76, height: size * 0.76)

            Image(AchievementGlyph.assetName(for: medalGlyph))
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(stateColor)
                .frame(width: size * 0.34, height: size * 0.34)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var stateColor: Color {
        switch state {
        case .locked:
            Color(red: 0.19, green: 0.20, blue: 0.26)
        case .inProgress:
            WorthItColor.primaryContainer
        case .earned, .maxTier:
            WorthItColor.accentGold
        }
    }

    private var dashedRingOpacity: Double {
        switch state {
        case .locked: 0.42
        case .inProgress: 0.70
        case .earned, .maxTier: 0.55
        }
    }

    private var innerRingOpacity: Double {
        switch state {
        case .locked: 0.42
        case .inProgress: 0.95
        case .earned, .maxTier: 0.95
        }
    }
}
