import SwiftUI

struct WITopSpotlight: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                WorthItColor.primaryContainer.opacity(0.38),
                                Color(hex: 0x365FAD).opacity(0.20),
                                WorthItColor.pageBackground.opacity(0),
                            ],
                            center: UnitPoint(x: 0.70, y: 0.20),
                            startRadius: 6,
                            endRadius: 260
                        )
                    )
                    .frame(width: 560, height: 360)
                    .blur(radius: 24)
                    .offset(x: 116, y: -96)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: 0x2DD4BF).opacity(0.18),
                                Color(hex: 0x2DD4BF).opacity(0.08),
                                WorthItColor.pageBackground.opacity(0),
                            ],
                            center: UnitPoint(x: 0.72, y: 0.22),
                            startRadius: 0,
                            endRadius: 220
                        )
                    )
                    .frame(width: 430, height: 310)
                    .blur(radius: 34)
                    .offset(x: 214, y: -8)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
