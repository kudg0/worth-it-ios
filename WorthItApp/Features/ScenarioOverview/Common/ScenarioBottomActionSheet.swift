import SwiftUI

struct ScenarioBottomActionSheet<Content: View>: View {
    @State private var dragOffset: CGFloat = 0
    @State private var isFinishingDismiss = false

    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.black.opacity(backdropOpacity)
                    .ignoresSafeArea()
                    .onTapGesture(perform: finishDismiss)

                sheet(bottomInset: proxy.safeAreaInsets.bottom)
                    .offset(y: dragOffset)
                    .simultaneousGesture(dismissDragGesture)
                    .animation(.spring(response: 0.28, dampingFraction: 0.84), value: dragOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .bottom)
        .zIndex(20)
    }

    private func sheet(bottomInset: CGFloat) -> some View {
        VStack(spacing: WorthItSpacing.m) {
            Capsule()
                .fill(WorthItColor.outlineInput)
                .frame(width: 36, height: 4)
                .padding(.top, WorthItSpacing.s)

            content
        }
        .padding(WorthItSpacing.xl)
        .padding(.bottom, 28 + bottomInset)
        .frame(maxWidth: .infinity)
        .background(WorthItColor.surfaceContainerLow, in: UnevenRoundedRectangle(topLeadingRadius: WorthItRadius.xxl, topTrailingRadius: WorthItRadius.xxl))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(WorthItColor.outlineSubtle)
                .frame(height: 1)
        }
        .shadow(color: .black.opacity(0.34), radius: 24, y: -8)
        .contentShape(Rectangle())
    }

    private var backdropOpacity: Double {
        let progress = min(max(Double(dragOffset / 360), 0), 0.85)
        return 0.42 * (1 - progress)
    }

    private var dismissDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !isFinishingDismiss else { return }
                dragOffset = sheetOffset(for: value.translation.height)
            }
            .onEnded { value in
                guard !isFinishingDismiss else { return }
                if value.translation.height > 72 || value.predictedEndTranslation.height > 150 {
                    finishDismiss()
                } else {
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func sheetOffset(for translation: CGFloat) -> CGFloat {
        if translation >= 0 {
            return translation
        }

        return max(translation * 0.18, -28)
    }

    private func finishDismiss() {
        guard !isFinishingDismiss else { return }
        isFinishingDismiss = true

        withAnimation(.easeOut(duration: 0.22)) {
            dragOffset = 560
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            onDismiss()
        }
    }
}
