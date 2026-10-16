# Flight tuning and build 5 fixes

Open **Main Menu > Options > Tuning / Debug Menu**. Normal players unlock the menu after buying each of the seven paid products at least once on this device: Double Stars, Pink Stars, and the five star packs. Verified delivery saves product history in the same persistent snapshot as the wallet and transaction IDs. Re-delivery cannot grant a pack twice. Refunding a product removes it from the unlock history. Restore Purchases restores permanent perks; consumed packs and their local history cannot be restored after reinstalling.

Core gameplay, procedural maps, Favorites, and Replay Tutorial remain free. These controls change the next run; they do not modify an active simulation. Closing the menu saves changes. Reset Defaults restores the original balance, then Done saves it.

| Control | Default | Range | Effect |
| --- | ---: | ---: | --- |
| Game speed | 1 | 0.5–1.5 | Simulation ticks per real second; physics still uses 60 Hz steps |
| Player speed | 1 | 0.6–1.5 | Ship travel per simulation tick |
| Difficulty | 1 | 0.5–2 | Battery drain; asteroid count in new procedural maps |
| Gravity strength | 1 | 0.4–2 | Orbital launch velocity and gravitational acceleration |
| Planet rotation | 0 | 0–3 | Visual spin; each unit is 30 degrees per simulation second |
| Camera zoom | 1 | 0.75–1.25 | Camera magnification |
| Powerup duration | 1 | 0.5–2 | Autopilot, Star Magnet, Asteroid Armor duration |
| Battery capacity | 1 | 0.5–2 | Maximum charge |
| Planet density | 1 | 0.7–1.4 | New-map planet spacing, constrained by safe clearance |
| Planet size | 1 | 0.7–1.3 | New-map planet bodies and orbit zones |
| Asteroid density | 1 | 0–2 | New-map hazard count |
| Asteroid size | 1 | 0.6–1.4 | New-map asteroid size |
| Star density | 1 | 0.5–2 | New-map star count, capped by safe spacing |
| Route bends | 1 | 0–1.5 | New-map changes in route direction |
| Powerup frequency | 1 | 0–2 | New-map pickup frequency |

Favorites store full geometry and the run's tuning. Selecting a favorite always uses that saved tuning, even if global sliders change. New maps use generator version 2, with binary fixed-point coordinates that survive JSON without rounding-induced duplicate favorites. Existing version 1 favorites retain their original geometry and default physics. Old favorites are intentionally not regenerated; choose a new procedural map for the new star placement.

## Bugs found

- The 2013 commit `06862536974822d1e029c14ba7b8c5ede3323435` changed Autopilot's base duration from `5*60*1.3` to `50000*60*1.3` ticks. That is 65,000 seconds, about 18 hours. The normal value is restored to 390 ticks, **6.5 simulation seconds**, or 440 ticks (**7.33 seconds**) with the duration upgrade. The prior long-flight performance test intentionally forced an infinite powerup and did not catch the normal-duration bug. A new test collects a normal powerup through collision handling and checks actual expiry in classic and procedural modes, with and without the upgrade.
- Tutorial hints used transient per-run flags, a helper that permitted 99,999 plays, and a separate introductory mode lasting multiple games. The swipe-hand prompt had no tutorial-mode check. A persistent seen flag now reserves the tutorial for the first run, including a run quit before score saving. Existing players skip it. Options > Replay Tutorial explicitly enables it for one run.
- Procedural star centers were evenly spaced between planet centers. Geometry coordinates are scaled by 0.498 in gameplay while planet art is not; the first star could therefore overlap the visible body. The generator now reserves the maximum planet radius for its scale, the full animated star radius, and a 14-point visual gap. Star count adapts to the remaining corridor, with at least 32 world points between star centers. Enlarging or crowding planets cannot remove this clearance.

## Local development save unlock

Debug builds accept the one-time launch argument `--unlock-local-testing`. It grants all 33 local shop unlocks, credits the five pack amounts once (1,520,000 stars), preserves existing equipped choices and progress, and opens Tuning. This does not create transactions or receipts and does not charge the App Store. Subsequent StoreKit reconciliation preserves the local testing override in Debug. The grant command and override are compiled out of the App Store build; they are not a shipping purchase path.
