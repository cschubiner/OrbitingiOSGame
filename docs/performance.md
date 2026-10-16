# Frame pacing and energy work

The 2012–2013 simulation used a mixture of per-frame constants and elapsed-time movement. Gravity, time dilation, powerup counters, pickup acceleration, and timeout counters assumed 60 updates per second. A fixed 60-Hz accumulator now advances the same original tuning at 30, 60, or 120 display callbacks, with bounded catch-up after a stall. CADisplayLink explicitly requests 60 FPS.

Every star also created an extra, unbatched HUD sprite for its eventual pickup animation, parked just outside the screen. Cocos2d still visited and submitted these visible sprites. Pickup sprites are now created on collection and removed when their animation finishes. Dead stars skip physics, stationary stars skip vector normalization, and score text is regenerated only when the displayed value changes. Menu background particles are bounded and fill the actual viewport.

The camera used to allocate a new CCFollow action on every update. The target was not a running scene node, so CCFollow completed on the following tick. This was repeated allocation and redundant scheduling, not an indefinitely growing action list. The camera now assigns its calculated position directly.

The longer procedural flight test found an older transition crash: discarded galaxies were replaced by NSNull, but color interpolation checked only for a null pointer. The type check now uses the previously saved color for a discarded galaxy.

## Evidence and limits

The native XCTest clock test produces exactly 600 simulation ticks over 10 seconds at each of 30, 60 and 120 Hz. The replay test rebuilds the same live planet, asteroid, star and powerup geometry after a JSON round trip, and verifies zero camera actions after 3,600 camera updates.

An instrumented iPhone 17 Pro Max simulator run used the same procedural seed and build with the old camera/HUD behaviors enabled and disabled. Initial HUD nodes fell from 65 to 5; in the next galaxy they fell from 98 to 4. The optimized simulator measured roughly 43–55 FPS during the first 20 seconds, compared with roughly 41–53 FPS with the old behaviors enabled. These are simulator observations on a busy shared Mac, not reliable iPhone GPU, power or battery-life measurements. CPU percentages were similar in that sample. No percentage battery-life improvement is claimed.

A post-fix live simulator flight reached the tenth galaxy, visited 171 planets, and ended normally at score 112,750. Native physics coverage also advances three distinct seeds for 60 simulation seconds each across several galaxies. The full gameplay/layout suite now passes 13 tests with zero failures.

## Physical iPhone measurement — October 15, 2026

After reconnection, the current build passed **20 hardware tests, zero failures or skips**, on an iPhone 17 Pro Max running iOS 27.0.1 (`StarStreamHardwareBuild4.xcresult`). This includes all 13 current gameplay/layout tests and all seven local StoreKit Test cases.

A controlled Debug comparison used seed 12345678 with Autopilot. One run re-enabled the old camera allocation and eager pickup-HUD sprite behavior; the other used the optimized path. Both used the corrected fixed-step physics and the same current audio/rendering code. This isolates those two costs rather than reconstructing the entire 2013 app. Discarding the first five seconds and comparing the next 95 seconds:

| Metric | Old camera/HUD behavior | Optimized |
| --- | ---: | ---: |
| Mean FPS | 59.07 | 59.02 |
| App CPU time / wall time | 9.78% | 6.58% |
| Mean frame-work time | 2.54 ms | 1.92 ms |
| HUD nodes at 100 seconds | 362 | 4 |
| Planets visited at 100 seconds | 67 | 67 |

The optimized path used **32.8% less app CPU time** in that matched interval while maintaining approximately 59 FPS. CPU percentage here uses process CPU time divided by wall time; 100% represents one full CPU core, not the whole phone. The full optimized capture spans 145 seconds, reaches the tenth galaxy without crashing, and remains near the 60-FPS target.

A valid direct power/energy trace could not be obtained: Instruments could not find the running app by name or PID; a minimal standalone Power Profiler trace ended after about two seconds with Device disconnected while CoreDevice file transfer still worked. Those trace attempts are not used as energy evidence. Actual battery-life improvement remains unmeasured; the CPU reduction is not a battery-life percentage. After profiling, the app was relaunched normally with both debug switches off.

Profiling flags and legacy-behavior switches are compiled only into COCOS2D_DEBUG builds. The release executable does not expose them.
