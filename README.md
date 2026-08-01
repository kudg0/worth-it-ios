# Worth It iOS

Native SwiftUI client for Worth It.

Target architecture: the backend contract is consumed through OpenAPI rather
than by importing backend source. The current production repositories still use
handwritten HTTP/wire models for many endpoints; migration and drift protection
are tracked as CONTRACT-001 in the canonical roadmap.

## Contract

Development backend:

    OPENAPI_URL=http://localhost:3000/docs/json ./Scripts/fetch-openapi.sh

The script updates Sources/WorthItAPI/openapi.json for
swift-openapi-generator.

## Build notes

- Target platform: iOS 18+.
- Open WorthIt.xcodeproj, select the WorthIt scheme, choose the default iPhone
  simulator, and Run.
- Do not run the Swift Package as the app. The package owns the generated
  WorthItAPI client; SwiftUI app code lives in WorthItApp.
- Views should depend on repositories/services rather than direct HTTP.

## Product roadmap

There is one roadmap for backend and iOS:

- Local sibling checkout:
  ../assets-invest-comparator/docs/product-work-plan.md
- Repository:
  [assets-invest-comparator/docs/product-work-plan.md](https://github.com/kudg0/assets-invest-comparator/blob/main/docs/product-work-plan.md)

Do not add task status or a second backlog to this README. Focused documents in
Docs expand canonical task IDs:

- Docs/ActionButtonInteractionPlan.md — UX-001
- Docs/AchievementMedalRedesignPlan.md — ACH-100 through ACH-107
- Docs/OEMVehicleDataIntegrationPlan.md — OEM-001
- Docs/ValueFirstOnboardingPlan.md — ONB-100 through ONB-105
