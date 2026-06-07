import SwiftUI

struct ScenarioMetricPill: View {
    let text: String
    let iconName: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 9, weight: .bold))

            Text(text)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.25)
        }
        .foregroundStyle(color.opacity(0.85))
        .padding(.horizontal, 13)
        .padding(.vertical, 5)
        .background(color.opacity(0.10), in: Capsule())
        .overlay {
            Capsule().stroke(color.opacity(0.20), lineWidth: 1)
        }
    }
}
