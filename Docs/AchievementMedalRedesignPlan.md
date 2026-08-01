# Achievement Medal Redesign

Canonical tasks: ACH-100 through ACH-107

The canonical status, dependencies, and execution order live in the
[cross-repository roadmap](https://github.com/kudg0/assets-invest-comparator/blob/main/docs/product-work-plan.md).
This document expands the medal program and does not own backlog status.

## Product goal

Turn Worth It achievements from small status icons into collectible automotive medals that feel earned, remain recognizable across the app, and produce a share artifact people are proud to post.

North-star test: after an unlock, the user should want to inspect the medal, understand why it was earned, and consider sharing it without needing an extra explanation.

This is not a visual-only reskin. The work includes medal art direction, collection hierarchy, unlock celebration, progress states, sharing, metadata, accessibility, analytics, and production tooling.

## Current implementation baseline

The redesign must migrate the existing system instead of layering a second achievement UI beside it:

- `AchievementBadgeImage` currently draws one dashed circle and one monochrome center glyph for `locked`, `inProgress`, `earned`, and `maxTier`; `maxTier` is defined but not used.
- The asset catalog already contains 29 vector achievement glyphs. Treat them as candidate center marks, not finished medals, and redraw glyphs whose silhouettes fail at compact size.
- `AchievementGlyph` silently falls back to `car-ring` for an unknown backend value. The new resolver must expose a diagnostic fallback so missing art is discoverable before release.
- `WIAchievementProgressRing` provides progress and sweep motion, but continuous `TimelineView` animation can run in many map cells at once. The redesign must limit animation to visible/focused content and respect Reduce Motion.
- `AchievementRecentUnlocks` exists but is not connected to the hub.
- `listAchievementAwards()` exists in the repository but is not used by the current Achievements UI. Award records are needed for exact tier and the immutable awarded date. ACH-005 reads recent history without consuming it; ACH-101 defines, and ACH-104 alone consumes, the unseen cursor/ack lifecycle.
- Share icons already appear on map/detail surfaces, but currently have no share implementation.
- Game Center IDs exist in the payload, but the app has no GameKit reporting flow or entitlement integration yet.
- Achievements use handwritten models outside the generated OpenAPI contract, creating backend drift risk.
- Achievement-specific unit, snapshot, accessibility, share-rendering, and UI tests are currently missing.

## Reference findings

### Duolingo Achievements

Reference: [Duolingo achievement badge redesign](https://blog.duolingo.com/achievement-badges/)

Additional references: [streak milestone animation and share card](https://blog.duolingo.com/streak-milestone-design-animation/), [Year in Review sharing design](https://blog.duolingo.com/year-in-review-behind-the-scenes/)

Useful patterns:

- Achievements are treated as a visible collection rather than profile metadata.
- Large milestones, personal records, rare long-term goals, and playful surprises coexist.
- Awards can have multiple difficulty levels.
- The redesign explicitly optimizes for celebration and sharing.
- Every badge receives memorable artwork instead of only a generic status glyph.
- Major milestones receive a stronger transformation/reveal than routine progress.
- Shareable identities give ordinary users something meaningful to post, not only top-percentile performers.

Apply to Worth It:

- Give each achievement a distinct identity while keeping a shared Worth It medal grammar.
- Mix long-term ownership milestones with personal records and surprising behavioral achievements.
- Show tier progression through the medal itself, not only through nearby text.
- Make `Share` a first-class action on earned medals.
- Integrate a large verified number or short result mark into medals when the achievement is inherently numeric.
- Create identity medals such as `Garage Awake`, `Road Regular`, `Careful Keeper`, or `Cost Detective` alongside pure high-score awards.

Do not copy:

- Cartoon characters, Duolingo shapes, colors, or badge compositions.
- Excessive brightness that conflicts with Worth It's dark automotive analytics style.
- Celebration language that trivializes meaningful financial or vehicle data.
- Rewarding the act of sharing itself; sharing must remain voluntary and must not become an achievement requirement.

### Duolingo illustration system

Reference: [The shape language of Duolingo's art style](https://blog.duolingo.com/shape-language-duolingos-art-style/)

Useful patterns:

- Strong silhouette comes before small details.
- Minimal vector construction makes a large asset family scalable.
- Negative space protects readability at small sizes.
- Exaggeration and motion create personality and direct attention.

Apply to Worth It:

- Require every medal to remain identifiable at 40, 64, and 160 points.
- Build medals from reusable vector layers instead of commissioning an unrelated illustration for every state.
- Reserve fine engraving and texture for detail/share sizes; keep list-size rendering simple.

### Apple Fitness Awards

References: [Apple Watch awards](https://support.apple.com/en-lamr/guide/watch/apd3bf6d85a6/watchos), [Apple Fitness+ awards](https://www.apple.com/apple-fitness-plus/)

Useful patterns:

- Awards resemble physical objects, not ordinary interface icons.
- Personal records, streaks, milestones, monthly awards, and limited editions form separate collectible families.
- A medal can be inspected as an object; on Apple Watch it can be rotated.
- Limited awards can extend into animated stickers and other share surfaces.

Apply to Worth It:

- Use restrained dimensionality: layered rim, enamel face, edge highlight, depth shadow, and optional tilt response.
- Create recognizable families and occasional limited medals without breaking the core system.
- Give hero/detail presentation enough scale to appreciate the object.

### Strava Trophy Case

Reference: [Strava Trophy Case](https://support.strava.com/en-us/articles/15402068-the-strava-trophy-case)

Additional reference: [Strava activity sharing](https://support.strava.com/en-us/articles/15401840-sharing-your-strava-activities)

Useful patterns:

- Completed challenge badges live together in a dedicated trophy collection.
- Recent awards receive prominent profile placement.
- Each trophy opens its details and can be shared.
- Completion date provides collection history.
- Shared artifacts combine a relevant image with a small, selected set of stats rather than exposing the entire detail screen.

Apply to Worth It:

- Keep recent unlocks visible near the top of the hub.
- Treat completed medals as a trophy shelf, ordered by earned date with filters by family and tier.
- Preserve the planned collapsed `Completed (N)` category section for dashboard clarity while still offering a rich full collection.

### Nike Run Club challenges

Reference: [Nike Run Club challenges and trophies](https://www.nike.com/help/a/nrc-challenges)

Additional references: [Nike Run Levels](https://www.nike.com/help/a/nrc-run-level), [Nike Run Club share customization](https://www.nike.com/help/a/nrc-share)

Useful pattern: a clearly scoped challenge ends with a named trophy stored under Achievements. The goal and reward stay directly connected.

Additional useful patterns: long-term status is separate from individual trophies, while the share flow can use a route image, user photo, or designed poster with selected data.

Apply to Worth It: every medal detail and share card must state the verified action or milestone that earned it. Keep lifetime ownership level separate from individual medals. Avoid decorative awards whose requirement is ambiguous.

### Apple Game Center

References: [Game Center achievement design guidance](https://developer.apple.com/design/human-interface-guidelines/game-center/), [Rewarding players with achievements](https://developer.apple.com/documentation/gamekit/rewarding-players-with-achievements)

Useful patterns:

- Locked, in-progress, hidden, and completed are distinct states.
- Progressive achievements communicate completion clearly.
- High-quality unique artwork is required because achievements are prominent collectible content.
- Titles and descriptions stay short enough for compact cards.
- Achievement art is authored at 1024 x 1024 pixels for Game Center.

Apply to Worth It:

- Keep in-app state semantics aligned with Game Center where possible.
- Produce an export-safe 1024 x 1024 master for every Game Center achievement.
- Do not reuse one medal image for multiple achievements.

## Worth It art direction

Working concept: **Roadworthy Medals**.

The visual metaphor combines an automotive club badge, machined dashboard instrument, enamel pin, and premium ownership record stamp. It must feel grown-up and desirable, not like a casino token or a children's sticker.

### Medal anatomy

Every medal is assembled from consistent layers:

1. Outer silhouette — category family and immediate recognition.
2. Machined rim — tier/material and earned-state depth.
3. Enamel face — category palette and contrast.
4. Central symbol — achievement-specific story.
5. Result mark — a large number or compact sign when central to the achievement.
6. Progress or tier marks — readable without opening details.
7. Micro-engraving — optional achievement key, tier, or year at hero/share size only.
8. Light treatment — static highlight plus earned/max-tier effects.

### Category families

Initial family grammar:

| Category | Base silhouette | Visual motif | Suggested accent |
| --- | --- | --- | --- |
| Economics / Costs | chamfered coin | ledger segments, receipt cuts, declining graph | warm amber |
| Usage | road shield | route arc, odometer ticks, distance marks | electric blue |
| Consistency / Tracking | instrument dial | pulse, repeating ticks, calendar cadence | cyan |
| Lifecycle | key-head crest | key, wrench, service stamp, handoff | copper |
| Comparison / Alternatives | split hexagon | branching route, versus divide, two trajectories | violet |
| Value | faceted gauge | valuation dial, upward curve, retained value | gold |
| Evidence | inspection seal | document, scan line, verified stamp | mint |
| Social | linked roundel | people/network geometry | coral |

Final colors must become Worth It design tokens and pass contrast checks on existing dark surfaces. Category color is supporting information; shape and symbol must carry identity without color.

### Tier materials

Use tiers as increasing craft, not only color swaps:

- Tier 1 — dark steel rim, one enamel region, restrained reflection.
- Tier 2 — brushed silver rim, two enamel regions, deeper relief.
- Tier 3 — warm gold rim, richer highlight, engraved edge marks.
- Tier 4 / mastery — black chrome or platinum base with gold edge, subtle animated foil/sweep.

Exact names must follow the product's level model. Do not introduce Bronze/Silver/Gold copy unless it maps cleanly to backend semantics.

### State system

- `locked`: recognizable silhouette, matte graphite, obscured center detail, lock treatment, no celebratory glow.
- `inProgress`: category color appears on the face; rim or inset arc shows real progress.
- `earned`: full material, complete symbol, dimensional highlight, earned timestamp available in detail.
- `maxTier`: premium material, restrained animated foil/sweep, unique edge treatment.
- `hidden`: mystery silhouette and semantic mystery copy; do not expose secret requirements.

Locked art should create curiosity without making the collection look broken. Earned art must be visibly more valuable than in-progress art even in grayscale.

### Scale variants

One medal model, three deliberate render modes:

- `compact` at 36–48 pt: silhouette, rim, central symbol; remove texture and engraving.
- `collection` at 72–104 pt: full face, progress/tier marks, modest depth.
- `hero/share` at 180 pt and above: full material, texture, light, engraving, optional motion.

Avoid rendering the hero composition and merely shrinking it; small variants need fewer layers and stronger strokes.

## Achievement content model

The collection should include multiple motivation types:

- Milestones — cumulative distance, ownership duration, logged expenses, services completed.
- Personal records — most distance in a day/month, longest trip, strongest saving period, best consistency streak.
- Identity medals — recognizable ownership behaviors that feel personal and shareable without requiring extreme performance.
- Consistency — recurring logging and evidence habits.
- Mastery — tiered achievements with clear rising requirements.
- Surprise achievements — occasional behavior-based awards whose existence may remain hidden until first progress or completion.
- Limited or seasonal medals — used sparingly for genuinely time-bound events.

Copy framework:

- Title: short, evocative, ideally 1–3 words.
- Requirement: factual and unambiguous.
- Earned statement: past tense and specific.
- Proof fact: the user's verified number, date, or streak.
- Next tier: one clear target and remaining amount.

Avoid generic names such as `Achievement 3`, unexplained jargon, and fake scarcity.

## Experience changes

### Achievements Hub

- Replace tiny uniform line badges with `collection` medals.
- Keep active/in-progress categories in the main dashboard.
- Keep the already planned completed-category disclosure below active categories.
- Add a visually stronger Recent Unlocks shelf with earned date and direct share action.
- Add a Trophy Case entry point for all earned medals.
- Let the user filter the full collection by category, tier, earned/unearned, and newest.
- Consider one pinned/favorite medal for later profile display; keep this out of MVP unless a profile surface is ready.

### Achievement map

- Keep map progression readable; medal art must not overwhelm the path.
- Use compact medals for locked nodes, collection medals for the current/earned focus.
- Animate only the focused node and newly earned transition.
- Preserve a clear route to requirement and detail content.

### Achievement detail

- Make the medal the visual hero.
- Add subtle drag/tilt response or light parallax for earned hero medals; provide a static Reduce Motion version.
- Show status, tier, requirement, verified proof, earned date, rarity only when trustworthy, and next tier.
- Put `Share achievement` beside the primary earned-state action, not inside an overflow menu.
- Keep similar achievements below the core proof and progression content.

### Unlock celebration

Unlock is a short staged event, not a permanent looping animation. Use two intensity levels:

- Standard tier: contained sheet/overlay, one haptic, short sweep, approximately 1.0–1.6 seconds.
- Major, mastery, rare, or limited medal: full-screen spotlight/reveal, approximately 1.5–2.5 seconds, still immediately dismissible.

Shared sequence:

1. Existing badge resolves from locked/in-progress material.
2. Rim assembles or lights clockwise.
3. Central symbol lands with one controlled haptic.
4. Medal receives a brief highlight sweep.
5. Title, proof fact, and tier appear.
6. Actions: `Share` and `Continue`.

Never block dismissal. If several medals unlock together, show one summary followed by a horizontal review instead of playing multiple full-screen reveals back to back.

Respect Reduce Motion, Reduce Transparency, VoiceOver, and silent-device expectations. Sound is optional and off by default unless the broader product adds sound preferences.

## Sharing specification

Sharing is part of the feature definition, not a follow-up.

### Entry points

- Unlock celebration.
- Earned achievement detail.
- Recent Unlocks shelf.
- Trophy Case medal context action.

### Share artifact

Render a native image and share through SwiftUI `ShareLink` / `Transferable`: [Apple ShareLink documentation](https://developer.apple.com/documentation/swiftui/sharelink).

Initial formats:

- 1080 x 1920 story.
- 1080 x 1350 portrait feed.
- 1080 x 1080 square fallback.

Composition:

- Worth It brand mark, quiet and secondary.
- Large medal with enough negative space.
- Achievement title and tier.
- One human-readable earned statement.
- One proof stat, such as distance, streak, savings, or completion date.
- Optional scenario/vehicle label only with explicit user control.
- Small product line such as `Tracked with Worth It`; avoid aggressive acquisition copy.

Offer two visual variants only if user testing shows value:

- `Clean`: medal, title, date.
- `With stats`: medal plus proof fact and progress context.

### Privacy rules

- Never include exact routes, coordinates, home/work labels, number plates, attachments, notes, or merchant details.
- Hide scenario and vehicle names by default when they may identify the user.
- Financial values require an explicit preview and opt-in before rendering; offer `Hidden` by default, then `Rounded` or `Exact` when relevant.
- Render the final card locally; do not upload private data merely to generate an image.
- Show the exact share preview before opening the system sheet.

### Share quality bar

- Text remains readable after social-platform compression.
- Medal owns most visual attention.
- Card works without accompanying post text.
- Branding is recognizable but does not make the artifact look like an ad.
- Localized copy fits supported languages and Dynamic Type does not affect exported layout unpredictably.

## Data and backend requirements

Audit current payloads before locking the visual system. Likely additions:

- `medalDesignId` or stable visual style key.
- Explicit tier visual identity when level alone is insufficient.
- `isSecret` / hidden state.
- Earned proof snapshot so a shared award remains historically accurate after later data changes.
- Optional personal-record metadata.
- Optional trustworthy rarity percentage and minimum cohort threshold.
- Optional limited-edition availability window.
- Share-safe display facts separate from private raw event data.

Contract decisions required before implementation:

- Define one presentation-state resolver for `selectedLevel`, `earnedTierIndex`, required tiers, and max tier; every surface must use it.
- Decide whether backend-provided title, description, and tier labels are already localized for the requested locale or should become stable semantic identifiers.
- Separate global achievements from scenario-scoped proof. `sourceScenarioId` must control whether a vehicle/scenario can appear in detail or sharing.
- Move achievements into the generated OpenAPI contract or add an explicit contract test for the handwritten models.

Do not calculate rarity from a small cohort or invent labels such as `Rare`. If trustworthy global rarity is unavailable, use tier and completion state only.

Keep `gameCenterAchievementId` and reporting compatibility. Produce unique Game Center artwork and localized pre-earned/earned descriptions for mapped achievements.

## SwiftUI component plan

Evolve the current implementation rather than maintaining two badge systems.

Proposed components:

- `WIAchievementMedal` — shared medal renderer with compact, collection, and hero sizes.
- `WIAchievementMedalStyle` — category, tier/material, state, and motion tokens.
- `AchievementMedalArtwork` — stable mapping from backend design ID/glyph to visual composition.
- `AchievementUnlockCelebration` — presentation and seen/unseen lifecycle.
- `AchievementShareCard` — fixed-layout localized render target.
- `AchievementShareItem: Transferable` — asynchronous PNG export for `ShareLink`.
- `AchievementTrophyCase` — earned collection and filters.

Migration targets:

- Replace `AchievementBadgeImage` internally with the new renderer, keeping a compatibility wrapper during migration.
- Reuse `AchievementGlyph` assets only where their silhouettes meet the new compact-size bar; redraw weak or overly similar glyphs.
- Keep `WIAchievementProgressRing` for progress contexts, but do not use a progress ring as the medal itself.
- Preserve existing navigation from hub, map, category, similar achievement, and detail screens.

All new user-facing strings must use semantic keys in `Localizable.xcstrings`; regenerate `I18nKey.generated.swift` after additions.

## Delivery plan

### Phase 0 — inventory and metrics contract

- Inventory every current achievement, category, glyph, tier count, state, and Game Center mapping.
- Identify duplicate or weak glyph silhouettes.
- Define achievement taxonomy and proof fact for every award.
- Confirm backend fields and historical earned snapshot behavior.
- Define baseline analytics before visual launch.

Exit: signed-off medal matrix covering every achievement and state.

### Phase 1 — Stitch concept and art system

- Build reference/moodboard pages inside the existing Worth It Stitch project.
- Generate at least three directions: machined instrument, enamel club badge, and premium rally plaque.
- Test each direction on the current dark background at compact, collection, and hero sizes.
- Select one grammar; define category silhouettes, material tiers, colors, depth, texture, and lighting.
- Produce a six-medal pilot set covering different categories and states.

Exit: approved Stitch concept plus production token/art specification.

### Phase 2 — medal renderer MVP

- Implement `WIAchievementMedal` and style tokens.
- Migrate category cards, recent unlock rows, next unlock, map nodes, similar rows, and detail hero.
- Add snapshot previews for all states, sizes, categories, light conditions, and accessibility settings.
- Keep unlock behavior unchanged during this phase to isolate visual risk.

Exit: all current achievement surfaces use the unified medal system.

### Phase 3 — collection hierarchy

- Implement active versus completed category separation.
- Add Trophy Case with recent-first ordering and filters.
- Refine map emphasis and detail hierarchy around the new medals.
- Validate empty, locked-level, partial-progress, fully completed, and large-collection states.

Exit: collection feels browsable with 5, 30, and 100+ medals.

### Phase 4 — unlock celebration

- Add first-seen unlock state and queue semantics.
- Implement staged motion, haptics, Reduce Motion fallback, interruption, and dismissal.
- Handle unlocks received after refresh, offline recovery, and multiple simultaneous awards.

Exit: an award celebrates once, never gets lost, and never traps the user.

### Phase 5 — sharing

- Build story, portrait, and square share templates.
- Add privacy preview and safe-field policy.
- Implement local image rendering, `Transferable`, `ShareLink`, and error fallback.
- Add share entry points and analytics.
- Test common targets: Messages, Instagram-compatible save/share flow, WhatsApp, Telegram, Mail, Copy, and Save Image where available.

Exit: exported images meet the quality bar in English and every supported locale.

### Phase 6 — polish and rollout

- Complete remaining medal artwork and Game Center masters.
- Performance-test scrolling, image memory, and first render.
- Add feature flag or staged rollout.
- Compare behavior to baseline and iterate on weak medals/share templates.

Exit: stable production rollout with monitored engagement and no regression to core scenario flows.

## Acceptance criteria

Visual:

- Every medal has a distinct silhouette or central story at 40 pt.
- Category family and tier remain legible without reading text.
- Earned, in-progress, locked, and max-tier states remain distinguishable in grayscale.
- Medals feel native to Worth It's dark automotive visual language.
- No third-party artwork, trademarked characters, or copied badge compositions.

Product:

- User can find newly earned medals in one tap from the hub.
- User can understand requirement, earned proof, tier, and next target.
- Completed categories reduce dashboard noise without hiding the collection.
- Earned medal can be shared from celebration and detail.
- Multiple unlocks and offline refresh do not lose celebrations.

Technical:

- Smooth scrolling on the oldest supported iPhone target.
- No continuous animation in off-screen cells.
- Reduce Motion and VoiceOver paths are complete.
- Localized semantic keys only; no new hardcoded UI copy.
- Snapshot/unit tests cover state mapping, tier mapping, privacy filtering, and share rendering.
- Game Center artwork and descriptions remain valid for mapped achievements.

Treat full Game Center reporting as a separate integration after the in-app medal MVP is stable: entitlement, authentication, retry/reporting semantics, App Store Connect metadata, and release validation must not block the first visual migration.

## Success metrics

Primary:

- Unlock-to-share intent rate.
- Completed share-sheet action rate where observable without collecting destination content.
- Achievement detail open rate after unlock.
- Trophy Case revisit rate.

Secondary:

- Seven-day return after achievement unlock.
- Progression from one tier to the next.
- Percentage of users with at least one earned medal who revisit Achievements.
- Share render failures and time-to-share-sheet.

Guardrails:

- No increase in crash rate, memory warnings, or hub load time.
- No exposure of route, financial, vehicle, or merchant data in default share cards.
- Celebration dismiss rate and duration must not indicate that animation blocks normal work.

Suggested analytics events:

- `achievement_medal_viewed`
- `achievement_unlock_presented`
- `achievement_unlock_dismissed`
- `achievement_share_previewed`
- `achievement_share_started`
- `achievement_share_completed`
- `achievement_trophy_case_opened`
- `achievement_collection_filter_changed`

Do not log private proof values, route data, or share destinations unless a separate privacy review explicitly approves them.

## Main risks

- Asset explosion: solve with a compositional medal grammar and a limited hero-art budget.
- Small-size noise: maintain dedicated compact rendering.
- Fake rarity: omit rarity until the backend can support a trustworthy cohort calculation.
- Celebration fatigue: celebrate first unlocks once; keep repeated/recovered awards quiet.
- Share privacy: render from an allowlisted safe snapshot, never directly from raw scenario/event models.
- Style drift: approve the family in Stitch before producing the full asset set.
- Game Center mismatch: keep state, copy, image size, and ID mapping in the inventory matrix.

## Explicit non-goals for the first release

- Public leaderboards.
- Competitive ranking between users.
- Paid or purchasable medals.
- NFT/blockchain ownership.
- User-generated medal art.
- Public social profiles solely for displaying trophies.
