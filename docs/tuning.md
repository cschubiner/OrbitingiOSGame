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

Favorites store full geometry and the run's tuning. Selecting a favorite always uses that saved tuning, even if global sliders change. New maps use generator version 3, with binary fixed-point coordinates that survive JSON without rounding-induced duplicate favorites. Existing version 1 and 2 favorites retain their original geometry (and version 1 its default physics). Old favorites are intentionally not regenerated; choose a new procedural map for the new layouts.

## Procedural generator version 3

Version 2 built every section the same way: five equal planets on a gentle line, three stars in a row per gap and a mirrored asteroid pair. Version 3 is measured against the handmade galaxies (`LevelsFromLevelCreator`) and ramps from galaxy 1 to galaxy 10:

- Each section has a style: cruise, zigzag, sweep, asteroid gauntlet, asteroid field or star stream. Later galaxies favor gauntlets and fields.
- Sections hold 4–6 planets. Interior planets range from 0.78× to 1.6× size; section ends stay 1× so seams match. Hops range from tight (≈350) to long jumps (up to 950), and the maximum heading change grows from about 32° to 77°.
- Stars form lines, bowed arcs, waves, partial rings around interior planets and risky off-route clusters.
- Asteroids line the corridor, scatter as fields, wall gauntlets and include occasional wide boulders. At default tuning, median rocks per section rise from about 12 (galaxy 1) to about 30 (galaxy 10), against 15–40 in the handmade maps.

Every object is placed by rejection against fixed fairness rules: stars clear planet art and each other by 32 world points; rocks clear every orbit zone and stay at least 100 map units (plus their radius) from every hop in the section; section first and last hops stay within 25° of the section axis. The tests check these rules for 60 seeds and at the minimum and maximum of every tuning slider.

## Bugs found

- The 2013 commit `06862536974822d1e029c14ba7b8c5ede3323435` changed Autopilot's base duration from `5*60*1.3` to `50000*60*1.3` ticks. That is 65,000 seconds, about 18 hours. The normal value is restored to 390 ticks, **6.5 simulation seconds**, or 440 ticks (**7.33 seconds**) with the duration upgrade. The prior long-flight performance test intentionally forced an infinite powerup and did not catch the normal-duration bug. A new test collects a normal powerup through collision handling and checks actual expiry in classic and procedural modes, with and without the upgrade.
- Tutorial hints used transient per-run flags, a helper that permitted 99,999 plays, and a separate introductory mode lasting multiple games. The swipe-hand prompt had no tutorial-mode check. A persistent seen flag now reserves the tutorial for the first run, including a run quit before score saving. Existing players skip it. Options > Replay Tutorial explicitly enables it for one run.
- Procedural star centers were evenly spaced between planet centers. Geometry coordinates are scaled by 0.498 in gameplay while planet art is not; the first star could therefore overlap the visible body. The generator now reserves the maximum planet radius for its scale, the full animated star radius, and a 14-point visual gap. Star count adapts to the remaining corridor, with at least 32 world points between star centers. Enlarging or crowding planets cannot remove this clearance.

## Local development save unlock

Debug builds accept the one-time launch argument `--unlock-local-testing`. It grants all 33 local shop unlocks, credits the five pack amounts once (1,520,000 stars), preserves existing equipped choices and progress, and opens Tuning. This does not create transactions or receipts and does not charge the App Store. Subsequent StoreKit reconciliation preserves the local testing override in Debug. The grant command and override are compiled out of the App Store build; they are not a shipping purchase path.
