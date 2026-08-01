import SwiftUI

enum WIAchievementRingState {
    case locked
    case inProgress
    case earned
}

struct WIAchievementProgressRing<CenterContent: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let progress: Double
    var state: WIAchievementRingState = .inProgress
    var lineWidth: CGFloat = 14
    var trackColor: Color = WorthItColor.primaryContainer
    var progressColor: Color = WorthItColor.primaryContainer
    var showsPulse = true
    var pulseSpeed = 1.35
    var sweepLineScale: CGFloat = 0.34
    var initialFillDelay: Duration = .zero
    @ViewBuilder let centerContent: CenterContent

    @State private var renderedProgress: Double = 0
    @State private var sweepStartDate = Date()
    @State private var isSweepRunning = false
    @State private var glowPhase = false

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var animationIdentity: String {
        "\(clampedProgress)-\(state)-\(showsPulse)-\(reduceMotion)"
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
                    .shadow(color: progressColor.opacity(progressGlowOpacity), radius: progressGlowRadius)

                if shouldRenderSweep, renderedProgress > 0 {
                    TimelineView(.animation) { timeline in
                        AchievementRingSweep(
                            progress: renderedProgress,
                            cycle: sweepCycle(at: timeline.date),
                            lineWidth: lineWidth,
                            color: progressColor,
                            lineScale: sweepLineScale
                        )
                    }
                }

                centerContent
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .task(id: animationIdentity) {
            renderedProgress = reduceMotion ? clampedProgress : 0
            isSweepRunning = false
            glowPhase = false

            guard !reduceMotion else { return }

            if initialFillDelay > .zero {
                try? await Task.sleep(for: initialFillDelay)
                guard !Task.isCancelled else { return }
            }

            withAnimation(.easeInOut(duration: 1.05)) {
                renderedProgress = clampedProgress
            }

            guard canSweep else { return }
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }
            sweepStartDate = Date()
            isSweepRunning = true

            withAnimation(.easeInOut(duration: pulseSpeed * 0.72).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
        }
    }

    private var canSweep: Bool {
        showsPulse && state == .inProgress
    }

    private var shouldRenderSweep: Bool {
        canSweep && isSweepRunning
    }

    private func sweepCycle(at date: Date) -> AchievementRingSweep.Cycle {
        let activeDuration = max(pulseSpeed, 0.8)
        let pauseDuration = max(activeDuration * 0.62, 0.75)
        let elapsed = date.timeIntervalSince(sweepStartDate)
        let cycleDuration = activeDuration + pauseDuration
        let cycleElapsed = elapsed.truncatingRemainder(dividingBy: cycleDuration)

        guard cycleElapsed <= activeDuration else {
            return .idle
        }

        let rawPhase = cycleElapsed / activeDuration
        let easedPhase = 0.5 - 0.5 * cos(.pi * rawPhase)
        let opacity = pow(sin(.pi * rawPhase), 0.62)
        return .active(phase: easedPhase, opacity: opacity)
    }

    private var progressGlowOpacity: Double {
        switch state {
        case .locked: 0.10
        case .inProgress: glowPhase ? 0.38 : 0.18
        case .earned: 0.34
        }
    }

    private var progressGlowRadius: CGFloat {
        switch state {
        case .locked: lineWidth * 0.35
        case .inProgress: glowPhase ? lineWidth * 0.82 : lineWidth * 0.46
        case .earned: lineWidth * 0.72
        }
    }
}

private struct AchievementRingSweep: View {
    enum Cycle {
        case idle
        case active(phase: Double, opacity: Double)
    }

    let progress: Double
    let cycle: Cycle
    let lineWidth: CGFloat
    let color: Color
    let lineScale: CGFloat

    private var phase: Double {
        guard case let .active(phase, _) = cycle else { return 0 }
        return phase
    }

    private var window: Double {
        min(0.20, max(progress * 0.46, 0.07))
    }

    private var end: Double {
        max(window, min(progress, phase * progress))
    }

    private var start: Double {
        max(0, end - window)
    }

    private var sweepOpacity: Double {
        guard case let .active(_, opacity) = cycle else { return 0 }
        return opacity * 0.96
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: start, to: end)
                .stroke(
                    color.opacity(0.45),
                    style: StrokeStyle(lineWidth: max(lineWidth * lineScale * 1.65, 3), lineCap: .round)
                )
                .blur(radius: lineWidth * 0.14)

            Circle()
                .trim(from: start, to: end)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0),
                            Color.white.opacity(0.95),
                            color.opacity(0.92),
                            color.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: max(lineWidth * lineScale, 2), lineCap: .round)
                )
        }
        .rotationEffect(.degrees(-90))
        .opacity(sweepOpacity)
        .shadow(color: Color.white.opacity(0.26), radius: lineWidth * 0.22)
        .shadow(color: color.opacity(0.55), radius: lineWidth * 0.62)
    }
}
