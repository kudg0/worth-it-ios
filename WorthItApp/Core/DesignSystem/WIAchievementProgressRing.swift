import SwiftUI

struct WIAchievementProgressRing<CenterContent: View>: View {
    let progress: Double
    var lineWidth: CGFloat = 14
    var trackColor: Color = WorthItColor.primaryContainer
    var progressColor: Color = WorthItColor.accentGoldBright
    var showsPulse = true
    var pulseSpeed = 1.35
    var initialFillDelay: Duration = .milliseconds(500)
    @ViewBuilder let centerContent: CenterContent

    @State private var renderedProgress: Double = 0
    @State private var sweepPhase: Double = 0
    @State private var glowPhase = false

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                Circle()
                    .fill(trackColor.opacity(0.05))
                    .blur(radius: size * 0.16)

                Circle()
                    .stroke(trackColor.opacity(0.96), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .shadow(color: trackColor.opacity(0.22), radius: lineWidth * 0.85)

                Circle()
                    .stroke(trackColor.opacity(0.22), style: StrokeStyle(lineWidth: max(lineWidth * 0.42, 3), lineCap: .round))
                    .padding(lineWidth * 0.90)

                Circle()
                    .trim(from: 0, to: renderedProgress)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .shadow(color: progressColor.opacity(glowPhase ? 0.58 : 0.26), radius: glowPhase ? lineWidth * 1.05 : lineWidth * 0.58)

                if showsPulse, renderedProgress > 0 {
                    AchievementRingSweep(
                        progress: renderedProgress,
                        phase: sweepPhase,
                        lineWidth: lineWidth,
                        color: progressColor
                    )
                }

                centerContent
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .task(id: clampedProgress) {
            renderedProgress = 0
            sweepPhase = 0
            glowPhase = false

            try? await Task.sleep(for: initialFillDelay)
            guard !Task.isCancelled else { return }

            withAnimation(.smooth(duration: 1.15)) {
                renderedProgress = clampedProgress
            }

            guard showsPulse else { return }
            withAnimation(.linear(duration: pulseSpeed).repeatForever(autoreverses: false)) {
                sweepPhase = 1
            }
            withAnimation(.easeInOut(duration: pulseSpeed * 0.72).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
        }
    }
}

private struct AchievementRingSweep: View {
    let progress: Double
    let phase: Double
    let lineWidth: CGFloat
    let color: Color

    private var window: Double {
        min(0.10, max(progress * 0.36, 0.035))
    }

    private var end: Double {
        max(window, min(progress, phase * progress))
    }

    private var start: Double {
        max(0, end - window)
    }

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(
                LinearGradient(
                    colors: [
                        color.opacity(0),
                        color.opacity(0.92),
                        Color.white.opacity(0.82),
                        color.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: max(lineWidth * 0.34, 3), lineCap: .butt)
            )
            .rotationEffect(.degrees(-90))
            .shadow(color: color.opacity(0.42), radius: lineWidth * 0.48)
    }
}
