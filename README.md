# Star Stream — OrbitingiOSGame

A revival of the original space arcade game for iPhone and iPad. Requires iOS 15 or later. The shipping app is free, works offline, and offers optional StoreKit 2 star packs and permanent perks alongside earned-star unlocks.

## Build and test

Open `Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj` in Xcode. Choose the `Star Stream` scheme to run the game, or `Star Stream QA` to run the hosted XCTest suite. No CocoaPods, Carthage, package download, or external service credentials are needed.

From the repository root:

```sh
xcodebuild -project 'Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj' \
  -scheme 'Star Stream' -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

# Replace SIMULATOR_ID with an available iPhone simulator from `xcrun simctl list devices`.
xcodebuild -project 'Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj' \
  -scheme 'Star Stream QA' -configuration Debug \
  -destination 'platform=iOS Simulator,id=SIMULATOR_ID' CODE_SIGNING_ALLOWED=NO test
```

Device builds require an Apple Development or Distribution identity and a matching provisioning profile for `com.cschubiner.starstream`. Set the development team and a matching development profile in Xcode for hardware runs. Release automation uses an explicitly selected App Store profile. Never commit signing certificates, keys, or profiles.

## Modernization

- Replaced CocosDenshion/OpenAL audio with an AVFoundation implementation retaining the game's existing API.
- Replaced iRate's network lookup and custom prompts with a StoreKit review adapter.
- Removed Kamcord recording, Flurry analytics, old StoreKit purchase helpers, remote tips, and unused Game Center entry points from the active app.
- Kept the original vendored cocos2d renderer and game logic, with arm64, CGFloat, shader, and compiler compatibility fixes. OpenGL ES remains a deprecated Apple API and is a future migration item.
- Expanded the logical viewport to fill each screen with a uniform point scale. Planets retain their proportions; HUD controls follow safe areas. Menu backgrounds fill the display and menu controls remain reachable.
- Added procedural routes based on the original maps’ scale and median spacing, with clear flight corridors, stable map RNG, and locally saved favorites containing the full geometry. Favorites replay from the main menu.
- Removed the per-frame creation of camera-follow actions, allocated pickup animation sprites only on collection, skipped dead-star physics, and applied a fixed 60-Hz physics clock. Display presentation explicitly requests 60 FPS.
- Added an asset-catalog icon, privacy manifest, modern launch configuration, and iPhone/iPad support.
- Fixed immutable saved-score and mission collections, repeated progress loading, and a missing upgrade-description accessor.

The old third-party source and unused images remain in the repository for provenance, but Kamcord, Flurry, OpenAL/CocosDenshion, and legacy purchase binaries are not linked or embedded in the shipping executable.

See [support](docs/support.md), [privacy](docs/privacy.md), and [QA evidence](docs/qa-report.md).
