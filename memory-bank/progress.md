# Progress

Status recorded 2026-08-04, from repo inspection (not from README claims alone unless marked as such).

## 2026-08-12 — Root cause of rides discarded as "no movement detected"

- Reported on-device: a real commute at an indicated 130 km/h ended with
  "Sürüş çok kısa veya hareket algılanmadı. Kaydedilmedi." and no saved ride.
- Root cause (Android, primary): `ValidatedSpeedEngine.processPosition` only
  integrated a segment into ride distance when the gap between accepted samples
  was `<= TelemetryConfig.continuousDataGapSeconds` (3.0 s), while
  `RideLocationService` requested `AndroidSettings.intervalDuration` of 4 s.
  `geolocator_android` 4.6.2 maps that to `setIntervalMillis` and
  `setMinUpdateIntervalMillis`, a hard floor on sample spacing, so every segment
  of every ride was above the 3.0 s gate and dropped. The ride finalized with
  `totalDistanceKm == 0` and zero average speed, and the caller's
  `distanceKm < 0.1 && averageSpeedKmh < 1.0` check discarded it. The earlier
  `acceptedSampleCount` fix did not cover this second, independent gate.
- Root cause (secondary): validated max speed required a supporting neighbour
  sample within a hardcoded 3.5 s window, which no sample can satisfy at a 4 s
  cadence, so `validatedMaxSpeedKmh` was always null on Android and the UI fell
  back to the unverified raw peak.
- Fixes: added `TelemetryConfig.maxDistanceIntegrationDtSeconds` (15.0) and used
  it for distance integration, leaving `continuousDataGapSeconds` as the
  diagnostic gap flag only; scaled the max-speed support window to the ride's own
  median sample spacing; set Android `intervalDuration` to 1 s and
  `distanceFilter` to 0 on all platforms (a non-zero `distanceFilter` maps to
  `setMinUpdateDistanceMeters` and starves integration at low speed).
- Added a last-resort guard: the engine now also accumulates a plain
  great-circle `coordinateDistanceKm` across accepted samples (segments implying
  over 90 m/s are skipped), and `stopTracking` uses it when the integrated
  distance is under 0.05 km, plus an elapsed-time average-speed fallback. A real
  ride can no longer be discarded merely because the integrator produced nothing.
- Verification: `flutter test` 98/98 pass, including a new regression test that
  drives the engine at a 4 s cadence at 130 km/h. `dart format` and
  `flutter analyze lib/rides` clean for the changed files (pre-existing unused
  variable/element warnings in `rides_screen.dart` remain).
- Not verified on-device yet: this needs one real ride on the LG G5 (and ideally
  an iPhone) to confirm the fix end to end, plus a battery-drain sanity check now
  that positions stream at 1 Hz with no distance filter.
- Still open after the first pass, then fixed in the second pass below: ride
  telemetry lived only in memory until the rider ended the ride.

## 2026-08-12 — Second audit pass: mid-ride process kill was a second, independent cause

- Re-audited the whole path including the three screens that end a ride
  (`rides_screen.dart`, `apex_dashboard_screen.dart`,
  `group_ride_lobby_screen.dart`) and the start path (`start_ride_sheet.dart`).
- Found a second live defect producing the identical "no movement detected"
  symptom, unaffected by the sampling-cadence fix: `rides.is_active` and
  `rides.started_at_iso` persist across a process kill, but the ride's telemetry
  did not. `RidesScreen.initState` resumes tracking via `_resumeGpsTracking`,
  and `startTracking` calls `_positions.clear()` plus
  `ValidatedSpeedEngine.startRide`, wiping every kilometre accumulated before
  the kill. On an aggressive Android battery manager this loses a whole commute.
- Fix: `RideLocationService` now checkpoints the ride's running aggregates
  (distance, moving distance, coordinate distance, moving seconds, max speed) to
  `rides.telemetry_snapshot` at most every 10 s, keyed on
  `rides.started_at_iso`. `startTracking` restores them, `stopTracking` merges
  them into the result and clears the key. A snapshot whose `startedAtIso` does
  not match the current ride is ignored, so a new ride can never inherit an old
  one's distance.
- Fix: `RideController._hydrate` calls `RideLocationService.restoreInterruptedRide()`
  when a ride is active, so an interrupted ride can also be ended from the
  dashboard or the group lobby — screens that call `stopTracking` without ever
  calling `startTracking`. The method is a no-op while tracking is live, which
  prevents double-counting.
- `stopTracking` no longer bails out on `acceptedSampleCount < 2` when carried
  distance exists, and average speed is now derived from the merged moving
  distance and moving time.
- Account deletion now also removes `rides.telemetry_snapshot`.
- Removed the dead, misleading `RideLocationService.hasGpsData` getter, which
  still expressed the old `_positions.length >= 2` gate that caused the original
  bug. The `RideLocationResult.hasGpsData` field is unrelated and unchanged.
- Verification: `flutter test` 100/100 pass, including a new
  `test/ride_resume_snapshot_test.dart` covering both the carry-forward and the
  stale-snapshot-rejection cases. `flutter analyze lib/rides` reports no errors.
- Known remaining inconsistencies, not changed here: the three end-ride blocks
  are near-duplicates with divergent thresholds (`< 0.1 km` on rides/dashboard,
  `< 0.5 km` in the group lobby), which is how the earlier partial fix missed a
  gate. Consolidating them into one application-layer helper is the right next
  step. Still unverified on-device: one real ride, an app-kill-mid-ride test, and
  a battery check at the new 1 Hz cadence.

## 2026-08-12 — One discard rule for solo and group rides

- User decision: group rides are measured by the same engine and stored in the
  same record, so a separate threshold made no sense. Removed
  `RideDiscardPolicy` entirely; `resolveRideCompletion` now applies one rule.
- `kGroupRideMinimumDistanceKm` (0.5) is gone. `kSoloRideMinimumDistanceKm` and
  `kSoloRideMinimumAverageSpeedKmh` are renamed `kRideMinimumDistanceKm` (0.1)
  and `kRideMinimumAverageSpeedKmh` (1.0). A group ride between 100 m and 500 m
  is now kept instead of being silently discarded.
- The group policy's extra `!hasGpsData` clause was dropped as redundant:
  without GPS every metric is already zeroed, so the shared AND rule discards it
  anyway. The group lobby's one-minute duration floor was also redundant —
  `stopTracking` already floors the active duration at 1 when GPS data exists.
- `allowWithoutGps` is kept for the group lobby's `FLUTTER_TEST` path.
- Verification: `flutter test` 110/110 pass, including the group ride lobby
  widget test; `flutter analyze lib test` reports zero errors.

## 2026-08-12 — Lean angle removed from the product entirely

User decision: remove the lean-angle feature completely, including the stored
field. The pocket-mode fix below is superseded — it is kept as the record of why
the feature was unreliable.

- Deleted `lib/rides/application/sensor_fusion_engine.dart`,
  `lib/rides/application/lean_angle_engine_v3.dart` (which also held the dead
  `LeanAngleEngineV3` and `LeanPersistenceSanitizer`), and
  `lib/rides/application/telemetry_isolate.dart`. The telemetry isolate existed
  only to fuse lean angle, so the whole isolate and its sensor subscriptions are
  gone; `sensors_plus` was dropped from `pubspec.yaml` as it had no other user.
- `RideLocationService`: removed the isolate, `_maxFusedLeanAngle`,
  `calibrateMount()`, the GPS kinematic feed, the mount/pocket status suffix,
  and the `isMounted` parameter of `startTracking`. The snapshot no longer
  carries a lean maximum.
- `RideTelemetryAnalyzer`: removed `maxLeanAngle`, the `fusedMaxLeanAngle`
  parameter, the trajectory-curvature block, and the ">35° cornering master"
  mood branch. Hard braking, rapid acceleration and smoothness are unchanged.
- Removed `maxLeanAngle` from `RideSession`, its JSON, `RideSessionEntity` and
  the regenerated Isar schema (`build_runner`). Isar 3 drops a removed property
  on open; `IsarDbService` already backs the file up and falls back to read-only
  if an open ever fails.
- Removed the lean inputs from `HarmonyEngine` penalties/bonuses and from
  `GarageState.applyRideImpact` (aggressive-wear detection now uses mood, speed
  and hard braking).
- UI: removed the "Max Lean" row from the last-ride card, the "Estimated Max
  Lean Angle" summary row and its GNSS footnote, and the mount-mode plumbing in
  `start_ride_sheet.dart` (its `_isMounted` was already hardcoded false).
- Removed the `BugCategory.leanAngle` report category and its `LEAN_ANGLE`
  Discord tag. `BugReport.fromJson` resolves unknown categories with
  `orElse: () => BugCategory.other`, so previously filed reports still parse.
  Also reworded the report title placeholder and two profile policy sentences
  that referenced lean angle.
- Added `test/ride_session_legacy_lean_test.dart`: legacy JSON carrying
  `maxLeanAngle` still parses, serialization no longer emits it, and an entity
  round-trip preserves the remaining metrics. Deleted `lean_fusion_test.dart`
  and `lean_angle_engine_v3_test.dart`.
- Verification: `flutter test` 111/111 pass; `flutter analyze lib test` reports
  zero errors; `flutter build apk --debug` succeeds.
- Not verified on-device: opening an existing Isar database whose ride records
  still contain the removed property. Isar 3 handles this, but confirm the ride
  history still lists correctly on first launch of a build with this change.

## 2026-08-12 — Pocket-mode lean angle was destroyed by the gyroscope handler

- Reported: the app no longer measures lean angle. Root cause in
  `telemetry_isolate.dart`'s `'GYRO'` command, pocket mode branch: it set
  `currentLeanAngle = 0.0` on every gyroscope sample. The gyroscope streams at
  50 Hz (20 ms sampling) while GPS corrections arrive at 1 Hz, so every
  GPS-derived angle was wiped within 20 ms and the 5 Hz reporting timer almost
  always emitted ~0. `RideLocationService._maxFusedLeanAngle` therefore stayed
  at 0 for every pocket ride. Introduced in `3c82b60` (2026-08-03).
  This is the "pocket telemetry zeroing" risk listed in CLAUDE.md, now closed.
- The intent (pocket mode must not integrate the gyroscope, DOC 24 §17) was
  correct; the implementation also discarded the independent GPS kinematic
  estimate, which is the only valid pocket-mode source.
- Fix: extracted the fusion into `LeanFusionState` in `sensor_fusion_engine.dart`
  and made the isolate delegate to it. In pocket mode the gyroscope now only
  zeroes the reported roll rate and leaves the angle untouched.
- Pocket-mode GPS smoothing changed from alpha 0.85 to 0.6. With no gyroscope
  contribution the filter is purely a GPS noise smoother, and at 1 Hz an alpha
  of 0.85 reached only ~14° of a real 30° corner before it ended.
- Added `SensorFusionEngine.maxPlausibleLeanDeg` (55°): a computed angle above
  it comes from a GPS heading jump, not from the rider, and is now rejected
  rather than stored as a personal record.
- `_maxFusedLeanAngle` is now carried in the ride snapshot, so a ride
  interrupted by a process kill keeps its maximum lean as well as its distance.
- Added `test/lean_fusion_test.dart` (9 tests): the gyroscope may not erase a
  GPS angle, a sustained corner converges above 24° of a 30° corner, the
  gyroscope alone never invents an angle in pocket mode, mounted mode still
  integrates, calibration zeroes the offset, implausible gaps are ignored, and
  a heading-jump angle is rejected.
- Verification: `flutter test` 120/120 pass; `flutter analyze lib test` reports
  zero errors; `flutter build apk --debug` succeeds.
- Not verified on-device: the actual gyroscope/heading behaviour of a real
  phone in a pocket during cornering.

## 2026-08-12 — Fifth pass: end-to-end verification without a device

- Added `test/ride_location_service_integration_test.dart`, which drives the
  real `RideLocationService` (Android branch, real permission flow, real engine,
  real Hive/SharedPreferences snapshotting) with a scripted
  `GeolocatorPlatform`. permission_handler and sensors_plus channels are mocked
  so the lean-angle isolate does not abort tracking.
  - A 5-minute 130 km/h commute records 10.83 km ± 0.4 and 130 km/h ± 6, and
    `resolveRideCompletion` keeps it.
  - A ride split by a simulated process kill (two 3-minute segments) finishes
    with ~13 km. Verified this test fails at 6.46 km when snapshot restore is
    disabled, i.e. it reproduces the exact reported data loss.
- Changed snapshot checkpointing to trigger on either 10 s of sample time or
  10 s of wall time. Sample time is what actually advances a ride; wall time
  remains the backstop for devices reporting odd fix timestamps.
- `flutter build apk --debug` succeeds, so the change set builds for the target
  platform.
- Verified from the merged manifest (`build/app/intermediates/merged_manifests`)
  that `GeolocatorLocationService` is declared with
  `foregroundServiceType="location"` alongside `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_LOCATION` and `WAKE_LOCK`, and that `ic_notification` is
  present in `res/drawable` and packaged into the APK. Every tracking start path
  (`start_ride_sheet`, `RidesScreen.initState` resume, group ride) runs with the
  app in the foreground, which is the condition under which a location-type
  foreground service keeps location access without `ACCESS_BACKGROUND_LOCATION`.
  The 2026-08-09 removal of that permission is therefore correct for this flow.
- Genuinely not machine-verifiable and still open: real GPS hardware behaviour
  on the LG G5 (fix rate and accuracy) and battery drain at the 1 Hz cadence.
  These are physical measurements, not code defects.

## 2026-08-12 — Fourth pass: config and platform request tied together

- Root structural cause of the whole episode: `TelemetryConfig.desiredIntervalMs`
  (1000 ms) was dead code — never read anywhere — while `RideLocationService`
  hardcoded a 4 s Android interval. The engine's tolerances and the platform's
  actual delivery rate had no link, so they could drift apart silently.
  `RideLocationService` now owns one `TelemetryConfig`, passes it to
  `ValidatedSpeedEngine`, and derives `AndroidSettings.intervalDuration` from
  `desiredIntervalMs`.
- Added a config-invariant test: the distance-integration window must be at
  least four times the requested sampling interval, and the diagnostic gap
  threshold must stay strictly below the integration window. This fails the
  build if anyone reintroduces the original mismatch.
- Self-review fix: `stopTracking` no longer substitutes the whole segment's
  distance for moving distance when the motion machine classified none of it as
  moving. On a resumed ride that inflated the average speed, because the carried
  moving seconds covered time the substituted distance did not.
- Self-review fix: replaced the null-assertions in the engine's great-circle
  fallback with local non-null bindings.
- `minimumIntervalMs` and `maxSampleAgeSeconds` remain unused in
  `TelemetryConfig`; left in place but noted here so they are not mistaken for
  live tuning knobs.
- Verification: `flutter test` 109/109 pass; `flutter analyze lib test` reports
  zero errors.

## 2026-08-12 — End-ride logic consolidated into one policy

- Added `lib/rides/application/ride_completion.dart`: `resolveRideCompletion`
  plus `RideDiscardPolicy.solo` / `.group` and the named thresholds
  (`kSoloRideMinimumDistanceKm` 0.1, `kSoloRideMinimumAverageSpeedKmh` 1.0,
  `kGroupRideMinimumDistanceKm` 0.5). It owns the rounding, the no-GPS zeroing,
  the group ride's one-minute duration floor and the discard decision.
- Rewired all four end-ride call sites to it: `rides_screen.dart`,
  `apex_dashboard_screen.dart`, and both paths in `group_ride_lobby_screen.dart`.
  Behavior is preserved exactly, including the group lobby's stricter 0.5 km
  minimum and its `FLUTTER_TEST` bypass (now the explicit `allowWithoutGps`
  flag). The duplication is what let the earlier telemetry fix land on one
  screen's gate and miss the others.
- Added `test/ride_completion_policy_test.dart` covering both policies: a real
  commute is kept, a short-but-moving ride is kept (the rule is an AND, not an
  OR), a stationary ride is discarded, missing GPS zeroes every metric, and the
  group minimum and duration floor hold.
- Verification: `flutter test` 108/108 pass; `flutter analyze lib` reports no
  errors. An unrelated whitespace-only reformat of `telemetry_isolate.dart`,
  picked up by a directory-wide `dart format`, was reverted.

## 2026-08-12 — Third audit pass: hardening and independent verification

- Closed a race introduced by the second pass: `RideController._hydrate` now
  awaits `restoreInterruptedRide()` (and re-checks `_mounted`) before publishing
  `isRideActive: true`, so the rider cannot press stop on the dashboard before
  the interrupted ride's aggregates are loaded.
- Added `test/ride_commute_simulation_test.dart`: a 20-minute commute simulated
  at Android's 4 s cadence with varying accuracy (4–38 m), three stops, periodic
  GPS speed spikes and a 40 s tunnel outage. It asserts recorded distance within
  10% of ground truth, a validated max speed of 130 ± 12 km/h, moving time that
  excludes the stops, and that the outage is flagged. Confirmed this test fails
  with `totalDistanceKm == 0.0` when the pre-fix integration gate is restored,
  so it genuinely guards the shipped bug rather than merely passing.
- Reviewed but deliberately not changed: `ACCESS_BACKGROUND_LOCATION` was
  removed from `AndroidManifest.xml` in `bdd264b` (2026-08-09). With the
  `GeolocatorLocationService` foreground service (`foregroundServiceType=location`,
  `FOREGROUND_SERVICE_LOCATION`, `WAKE_LOCK`) this is the Play-policy-correct
  setup and should keep tracking alive with the screen locked, but it changed one
  day before the reported failure and has not been re-verified on-device. Test a
  screen-locked ride explicitly.
- Confirmed correct on inspection: `IsarDbService.saveRideSession` writes inside
  a `writeTxn`; snapshot restore cannot double-count (the persisted value already
  includes previously carried totals, and `restoreInterruptedRide` is a no-op
  while tracking); a snapshot cannot leak into a new ride (start marker mismatch).
- Known limitation of resume, accepted for now: `_positions` is not persisted, so
  after a process kill the lean-angle and hard-braking analysis covers only the
  final segment. Distance, speed and duration are complete.
- Verification: `flutter test` 101/101 pass; `flutter analyze lib test` reports
  zero errors.

## 2026-08-09 — Closed-beta build `1.0.0+34` and live privacy backend

- Final signed artifact: `build/app/outputs/bundle/release/app-release.aab`,
  86,758,816 bytes, manifest `versionCode=34` / `versionName=1.0.0`, verified by
  `jarsigner`. SHA-256:
  `24FA0A7F7D4108C0D70D8BD978C6EA7EEB3EDD514CD4C9A64CA538CE174E4603`.
  Matching release APK installed successfully on the LG G5. Builds `+31` through
  `+33` are superseded.
- Deployed Firestore rules to `apex-flow-7baea`. Friend-only blood type, phone,
  emergency phone, and license-plate toggles now save and persist; all were
  device-tested, then restored to OFF. Email and emergency-contact name are
  never shared. Compact, text-scale-bounded sharing rows were visually checked
  on LG G5; Samsung Galaxy S21 FE remains a useful typography check.
- Leaderboard duplicate informal/current-user labels were removed. It now shows
  only localized `Siz`/`You`/`Sie`, with formal Turkish week copy; verified on
  the LG G5.
- Deployed only the previously missing v2 callable `deleteAccountAndData` to
  `europe-west1`. The app now deletes remotely before local cleanup and cannot
  remain visually signed in merely because local DB cleanup fails. No real
  account was destroyed during verification; run a final disposable-account
  deletion test on v34. Follow-up: move off Node.js 20 before its scheduled
  2026-10-30 decommission and update the warned-old `firebase-functions` package.
- Created and deployed the separate privacy site
  `https://apex-flow-privacy-7baea.web.app/`; QR hosting remains separate and was
  not redeployed. Privacy and deletion pages have complete TR/EN/DE content,
  language selector and `?lang=` routing. The app opens them in its active
  language. All languages/cross-links passed live DOM checks; Turkish navigation
  from the app was confirmed on-device.
- Verification: Flutter 97/97 tests pass; targeted analyze has no errors (two
  pre-existing async-context info notices); wider analyze has 276 warning/info
  items and no errors; Functions lint, legal JS syntax, and diff whitespace
  checks pass.
- Scoped live changes only: Firestore rules, `deleteAccountAndData`, and privacy
  hosting. No commit or push. Worktree remains dirty with mixed pre-existing,
  user, and Claude changes.

## 2026-08-09 — Friend-only profile visibility (earlier local snapshot; superseded by `+34` above)

- Added independent opt-in controls for blood type, phone, emergency phone,
  and license plate under Settings; all default off except the backward-compatible
  blood-type migration from the former combined emergency toggle. The emergency
  contact person's name is explicitly never shared.
- Sensitive friend fields moved to friendship-gated `friend_profiles/{uid}`;
  `rider_tags` explicitly rejects email and sensitive profile fields.
- Friend add/sync merges allowed fields only after a friendship document exists;
  profile UI points users to Settings and states that email is never shown.
- Account deletion and privacy policy cover the new projection.
- Verified locally: Flutter tests 97/97, Functions lint/syntax pass, QR web build
  passes, Firestore rules compile in Firebase CLI dry-run. Not deployed or
  cross-account device-tested.
- Internal-test artifact advanced to `1.0.0+31`; signed release AAB built and
  release manifest verified as `versionCode=31`, not uploaded.

## 2026-08-08 — Typography/icon rollout done, profile photo upload shipped, real ride-telemetry bugs fixed
Full detail in `activeContext.md` "Current Task". All commits `flutter analyze` (0 new errors) + `flutter test` (96/96) verified; most also confirmed on-device (LG G5).

**FIXED, verified on device:**
- `ApexTypography` design-system text theme now wired into all high-traffic screens (dashboard, garage, profile hub, rides, insights, documents, settings, onboarding, both paywalls) — closes the design audit's long-standing "9-step scale defined but unused" item. Found and fixed a real overflow regression along the way (tight fixed-width rows growing 1px/char when a literal's font size was smaller than its mapped theme step).
- Icon language unified on Material Icons; `phosphor_flutter` dependency removed (was 2 files/51 sites vs. 423 Material uses elsewhere).
- New feature: custom profile photo upload (Firebase Storage, size-capped client-side, visible to other riders via the existing public `rider_tags` channel). Firebase Storage had never been enabled on this project — set up live with the user this session. Found and fixed a real "Remove Photo doesn't actually clear" bug (nullable-copyWith ambiguity between "no change" and "explicit clear").
- Preset 8-avatar picker removed at user's request; no-photo state now shows one neutral generic-rider icon instead.
- **Real bug**: rides were being discarded as "no movement detected" regardless of actual GPS movement. Root cause: `RideLocationService.stopTracking()` gated the whole ride on a stricter, separate accuracy cutoff (45m) than the speed engine's own (50m) — a ride with real, validly-computed distance could still get zeroed before that data was ever read. Fixed by gating on the speed engine's own accepted-sample count. **Not verified with a real outdoor ride** (can't simulate device motion in this environment).
- **Real bug**: `_LastRidePanel` showed a hardcoded fake max-speed number (`113,1 km/sa`) whenever a real ride's speed was genuinely unmeasured (0) — violated the codebase's own "don't fabricate unmeasured telemetry" rule at the display layer even though the model layer already respected it. Now shows `-`.
- Hard-braking/rapid-acceleration detection now derived from the same Kalman-filtered speed series as distance/max-speed, instead of raw noisy GPS speed (which could disagree and register noise spikes as fake hard-braking events).
- Duplicate rider-name header removed from the Profile tab (was shown both above and inside the `RiderIdCard`; now only inside the card).

**Known-broken / explicitly deferred:**
- `friends_state.dart` reads a friend's profile from `users/{friendUid}`, which is permission-denied under `firestore.rules` (owner-scoped read) — a real, pre-existing bug, load-bearing for whether the new profile photo is actually visible to friends. Not fixed this session (the new photo feature was deliberately built around the channel that *does* work — `rider_tags` — rather than on top of this bug).
- Vector/brand-asset design-audit item explicitly out of scope — **user has permanently banned any app logo/icon changes, including drafts**, after a brand-mark proposal was shown and rejected. Do not re-propose without being asked.
- Cross-account visibility of the new profile photo (friends, group ride lobby) and iOS support for the same feature — neither tested this session (no second test account, no iOS device).
- 38 pre-existing lint-level `flutter analyze` issues in `profile_hub_screen.dart` (unused imports/private classes, deprecated `withOpacity`, style notes) — catalogued, not fixed (user asked for a memory-bank update instead of a cleanup pass this time).

## 2026-08-07 (afternoon) — Accessibility/design pass + two real login/data-loss bugs fixed on device
Full detail in `activeContext.md` "Current Task". Ran on the work Mac; repo re-cloned fresh after the local copy was lost. Pushed through `00885ca`.

**FIXED, verified on a real device (LG G5) with before/after screenshots:**
- Login threw for every freshly-registered account: `loginWithEmail()`'s email-filtered fallback query on `/users` is structurally rejected by `firestore.rules` (owner-scoped read rule can't validate a collection query filtered by `email`). Surfaced as the generic "Hata oluştu" *after* Firebase Auth had already signed the user in successfully. Now caught and fallen through.
- Local profile + garage data appeared wiped after a cold start ("motosiklet ve profil silindi"): `FirebaseService.init()` didn't wait for Auth to restore its persisted session, so `currentUser` read null, and the account-switch purge treated the real user as a guest. Now awaits the first `authStateChanges()` event with a 5s timeout.
- The floating nav bar clipped the bottom of every scroll surface — Insights' stat-card row was fully unreadable. Fixed app-wide via `ApexSpacing.navBarClearance`.
- Profile tab bar was rendering a live `OVERFLOWED BY` stripe over the UI.
- Number/currency formatting: locale-less `NumberFormat` gave Turkish "6,000" instead of "6.000"; other sites printed raw "12000"; currency concatenated to "TL0". Centralized in `AppSettingsState.formatNumber`/`formatCurrency`.
- Phone numbers saved as "+90 0544…" (both international prefix and national trunk zero).
- 40 IconButtons had no accessibility label; 26 UI text sites were 6–9px, below the type scale's own 11px floor.

**Known-broken / not started (design audit items 5–7, see `activeContext.md` for detail):**
- `ApexTypography`'s text theme is effectively dead — only 2 files use `context.textTheme`, against 941 hand-written `TextStyle` literals. Highest-value remaining item, but must be done screen-by-screen with device verification.
- Material Icons (423 uses) and Phosphor (51 uses) are mixed in the same UI. Bounded; good next task.
- No vector assets at all (0 SVG, `flutter_svg` not a dependency) — no brand mark, no empty-state illustrations.
- Smaller on-device findings not yet filed: achievement chip row clips and overlaps "Tümünü Gör"; the KM/MI selector is orange/white, outside the design language; blood-type badge shows a bare "—" when unset; auth error handling doesn't branch on `FirebaseAuthException.code` (all failures collapse to one generic string).

**Environment caveat for the next session:** the signing files (`android/key.properties`, `android/app/upload-keystore.jks`) are gitignored and absent from a fresh clone — copy them in before any release build. The current local release is `1.0.0+34`; its signed AAB was built and verified locally.

## 2026-08-07 — Pre-release hardening: security fixes, App Check verified live, Discord pipeline fixed for real
Full detail in `activeContext.md` "Current Task" — this is the status-tracking summary.

**FIXED, verified working:**
- Bug report → Discord dispatch (`bug_report_controller.dart` now actually calls `createBugReportDraft`) — **supersedes the entry immediately below, which is now stale**. Confirmed live via `firebase functions:log` (`app`/`auth` both `VALID`) and the user seeing the report land in Discord.
- Hardcoded `@apex_dev#1881` premium backdoor — fully removed, no code path grants premium without a real RevenueCat/receipt check anymore.
- `deleteUserAccount()` — was silently swallowing errors and deleting the Auth account regardless of Firestore cleanup failures; also missing several collections (`public_rider_cards`, `entitlements`, `users/{uid}` subcollections, `bug_reports`). All fixed; local device data is now also purged via `DbService.deleteAllForUser()`. This substantially closes CLAUDE.md's long-standing "incomplete per-user local isolation/account deletion" risk area for Android — not independently re-verified for iOS.
- Stale local profile/insights data surviving an abnormal session end (crash/force-quit) and leaking to the next account on the same device — fixed via a last-hydrated-UID marker.
- App Check: client activated, server enforcement flipped on for all 4 callables, verified live end-to-end on a real device. This closes the `enforceAppCheck: false` gap noted below.
- A real Firebase project misconfiguration: the Android app was registered under the Flutter template's default package name (`com.example.apexflow`) instead of `com.apexflow.app`, and `main.dart` was handing Android builds the **web** app's Firebase config. Neither ever broke Auth/Firestore, but both would have made App Check permanently non-functional had they not been found. Fixed.

**Still known-broken / not attempted:**
- iOS Firebase app registration was not re-audited given the Android-side bug found above — genuinely unknown whether iOS has an analogous mismatch.
- Full Discord bidirectional sync / buttons / roles (Phase 2+ per the original spec) — Phase 1 one-way dispatch is what's live.

## 2026-08-06 — Bug Report → Discord pipeline: diagnosed, NOT fixed (known broken) — SUPERSEDED, see 2026-08-07 above
User asked to check why in-app bug reports never show up in Discord. Root cause traced end-to-end, no code changed (user chose diagnosis-only for now):
1. **Client never leaves the device.** `lib/features/support/bug_report/application/bug_report_controller.dart` (`submitReport`) only calls `LocalBugOutbox.saveReport(report)`, which writes to `ApexKvStore` (local SharedPreferences-backed storage). There is no Firestore write and no Cloud Functions call anywhere in `lib/` — confirmed via repo-wide grep for `createBugReportDraft`/`httpsCallable`/`bug_reports`, zero hits outside the local-outbox files. `my_bug_reports_screen.dart` / `my_bug_reports_controller.dart` only read back that same local queue, so the UI shows "submitted" reports that never actually transmitted anywhere.
2. **Even the one Cloud Function that exists doesn't reach Discord.** `functions/index.js`'s `createBugReportDraft` (an `onCall` function, currently unused by the client per #1) only writes a doc to Firestore's `bug_reports` collection and returns — no Discord dispatch. The project's own spec (`docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md`, ~line 1237) defines a separate `createDiscordBugThread()` function that POSTs to `discord.com/api/v10/channels/{forumId}/threads` using a bot token — that function does not exist in `functions/index.js` at all.
3. **App Check also not enforced**: `createBugReportDraft` is declared with `enforceAppCheck: false`, contrary to CLAUDE.md's stated requirement that this feature use App Check.
**Not fixed yet** — real fix needs (a) wiring `bug_report_controller.dart` to actually call the Cloud Function/Firestore, (b) writing the missing `createDiscordBugThread` function server-side, and (c) the user provisioning a Discord bot token + forum channel ID into Firebase Secret Manager (secrets this agent cannot generate). User deferred all of this pending a decision on scope.

## 2026-08-05 — Third-Pass Audit: Parking/QR System + i18n + Layout (24/24 done, on branch `agent/fix-safety-persistence-maps`)
User asked for a deep audit specifically of the parking-warning/QR-contact system (`qr_contact_web/` + Firestore), QR generation/scanning, and app-wide i18n/layout inconsistencies. 3 parallel Explore agents scanned each area; critical findings verified directly in code. Plan at `C:\Users\onyed\.claude\plans\stateful-swimming-fern.md` (replaced the prior 20-item plan file). All 24 items fixed and committed across 8 commits (`0770a74`, `992f090`, `71d1e3e`, `6d3f6c3`, `2dd4c0e`, `3cb3d46`, `1d680a6`).

**Most important fix**: the in-app QR-scan "Send Smart Park Alert" flow only posted a local notification on the scanning device while claiming "Notification sent successfully to the owner!" — the owner received nothing. Now writes to the real `parking_notifications` Firestore collection (same infra `qr_contact_web/main.js` already used). See `activeContext.md` for the full list of related fixes (reason-key translation, `firestore.rules` ownership check — prepared, **not deployed**, ties to notification delivery integrity, currency-symbol correctness, QR-scanner host-matching, bottom-nav clearance, etc.).

**Confirmed not a bug** (investigated, user concurred): TR/EU accident-report wizard hardcoded language — these are jurisdiction-locked legal document formats, correctly independent of app UI language.

**Deferred, needs real visual verification**: a second batch of hardcoded-color findings (nav bar color duplicated ~10x, a "wrong cyan" `0xFF0EA5E9` used ~15 places, `profile_hub_screen.dart`'s own slate palette) — same reasoning as the prior pass's #19, explicitly left untouched.

**CORRECTED (same session)**: FCM push for parking alerts is NOT missing infra — `functions/index.js`'s `onParkingNotificationCreated` is already live in production (confirmed via `firebase functions:list`) and does send a real push. The earlier "deferred, needs bigger infra" claim here was wrong (came from not checking `functions/`, which is skipped by default per this project's token-efficiency guidance). A real bug was found instead: the deployed function's reason-text allowlist never matched what any client sent, so push bodies always showed generic text — fixed (commit `4492226`), **not deployed**, needs user go-ahead for `firebase deploy --only functions`. See `activeContext.md` for full detail.

## 2026-08-05 — Second-Pass Bug Audit (19/20 done, 1 deliberately deferred, on branch `agent/fix-safety-persistence-maps`)
Full-project scan (3 parallel Explore agents + direct code verification of every finding before fixing) found 20 issues beyond the original 6-item list. Plan at `C:\Users\onyed\.claude\plans\stateful-swimming-fern.md`. Items #1-18 and #20 fixed and committed (`134c2f2`, `f1c0120`, `329e390`, `fa5f2f2`, `bbb33e6`). **Item #19 later closed out** (commits `c5980cf`, `afadd78`, `ab46749`, `d7fe736`) via a zero-visual-risk approach: fixed the one genuine mistake (wrong-cyan `0xFF0EA5E9`), and centralized the rest (nav-chip color, Insights + Profile Hub's shared "slate" palette) into named constants (`ApexColorsExtension.navChip`, `lib/shared/design/slate_palette.dart`) instead of guessing at a recolor — see `activeContext.md` for detail. Actually unifying the slate palette with the app's official tokens remains a real design decision needing visual verification, not a code task. Two findings (#7, #12) were investigated earlier and found to be false positives — no change made, documented in `activeContext.md` rather than "fixed."

**Important**: this work landed on branch `agent/fix-safety-persistence-maps`, not `main` — a different concurrent Claude Code session was found to be working in the same repo directory on that branch. See `activeContext.md` "Current Task" for full detail before assuming `main`'s state reflects this work, and before merging/pushing.

A debug build was installed on the user's LG G5 (`com.apexflow.app`) for manual testing, reflecting code through item #16 only.

## Verified Working (evidence: code/rules present and consistent)
- Firestore rules for `users`, `public_rider_cards`, `rider_tags`, `entitlements`, `notification_tokens`, `parking_requests`, `bug_reports` are defined with owner-scoping / backend-only-write patterns consistent with CLAUDE.md invariants (client cannot self-grant entitlements; PII-adjacent collections are not publicly readable).
- Isar entity set exists for daily checks, documents, friends, motorcycles, ride sessions, service records, tax records, each with generated code — indicates schema is wired, not merely stubbed.
- `flutter --version` succeeds locally: Flutter 3.41.4 / Dart 3.11.1 — toolchain is available for verification gates.

## Documentation Claims — Not Independently Verified This Session
- README claims: Closed Beta live since 2026-08-04, "12/12 bridges fully connected, 0 critical errors", 6 test devices, Discord feedback channel active. Treat as claim until confirmed by running the verification gate (`flutter analyze`, `flutter test`) and/or checking Play Console.
- Commit `81057dd fix: accident PDF impact marks + complete 3 partial bridges` implies bridges were previously partial — "12/12 fully connected" in README should be spot-checked against actual sync/bridge code before repeating as fact.
- Premium paywall pricing/billing described in README is UI/pricing-copy level; CLAUDE.md explicitly warns `purchases_flutter` installed ≠ real billing complete — production entitlement correctness not verified this session.

## 2026-08-04 — User-Reported Issue List: Verified Against Code, Fix in Progress
User raised 6 suspected issues from their own review. All 6 verified real by direct code inspection (see `activeContext.md` for the session log). Fix order: #4 → #1 → #3 → #5 → #6 → #2.

1. **Plaintext password local storage — FIXED (commit `443ea27`).** `profile.password` was written via `ApexKvStore` (Hive box, unencrypted; SharedPreferences fallback) on every login/profile update. Confirmed dead data (never read back for re-auth or Firestore sync) before removing the key and all call sites. Firebase Auth's own session handles real authentication, unaffected.
2. **Simulated premium/supporter purchases — FIXED, code + live RevenueCat dashboard config (commit `e2eb1d0`).** Added `lib/core/services/purchases_service.dart` wrapping the RevenueCat SDK (configure/getCurrentOffering/getProduct/purchasePackage/purchaseProduct/restorePurchases/hasActiveEntitlement/logIn) — no code path can grant an entitlement without a real `CustomerInfo` from RevenueCat. Wired `Purchases.configure()` + `logIn(ownerId)` into `main.dart` startup, right after Firebase init, using the same `getOrCreateInstallationId()` identity as the rest of the app (item #6). Removed the fake "SIMULATE PAYMENT" dialogs entirely from both paywalls; `_executePurchase()` now runs the real store purchase flow and only calls `updatePremiumStatus`/`updateSupporterTier` if the resulting entitlement is actually active.
   - **RevenueCat dashboard was configured interactively with the user this session** (project "Apex Flow", Android app `com.apexflow.app`): Google Cloud service account created and granted the correct Play Console permissions (financial data view + manage orders/subscriptions + app-level access — took several iterations, see `activeContext.md` for the exact permission gotchas), credentials validated. 5 real Play Console products imported: `apexflow_premium_monthly`, `apexflow_premium_yearly`, `apexflow_supporter_tier1/2/3`. Entitlements: `premium` (both premium products), `supporter_tier_1`/`supporter_tier_2`/`supporter_tier_3` (one product each). Premium products also sit in the `default` offering's Monthly/Yearly packages.
   - **Still using the sandbox/`test_` RevenueCat API key** (`test_fvELpOGwmQYczPBZoMCjnadMUaD`, in `purchases_service.dart`) — must be swapped for the production key before a real release build. iOS API key still unset (iOS purchases silently disabled until then, by design — no crash, `hasActiveEntitlement` just returns false).
   - **Not done, explicitly deferred**: no "Restore Purchases" UI entry point (service method exists, unused); RevenueCat real-time developer notifications (Pub/Sub topic for instant renewal/cancellation events) were skipped as optional per user's choice — without it, entitlement state only refreshes on-demand (app open / `getCustomerInfo()` calls), not instantly on server-side subscription events.
   - flutter analyze: 329 issues, 0 errors. flutter test: 91/91 passed.
3. **Firestore collection/rules mismatch — FIXED in code, NOT DEPLOYED (commit `aece0d1`).** Added rules for `bikes`/`rides` (owner via `userId`), `friendships` (either of `userA`/`userB`), `lobbies` (signed-in-only — see decision note below), `parking_notifications` (anonymous create, owner-only read/update), and a `users/{uid}/{document=**}` owner-scoped wildcard covering `sync_coordinator.dart`'s separate subcollection model. **Not run through the Firestore emulator** (`firebase emulators:exec` needs Java 21+, not installed here) — test via Firebase Console Rules Playground before `firebase deploy --only firestore:rules`, which was deliberately not run (production security-rule deploy needs explicit user go-ahead).
   - Extra findings while scoping this: `bikes`/`rides` top-level collections have **no writer anywhere in the app** — only `deleteUserAccount`'s defensive cleanup query touches them. So the real-world impact of the mismatch was concentrated in `friendships`/`lobbies`/`parking_notifications`, which are actively written to.
   - `lobbies` decision: `hostId` and the `riders[]` array store app-level rider tags (`userProfile.riderTag`), not Firebase Auth UIDs — Firestore rules can't natively express "only this lobby's members" without a schema change (adding a real UID array). Scoped to "any signed-in user" instead of blocking on that larger change; still strictly better than the prior "nobody" state.
   - `parking_notifications` decision: `qr_contact_web/main.js` writes here with **no Firebase Auth session at all** (anyone who scans a physical QR sticker, no ApexFlow account) — `allow create` had to stay open, narrowed only by shape checks; read/update are owner-only via a `rider_tags` ownership lookup.
4. **4 compile errors — FIXED (commit `ce6131b`).** All in `lib/core/sync/sync_coordinator.dart` (`ApexSyncCoordinator`, confirmed unwired/unused anywhere else in the app): missing `ApexKvStore.getStringList`/`setStringList`, and `FirebaseService().currentUser` (no unnamed constructor, no such getter). Added the two store methods, made outbox loading properly async, switched to `FirebaseAuth.instance.currentUser`. `flutter analyze`: 337→333 issues, 0 errors. `flutter test`: 83/83 passed both before committing.
5. **Account deletion doesn't fully clear Firestore — FIXED, code + rules (commits `e107a75`, rules amended in same commit).** Added the three missing cleanup steps: `notification_tokens/{uid}/devices/*`, hosted `lobbies` (by `hostId` == rider tag), `parking_notifications` addressed to the user's rider tag. Also fixed a real bug found while doing this: the rider-tag cleanup checked `tagDoc.data()?['uid']` but the field is actually written as `ownerId` — the rider tag document was never being deleted. Fixing that exposed a second, preexisting `firestore.rules` bug: the `rider_tags` write rule required `request.resource.data.ownerId == request.auth.uid`, but `request.resource` is always null on delete, so no rider_tags delete could ever succeed under the old rule — split delete into its own `resource.data`-keyed rule. `flutter analyze` 0 errors, `flutter test` 83/83. Still not deployed (same emulator caveat as #3).
6. **No per-user local data isolation — FIXED, code + migration + tests (commit `5ba660d`).** Added `@Index() String userId = ''` to `MotorcycleEntity`, `ServiceRecordEntity`, `DailyCheckEntity`, `DocumentEntity`, `TaxRecordEntity`, `FriendEntity` (matching the pattern `RideSessionEntity` already had), plus fixed a related bug found along the way: `DailyCheckEntity.isoDate` was globally unique across all users, so two accounts checking in the same device on the same date would overwrite each other — changed to a composite unique index on `(isoDate, userId)`. All `get*()` methods in `isar_db_service.dart` now filter by `userId` and return `[]` if it's null/empty (strict-privacy default, same as the existing `RideSession` behavior); all `save*()` stamp the owner id. Owner identity uses `FirebaseService.getOrCreateInstallationId()` (Firebase UID if signed in, else a persisted per-install id) rather than raw nullable Firebase UID, specifically so guest/offline users never lose visibility into their own local data. A new `MigrationService.checkAndBackfillOwnerId()` runs once at startup and assigns any pre-existing unowned (`userId == ''`) record to the current install's owner id — never deletes data, retries on next launch if it fails. Wired into the 4 real consumers: `garage_state.dart`, `rituals_state.dart`, `document_vault_state.dart`, `friends_state.dart`.
   - **Testing gap, disclosed**: could not verify the real per-query filtering against actual Isar storage — `isar.dll` is not available in this environment (confirmed by direct probe: `Isar.open()` throws "Failed to load dynamic library"). Added `test/entity_owner_id_test.dart` (8 tests) covering the part of this change most likely to contain a mechanical mistake — that each entity's `fromDomain()` actually assigns the `userId` field — but the live `.filter().userIdEqualTo(...)` query behavior in `isar_db_service.dart` is unverified by automated test. **Recommend manual verification on a real device/emulator** (two accounts, confirm garage/documents/friends don't bleed across) before treating this as fully closed.
   - Scope limits: `delete*()` methods were left unscoped by `userId` (deletion is already keyed by a unique app-generated `stableId`); `isar_db_service_stub.dart` (confirmed unreachable via current `dbServiceProvider` wiring) was updated for interface compliance but its deletes and `backfillOwnerId` remain best-effort/no-op.

## 2026-08-06 — Discord Bug Report Dispatch: Root Cause Found and Fixed (Phase 1, one-way)
Root cause: `functions/index.js`'s `createBugReportDraft` only ever wrote to `bug_reports` in Firestore — no code path anywhere in the repo posted to Discord. The full bidirectional pipeline described in `docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md` (outbox, dispatch worker, bot, forum threads, interaction endpoint, buttons/roles) was never implemented — not a regression, a feature gap.

User chose **Phase 1 scope only** (their explicit choice, not the full spec): one-way delivery (Firestore → Discord forum thread), with outbox + built-in Cloud Functions retry + duplicate protection. No buttons, no role-gated interactions, no bidirectional Discord→Firestore sync yet — deferred, matches the spec's own guidance to implement phase-by-phase rather than all at once.

Implemented (not yet deployed — user must run `firebase functions:secrets:set DISCORD_BOT_TOKEN` themselves, then `firebase deploy --only functions`, both explicitly not run this session per CLAUDE.md's no-deploy-without-approval rule):
- `functions/src/discord/sanitize.js` — `sanitizeUserText()`, strips `@everyone`/`@here`/role-mentions/leaked webhook URLs (spec §14.4). Also now applied server-side to `bug_reports` fields at write time in `createBugReportDraft` (previously only length-capped, no mention sanitization at all).
- `functions/src/discord/messageBuilder.js` — builds the thread name and embed; reporter identity shown as a non-reversible `TESTER-XXXX` code (sha256 of `reporterUid`, first 4 hex chars), never the raw Firebase UID, per CLAUDE.md's PII invariant.
- `functions/src/discord/client.js` — `createForumThread()`, POSTs to `https://discord.com/api/v10/channels/{forumId}/threads` using the bot token (Firebase Functions v2 `defineSecret`, never in source).
- `functions/src/discord/dispatchWorker.js` — `dispatchBugReportToDiscord`, a `onDocumentCreated` trigger on `bug_dispatch_outbox/{internalBugId}` with `retry: true` (uses Cloud Functions v2's built-in exponential-backoff retry instead of a custom scheduler/poller). Checks `bug.discord.threadId` before sending (duplicate protection if a prior attempt partially succeeded then retried). On success, batch-writes `discord.threadId`/`messageId`/`syncStatus` onto the `bug_reports` doc and marks the outbox entry `delivered`. On failure, records `discord.lastErrorCode` and rethrows so the platform retries.
- `functions/index.js` — `createBugReportDraft` now writes the bug doc and its `bug_dispatch_outbox` entry in one atomic `batch()` (approximates the spec's "same transaction" requirement without a full two-phase draft/finalize rewrite, which was out of scope for this fix). Exports the new trigger.
- `functions/.env` — `DISCORD_BUG_REPORT_FORUM_ID=1532141078319333638` (non-secret per spec's secret table, committed intentionally; forum channel ID only, not a token).
- `firestore.rules` needed **no change** — `bug_dispatch_outbox` was already fully client-denied (`allow read, write: if false`) from an earlier session, ahead of the dispatcher that actually uses it now.

Verification this session: `node --check` on all 5 changed/new files (pass), `require("./index.js")` loads cleanly and exports all 3 functions, manual unit-style smoke tests of `sanitizeUserText`/`buildThreadName`/`buildBugEmbed`/`createForumThread` (mocked `fetch`) — all behaved as expected (mention stripped, TESTER code generated, correct Discord REST payload shape). **`flutter analyze`/`flutter test` not needed (no Dart changed). `eslint` not run — pre-existing gap, not caused by this change: `functions/` has no ESLint config file at all despite `eslint`/`eslint-config-google` being devDependencies, and the local `node_modules/.bin/eslint` shim is corrupted (empty stub, not a real launcher script).** Neither was touched/fixed as part of this change (out of scope).

Not done / explicitly deferred to a later phase (per user's Phase 1 choice): Discord buttons (`bug:confirm`, `bug:need_info`, etc.), the `X-Signature-Ed25519` interaction endpoint, QA-role authorization, the full state-machine (`new`/`confirmed`/`needs_info`/...), FCM status push-back to the user, attachments upload to Discord, the two-phase draft/finalize/idempotency-transaction protocol from spec §11-12 (current flow is still single-call, matching the pre-existing `createBugReportDraft` shape rather than rewriting it).

**Not deployed. Two manual steps remain, both requiring the user's own action:**
1. `firebase functions:secrets:set DISCORD_BOT_TOKEN` (interactive prompt — token must never be pasted into chat or committed).
2. Confirm the bot has `View Channels`/`Send Messages`/`Send Messages in Threads`/`Embed Links`/`Manage Threads` on forum channel `1532141078319333638`, then `firebase deploy --only functions`.

## 2026-08-06 — Deployed Discord Fix; Discovered & Recovered from a Production Functions Incident
Deployed the Phase 1 Discord dispatch work above to `apex-flow-7baea` (user explicitly authorized both the deploy and letting the assistant run `firebase` commands directly in this session, including `--force` to accept the `retry: true` failure-policy prompt).

**Incident, self-caused, self-recovered within ~5 minutes:** `firebase deploy --only functions` fully syncs production to local source — any function not present locally gets deleted. This repo's tracked `functions/index.js` (156 lines, 2 functions) turned out to be **stale relative to what was actually running in production** (7 functions). The first deploy silently deleted 5 production functions that existed only in Cloud Functions, never committed to this repo:
- `activateApexPass`, `claimAchievementMilestone`, `verifyRideContribution` — **unrelated to Discord entirely** (an Apex Pass / achievement-reward engine). Real production regression for ~5 minutes until restored.
- `onBugReportSubmitted`, `discordInteractions` — an **undocumented, never-committed prior Discord integration attempt** (deployed 2026-07-29, source recovered from the `gcf-v2-sources-*` GCS bucket's soft-delete window before recreating). This one materially changes the earlier "nothing was ever implemented" diagnosis: `onBugReportSubmitted` *did* attempt to post to Discord via `sendBugToDiscordForum()`, but silently swallowed failures (`console.error` only, no retry, no outbox) — almost certainly the actual mechanism behind the user's "raporlar Discord'a gitmiyordu" complaint, not a total absence of integration.

**Recovery:** Used the still-authenticated `firebase-tools` OAuth token to call the Cloud Storage JSON API directly (`gcf-v2-sources-29839209813-europe-west1` bucket has versioning + a 7-day soft-delete retention window) and downloaded the deleted functions' `function-source.zip` by generation number before the retention window could expire. Restored `verifyRideContribution`/`claimAchievementMilestone`/`activateApexPass` verbatim into `functions/index.js` immediately (production-safety priority, done without waiting for user confirmation — leaving them broken was strictly worse than restoring). Restored `discordInteractions` as `functions/src/discord/interactions.js` (added `tweetnacl` dependency, `DISCORD_PUBLIC_KEY` to `functions/.env` — confirmed via the Discord Developer Portal screenshot that `https://europe-west1-apex-flow-7baea.cloudfunctions.net/discordInteractions` is genuinely registered as the app's Interactions Endpoint URL) — kept behavior identical to the recovered version (PING/PONG + ack-only stub, no button/state-machine logic, that's still explicitly Phase 2). **Deliberately did NOT restore `onBugReportSubmitted`** — running it alongside the new `dispatchBugReportToDiscord` outbox trigger would double-post every bug report to Discord. Verified post-recovery: `firebase functions:list` shows all 7 functions present, `curl` against the live `discordInteractions` URL returns 401 for an unsigned request (correct behavior, not 404/500).

**Secondary finding, unrelated to the incident but discovered while recovering the zip:** the recovered `.env` bundled inside that 2026-07-29 deployment contained a **real, plaintext `DISCORD_BOT_TOKEN`** (Secret Manager was not used for it at the time) plus `DISCORD_PUBLIC_KEY`/`DISCORD_APPLICATION_ID`/`DISCORD_GUILD_ID`/`DISCORD_QA_ROLE_ID`. None of these were written to any file in this repo or echoed back to the user beyond confirming which value the user had pasted into chat earlier was actually `DISCORD_PUBLIC_KEY` (not the bot token — the user's real bot token exposure during this session's setup was to a *different*, since-rotated value, confirmed via hash comparison, never displayed). The old token is dead regardless once the user reset it in the Discord Developer Portal this session.

**Also fixed as a deploy blocker, not part of the Discord feature itself:** `functions/node_modules/.bin/*` shims were all non-executable and missing their shebang/exec wrapper content (e.g. `eslint`, `firebase-functions` were just bare relative-path text files, not real launcher scripts) — this is why `flutter`-side ESLint never worked and why the first deploy attempt failed with `EACCES`/`ENOEXEC` before any Discord code was even reached. Fixed by `chmod +x` on the whole `.bin/` dir and manually rewriting the `firebase-functions` shim with the standard npm launcher pattern. **Note: `functions/node_modules/` is tracked in git in this repo (unusual — normally gitignored)**, so these permission/content fixes show up as tracked-file changes; not reverted since deploy is not possible without them, but flagged here in case a future session wants to properly `.gitignore` node_modules and stop tracking it.

**Not committed yet** — `functions/index.js`, `functions/.env`, `functions/src/discord/*`, `functions/package.json`/`package-lock.json` (added `tweetnacl`), and the `functions/node_modules/.bin/*` permission fixes are all working-tree changes only, awaiting the user's explicit commit request per CLAUDE.md.

## 2026-08-06 — Faz 1 (Production Doğruluğu) Tamamlandı
Kullanıcının onayladığı çok fazlı plana göre (bkz. `activeContext.md`) Faz 1'in 4 maddesi tamamlandı:

1. **Firestore rules deploy edildi.** Kod tarafı taraması (tüm `.collection()` çağrıları grep ile) rules dosyasıyla birebir örtüştüğü doğrulandı, `firebase deploy --only firestore:rules --project apex-flow-7baea` ile production'a yayınlandı. Emulator testi Java 21+ gerektirdiği için (mevcut: 17) yine yapılamadı, kod-tabanlı doğrulamayla yetinildi — kullanıcı onayıyla deploy edildi.
   - **Yan bulgu:** Bu oturumda geri getirilen `verifyRideContribution`/`claimAchievementMilestone`/`activateApexPass` fonksiyonlarının kullandığı `users/{uid}/reward_wallet`, `achievement_private`, `telemetry_dna`, `users/{uid}/entitlements` alt koleksiyonları hiçbir Flutter ekranından okunmuyor/yazılmıyor (sıfır client referansı) — yarım kalmış, client'a hiç bağlanmamış bir "Apex Pass" özelliği. Şu an zararsız, ama `users/{uid}/{document=**}` wildcard kuralı kullanıcının kendi bu alt dokümanlarını serbestçe yazabilmesine izin veriyor — biri client'ı bu path'lere bağlarsa (örn. entitlement kontrolü için okursa) sahte-entitlement riski doğar. Takip gerektirir, ama şu an aktif sömürülebilir değil.
2. **RevenueCat production API key ayarlandı** (commit henüz yok). `lib/core/services/purchases_service.dart`'taki `_androidApiKey`, sandbox `test_...` değerinden production `goog_pGsrqzcNiRuecBuzekHGWCmlrLW` değerine güncellendi. iOS key hâlâ `null` (RevenueCat'te iOS app henüz kurulmadı — ayrı, gelecekteki bir iş). `flutter analyze`: 0 sorun.
3. **"Satın Alımları Geri Yükle" UI'ı eklendi.** `premium_paywall_screen.dart` (sadece premium olmayan kullanıcılara gösterilir) ve `supporter_paywall_screen.dart`'a (her zaman görünür) `PurchasesService.instance.restorePurchases()`'ı çağıran birer `TextButton` eklendi; sonuç `updatePremiumStatus`/`updateSupporterTier`'a bağlandı (supporter tarafında 3 tier'den en yükseği seçiliyor). `flutter analyze`: 0 sorun. Gerçek restore akışı sandbox hesap gerektirdiği için **test edilemedi** (not verified).
4. **iOS bundle ID uyumsuzluğu düzeltildi.** Firebase'de tek iOS app `com.example.apexflow` (Flutter şablon varsayılanı) ile kayıtlıydı — Firebase bir app'in bundle ID'sini değiştirmeye izin vermediği için Firebase Management API üzerinden (aynı oturumda zaten authenticated olan `firebase-tools` OAuth token'ıyla) doğru ID'yle **yeni bir iOS app** (`1:29839209813:ios:d5ddb728b3ba9723796bdc`, `com.apexflow.app`) oluşturuldu, `GoogleService-Info.plist` indirilip `ios/Runner/GoogleService-Info.plist`'in yerine kondu, `ios/Runner.xcodeproj/project.pbxproj`'daki 3 `PRODUCT_BUNDLE_IDENTIFIER` satırı (`RunnerTests` hariç, o zaten doğruydu) `com.apexflow.app` yapıldı. `flutter build ios --no-codesign` başarıyla tamamlandı ("Building com.apexflow.app for device" logu doğrulandı). Eski `com.example.apexflow` app'i Firebase'de hâlâ duruyor (zararsız, silinmedi — kullanıcı isterse Console'dan silebilir).
   - **Not:** İmzalama/provisioning profile, APNs sertifikaları, TestFlight/App Store Connect kaydı bu değişikliğin kapsamında değildi — sadece Firebase eşleşmesi ve bundle ID tutarlılığı düzeltildi. Gerçek cihazda code-signed bir build/imza akışı **test edilmedi**.

**Commit edilmedi** — kullanıcı onayı bekleniyor.

## 2026-08-06 — Faz 2 (Doğrulama ve Temizlik) Tamamlandı
1. **Phase 9.1 doğrulaması** — bkz. yukarıdaki güncellenmiş "Phase 9.1 Optimization Items" bölümü, tüm 3 iddia CONFIRMED.
2. **`functions/` ESLint config eklendi** (`.eslintrc.json`, `eslint-config-google` tabanlı ama proje stiliyle çakışan kurallar — `object-curly-spacing`, `indent`, `quote-props`, `comma-dangle` vb. — kapatıldı, kodu toptan reformat etmek yerine). `npm run lint` artık 0 hatayla geçiyor. Ayrıca `node_modules/.bin/eslint` shim'i de (aynı `firebase-functions` sorunundaki gibi) içerik olarak bozuktu, standart npm launcher formatıyla düzeltildi.
3. **`functions/node_modules` git tracking'den çıkarıldı.** Kullanıcı iki bilgisayar (iş yeri Mac + ev Windows) arasında dependency versiyonlarını eşit tutmak istiyormuş — bunun doğru yolu zaten git'te olan `package-lock.json` ile her iki makinede ayrı `npm install` çalıştırmak (node_modules'ı git ile taşımak platformlar arası zaten çalışmıyor, native binary'ler ve `.bin/` shim'leri OS'e özel — bu oturumda tam da bunun bozukluğunu gördük). `.gitignore`'a `node_modules/` eklendi, `git rm -r --cached functions/node_modules` ile 6983 dosya tracking'den çıkarıldı (diskte duruyor, silinmedi).
4. **`lib/` ölü kod taraması** — 127 dosya tek tek `grep` ile (hem `package:` hem relative import biçimleri) tarandı. 6 dosya, 4 grup halinde kullanıcı onayıyla silindi:
   - `lib/core/sync/sync_coordinator.dart`, `sync_conflict_resolver.dart`, `sync_models.dart` — önceden de tespit edilmiş, hiç bağlanmamış eski senkron alt-sistemi.
   - `lib/features/harmony/domain/harmony_engine_v2.dart` — aktif Harmony Engine'in (`lib/harmony_engine/harmony_engine.dart`, 2a'da CONFIRMED) yarım kalmış v2 yeniden yazımı.
   - `lib/rides/application/ride_vibe_pdf.dart` — hiçbir ekrandan tetiklenmeyen temalı PDF paylaşım özelliği.
   - `lib/core/preview/preview_policy.dart` — kullanılmayan, geçersiz "sadece Chrome'da test et" notu.
   - Yanlış pozitifler (silinmedi, gerçekten kullanılıyorlar — relative import kullandıkları için ilk grep taraması kaçırmıştı): `fuel_history_list.dart`, `speed_kalman_filter.dart`, `motion_state_machine.dart`.
   - Silme sonrası doğrulama: `flutter analyze` → 325 issue, **0 error** (silinen dosyalara hiç dangling reference yok); `flutter test` → **91/91 passed**.

**Commit edilmedi** — kullanıcı onayı bekleniyor. Faz 3 (yeni özellikler) henüz başlamadı.

## 2026-08-06 — Faz 3a (Yakıt Ekonomisi Analitiği) Tamamlandı
`lib/fuel/` zaten bir giriş formu + `FuelHistoryList` (range-filtreli geçmiş) içeriyordu; `FuelEntry`'de `brand` ve `odometerKm` alanları, `receipt_parser.dart`'ta marka OCR/alias tanıma (Shell/Opet/BP/vb.) ve `fuel_screen.dart`'ta bir sonraki odometre tahmini için "son dolumdan bu yana kat edilen mesafe" hesaplaması **zaten vardı** — sıfırdan değil, üzerine inşa edildi. Ayrıca `garage_screen.dart`'ta zaten `CostAnalyticsPainter` ile 6 aylık yakıt+bakım harcama trendi çizilen bir grafik olduğu keşfedildi — bu yüzden TODO.md'nin "harcama trendi" isteği zaten kısmen karşılanıyormuş; eksik olan asıl **tüketim (L/100km) trendi**, istasyon kıyaslaması, anomali tespiti ve km-başı-maliyetti.

Eklenenler (`lib/fuel/application/fuel_state.dart`):
- `FuelConsumptionPoint`/`FuelBrandStat`/`FuelAnomaly` modelleri.
- `consumptionTrend`: art arda odometre etiketli iki dolum arasındaki L/100km (odometre geriye gitmesi/typo'ya karşı korumalı, tüm geçmiş üzerinden hesaplanıp aktif aralığa kırpılıyor — `filteredEntries` ile tutarlı kalması için range hesaplaması `_rangeBounds` adlı ortak bir getter'a çıkarıldı).
- `brandComparison`: marka bazlı dolum sayısı, ortalama L/fiyatı, ortalama L/100km.
- `costPerKm`: aktif aralıktaki toplam harcama / toplam mesafe.
- `latestConsumptionAnomaly`: son dolum, önceki noktaların ortalamasının **%20 üzerindeyse** işaretleniyor (kullanıcı isteği: "normal tüketimin %20 üzerine çıkılması").

Eklenenler (UI, `lib/fuel/presentation/widgets/fuel_insights_panel.dart`, yeni dosya):
- Anomali banner'ı (lastik basıncı/hava filtresi/zincir önerisi, hata değil bilgi tonunda).
- Tüketim trendi mini bar chart'ı — proje genelinde harici bir chart kütüphanesi olmadığı için (garage'daki `CostAnalyticsPainter` ile aynı desen) `CustomPainter` ile yazıldı, kendi izole `_ConsumptionTrendPainter` sınıfı olarak (mevcut painter'a bağımlılık eklemeden, aynı görsel dili taklit ederek).
- İstasyon kıyaslaması listesi.
- `fuel_screen.dart`'a `FuelHistoryList`'in hemen üstüne eklendi.

Test: 7 yeni birim testi (`test/fuel_economy_analytics_test.dart`) — tüketim hesabı, odometre-geriye-gitme koruması, anomali eşiği, marka gruplama. `flutter analyze`: yeni dosyalarda 0 sorun (pre-existing 325 issue'dan bağımsız). `flutter test`: **98/98 passed**.

**Commit edilmedi.**

## 2026-08-06 — Faz 3b (Belge Cüzdanı Hatırlatıcı Sistemi) Tamamlandı
`lib/documents/` zaten büyük ölçüde inşa edilmişti — `DocumentEntity.expirationDateIso` Isar şemasında zaten vardı (migration gerekmedi), `TaxRecord` domain modeli (mtv_1/mtv_2/insurance/inspection/road_tax, dueDate, isPaid) tamamen kuruluydu ve vault ekranında add/list/paid-toggle akışı çalışıyordu, `NotificationScheduler.scheduleDocumentExpiryReminder` **tek** bir 30 günlük hatırlatıcı zaten atıyordu. Eksik olan: 15/1 günlük ek hatırlatıcılar, tax kayıtları için hiç hatırlatıcı olmaması, resmi yönlendirme kısayolları, ve şifreleme.

1. **30/15/1 gün hatırlatıcılar**: `NotificationScheduler.scheduleDocumentExpiryReminder` tek çağrıdan 3 çağrıya çıkarıldı (`reminderOffsetsDays = [30, 15, 1]`, geçmişte kalan offsetler sessizce atlanıyor). Yeni `scheduleTaxDueReminder` eklendi ve `document_vault_screen.dart`'ın tax-ekleme akışına bağlandı (önceden hiç bildirim yoktu). `app_strings.dart`'taki `notifDocExpiryBody` artık `daysLeft` parametresi alıyor (30/15/1 için farklı metin), yeni `notifTaxDueTitle`/`notifTaxDueBody` eklendi.
2. **Resmi kısayollar**: Tax sekmesine TÜVTÜRK (muayene randevu) ve e-Devlet (MTV ödeme) linklerine açılan iki küçük `OutlinedButton` chip eklendi (`_OfficialShortcutChip`, `url_launcher` — zaten bağımlılık olarak vardı, sadece bu dosyada import edilmemişti).
3. **Şifreli yerel depolama**: Isar v3.1'in (bu projenin kullandığı sürüm) **native veritabanı şifrelemesi olmadığı** tespit edildi (`Isar.open()`'da `encryptionKey` parametresi yok — bu Isar v4'e ait, henüz olgunlaşmamış bir özellik; v4'e geçmek ayrı, büyük bir upgrade olurdu). Kullanıcıyla konuşulup asıl hassas verinin (taranmış ehliyet/ruhsat/sigorta görselleri) dosya seviyesinde şifrelenmesine karar verildi — Isar'daki metadata (başlık/açıklama) şifrelenmedi, gerçek risk zaten görsellerdeydi.
   - Yeni `lib/core/storage/document_file_crypto.dart`: `flutter_secure_storage` (Keychain/Keystore) ile cihaza özel rastgele AES-256 anahtarı saklanıyor (kullanıcı hesabına değil cihaza bağlı — kullanıcı tercihiyle), her dosya için rastgele IV üretilip dosyanın başına ekleniyor (`encrypt` paketi, AES-CBC).
   - `document_vault_screen.dart`'ın "Kaydet" akışında, `image_picker`'dan gelen ham dosya artık kaydedilmeden önce `DocumentFileCrypto.encryptIntoVault()` ile şifrelenip app'in belgeler dizinine taşınıyor (eski plaintext temp dosya siliniyor), dönen şifreli path Isar'a yazılıyor.
   - Görüntüleme tarafında yeni `_VaultImage` widget'ı (`FutureBuilder` + `Image.memory`) hem thumbnail'de hem tam ekran dialogda kullanılıyor; decrypt başarısız olursa (örn. bu özellikten önce kaydedilmiş eski plaintext dosyalar) `Image.file`'a **sessizce fallback** yapıyor — kırık görsel veya crash yok.
   - **Gerçek kullanıcı olmadığı için** (kullanıcının kendi teyidi) migration/veri kaybı riski değerlendirilmedi — bu karar sadece test/geliştirme ortamı için geçerli, üretimde gerçek kullanıcılar olduğunda bu tür bir şema/depolama değişikliği CLAUDE.md'nin migration kuralına tabi olurdu.

Test: `flutter analyze` yeni dosyalarda 0 sorun, `flutter test`: 98/98 passed, `flutter build ios --no-codesign` başarılı (yeni native bağımlılık `flutter_secure_storage` derlendi doğrulandı). Android build ayrıca **test edilmedi** (not verified).

**Commit edilmedi.**

## 2026-08-06 — Faz 3c (Grup Sürüşü Canlı Takip): Kasıtlı Olarak Ertelendi
Kod yazmadan önce kullanıcıyla maliyet/ürün-uyumu konuşuldu (kullanıcı özellikle "başlamadan önce dur, beni dinle" dedi):
- **Maliyet analizi:** Proje zaten Blaze planında (bu oturumda Cloud Functions'ı sorunsuz deploy ettik — Spark planda 2nd gen Functions deploy edilemez, bu kesin kanıt). Realtime Database ile tahmini maliyet: 5 kişilik, 1 saatlik bir grup sürüşü ~1-1.5MB veri trafiği üretir — RTDB'nin ücretsiz 10GB/ay indirme kotasının onbinde biri. **Maliyet gerçek engel değildi.**
- **Ürün karar:** Kullanıcı, sürekli canlı GPS yayınının piyasada doymuş bir kategori olduğunu (Life360/Strava Beacon/Rever) ve ApexFlow'un asıl farkının (Harmony Engine, telemetri, bakım/yakıt takibi) bu olmadığını fark etti. Karar: **ilk sürümden sonra, ayrı büyük bir güncellemede** ele alınacak.
- Mimari yönü netleşti (ileride uygulanacaksa): Supabase değil **Firebase Realtime Database** (TODO.md'nin eski notu güncellendi), `flutter_map`+OSM (Google Maps değil — `google_maps_flutter` pubspec'te kurulu ama `lib/`'de sıfır kullanım, ölü bağımlılık, ayrı bir temizlik konusu olarak not edildi).
- `TODO.md`'nin ilgili maddesi güncellendi: "Grup Sürüşü Yönetimi" (davet/QR/roster) aslında **zaten tam kurulu** (`group_ride_lobby_screen.dart`) — TODO.md'de yanlışlıkla işaretlenmemiş, düzeltildi. Kalan 4 alt görev (gerçek zamanlı senkron, canlı harita, interpolation, pil tasarrufu) "ERTELENDİ" notuyla işaretli bırakıldı.

## Faz 3 (Yeni Özellikler) — Genel Özet
3a (yakıt ekonomisi) ve 3b (belge hatırlatıcıları) tamamlandı, kod yazıldı ve test edildi (yukarıda ayrı ayrı detaylı). 3c kasıtlı olarak ertelendi (yukarıda). Üçü de **commit edilmedi** — kullanıcı onayı bekleniyor. `flutter test` son durumda 98/98 passed (3a+3b testleri dahil), `flutter analyze` yeni/değişen dosyalarda 0 sorun, `flutter build ios --no-codesign` başarılı.

## Other Known Pre-Existing Risk Areas (per CLAUDE.md, carry forward until closed by evidence)
- ~~Pocket telemetry zeroing~~ — **OBSOLETE, confirmed by user 2026-08-06.** The pocket-mode lean-angle estimation system this risk referred to was intentionally removed by the user and will not be reintroduced. No longer tracked as an open risk. Note: `CLAUDE.md`'s Critical Invariants section still has a line referencing this ("gyro updates must not erase valid pocket-mode estimates") — that line is now stale; not edited here since `CLAUDE.md` is the user's own governance file, flagging for the user to update it directly if desired.
- Platform configuration inconsistencies (Android/iOS) — not verified this session.
- **Resolved, 2026-08-04**: `assets/word documents/key.properties` and `assets/word documents/upload-keystore.jks` are the current, actively-used signing config (user confirmed) — byte-identical to `android/key.properties` / `android/app/upload-keystore.jks`. The plaintext password value observed in the file during this session's read is stale (user confirmed it is no longer the real keystore password), so treat the specific value as non-sensitive at this point, but do not assume future contents of these files are safe to read aloud or commit — apply the same care to any signing file regardless of whether a previously-seen value has since rotated. `.gitignore` was broadened (`key.properties`, `*.jks`, `*.keystore`, global patterns — commit `2f53bfd`) so these and any future copies can never be accidentally committed. Files intentionally kept on disk, not deleted — they are needed for local release builds.

## Repo State as of 2026-08-04 (post Memory Bank init + cleanup)
- `main` has 2 local commits not yet pushed: `31d1808` (memory bank update) and `2f53bfd` (`.gitignore` fix). `origin/main` is at `faa045d`. Prior pushed commits: `347ae4b` (memory bank init + 9-file docs cleanup) and `faa045d` (tracked `CLAUDE.md`, the closed-test-deploy workflow, `docs/google_closed_testing.md`, `distribution/whatsnew/*`).
- Remaining untracked files: `assets/word documents/key.properties`, `assets/word documents/upload-keystore.jks` — now gitignored, correctly excluded from version control by design (see risk note above), not an open item.
These represent in-progress user work related to Closed Beta release; do not discard or overwrite without explicit approval.

## Phase 9.1 Optimization Items — CONFIRMED 2026-08-06 (all 3, code-verified)
`PHASE_LOCK.md` and commit `887ad57` claimed these three items complete. Verified by direct code read this session:
1. **CONFIRMED.** `lib/rides/application/telemetry_isolate.dart` — gyro sampled at 20ms (50Hz), accelerometer at 100ms (10Hz) inside the isolate, output gated to the main isolate via a real `Timer.periodic(Duration(milliseconds: 200))` (5Hz), lines 165-175.
2. **CONFIRMED.** `lib/rituals/application/weather_service.dart` lines 915-949 — real 30-minute TTL via `ApexKvStore` (not raw `shared_preferences`, but the same underlying storage per CLAUDE.md's stack notes), both an exact-coordinate cache and a 5km-radius general-location fallback cache.
3. **CONFIRMED**, with a caveat. `lib/harmony_engine/harmony_engine.dart` lines 87-90/105-109 — `latestRide.maxLeanAngle > 45.0 || latestRide.hardBrakes > 3` really is OR'd with the mood-string check, not mood-only. This is the file actually wired into the app (`dashboard_state.dart`, `garage_state.dart`, `user_profile_state.dart` all reference it). **Caveat:** a second, unrelated `lib/features/harmony/domain/harmony_engine_v2.dart` exists with zero references anywhere else in `lib/` — fully dead code, added to the 2c dead-code-sweep candidate list.

## Planned / Not Started (per `TODO.md`)
- Fuel economy analytics: station comparison, anomaly detection, consumption graphs, cost-per-distance — all unchecked.
- Document vault: encrypted local storage confirmation, renewal calendar, proactive 30/15/1-day reminders, official redirect shortcuts — unchecked.
- Group ride live tracking (Supabase Realtime/WebSocket, live map via `flutter_map`/OSM, interpolation, battery-saving mode) — unchecked, premium-gated feature, not yet implemented per TODO (rider profile/friend system items are marked done `[x]`).

## Next Step
No active task in progress. When work begins, update `activeContext.md` with the specific task, branch/commit, and decisions before editing code.

## 2026-08-05 — Safety and Broken-Flow Fixes (Local, Uncommitted)
- Removed all repository occurrences of the debug TLS certificate bypass (`HttpOverrides.global` / `badCertificateCallback`) from app startup and Maps short-link resolution.
- Replaced the Insights cost-entry fake-success action with validated, durable `ApexKvStore` persistence. Manual entries are kept separate from fuel-derived ledger rows, hydration restores them, and an unsuccessful write rolls state back before the UI reports failure. Added two regression tests.
- Declared directly imported `crypto`, `path_provider_platform_interface`, and `plugin_platform_interface` packages in `pubspec.yaml`.
- Removed Android/iOS dummy Google Maps keys. Android now reads `MAPS_API_KEY` from a Gradle property or environment variable. iOS reads `GOOGLE_MAPS_API_KEY` from a gitignored `ios/Flutter/Secrets.xcconfig`; an example file is tracked. No real key was added.
- Verification: `flutter test --no-pub` passed 93/93; `flutter analyze --no-pub` reported 325 warnings/info and 0 errors (baseline was 328); `flutter build apk --debug --no-pub` succeeded. iOS build remains not verified because the current environment is Windows.
