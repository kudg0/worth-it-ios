# Worth It iOS

Native SwiftUI client for Worth It.

Backend contract is consumed through OpenAPI, not by importing backend source files.

## Contract

Development backend:

```sh
OPENAPI_URL=http://localhost:3000/docs/json ./Scripts/fetch-openapi.sh
```

The script updates:

- `Sources/WorthItAPI/openapi.json` for `swift-openapi-generator`

## Build Notes

Target platform: iOS 18+.

This repo uses `swift-openapi-generator` for API types and client code.
SwiftUI app code should depend on repositories/services, not direct HTTP calls from views.

Open `WorthIt.xcodeproj` in Xcode, select the `WorthIt` scheme, choose an iPhone simulator, and press Run.
Do not run the Swift Package directly for the app; the package only owns the generated `WorthItAPI` client.
SwiftUI app code lives in `WorthItApp/`, while `Sources/` is reserved for Swift Package targets.

## Product roadmap

Last audited: **2026-08-01**, against the complete local working tree, including uncommitted changes.

Status meanings:

- **DONE** — the acceptance point exists in the current working tree and was verified by source audit.
- **PARTIAL** — usable groundwork exists, but the requested feature is not complete.
- **NOT STARTED** — no implementation was found; documentation or placeholders do not count.
- **DEFERRED** — intentionally blocked by a named external prerequisite.

Verification baseline:

- [x] `xcodebuild test` succeeds on the iPhone 17 / iOS 26.5 simulator: 3 tests, 0 failures.
- [ ] Feature coverage is not sufficient yet: the repository has one unit-test file for overview navigation and no UI-test target.
- [ ] The current widget and achievement polish is still uncommitted. A passing build proves integration, not visual or interaction correctness.

### Recommended execution order

1. Stabilize the current widget and achievement worktree: fix the widget-editor click-through, add minimum state/regression tests, add Reduce Motion handling, and run device visual QA.
2. Close the small scoped UX tasks: make `Add Trip` primary, replace Exit with Garage, and add the completed-achievement disclosure.
3. Add duplicate-entry warnings for expenses, trips/routes, and recurring services.
4. Finish Overview customization: category picker, average widgets, averaging rules, and tests.
5. Add per-scenario top-tab visibility and the trailing restore `+`.
6. Ship localization in phases: app language infrastructure and Russian first, then the remaining official EU languages.
7. Run the collectible-medal implementation and Profile Stitch alignment as separate design workstreams.
8. Keep OEM vehicle data deferred until the legal and backend gates are satisfied.

### Action-button interaction foundation — **NOT STARTED**

The [detailed interaction plan](Docs/ActionButtonInteractionPlan.md) exists, but the implementation has not started.

- [ ] Add a regression test for the widget-editor `Done` click-through. The bug is still present: the overlay changes edit mode while the tile underneath keeps its tap gesture.
- [ ] Restructure edit and non-edit tile interaction so the same tap cannot reach underlying content.
- [ ] Increase widget-editor targets: `Done` and Reset are currently 34 x 34 pt; Remove is 24 x 24 pt.
- [ ] Define a minimum 44 x 44 pt hit region and a 48 x 48 pt Worth It default, separate visual and interaction sizes, and migrate `WIIconButton` from its current 40 x 40 pt target.
- [ ] Audit navigation, overlay, close, add/remove, reset, share, destructive, and form actions for hit regions, press/disabled states, semantics, and click forwarding.

### Overview widget customization and averages — **PARTIAL**

The underlying picker mechanics were added in the current uncommitted worktree; the old note that the picker UI did not exist was stale.

- [x] The same enabled metric collection now drives the hero carousel and `OverviewMetricsGrid`.
- [x] Add, hide, reorder, reset, picker-sheet, and empty-state UI exist for the current metric set.
- [x] Enabled ids and ordering persist through per-scenario server settings, not only local app storage.
- [ ] Decide and communicate the pinned-metric rule: `currentMonthCostPerKm` and `paybackDistance` are currently forced back into the enabled set, so their Remove action cannot truly hide them.
- [ ] Create and visually validate the picker concept in the main Stitch project.
- [ ] Group the add-widget menu into Costs, Mileage & Trips, Savings & Comparison, and Ownership & Value.
- [ ] Add average distance in the configured `km`/`mi` unit with an in-widget Day / Week / Month `WISegmentedControl`.
- [ ] Add Workdays / Weekend average distance.
- [ ] Add average trip count for Day / Week / Month.
- [ ] Consider average trip distance and active driving days.
- [ ] Define averaging windows, timezone/day-boundary rules, empty-data behavior, and backend/client ownership centrally.
- [ ] Add layout-persistence, reorder, hide/show, selector, and averaging tests; complete device and accessibility QA.

### Achievements Hub polish — **PARTIAL**

Substantial ring/map/detail polish exists in the current uncommitted worktree, but it is not the planned medal redesign.

- [x] Locked, in-progress, and earned states now have state-aware rings across Hub, Map, and Detail.
- [x] Map lanes, category cards, detail progress, similar achievements, and semantic achievement strings were improved.
- [ ] Add Reduce Motion and visibility gating to the continuously animated in-progress rings.
- [ ] Add achievement state/tier/category tests, visual snapshots or smoke coverage, and device QA.
- [ ] Connect the existing `AchievementRecentUnlocks` scaffold to award loading and real navigation; it is currently unused by the Hub.

### Completed achievement categories — **NOT STARTED**

- [ ] Split category summaries into active and completed for the selected achievement level.
- [ ] Keep active categories in the main dashboard and move `earned == total` categories into localized `Completed (N)` disclosure content.
- [ ] Keep the disclosure collapsed by default, hide it when empty, and recalculate it when the selected level changes.
- [ ] Preserve existing cards, detail navigation, and `View all`; add state and navigation tests.

### Collectible achievement medals — **NOT STARTED**

Research and the [detailed medal redesign plan](Docs/AchievementMedalRedesignPlan.md) are complete. The product implementation is not: the current badge remains a glyph inside rings.

- [x] Document reference principles from Duolingo, Apple Fitness, Strava, and Nike Run Club without copying their artwork.
- [x] Define the intended medal anatomy, automotive families, tiers/materials, states, Trophy Case hierarchy, unlock flow, privacy-safe share formats, accessibility, analytics, and staged rollout.
- [ ] Complete the Phase 0 achievement matrix and API/model gaps: stable design ids, proof snapshots, hidden/secret state, rarity, limited/seasonal metadata, and inventory semantics.
- [ ] Produce a six-medal Stitch pilot and scalable medal renderer/art pipeline.
- [ ] Build Trophy Case and Recent Unlocks hierarchy.
- [ ] Build share-card rendering and preview. Current share icons are no-op placeholders.
- [ ] Build unlock celebration, seen/unseen queue, haptics, recovery, and Reduce Motion behavior.
- [ ] Add Game Center reporting, retry/idempotency, assets, metadata, and entitlement. Current models only contain a few Game Center fields; there is no GameKit integration.

### Profile screen — **PARTIAL**

The old “temporary mock” description was stale. The iOS screen is functional; only the planned Stitch/design alignment remains.

- [x] Show the authenticated account identity and avatar.
- [x] Load and update region, default currency, and distance unit.
- [x] Edit display name and profile photo.
- [x] Keep the real account sign-out action separate from scenario navigation.
- [ ] Generate the Profile concept in the main Stitch project and reconcile it with existing Worth It design-system components.
- [ ] Complete device, Dynamic Type, loading/error, and accessibility QA; add tests around settings/profile updates.

### Application localization and language picker — **PARTIAL**

The foundation exists, but the app is still English-only.

- [x] `I18n`, generated typed keys, typed format arguments, and root SwiftUI locale injection exist.
- [x] `Localizable.xcstrings` currently has 301 English-only keys; the key generator is connected to the project build.
- [ ] Replace the fixed root locale (`en`) with an observable app language store and fallback chain.
- [ ] Add `System Default`, English, and Russian to Settings; persist the selection and update the app without restart.
- [ ] Complete the semantic-key migration. Audit counts at this checkpoint: 185 semantic catalog keys, 116 legacy catalog keys, 324 raw-string `i18n.t("...")` call sites across 62 files, and 164 obvious direct user-facing strings across 68 files.
- [ ] Localize dynamic formats, plurals, validation/errors, accessibility, widgets, notifications, achievement/share content, and empty/loading states.
- [ ] Make dates, numbers, currency, distance, capitalization, and list formatting locale-aware.
- [ ] Define a stable localization contract for backend achievement and analytics copy.
- [ ] Add missing/unused-key, placeholder, generator, and new-hardcode CI checks; add pseudolocalization, long-copy/Dynamic Type screenshots, and critical-flow smoke tests.
- [ ] After reviewed English and Russian, roll out the other 23 [official EU languages](https://european-union.europa.eu/principles-countries-history/languages_en) in reviewable waves with native review for financial, privacy, validation, and share copy.

### Make `Add Trip` the primary mileage action — **NOT STARTED**

- [x] The pre-existing edit flow already preserves an event's actual trip or odometer mode; this prerequisite does not implement the requested new default.
- [ ] Put `Add Trip` before `Update Odometer` in the selector.
- [ ] Default new mileage entry state and form reset to trip mode; both still use odometer mode.
- [ ] Add tests for a new entry plus editing both event types.

### Garage navigation icon — **NOT STARTED**

The navigation route already returns to the scenarios/Garage list, but its presentation is still logout-like.

- [ ] Replace `rectangle.portrait.and.arrow.right` with `door.garage.closed` after device QA, or use a Worth It garage/car glyph if it is unclear.
- [ ] Replace the hardcoded `Exit scenario` semantic label with a typed localized `Back to Garage` key.
- [ ] Remove the mirrored-exit treatment while leaving the real Profile sign-out action unchanged.

### Customizable top scenario tabs — **NOT STARTED**

The current worktree improves scroll synchronization only; all six chips remain hardcoded.

- [ ] Add visible tab ids to scenario settings and offline cache; default existing scenarios to all tabs visible.
- [ ] Keep Overview as the required anchor and preserve the existing relative order for the initial version.
- [ ] Filter visible chips and show a persistent trailing `+` only when optional tabs are hidden.
- [ ] Open a localized Visible / Hidden editor from `+` and support restoring tabs.
- [ ] Keep hidden features available to internal/deep-link navigation; fall back safely to Overview if the selected tab is hidden.
- [ ] Test all-visible, some-hidden, single-visible, selected-hidden, offline, sync, and reset states.

### Duplicate-entry warnings — **NOT STARTED**

Current expense, mileage, and scheduled-service save paths write directly through the repository. No preflight matcher, warning UI, central tolerances, or tests were found.

- [ ] Expenses: compare approximate amount, category, and timestamp.
- [ ] Trips/routes: compare approximate route, distance, and timestamp.
- [ ] Recurring/scheduled services: compare service identity plus overlapping recurrence or scheduled date.
- [ ] Keep detection advisory: show the likely existing record and offer Cancel or Save Anyway.
- [ ] Define tolerances centrally, exclude the record being edited, handle timezone/offline behavior, and test true matches plus nearby non-matches.

### OEM vehicle-data integration — **DEFERRED**

- [ ] Start only after Worth It has an EEA legal entity, backend support, GDPR/legal documents, provider budget, and validated demand.
- [ ] Keep the first version read-only, preserve manual logging, and do not promise real-time or complete historic trip data.
- [ ] Provider order remains BMW CarData B2B, then Audi/Volkswagen Group and Mercedes-Benz. See the [detailed OEM integration plan](Docs/OEMVehicleDataIntegrationPlan.md).
