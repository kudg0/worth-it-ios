# Project Agent Notes

Please review yourself through this `AGENTS.md`.

Default communication mode for every new chat:

- Enable `caveman:caveman` automatically from chat start.
- Use Russian mode by default: `ru-full`.
- Keep this mode active for whole chat unless user says `normal mode`, `stop caveman`, or `обычный режим`.

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
- After adding semantic localization keys, run `python3 Scripts/generate_i18n_keys.py`.
- Do not add new hardcoded English strings in SwiftUI views, API error mappers, alerts, buttons, placeholders, or validation messages.
