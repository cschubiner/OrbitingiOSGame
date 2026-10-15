# Star Stream — OrbitingiOSGame

A revival of the original space arcade game for iPhone and iPad. Requires iOS 15 or later. The shipping app is free, works offline, and uses earned stars for every unlock.

## Build and test

Open `Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj` in Xcode. Choose the `Planet Orbiting iOS Game` scheme to run the game, or `Star Stream QA` to run the hosted XCTest suite. No CocoaPods, Carthage, package download, or external service credentials are needed.

From the repository root:

```sh
xcodebuild -project 'Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj' \
  -scheme 'Planet Orbiting iOS Game' -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

# Replace SIMULATOR_ID with an available iPhone simulator from `xcrun simctl list devices`.
xcodebuild -project 'Planet Orbiting iOS Game/Planet Orbiting iOS Game.xcodeproj' \
  -scheme 'Star Stream QA' -configuration Debug \
  -destination 'platform=iOS Simulator,id=SIMULATOR_ID' CODE_SIGNING_ALLOWED=NO test
```

Device builds require an Apple Development or Distribution identity and a matching provisioning profile for `com.cschubiner.starstream`. The project uses automatic development signing; release automation can override it with a manually selected App Store profile. Never commit signing certificates, keys, or profiles.

## Modernization

- Replaced CocosDenshion/OpenAL audio with an AVFoundation implementation retaining the game's existing API.
- Replaced iRate's network lookup and custom prompts with a StoreKit review adapter.
- Removed Kamcord recording, Flurry analytics, old StoreKit purchase helpers, remote tips, and unused Game Center entry points from the active app.
- Kept the original vendored cocos2d renderer and game logic, with arm64, CGFloat, shader, and compiler compatibility fixes. OpenGL ES remains a deprecated Apple API and is a future migration item.
- Embedded the authored 568 × 320 landscape game canvas proportionally inside the available safe area. This preserves gameplay and touch coordinates across small phones, display cutouts, and large iPads; unused space is letterboxed.
- Added an asset-catalog icon, privacy manifest, modern launch configuration, and iPhone/iPad support.
- Fixed immutable saved-score and mission collections, repeated progress loading, and a missing upgrade-description accessor.

The old third-party source and unused images remain in the repository for provenance, but Kamcord, Flurry, OpenAL/CocosDenshion, and legacy purchase binaries are not linked or embedded in the shipping executable.

See [support](docs/support.md), [privacy](docs/privacy.md), and [QA evidence](docs/qa-report.md).
