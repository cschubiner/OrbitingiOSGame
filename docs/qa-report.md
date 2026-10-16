# Star Stream 3.0 build 5 QA — 2026-10-15

## Automated checks

Xcode 27.0 / iOS SDK 27.0; simulator runtime 26.5; physical iPhone 17 Pro Max running iOS 27.0.1.

- **Physical iPhone: 27 tests passed**, zero failures or skips (`StarStreamTuningHardware5.xcresult`): 19 gameplay/layout/audio/persistence tests and eight StoreKit Test cases.
- **iPhone SE, iPad mini and iPad Pro 13-inch: 20 gameplay/UI tests passed on each**, zero failures (`StarStreamTuningSmall5.xcresult`, `StarStreamTuningMini5.xcresult`, `StarStreamTuningPro5.xcresult`).
- **Large iPhone simulator:** all 19 gameplay tests passed (`StarStreamTuningSimulator3.xcresult`), then the added native slider/controller test passed separately (`StarStreamTuningUITest1.xcresult`).

Coverage includes immutable/restored leaderboards, saved-game loading, audio, uniform fullscreen canvas and safe menu edges across phone/iPad aspect ratios, fixed 60-Hz physics at 30/60/120 display callbacks, favorite persistence and duplicate saves, and identical live map positions after saved JSON replay. The camera test executes 3,600 updates without follow-action allocation or a preallocated HUD sprite per star.

Build 5 adds normal Autopilot collision pickup and actual expiry in both map modes, with and without its upgrade; first-run tutorial persistence and one-run Replay; malformed/clamped tuning values; actual game-speed and player-speed changes; saved favorite physics; and slider action delivery, displayed values, Done persistence and Reset Defaults.

Star-to-planet and star-to-star clearance is checked across **300 maps** (100 seeds each at defaults and the minimum/maximum tuning presets), with 120 sections per map. Actual live sprite clearance is also checked across section seams for 20 seeds. Three seeded routes run through real steering/physics for 60 simulated seconds each with a test-only long-lived Autopilot, crossing multiple galaxies without a crash. The normal-expiry regression is separate from this endurance test.

The eight StoreKit Test cases cover all five pack amounts, duplicate delivery, reload, wallet saturation, cancellation, pending approval, permanent perks, restore, refund/revocation, and the actual seven-product tuning gate with persistence. A mandatory local-only guard product prevents falling through to real App Store charges. Simulator 26.5's SKTestSession service fails, so purchase tests use the physical iPhone.

## Manual checks

Dedicated iPhone SE 3, iPhone 17 Pro Max, iPad mini A17 Pro and iPad Pro 13-inch M5 simulators were used. Menu and gameplay fill the actual display; HUD and controls follow safe edges. Options and the native scrollable tuning menu fit all four screens. Touch-driven slider changes, scrolling, Done and Reset Defaults work.

A normal procedural run accepted a manual swipe, reached the next planet, collected stars, ended at score 377 and saved the map. Favorite Maps listed that seed and launched it for replay. Existing checks cover pause/resume/quit, shop categories, insufficient-star behavior, score/name editing, Replay and purchase/restore UI. Store rows clip above their footer. Five public screenshots per family and all seven IAP review screenshots were uploaded previously.

New maps use generator version 2 with safe star spacing and fixed-point geometry. Existing version 1 favorites remain loadable and preserve their original geometry and default physics. They are not regenerated. See [tuning.md](tuning.md) for controls, exact-replay behavior and bug causes.

## Performance evidence

See [performance.md](performance.md) for the old-code defects, controlled build 4 measurements and limits. A matched physical-iPhone comparison averaged 59.02 FPS and reduced app CPU time from 9.78% to 6.58% (32.8% less CPU time) when the old camera/HUD behavior was removed. Both runs reached 67 planets by 100 seconds; the optimized capture spans 145 seconds. Direct power profiling was unavailable, so actual battery-life improvement remains unmeasured. These numbers are the earlier controlled comparison, not a new build 5 power measurement.

## Distribution and current release state

Star Stream: Orbit Adventure, Apple ID 6823318721, bundle com.cschubiner.starstream, version 3.0 build 5. Free game, five optional star packs and two permanent perks. All seven IAP records retain complete metadata, availability, prices and review screenshots. App Privacy is Data Not Collected. The original description is adapted to the revived features and describes the optional tuning gate.

Build 5 is archived, exported, codesign-verified, uploaded, processed as VALID, and attached to version 3.0. Its executable excludes the local unlock command and both profiling switches; its app bundle contains no StoreKit Test configuration or test bundle.

Build 4's review was canceled to replace the known bugs. Replacement submission 1768d797-19a3-478d-b8e9-debb717ae2ab is **READY_FOR_REVIEW**, with the app version attached. The seven IAPs are **READY_TO_SUBMIT**, pending addition through App Store Connect's web UI before submitting the combined package. This draft is not queued for Apple review. Automatic release AFTER_APPROVAL remains configured. Public availability is not confirmed.
