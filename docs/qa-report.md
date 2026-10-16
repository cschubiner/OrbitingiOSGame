# Star Stream 3.0 release QA — 2026-10-15

## Automated checks

Xcode 27.0 / iOS SDK 27.0, iOS Simulator 26.5. The latest gameplay/layout hosted run passed **13 tests, zero failures** (`StarStreamSafeMenusFinal.xcresult`, retained outside Git).

Coverage includes immutable/restored leaderboards, top-20 score retention, repeated saved-game loading, real AVAudioPlayer playback/pause/resume/mute, full canvas coverage with a uniform scale, phone/iPad aspect ratios, fixed 60-Hz physics at 30/60/120 display callbacks, 100 generated maps' dimensions and flight-corridor clearance, favorite persistence and duplicate saves, and identical live planet/asteroid/star/powerup positions after replaying saved JSON. The camera test executes 3,600 updates without allocating follow actions or preallocating a HUD pickup sprite for each star.

Three seeded procedural routes each ran through the real steering/physics code for 60 simulated seconds with Autopilot, crossed several galaxies, and remained finite and playable. This reproduces and guards the old NSNull galaxy-color crash discovered during a longer run. A subsequent live simulator run reached galaxy 10, 171 planets and score 112,750 before normal game over, without that crash. Autopilot flight and geometry constraints are supplemented by manual swipes; they do not prove every possible human input succeeds.

After the phone reconnected, the complete current physical-iPhone suite passed **20 tests, zero failures or skips** (`StarStreamHardwareBuild4.xcresult`): 13 gameplay/layout/audio/persistence tests plus seven StoreKit Test cases. Purchases cover all five advertised pack amounts (1,520,000 combined), duplicate transaction delivery, wallet saturation, cancellation, pending approval, both permanent perks, restore, and refund/revocation. A mandatory local-only test product guards against accidentally charging the real App Store. iOS Simulator 26.5's SKTestSession service fails, so the purchase suite runs on the connected iOS 27 phone instead.

## Manual checks and captures

Dedicated iPhone SE 3, iPhone 17 Pro Max, iPad mini A17 Pro and iPad Pro 13-inch M5 simulators are used. The canvas now fills the whole device window; it is no longer fitted inside a 568×320 safe-area rectangle. Geometry retains a uniform scale, backgrounds extend into the extra space, and HUD controls follow safe edges.

Verified new flows include selecting a procedural map, playing it with swipes, saving it after game over, opening Favorite Maps from the main menu, and replaying the saved route. Existing checks cover pause/resume/quit, score and earned stars, shop categories and insufficient-star behavior, game-over name editing, Replay, and purchase/restore UI. Verified that store rows clip above the Restore Purchases footer on phone and iPad, and menu panels fit inside safe edges. Five new public screenshots for each family and seven IAP review screenshots were uploaded successfully.

## Performance

See [performance.md](performance.md) for the old-code defects, measurements and limits. A matched physical-iPhone run averaged 59.02 FPS, with app CPU use falling from 9.78% to 6.58% when the old camera/HUD behavior was removed (32.8% less CPU time). Both runs crossed the same 67 planets by 100 seconds. The full optimized capture spans 145 seconds. Direct power profiling was unavailable, so no battery-life percentage is claimed. The app was left running normally with profiling switches off.

## Release state

App: Star Stream: Orbit Adventure (`6823318721`), bundle `com.cschubiner.starstream`, version 3.0. The game is free, with five optional consumable star packs and two permanent perks. All seven IAP records have localized metadata, availability, prices and review screenshots. App Privacy is published as Data Not Collected. The restored original description has been adapted to the current features.

Build 4 is uploaded, processed as VALID, and attached to version 3.0, replacing build 3. The App Store archive passed codesign verification; its IPA contains no StoreKit Test configuration, test bundle, or debug profiling markers. Automatic release after approval is configured. The app and all seven IAPs were submitted together at 7:56 PM EDT on October 15, 2026. App Store Connect and the public API both confirm WAITING_FOR_REVIEW, submission 3236a5e0-e7b0-4329-aecf-f904a291188b. This is a review submission; public availability still depends on Apple approval.

## Build 5 regression and tuning verification

The physical iPhone passed **27 tests, zero failures or skips** (`StarStreamTuningHardware5.xcresult`): 19 gameplay tests and eight StoreKit Test cases, including the actual all-seven-product tuning gate and its persistence/revocation. An additional native controller test covers slider target/action delivery, displayed values, Done persistence, and Reset Defaults. The iPhone SE, iPad mini and 13-inch iPad Pro each passed the resulting full **20 gameplay/UI tests** with zero failures. The large iPhone passed the 19-test gameplay run plus the added controller test separately.

New coverage exercises normal Autopilot collision pickup and expiry in both map modes, with and without the upgrade; first-run tutorial persistence and one-run Replay; finite/clamped settings; actual game-speed and player-speed movement; favorite physics snapshots; and exact JSON geometry without duplicate saves. Star-to-planet and star-to-star clearance is checked across 300 maps (100 seeds at defaults and both tuning extremes), 120 sections per map. Actual live sprite clearance is checked across section seams for 20 seeds. Existing three-seed, 60-second flight and camera/HUD bounds tests continue passing.

Manually verified Options and Tuning on iPhone SE, large iPhone, iPad mini and iPad Pro, including touch-driven slider changes, scrolling and reset. A normal procedural run accepted a swipe, reached the next planet, collected stars, ended at score 377, and saved its map successfully. Existing version 1 favorites remain loadable and keep their saved geometry; the new placement applies to new maps. See [tuning.md](tuning.md) for all controls and the root causes.

Version 3.0 build 5 was archived, exported, codesign-verified and processed by Apple as VALID. The distribution executable contains neither the local unlock command nor the two profiling switches, and its app bundle contains no test configuration or test bundle. Build 4's review was canceled and build 5 attached. The replacement submission is prepared; current submission state is recorded separately in the release receipt.
