# Action Button Interaction Foundation

Canonical task: UX-001

The canonical status, dependencies, acceptance, and execution order live in the
[UX-001 GitHub issue](https://github.com/kudg0/assets-invest-comparator/issues/35).
This document is the detailed interaction specification only.

## Goal

Make every Worth It action button easy to hit, impossible to accidentally pass through to content beneath it, visually responsive, and consistently accessible.

The widget editor `Done` button is the first failing case, but the fix must become a Design System rule and a repository-wide migration rather than a one-off patch.

## External guidance

Primary references:

- [Apple Human Interface Guidelines — Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [Apple Human Interface Guidelines — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Apple Human Interface Guidelines — Undo and redo](https://developer.apple.com/design/human-interface-guidelines/undo-and-redo)
- [Apple Human Interface Guidelines — Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [Apple Support — Edit Home Screen widgets](https://support.apple.com/en-gb/guide/iphone/iphb8f1bf206/ios)
- [Apple UI Design Dos and Don'ts — Hit Targets](https://developer.apple.com/design/tips/)
- [SwiftUI Gestures documentation](https://developer.apple.com/documentation/swiftui/gestures)
- [SwiftUI hit-testing and content-shape APIs](https://developer.apple.com/documentation/swiftui/view-input-and-events)

Relevant rules:

- iOS buttons should generally provide a hit region of at least 44 x 44 points.
- Comfortable spacing between neighboring controls matters in addition to target size.
- Custom controls need a visible pressed state.
- When an interaction is an instantaneous action, prefer SwiftUI `Button` over a raw tap gesture so standard behavior and accessibility remain intact.
- `contentShape` defines the interaction region; `allowsHitTesting` controls whether a view participates in hit testing.
- Button copy should describe the action it performs. Do not hide dismissal behind
  a Reset label/icon.
- Show the result of reverting a batch of edits and make it easy to Undo. Apple
  advises against confirmation alerts for common actions that are directly
  reversible; an uncommon irreversible reset needs explicit confirmation.

## Current widget-editor bug

The current `OverviewMetricsGrid` creates several overlapping interaction problems:

- The visible `Done` and Reset circles are only 34 x 34 points.
- The widget Remove control is only 24 x 24 points.
- The toolbar is placed over interactive widget tiles in a `ZStack`.
- `OverviewMetricTile` always installs its navigation `onTapGesture` and checks the mutable `isEditingLayout` value only when the gesture fires.
- `Done` changes `isEditingLayout` to `false`. A competing tile tap can then observe the new value and open the underlying metric during the same interaction sequence.
- `.allowsHitTesting(true)` on the toolbar does not by itself make transparent space consume touches or resolve competing gestures beneath the controls.

This is a gesture hierarchy/state-ordering bug plus an undersized target, not only a missing padding issue.

## Widget Reset behavior

Product semantics belong to OVW-001; this document owns only interaction and
accessibility behavior.

The current source already separates the commands: Reset calls
`onResetLayout()` and stays in edit mode, while Done calls `finishEditing()`.
Keep that separation. Based on the Apple guidance above, the product inference
is:

- `Reset layout` restores the canonical default widgets/order and leaves the
  editor open so the result is visible.
- Show localized `Default layout restored` feedback with an actionable `Undo`
  that restores the exact visible pre-reset layout.
- `Done` is the sole normal exit from edit mode. Never implement an implicit
  Reset-and-close behind `arrow.counterclockwise`; a combined action would need
  an explicit label and a new product decision.
- Disable Reset when the normalized layout is already the default. It must not
  emit a no-op save.
- When Undo is available, avoid a confirmation interruption. Until Undo exists,
  an irreversible reset needs an explicit Reset/Cancel confirmation and still
  leaves the editor open after Reset.
- Use `arrow.counterclockwise` for Reset and reserve undo imagery/copy for Undo.
  The localized accessibility hint explains that Reset restores defaults and
  keeps the editor open.

OVW-001 owns snapshot, save ordering, rollback/retry, reload persistence, and
Undo semantics. UX-001 owns the 48-point target, touch consumption, result
announcement/action focus, and proof that Reset neither dismisses nor opens a
tile underneath.

## Worth It interaction standard

### Target sizes

- Absolute iOS minimum interactive region: 44 x 44 pt.
- Worth It default icon action target: 48 x 48 pt.
- Visible icon or circle may remain 24–40 pt inside the 48 pt target.
- Full-width and text actions must never be shorter than 44 pt; standard primary actions can keep the existing 56–64 pt height.
- Adjacent icon actions need enough separation that their hit regions do not overlap. Start with at least 8 pt between 48 pt targets and visually QA dense toolbars; use more where layout permits.
- Never enlarge a hit region invisibly into a neighboring action's hit region.

### Interaction geometry

- Separate visual size from hit size explicitly in the component API.
- Apply the 44/48 pt frame to the `Button` label, not only to an inner `Image`.
- Apply `.contentShape(.interaction, Rectangle())` or the appropriate simple shape to the complete hit frame.
- Do not rely on transparent padding whose hit behavior is unclear from the view hierarchy.
- Keep hit targets inside safe areas and away from unintended system gesture regions.

### Gesture ownership

- Use `Button` for actions. Reserve `.onTapGesture` for direct object interaction where button semantics are genuinely wrong.
- Do not place independent parent/card tap gestures behind a child action and resolve the conflict with a mutable-state `guard`.
- Build mode-specific interaction hierarchies: when a card is editing, remove or disable its open/navigation interaction structurally while preserving only edit actions such as drag, remove, reset, and done.
- Overlay action bars must own an explicit hit-test layer and sit above content with deterministic `zIndex`.
- Where an overlay covers content, disable underlying interaction for the covered region or entire inactive layer. A transparent hit shield is acceptable when it has a clear bounded frame and accessibility behavior.
- Avoid simultaneous gestures for mutually exclusive actions. Use explicit exclusive gesture composition only when standard `Button` hierarchy cannot express the interaction.
- Changing UI mode during a button action must not make the same touch eligible for an underlying action.

### Feedback and state

- Every custom action gets a pressed state: scale, opacity, material, or color response consistent with its role.
- Disabled state must disable hit testing and communicate its state visually and to accessibility.
- Async actions expose loading/progress and prevent duplicate submission where duplication is harmful.
- Destructive actions use semantic button roles and confirmation where appropriate; target size rules remain identical.
- Haptics are optional reinforcement, never the only feedback.
- Editor commands are single-purpose. Reset changes layout; Done exits. A label
  or icon must not perform an additional hidden navigation/dismissal effect.

### Accessibility

- Every icon-only button requires a localized semantic accessibility label.
- Add an accessibility hint only when the result is not obvious from the label.
- Use correct roles and traits; do not add `.isButton` to a view that should instead be a real `Button`.
- Verify VoiceOver focus order matches visual order.
- Support Switch Control, Voice Control, Full Keyboard Access, pointer input, and Dynamic Type layouts.
- Do not encode enabled, selected, or destructive state only through color.

## Design System work

### Shared metrics

Add a single source of truth, for example:

- `WorthItInteraction.minimumTouchTarget = 44`
- `WorthItInteraction.iconButtonTarget = 48`
- `WorthItInteraction.compactVisualSize = 34`

Names can change during implementation, but controls must not duplicate raw target constants.

### `WIIconButton`

Extend or replace the current component so it supports:

- Separate `visualSize` and `hitTargetSize`.
- Default 48 pt hit target.
- Plain, circular, toolbar, destructive, and selected appearances without changing interaction geometry.
- Localized label, optional hint, disabled/loading state, role, and press feedback.
- Predictable `contentShape` and accessibility behavior.

The current 40 x 40 `WIIconButton` target must move to the shared standard.

### `WIButton`

- Clamp configurable height to at least 44 pt or assert in debug builds.
- Keep the full label area interactive.
- Add shared pressed/disabled/loading behavior rather than recreating it per screen.

### Overlay action container

Create a reusable overlay/toolbar interaction pattern when several floating actions sit above tappable content:

- Explicit stacking and hit-test ownership.
- Safe-area-aware placement.
- 48 pt action targets.
- Non-overlapping target spacing.
- Optional bounded hit shield below the toolbar.
- A single accessibility group when appropriate.

Do not turn every screen-specific toolbar into a new component; extract only after the widget editor and one additional overlay prove the API.

### Development guardrails

- Add a debug preview/audit overlay capable of drawing actual interaction frames around DS buttons.
- Add a lint or SwiftSyntax-based audit for suspicious button labels below 44 pt and raw `.onTapGesture` used as a button substitute.
- Allow explicit exceptions only for non-interactive decoration or platform-specific controls with documented reasoning.
- Update component previews to show visual bounds and hit bounds separately.

## Widget editor first fix

Implementation requirements:

1. Keep the visible `Done` and Reset circles at the desired visual size, but place each inside a 48 x 48 `Button` target.
2. Expand every widget Remove action to a minimum 44 x 44 target without visually enlarging the small close glyph unnecessarily.
3. Give the editor toolbar an explicit hit-test surface and top `zIndex` over the grid.
4. While `isEditingLayout` is true, do not install the metric-opening interaction on tiles. Use a separate editing branch rather than a closure that checks mutable state after recognition.
5. Keep drag/drop and Remove interactions active in edit mode.
6. End edit mode only from the `Done` action; the completing touch must be consumed before the normal tile hierarchy is restored.
7. Keep Reset in edit mode. Its completing touch performs exactly one reset and
   cannot trigger a tile, Done, drag, or Remove action underneath/adjacent to it.
8. Announce the restored-default result and expose the localized Undo action
   without moving VoiceOver focus into an underlying tile.
9. Preserve current layout animation without animating the interaction layer into an ambiguous overlap.

## Repository-wide audit

Audit all interactive surfaces, not only obvious circular buttons:

- Navigation and toolbar buttons.
- Close, Done, Cancel, Reset, Add, Remove, Edit, Share, overflow, retry, and disclosure actions.
- Buttons over cards, charts, maps, images, and list rows.
- Swipe/context actions and action overlays.
- Calendar arrows and period controls.
- Attachment, link, and metadata editors.
- Achievement map/detail actions.
- Scenario bottom navigation and top tab controls.
- Toast/banner dismissal actions.
- Authentication and profile actions.

The source currently contains many visible frames between 24 and 42 pt. Some are decorations inside larger buttons, so inspect effective button geometry rather than mechanically changing every frame.

Prioritize:

1. Overlapping actions above tappable content.
2. Destructive or navigation actions.
3. Frequently used form controls.
4. Dense toolbars and icon clusters.
5. Remaining secondary actions.

## Test plan

### Widget regression UI test

- Enter widget edit mode.
- Tap the center of `Done`.
- Assert edit mode closes.
- Assert no metric detail opens and selected metric/navigation state stays unchanged.
- Repeat using points near every edge of the 48 pt target but outside the visible 34 pt circle.
- From a customized layout, tap Reset at the center and near every edge. Assert
  defaults appear, edit mode stays active, exactly one reset fires, no metric
  detail opens, and localized feedback/Undo is accessible.
- Invoke Undo and assert the exact previous enabled set/order returns while edit
  mode remains active. Reset at defaults is disabled/no-op.
- Exercise Reset -> Done and rapid Reset -> Undo ordering; no touch reaches a
  tile while the editor state changes.
- Repeat edge/rapid/post-scroll checks for widget Remove.
- Repeat with rapid taps and after scrolling the grid.

### Design System tests

- Snapshot hit-target previews for every button style.
- Verify disabled/loading buttons execute no action.
- Verify a single tap produces exactly one action.
- Verify localized labels and VoiceOver traits.
- Exercise normal, pressed, disabled, selected, destructive, and high-contrast states.

### Manual matrix

- Smallest supported iPhone and largest iPhone.
- Portrait plus any supported landscape layouts.
- VoiceOver, Voice Control, Switch Control, Full Keyboard Access.
- Dynamic Type through accessibility sizes.
- Reduce Motion and Increase Contrast.
- Pointer input on iPad where supported.
- Slow deliberate taps, edge taps, quick taps, and scroll-then-tap.

## Acceptance criteria

- No production action button has an effective hit region below 44 x 44 pt without a documented platform exception.
- Worth It icon action components default to 48 x 48 pt targets.
- No overlay action activates content underneath it.
- No mode-changing action lets its finishing touch activate a newly enabled underlying action.
- Widget Reset shows defaults and remains in edit mode; it never dismisses or
  activates content underneath. Done remains the explicit editor exit.
- Every icon action has localized accessibility copy and visible press feedback.
- Widget `Done`, Reset, and Remove pass center, edge, rapid-tap, and scroll regression tests.
- New action buttons use DS components or the shared interaction metrics.
- CI or review tooling flags likely regressions before release.
