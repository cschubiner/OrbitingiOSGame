# Star Stream 3.0 release QA — 2026-10-15

## Automated checks

Xcode 27.0 / iOS SDK 27.0, iOS Simulator 26.5. The latest gameplay/layout hosted run passed **13 tests, zero failures** (`StarStreamSafeMenusFinal.xcresult`, retained outside Git).

Coverage includes immutable/restored leaderboards, top-20 score retention, repeated saved-game loading, real AVAudioPlayer playback/pause/resume/mute, full canvas coverage with a uniform scale, phone/iPad aspect ratios, fixed 60-Hz physics at 30/60/120 display callbacks, 100 generated maps' dimensions and flight-corridor clearance, favorite persistence and duplicate saves, and identical live planet/asteroid/star/powerup positions after replaying saved JSON. The camera test executes 3,600 updates without allocating follow actions or preallocating a HUD pickup sprite for each star.

Three seeded procedural routes each ran through the real steering/physics code for 60 simulated seconds with Autopilot, crossed several galaxies, and remained finite and playable. This reproduces and guards the old NSNull galaxy-color crash discovered during a longer run. A subsequent live simulator run reached galaxy 10, 171 planets and score 112,750 before normal game over, without that crash. Autopilot flight and geometry constraints are supplemented by manual swipes; they do not prove every possible human input succeeds.

The prior physical-iPhone hosted suite passed **12 tests, zero failures** before the viewport/procedural changes: five audio/persistence tests plus seven StoreKit Test cases. Purchases cover all five advertised pack amounts (1,520,000 combined), duplicate transaction delivery, wallet saturation, cancellation, pending approval, both permanent perks, restore, and refund/revocation. A mandatory local-only test product guards against accidentally charging the real App Store. iOS Simulator 26.5's SKTestSession service fails, so the purchase suite runs on the connected iOS 27 phone instead.

## Manual checks and captures

Dedicated iPhone SE 3, iPhone 17 Pro Max, iPad mini A17 Pro and iPad Pro 13-inch M5 simulators are used. The canvas now fills the whole device window; it is no longer fitted inside a 568×320 safe-area rectangle. Geometry retains a uniform scale, backgrounds extend into the extra space, and HUD controls follow safe edges.

Verified new flows include selecting a procedural map, playing it with swipes, saving it after game over, opening Favorite Maps from the main menu, and replaying the saved route. Existing checks cover pause/resume/quit, score and earned stars, shop categories and insufficient-star behavior, game-over name editing, Replay, and purchase/restore UI. Verified that store rows clip above the Restore Purchases footer on phone and iPad, and menu panels fit inside safe edges. Five new public screenshots for each family and seven IAP review screenshots were uploaded successfully.

## Performance

See [performance.md](performance.md) for the concrete old-code defects, simulator comparison and measurement limits. Simulator FPS is not an iPhone power measurement. The physical iPhone became unavailable before the new performance run, and reconnection was requested. Sustained device FPS/energy and the latest complete hardware suite remain pending that reconnection.

## Release state

App: Star Stream: Orbit Adventure (`6823318721`), bundle `com.cschubiner.starstream`, version 3.0. The game is free, with five optional consumable star packs and two permanent perks. All seven IAP records have localized metadata, availability, prices and review screenshots. App Privacy is published as Data Not Collected. The restored original description has been adapted to the current features.

Build 4 is uploaded, processed as VALID, and attached to version 3.0, replacing build 3. The App Store archive passed codesign verification; its IPA contains no StoreKit Test configuration, test bundle, or debug profiling markers. Automatic release after approval is configured. The app and all seven IAPs were submitted together at 7:56 PM EDT on October 15, 2026. App Store Connect and the public API both confirm WAITING_FOR_REVIEW, submission 3236a5e0-e7b0-4329-aecf-f904a291188b. This is a review submission; public availability still depends on Apple approval.
