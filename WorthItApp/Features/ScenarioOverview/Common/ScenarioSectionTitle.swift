import SwiftUI

struct ScenarioSectionTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 30, weight: .heavy))
            .foregroundStyle(WorthItColor.textPrimary)
            .tracking(-0.75)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
