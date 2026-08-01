# Project Agent Notes

Please review yourself through this `AGENTS.md`.

## Roadmap Source Of Truth

- All unfinished backend and iOS product work lives in
  ../assets-invest-comparator/docs/product-work-plan.md.
- Do not create another backlog in this README, AGENTS.md, a feature document,
  or source comments.
- A focused feature plan may expand one task, but it must name the canonical
  task ID and must not maintain a competing status.
- Re-audit IN WORKTREE tasks before editing because concurrent local changes are
  not shipped work.

## Roadmap Task Claim And Close-Out

- Before editing, claim one canonical task ID and re-audit its current truth,
  dependencies, acceptance, and verification against the code and worktrees.
- Do not implement from narrative Scope/Acceptance alone. Every new active WIP
  claim must have `Execution packet version: 1` in the sibling canonical task
  with exact child/finding IDs, allowed files, forbidden scope, preconditions,
  commands and expected results, stop conditions, and handoff. Run sibling
  `pnpm roadmap:lint` after recording it; a missing/contradictory packet blocks
  Swift or product edits.
- One packet owns one independently verifiable boundary. Split before work if a
  packet mixes backend and iOS implementation, local and remote proof, migration
  and rollout, or implementation and negative testing.
- Cross-repository, security, migration, release, generated-artifact, and
  remote-CI packets use a task branch/worktree. Do not implement them directly
  on local main or push/merge main before independent review.
- In the same work session, update that task in
  `../assets-invest-comparator/docs/product-work-plan.md`. Use `VERIFIED DONE`
  only after every acceptance criterion and required check passes, exact
  evidence is recorded, and the result is attributable to a commit/PR. Use
  `IN WORKTREE — VERIFIED` when every check passes locally but the work is not
  committed; otherwise use `PARTIAL` or `IN WORKTREE — UNVERIFIED` and record
  the remaining work or blocker.
- The final handoff must name the resulting roadmap status and task ID. Never
  report work as done, shipped, or closed while its canonical status is open.
- The implementer posts a `Review request` with exact commits, commands/counts,
  clean/dirty state, warnings, skipped checks, and remaining acceptance. Only an
  independent reviewer may record `Final review verdict: PASS` and advance a
  packetized task to VERIFIED DONE. Map every finding ID to a correction commit;
  do not erase review history or leave resolved IDs in Remaining/blocker.
- After editing the sibling canonical roadmap, run `pnpm roadmap:lint` from
  `../assets-invest-comparator`. If the linter/rules/fixtures changed, also run
  `pnpm roadmap:lint:test`. A failing check blocks handoff and commit.
- Do not copy task status or create a second backlog in this file or elsewhere.

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
