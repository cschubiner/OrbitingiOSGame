# Frame pacing and energy work

The 2012–2013 simulation used a mixture of per-frame constants and elapsed-time movement. Gravity, time dilation, powerup counters, pickup acceleration, and timeout counters assumed 60 updates per second. A fixed 60-Hz accumulator now advances the same original tuning at 30, 60, or 120 display callbacks, with bounded catch-up after a stall. CADisplayLink explicitly requests 60 FPS.

Every star also created an extra, unbatched HUD sprite for its eventual pickup animation, parked just outside the screen. Cocos2d still visited and submitted these visible sprites. Pickup sprites are now created on collection and removed when their animation finishes. Dead stars skip physics, stationary stars skip vector normalization, and score text is regenerated only when the displayed value changes. Menu background particles are bounded and fill the actual viewport.

The camera used to allocate a new CCFollow action on every update. The target was not a running scene node, so CCFollow completed on the following tick. This was repeated allocation and redundant scheduling, not an indefinitely growing action list. The camera now assigns its calculated position directly.

The longer procedural flight test found an older transition crash: discarded galaxies were replaced by NSNull, but color interpolation checked only for a null pointer. The type check now uses the previously saved color for a discarded galaxy.

## Evidence and limits

The native XCTest clock test produces exactly 600 simulation ticks over 10 seconds at each of 30, 60 and 120 Hz. The replay test rebuilds the same live planet, asteroid, star and powerup geometry after a JSON round trip, and verifies zero camera actions after 3,600 camera updates.

An instrumented iPhone 17 Pro Max simulator run used the same procedural seed and build with the old camera/HUD behaviors enabled and disabled. Initial HUD nodes fell from 65 to 5; in the next galaxy they fell from 98 to 4. The optimized simulator measured roughly 43–55 FPS during the first 20 seconds, compared with roughly 41–53 FPS with the old behaviors enabled. These are simulator observations on a busy shared Mac, not reliable iPhone GPU, power or battery-life measurements. CPU percentages were similar in that sample. No percentage battery-life improvement is claimed.

A physical iPhone is required to verify sustained device FPS and energy impact. It was unavailable when the new profiling run was attempted; the earlier purchase/audio/lifecycle suite had passed on that phone before these layout and procedural changes.

Profiling flags and legacy-behavior switches are compiled only into COCOS2D_DEBUG builds. The release executable does not expose them.
