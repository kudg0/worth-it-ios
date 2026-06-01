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

## Product TODO

- Generate the Profile screen in Stitch. It should cover user authorization state, account details, selected distance unit, default currency, and region. Current iOS implementation is a temporary mock.
- Generate/customize the Overview board widget picker. Users should be able to choose which KPI widgets appear in the hero carousel and supporting board. The iOS carousel already stores selected/enabled metric ids in app storage; the picker UI still needs a Stitch design.
