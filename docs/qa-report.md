# Star Stream 3.0 (1) QA — 2026-10-15

## Reproducible automated verification

Xcode 27.0, iOS SDK 27.0, iOS Simulator 26.5. Debug hosted XCTest run: 5 tests passed, zero failures. Result bundle: `FinalRegression.xcresult` retained in the release workspace, outside Git.

Tests cover restored immutable leaderboards, empty score initialization, the top-20 score limit, repeated saved-game loading with owned upgrades and mission flags, and actual AVAudioPlayer background/effect playback including pause/resume/mute. The persistence regression tests reproduce two crashes discovered by manual gameplay and cold-launch testing.

Signed Release arm64 archive and App Store IPA export succeeded. `codesign --verify --deep --strict` passed. The IPA includes the privacy manifest and asset-catalog icon, with no test bundle or Kamcord/Flurry framework embedded. Minimum OS: iOS 15.0; device families: iPhone and iPad.

## Manual simulator coverage

| Device | Resolution | Verified |
| --- | --- | --- |
| iPhone SE (3rd generation) | 1334 × 750 landscape | Main menu, swipe tutorial, scoring, pause/quit, shop and insufficient-star behavior |
| iPhone 17 Pro Max | 2868 × 1320 landscape | Safe-area fit around display cutout, menu/shop, disabled unaffordable purchase, earned-star unlock, cold launch restores 70,000 stars and equipped Double Stars |
| iPad mini (A17 Pro) | 2266 × 1488 landscape | Menu fit, swipe input, tutorial, score 160, game over and player-name keyboard editing |
| iPad Pro 13-inch (M5) | 2752 × 2064 landscape | Portrait-to-landscape re-layout, actual swipe tutorial and scoring (125), game over, Replay, pause and Quit |

All tested layouts retain proportions and reachable controls. iPads show top/bottom letterboxing; wide phones show side letterboxing. The game is designed for landscape. Screen fit was checked at these representative sizes, not on every Apple device.

An isolated simulator-only 100,000-star fixture was used to test a 30,000-star purchase. It is not an app default. Independent saved-preferences readback and a later launch without the fixture showed 70,000 stars and owned/equipped upgrade code 0.

## Release preparation

App Store Connect app: Star Stream: Orbit Adventure (`6823318721`). Bundle ID: `com.cschubiner.starstream`. The shorter title Star Stream was unavailable. Version 3.0 is prepared for manual release, with no review submission performed.

Description, keywords, review instructions, support/privacy pages, category, age rating, free pricing, and 175-country availability are configured. App Privacy is published as Data Not Collected. Actual iPhone and 13-inch iPad screenshots are being attached to the version.

## Limits and follow-up

A physical device was unavailable during this run. Speaker output, real-device GPU/performance, memory pressure, interruptions, and the oldest supported iOS version still need physical/TestFlight testing. The automated audio check confirms that playback starts; it does not substitute for listening on hardware.

No app review approval or public release is implied by a successful build upload. The current account has a new Paid Apps Agreement awaiting acceptance; inspect the account notice before a submission. Accepting legal terms requires the account holder's action-time decision.
