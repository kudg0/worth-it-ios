import SwiftUI

struct ScenarioAtmosphericGlow: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: 0x2C4677).opacity(0.05))
                .frame(width: 234, height: 578)
                .blur(radius: 75)
                .offset(x: -180, y: 350)
        }
        .allowsHitTesting(false)
    }
}
