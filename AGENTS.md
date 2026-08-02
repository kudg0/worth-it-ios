# Project Agent Notes

Please review yourself through this `AGENTS.md`.

## Roadmap Source Of Truth

- All unfinished backend and iOS product work lives in GitHub Issues in
  `kudg0/assets-invest-comparator`. Start from the
  [Worth It roadmap index](https://github.com/kudg0/assets-invest-comparator/issues/172)
  and open the issue titled with the exact task ID.
- One canonical task has one issue titled `[TASK-ID] Task title` and marker
  `<!-- worth-it-roadmap-task:TASK-ID -->`. Its body owns status, priority,
  dependencies, acceptance, packet, review evidence, and remaining work.
- The sibling `docs/product-work-plan.md` is an archived migration snapshot,
  not current status. Do not create another backlog in README, AGENTS.md, a
  feature document, archive, or source comments.
- A focused feature plan may expand one task, but it must link the canonical
  issue and must not maintain a competing status.
- Re-audit IN WORKTREE tasks before editing because concurrent local changes are
  not shipped work.

## Lead And Subagent Operating Model

- The lead is the only user-facing orchestrator. The lead owns decomposition,
  canonical task issue state, integration, verification, and the final answer.
  Subagents are bounded workers that report results to the lead.
- Solo execution is the default. Delegate only a concrete, independently
  verifiable slice when it gives a real speed, specialist-quality, or context-
  isolation benefit. Do not spawn a child for status watching, packet creation,
  or a quick check the lead can finish faster.
- Give a child one self-contained packet with the outcome, deliverable, minimum
  needed context, base/worktree, allowed writes, forbidden scope, checks, and
  stop state. Do not assume the child inherited or understood the lead's chat.
- A packet authorizes exactly one task. `DONE`, `BLOCKED`, `UNSAFE`, or
  `STALE_PACKET` ends it. A child must not choose the next task, prepare its own
  follow-up packet, edit canonical task issues, commit, or push unless that exact
  action is explicitly allowed.
- After dispatch, the lead continues useful independent work or waits for an
  event/completion notification. Do not poll children for status. The lead
  consumes one concise handoff, validates it, and decides the next task.

## Roadmap Task Claim And Close-Out

- Default to the lightweight workflow for ordinary product work. Solo work needs
  no child packet. Delegated work gets one canonical issue, one concise packet,
  one isolated worktree, one lead review, and at most one correction round.
- Before product edits, fetch and claim the exact issue. Add `Active claim` and
  the complete `Execution packet version: 1` record to its body. The live
  roadmap lint allows at most three simultaneous claims.
- A packet names the outcome, allowed/forbidden scope, exact worktree/base,
  write set, checks, stop conditions, handoff, steward, and reviewer. Reuse the
  existing template; do not build new governance for an ordinary feature.
- Use full digest and approval-ledger ceremony plus independent final review
  only for security/authentication, migrations/schema, API or generated-client
  contracts, releases/deployments, and similarly irreversible work.
- Every commit still requires lead review of the exact candidate followed by
  explicit user approval. Commit, push, merge, release, and deployment are
  separate permissions. “Continue” or “finish” is not commit approval.
- A normal lead review returns `PASS` or one bounded actionable finding. Permit one
  correction round; ask the user before a second review/correction cycle.
- Do not improve roadmap lint, coordination scripts, packet schemas, or agent
  governance during product implementation. Backlog non-blocking process
  defects. Stop only when a defect makes the requested work unsafe.
- Give evidence to the Roadmap steward, who alone updates the canonical issue in
  the same work session. Do not create another status source.
- `VERIFIED DONE` requires all acceptance and checks, attributable commit/PR
  evidence, independent PASS when required, and closing the issue with reason
  `completed`. Every other status remains open.
- GitHub Actions runs the authoritative live issue lint. The sibling
  `pnpm roadmap:lint` command requires `GITHUB_TOKEN` or `GH_TOKEN` with
  read access; its fixture suite is required only for linter/rule changes.

## Parallel Work

- Start with one child; use two in parallel when both slices are genuinely
  independent, with a hard cap of three. Each gets a
  separate branch/worktree with disjoint files/resources. Roadmap/linter,
  lockfiles, migrations/schema, generated contracts and localization keys,
  release configuration, and shared design-system primitives stay serial.
- Batch close-out and next-task preparation into one lead pass. Avoid repeated
  claim/close/open cycles when one safe transition is enough.
- Update shared instructions serially. Workers finish their current atomic
  command and return `WAIT` when a lead-owned instruction edit overlaps them.

## Design Source

- Main Stitch project: https://stitch.withgoogle.com/projects/7705134958589101922?pli=1
- Use this Stitch project as the product design reference for Worth It iOS screens.
- Purpose: keep new UI work aligned with the existing dark automotive analytics style, design system, and generated screen concepts.
- When adding or redesigning product screens, prefer generating or checking a Stitch concept in this project before implementing SwiftUI, especially for new detail pages or visually important flows.
- Recent reference: the Break-even detail page was generated in this project as screen `5c46e778c2a44d738124f94ed2a036fd`.

## Worth It UI / DS Rules

- Generated Stitch/Figma concepts are references, not final implementation style.
- In SwiftUI, translate concepts into existing Worth It DS components first.
- Use `WIIsland` for grouped detail sections and product "islands"; avoid one-off rectangular cards when an island fits.
- Use `WISegmentedControl` for option/comparison selectors; do not hand-roll toggle/chip selectors for these flows.
- Use `WorthItColor.accentGold` for positive money/savings values.
- Use `WorthItColor.danger` for negative/loss/behind values.
- Keep savings/comparison detail pages visually aligned with existing islands, spacing, typography, and DS surfaces.

## Localization Rules

- All new user-facing app text must go through `WorthItApp/Resources/Localizable.xcstrings`.
- Prefer typed keys from `I18nKey.generated.swift` via `i18n.t(...)` or `@Environment(\.i18n)`.
- Translation keys must be semantic dot-delimited identifiers, not English UI copy. Use keys like
  `achievements.levelRing.status.locked` or `scenarioOverview.actions.logMileage`; do not call
  `i18n.t("LOCKED")`, `i18n.t("Save")`, or interpolate Swift values inside key strings.
- Dynamic localized copy must use catalog format values with typed keys, for example
  `i18n.t(.achievements.common.level.titleFormat, level)`, while backend/user data stays plain data
  and must not become a translation key.
- After adding semantic localization keys, run `python3 Scripts/generate_i18n_keys.py`.
- Do not add new hardcoded English strings in SwiftUI views, API error mappers, alerts, buttons, placeholders, or validation messages.
