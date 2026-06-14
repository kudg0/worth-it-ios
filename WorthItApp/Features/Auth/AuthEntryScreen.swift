import SwiftUI

struct AuthEntryScreen: View {
    let onAppleSignIn: () -> Void
    let onEmailSignIn: () -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        ZStack {
            WorthItColor.surfaceLowest.ignoresSafeArea()
            WITopSpotlight()

            VStack(spacing: 0) {
                AuthWordmark()
                    .padding(.top, WorthItSpacing.m)

                Spacer(minLength: WorthItSpacing.xxl)

                VStack(alignment: .leading, spacing: WorthItSpacing.xl) {
                    heroCopy
                    CockpitCluster()
                }

                Spacer(minLength: WorthItSpacing.xxl)

                actionStack
            }
            .padding(.horizontal, WorthItSpacing.xl)
            .padding(.bottom, WorthItSpacing.xl)
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.m) {
            Text("Know what ownership really costs.")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("Compare private ownership scenarios against real-world alternatives with precision.")
                .font(WorthItTypography.bodySmall)
                .foregroundStyle(WorthItColor.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionStack: some View {
        VStack(spacing: WorthItSpacing.m) {
            if AuthCapabilities.isAppleSignInEnabled {
                AuthActionButton(title: "Continue with Apple", systemName: "apple.logo", style: .apple) {
                    onAppleSignIn()
                }
            }

            NavigationLink(value: AuthRoute.emailSignIn) {
                HStack(spacing: WorthItSpacing.s) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 17, weight: .semibold))

                    Text("Sign in with Email")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(WorthItColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(WorthItColor.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
                .overlay {
                    RoundedRectangle(cornerRadius: WorthItRadius.l)
                        .stroke(WorthItColor.outlineInput, lineWidth: 1)
                }
            }
            .simultaneousGesture(TapGesture().onEnded(onEmailSignIn))

            NavigationLink(value: AuthRoute.registration) {
                Text("Create account")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
            }
            .simultaneousGesture(TapGesture().onEnded(onCreateAccount))

            AuthFooterNote(text: "Your scenarios stay tied to your account.")
                .padding(.top, WorthItSpacing.xs)
        }
    }
}

private struct CockpitCluster: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(WorthItColor.primaryContainer.opacity(0.08))
                .frame(width: 252, height: 252)
                .blur(radius: 28)

            ForEach(0..<3) { index in
                Circle()
                    .trim(from: 0.08 + CGFloat(index) * 0.05, to: 0.42 + CGFloat(index) * 0.07)
                    .stroke(
                        WorthItColor.primaryContainer.opacity(0.34 - Double(index) * 0.08),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 226 - CGFloat(index * 42), height: 226 - CGFloat(index * 42))
                    .rotationEffect(.degrees(Double(index) * 38 - 22))
            }

            VStack(spacing: WorthItSpacing.m) {
                MetricPreviewChip(title: "Cost / km", value: "€0.41", alignment: .leading)
                    .offset(x: -52)

                MetricPreviewChip(title: "Alternatives", value: "4 options", alignment: .center)
                    .offset(x: 42)

                MetricPreviewChip(title: "Total Cost", value: "Tracked", alignment: .trailing)
                    .offset(x: -18)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 284)
        .background {
            RoundedRectangle(cornerRadius: WorthItRadius.xxl)
                .fill(
                    LinearGradient(
                        colors: [
                            WorthItColor.surfaceContainer.opacity(0.72),
                            WorthItColor.surfaceContainerLow.opacity(0.42)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

private struct MetricPreviewChip: View {
    let title: String
    let value: String
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: WorthItSpacing.xs) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textTertiary)
                .tracking(1.1)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
        }
        .padding(.horizontal, WorthItSpacing.m)
        .padding(.vertical, WorthItSpacing.s)
        .background(WorthItColor.surfaceContainerHigh.opacity(0.78), in: Capsule())
        .overlay {
            Capsule()
                .stroke(WorthItColor.primaryContainer.opacity(0.16), lineWidth: 1)
        }
    }
}

#Preview {
    AuthEntryScreen(onAppleSignIn: {}, onEmailSignIn: {}, onCreateAccount: {})
}
