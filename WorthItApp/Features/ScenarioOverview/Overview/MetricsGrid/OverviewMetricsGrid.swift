import SwiftUI
import UniformTypeIdentifiers

struct OverviewMetricEditorInteractionState: Equatable {
    private(set) var isEditing = false
    private(set) var isFinishingTouch = false

    var canOpenMetric: Bool {
        !isEditing && !isFinishingTouch
    }

    mutating func enterEditing() {
        isEditing = true
        isFinishingTouch = false
    }

    mutating func finishEditing() {
        isEditing = false
        isFinishingTouch = true
    }

    mutating func releaseFinishingTouch() {
        isFinishingTouch = false
    }
}

struct OverviewMetricsGrid: View {
    @Environment(\.i18n) private var i18n

    let metrics: [ScenarioOverviewView.MetricSlide]
    let hiddenMetrics: [ScenarioOverviewView.MetricSlide]
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onMoveMetric: (ScenarioOverviewView.OverviewMetric, ScenarioOverviewView.OverviewMetric) -> Void
    let onHideMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onShowMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onResetLayout: () -> Void

    @State private var editorInteraction = OverviewMetricEditorInteractionState()
    @State private var draggedMetric: ScenarioOverviewView.OverviewMetric?
    @State private var showsWidgetPicker = false

    private let columns = [
        GridItem(.flexible(), spacing: WorthItSpacing.l),
        GridItem(.flexible(), spacing: WorthItSpacing.l)
    ]

    private var isEditingLayout: Bool {
        editorInteraction.isEditing
    }

    var body: some View {
        ZStack(alignment: .top) {
            LazyVGrid(columns: columns, spacing: WorthItSpacing.l) {
                ForEach(metrics) { metric in
                    let tile = OverviewMetricTile(
                        metric: metric,
                        isEditingLayout: isEditingLayout,
                        onOpenMetric: { metric in
                            guard editorInteraction.canOpenMetric else { return }
                            onOpenMetric(metric)
                        },
                        onHide: { onHideMetric(metric.id) }
                    )

                    if isEditingLayout {
                        tile
                            .onDrag {
                                draggedMetric = metric.id
                                return NSItemProvider(object: metric.id.rawValue as NSString)
                            }
                            .onDrop(
                                of: [UTType.text],
                                delegate: OverviewMetricDropDelegate(
                                    targetMetric: metric.id,
                                    draggedMetric: $draggedMetric,
                                    onMoveMetric: onMoveMetric
                                )
                            )
                    } else {
                        tile
                    }
                }

                if isEditingLayout {
                    addWidgetCard
                }
            }

            if isEditingLayout {
                editorToolbar
                    .padding(.top, -(WorthItSpacing.xxl + WorthItSpacing.xl))
                    .zIndex(2)
            }
        }
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.45) {
            enterEditMode()
        }
        .task {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-widgetEditorQA") {
                editorInteraction.enterEditing()
            }
#endif
        }
        .sheet(isPresented: $showsWidgetPicker) {
            OverviewMetricWidgetPicker(
                metrics: hiddenMetrics,
                onSelect: { metric in
                    onShowMetric(metric)
                    showsWidgetPicker = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private var editorToolbar: some View {
        HStack(spacing: WorthItSpacing.s) {
            WIIconButton(
                systemName: "arrow.counterclockwise",
                accessibilityLabel: i18n.t(.scenario.overview.widgets.reset),
                style: .toolbar
            ) {
                withAnimation(.smooth(duration: 0.25)) {
                    onResetLayout()
                }
            }

            Spacer()

            WIIconButton(
                systemName: "checkmark",
                accessibilityLabel: i18n.t(.scenario.overview.widgets.done),
                style: .primary
            ) {
                withAnimation(.smooth(duration: 0.25)) {
                    editorInteraction.finishEditing()
                }
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(180))
                    editorInteraction.releaseFinishingTouch()
                }
            }
        }
        .padding(.horizontal, WorthItSpacing.xs)
        .frame(height: WorthItInteraction.iconButtonTarget)
        .background(WorthItColor.pageBackground.opacity(0.001))
        .contentShape(.interaction, Rectangle())
        .allowsHitTesting(true)
    }

    private var addWidgetCard: some View {
        Button {
            showsWidgetPicker = true
        } label: {
            VStack(spacing: WorthItSpacing.s) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorthItColor.primaryContainer)
                    .frame(width: 42, height: 42)
                    .background(WorthItColor.surfaceLowest, in: Circle())
                    .overlay {
                        Circle().stroke(WorthItColor.primaryContainer.opacity(0.25), lineWidth: 1)
                    }

                Text(i18n.t(.scenario.overview.widgets.add))
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .textCase(.uppercase)
                    .foregroundStyle(WorthItColor.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 108)
            .background(WorthItColor.surfaceContainerLow.opacity(0.42), in: RoundedRectangle(cornerRadius: WorthItRadius.l))
            .overlay {
                OverviewMetricEditBorder()
            }
        }
        .buttonStyle(.plain)
    }

    private func enterEditMode() {
        guard !isEditingLayout else { return }
        withAnimation(.smooth(duration: 0.25)) {
            editorInteraction.enterEditing()
        }
    }
}

private struct OverviewMetricTile: View {
    @Environment(\.i18n) private var i18n

    let metric: ScenarioOverviewView.MetricSlide
    let isEditingLayout: Bool
    let onOpenMetric: (ScenarioOverviewView.OverviewMetric) -> Void
    let onHide: () -> Void

    var body: some View {
        Group {
            if isEditingLayout {
                editingTile
            } else {
                Button {
                onOpenMetric(metric.id)
                } label: {
                    tileContent
                }
                .buttonStyle(.plain)
                .accessibilityLabel(metric.title)
            }
        }
    }

    private var editingTile: some View {
        tileContent
            .accessibilityElement(children: .contain)
            .overlay(alignment: .topTrailing) {
                WIIconButton(
                    systemName: "xmark",
                    accessibilityLabel: i18n.t(.scenario.overview.widgets.removeFormat, metric.title),
                    style: .destructive,
                    visualSize: 24,
                    hitTargetSize: WorthItInteraction.minimumTouchTarget,
                    action: onHide
                )
                .offset(x: 10, y: -20)
            }
    }

    private var tileContent: some View {
        VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
            Text(metric.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(WorthItColor.textSecondary)
                .tracking(1)
                .textCase(.uppercase)

            Text(metric.value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(WorthItColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle = metric.subtitle {
                Text(subtitle)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textTertiary)
                    .tracking(0.6)
                    .lineLimit(1)
                    .textCase(.uppercase)
            }

            progressBar
                .padding(.top, WorthItSpacing.s)
        }
        .padding(WorthItSpacing.xl)
        .frame(maxWidth: .infinity, minHeight: 108, maxHeight: .infinity, alignment: .leading)
        .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))
        .overlay {
            if isEditingLayout {
                OverviewMetricEditBorder()
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(WorthItColor.outlineInput.opacity(0.35))
                Capsule()
                    .fill(metric.accentColor)
                    .frame(width: proxy.size.width * metric.progress)
            }
        }
        .frame(height: 4)
    }
}

private struct OverviewMetricWidgetPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.i18n) private var i18n

    let metrics: [ScenarioOverviewView.MetricSlide]
    let onSelect: (ScenarioOverviewView.OverviewMetric) -> Void

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()

            VStack(spacing: WorthItSpacing.l) {
                header

                Group {
                    if metrics.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: WorthItSpacing.l),
                                    GridItem(.flexible(), spacing: WorthItSpacing.l)
                                ],
                                spacing: WorthItSpacing.l
                            ) {
                                ForEach(metrics) { metric in
                                    Button {
                                        onSelect(metric.id)
                                    } label: {
                                        OverviewMetricAddCard(metric: metric)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(WorthItSpacing.xxl)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var header: some View {
        ZStack {
            Text(i18n.t(.scenario.overview.widgets.sheetTitle))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorthItColor.textPrimary)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Text(i18n.t(.scenario.overview.widgets.cancel))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(WorthItColor.primaryContainer)
                        .padding(.horizontal, WorthItSpacing.l)
                        .frame(height: 44)
                        .background(WorthItColor.surfaceContainerLow, in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, WorthItSpacing.xxl)
        .padding(.top, WorthItSpacing.xl)
    }

    private var emptyState: some View {
        VStack(spacing: WorthItSpacing.s) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(WorthItColor.primaryContainer)
            Text(i18n.t(.scenario.overview.widgets.empty))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WorthItColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(WorthItSpacing.xxl)
    }
}

private struct OverviewMetricEditBorder: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dashPhase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: WorthItRadius.l)
            .stroke(
                WorthItColor.primaryContainer.opacity(0.64),
                style: StrokeStyle(
                    lineWidth: 1.2,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [6, 5],
                    dashPhase: dashPhase
                )
            )
            .shadow(color: WorthItColor.primaryContainer.opacity(0.12), radius: 5)
            .task {
                guard !reduceMotion else { return }
                dashPhase = 0
                withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) {
                    dashPhase = -22
                }
            }
            .onChange(of: reduceMotion) { _, isReduced in
                if isReduced {
                    dashPhase = 0
                }
            }
    }
}

private struct OverviewMetricAddCard: View {
    let metric: ScenarioOverviewView.MetricSlide

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: WorthItSpacing.xs) {
                Text(metric.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WorthItColor.textSecondary)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(metric.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(WorthItColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let subtitle = metric.subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WorthItColor.textTertiary)
                        .tracking(0.6)
                        .lineLimit(1)
                        .textCase(.uppercase)
                }

                progressBar
                    .padding(.top, WorthItSpacing.s)
            }
            .padding(WorthItSpacing.xl)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .background(WorthItColor.surfaceContainerLow, in: RoundedRectangle(cornerRadius: WorthItRadius.l))

            Image(systemName: "plus")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(WorthItColor.surfaceLowest)
                .frame(width: 28, height: 28)
                .background(WorthItColor.primaryContainer, in: Circle())
                .shadow(color: WorthItColor.primaryContainer.opacity(0.22), radius: 8)
                .padding(WorthItSpacing.m)
        }
        .overlay {
            RoundedRectangle(cornerRadius: WorthItRadius.l)
                .stroke(WorthItColor.outlineSubtle, lineWidth: 1)
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(WorthItColor.outlineInput.opacity(0.35))
                Capsule()
                    .fill(metric.accentColor)
                    .frame(width: proxy.size.width * metric.progress)
            }
        }
        .frame(height: 4)
    }
}

private struct OverviewMetricDropDelegate: DropDelegate {
    let targetMetric: ScenarioOverviewView.OverviewMetric
    @Binding var draggedMetric: ScenarioOverviewView.OverviewMetric?
    let onMoveMetric: (ScenarioOverviewView.OverviewMetric, ScenarioOverviewView.OverviewMetric) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedMetric, draggedMetric != targetMetric else { return }
        withAnimation(.smooth(duration: 0.20)) {
            onMoveMetric(draggedMetric, targetMetric)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedMetric = nil
        return true
    }
}

#if DEBUG
struct WidgetEditorQAHarness: View {
    @State private var metrics = Self.sampleMetrics
    @State private var hiddenMetrics: [ScenarioMetricSlide] = []
    @State private var openedMetric: ScenarioOverviewMetric?

    var body: some View {
        ZStack {
            WorthItColor.pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: WorthItSpacing.xxxxl) {
                    Text("Widget Editor QA")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(WorthItColor.textPrimary)

                    Text(openedMetric.map { "Opened: \($0.rawValue)" } ?? "No metric opened")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(openedMetric == nil ? WorthItColor.accentGold : WorthItColor.danger)
                        .accessibilityIdentifier("widget-editor-qa-status")

                    OverviewMetricsGrid(
                        metrics: metrics,
                        hiddenMetrics: hiddenMetrics,
                        onOpenMetric: { openedMetric = $0 },
                        onMoveMetric: moveMetric,
                        onHideMetric: hideMetric,
                        onShowMetric: showMetric,
                        onResetLayout: resetMetrics
                    )
                }
                .padding(.horizontal, WorthItSpacing.xxl)
                .padding(.top, 88)
                .padding(.bottom, 120)
            }
        }
        .environment(\.i18n, I18n(localeIdentifier: "en"))
    }

    private func moveMetric(_ source: ScenarioOverviewMetric, _ target: ScenarioOverviewMetric) {
        guard
            let sourceIndex = metrics.firstIndex(where: { $0.id == source }),
            let targetIndex = metrics.firstIndex(where: { $0.id == target })
        else { return }

        let item = metrics.remove(at: sourceIndex)
        metrics.insert(item, at: targetIndex)
    }

    private func hideMetric(_ metric: ScenarioOverviewMetric) {
        guard let index = metrics.firstIndex(where: { $0.id == metric }) else { return }
        hiddenMetrics.append(metrics.remove(at: index))
    }

    private func showMetric(_ metric: ScenarioOverviewMetric) {
        guard let index = hiddenMetrics.firstIndex(where: { $0.id == metric }) else { return }
        metrics.append(hiddenMetrics.remove(at: index))
    }

    private func resetMetrics() {
        metrics = Self.sampleMetrics
        hiddenMetrics = []
    }

    private static let sampleMetrics = [
        ScenarioMetricSlide(
            id: .monthlyCost,
            title: "Monthly Cost",
            value: "€486",
            subtitle: "August",
            footer: nil,
            footerIcon: "calendar",
            footerColor: WorthItColor.textSecondary,
            progress: 0.62,
            accentColor: WorthItColor.primaryContainer
        ),
        ScenarioMetricSlide(
            id: .costPerKm,
            title: "Cost per KM",
            value: "€0.41",
            subtitle: "12,840 km",
            footer: nil,
            footerIcon: "gauge.with.dots.needle.33percent",
            footerColor: WorthItColor.textSecondary,
            progress: 0.41,
            accentColor: WorthItColor.accentGold
        )
    ]
}
#endif
