# October 20, 2026 review resubmission

App 6823318721, version 3.0 build 6, submission `526343f0-e72a-4b9e-b009-942c6d65f036`.

## Actual feedback

Apple rejected build 6 under Guideline 4.3(a), Design–Spam, on October 20. The reviewer used an iPad Air 11-inch (M3). The message described similarity in binary, metadata, and/or concept to submissions from other developers, but did not identify a comparison app or a specific functional defect. All seven purchase items remained Ready for Review.

The message also included Apple's extended-review notice. This record does not establish which similarity triggered the rejection or whether Apple will accept the clarification below.

## Provenance clarification

The review notes previously omitted the original co-developer's history. They now link to:

- The [public source repository](https://github.com/cschubiner/OrbitingiOSGame), created June 22, 2012, and [initial commit](https://github.com/cschubiner/OrbitingiOSGame/commit/337398bddd237ae5cf4fa7b4cd91a2d858978ce9) by Clay Schubiner.
- The [2013 AppDelegate source](https://github.com/cschubiner/OrbitingiOSGame/blob/06862536974822d1e029c14ba7b8c5ede3323435/Planet%20Orbiting%20iOS%20Game/Planet%20Orbiting%20iOS%20Game/AppDelegate.m), which credits Clayton Schubiner and links to the original Star Stream App Store ID, 594091366.
- The [historical StutterStep listing](https://www.moddb.com/games/star-stream), also used for the restored description.

The notes explain the intentional continuity of the original name, artwork, handmade maps and orbit/swipe mechanics, and describe the procedural routes, exact-layout Favorites, saved map tuning and fullscreen layouts added in the revival. They ask Apple to identify any different comparison app, required documentation, or requirement to use the legacy app record. No claim of sole authorship or a completed app transfer was made.

The 3,534-character notes were read back through the public API and observed in App Store Connect before resubmission. Existing gameplay, purchase, tutorial and tuning instructions were retained. The public description and binary were unchanged. No new build or test run was performed for this review-context change; previous build 6 testing remains documented in `qa-report.md`.

## Verified result

The existing submission was updated and resubmitted on October 20, 2026 at **3:56:24 PM EDT / 19:56:24 UTC**. The web UI showed all eight items Waiting for Review. An independent API read confirmed both version 3.0 and the submission were `WAITING_FOR_REVIEW`. The submission-item API continued to expose `READY_FOR_REVIEW`, while the web UI showed the queue state.

The release policy was changed from automatic to **MANUAL** before resubmission and independently confirmed afterward. This is a resubmission for reconsideration, not approval or public availability. No separate message was sent to App Review, and no agreements were accepted.
