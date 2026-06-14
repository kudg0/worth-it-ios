import SwiftUI

struct GenericMetricRecommendation: View {
    struct Model {
        let text: String
        let onGenerateFullAppraisal: () -> Void
    }

    let model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.l) {
            HStack {
                Text("Strategic recommendation")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1.2)
                    .textCase(.uppercase)

                Spacer()

                Text("Certified")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x001A42))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .padding(.horizontal, WorthItSpacing.m)
                    .frame(height: 22)
                    .background(WorthItColor.primaryContainer, in: Capsule())
            }

            Text(model.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WorthItColor.textPrimary.opacity(0.92))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            WIButton(title: i18n.t("Generate Full Appraisal"), iconSystemName: "doc.text", action: model.onGenerateFullAppraisal)
                .padding(.top, WorthItSpacing.s)
        }
        .padding(WorthItSpacing.xxl)
        .background(WorthItColor.surfaceMetric, in: RoundedRectangle(cornerRadius: WorthItRadius.xxl))
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }
}
