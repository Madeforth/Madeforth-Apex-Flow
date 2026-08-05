# Active Context

## Current Task

**2026-08-05, THIRD-PASS audit — park/QR system + i18n + layout, DONE, branch `agent/fix-safety-persistence-maps`:**
User asked specifically for a deep audit of: the parking-warning/QR-contact system (`qr_contact_web/` + Firestore), in-app QR generation/scanning, app-wide design/workflow bugs, and i18n/language inconsistencies. 3 parallel Explore agents scanned each area; the most critical findings were verified directly in code before fixing (`smart_park_alert_handler_screen.dart`, `global_notification_overlay.dart`, `parking_notification_state.dart`, `qr_contact_web/main.js`, `firestore.rules`, `qr_scanner_screen.dart`, `main.dart`, `AndroidManifest.xml`). Plan at `C:\Users\onyed\.claude\plans\stateful-swimming-fern.md` (overwrote the prior 20-item plan — that one's done). All 24 items (A1-A10, B1-B10, C1-C3) fixed and committed across 8 commits (`0770a74`, `992f090`, `71d1e3e`, `6d3f6c3`, `2dd4c0e`, `3cb3d46`, `1d680a6`, plus the profile_hub tag-warning edit folded into `71d1e3e`), each verified with `flutter analyze` (0 errors, 324 issues) + `flutter test` (93/93).

**Highest-severity fix (A1)**: the in-app QR-scan "Send Smart Park Alert" flow (`smart_park_alert_handler_screen.dart`) previously only fired a *local* notification on the scanning device and then displayed "Notification sent successfully to the owner!" — a direct violation of CLAUDE.md's "do not show success before durable completion" invariant, since the owner received literally nothing. Fixed by writing to the real `parking_notifications` Firestore collection (same one `qr_contact_web/main.js` already used), reusing existing rules/stream-provider infra — no new backend needed.

**Other real fixes worth remembering**:
- `reason` sent to Firestore is now a translation key (`blocked`/`fallen`/`crash`/`towed`) instead of raw Turkish text, mapped to 3 languages in `global_notification_overlay.dart` (fallback to raw text for legacy docs).
- `firestore.rules` now requires `parking_notifications.vehicleId` to reference an existing `rider_tags` doc via `exists()` — **prepared but NOT deployed this session** (no local Firestore emulator; user must verify in Rules Playground before `firebase deploy --only firestore:rules`).
- `replyToNotification` wrapped in try/catch; the full-screen parking-alert overlay gained a "Not Now" local-dismiss so a failed/offline write can no longer trap the user behind an unclosable overlay.
- `driverNote` now timestamped and expires after ~3h in the web view (was showing indefinitely / cross-contaminating between unrelated alerts).
- QR scanner (`qr_scanner_screen.dart`) tightened to require the real host before routing into the alert flow (was matching bare `?id=`), added `mounted` guards, replaced raw exception text with friendly translated errors.
- Currency displays (Insights, Fuel history, wishlist, manual cost entry) now use `AppSettingsState.currencySymbol` instead of hardcoded `₺` — this field already existed and auto-detected from device locale, it just wasn't wired to these screens.
- **Explicitly investigated and confirmed NOT a bug**: the TR/EU accident-report wizards' hardcoded language (Turkish KTT form vs. English EU accident statement) — these are jurisdiction-locked official legal documents, correctly independent of the app's UI language setting. User confirmed this reading before any plan was finalized.
- Item **#19 from the prior pass (hardcoded colors bypassing ApexColors in Insights) remains deferred** — same reasoning applies to a new batch of similar findings from this pass (nav bar color duplicated across ~10 files, a "wrong cyan" `0xFF0EA5E9` used ~15 places, `profile_hub_screen.dart`'s own slate palette) — all explicitly left untouched pending a session with real visual verification (device/emulator screenshots), not guessed at.

**Deferred, larger-scope items (not bugs to silently carry, but out of this pass's scope by design):** real FCM push notifications for parking alerts when the owner's app is backgrounded/killed (needs a Cloud Function trigger — new server infra); notification dedup/local history; AndroidManifest App Links host correction + `assetlinks.json` hosting-side verification for the QR deep link (`main.dart`'s handler now reads both `rider` and `id` params defensively, but is still unreachable until the manifest/hosting side is fixed, which needs the user's own action).

---

**2026-08-05, second-pass bug audit — DONE (19/20, #19 deferred), branch `agent/fix-safety-persistence-maps`:**
Mid-session discovery: the working directory was found checked out to `agent/fix-safety-persistence-maps` instead of `main`, with a commit (`8bcf84e`) from what appears to be a **different, concurrent Claude Code session/window** working in this same repo directory (see the line below this one — that's its own note about its own commit, left as-is). Confirmed no file/content conflicts before continuing; user was asked and explicitly said to continue on this branch rather than move to `main`. **Before merging this branch to `main`, re-verify no further divergence happened from that other session.**

Task: user asked for a full-project scan (functional + design bugs), done via 3 parallel Explore agents (`isolation: "worktree"`) covering (a) core/services/storage/sync/settings/profile/onboarding/notifications, (b) garage/rides/rituals/harmony_engine/fuel/shared, (c) documents/insights/dashboard/features + design tokens. Plan approved via ExitPlanMode, saved at `C:\Users\onyed\.claude\plans\stateful-swimming-fern.md`. 20 findings total; **every finding was spot-checked directly in code before any fix was applied** (not blindly trusted) — this caught 2 false positives from the Explore agents (item #7 Insights cost-entry — already correctly implemented, turned out to be the *other concurrent session's* `8bcf84e` fix, which is why it looked "already fixed" when checked; item #12 addServiceRecord/lastServiceKm — the agent misunderstood `type: 'diy'` as "non-service", but it means rider-self-performed service, a real service event, so the flagged behavior is actually correct).

**Done (commits `134c2f2`, `f1c0120`), all verified with `flutter analyze` (0 errors) + `flutter test` (93/93) after each group:**
1. Google sign-in broken tag interpolation (`@google_randomNum}` → `@google_$randomNum`)
2. `loginUser()` (tag+password) now restores avatar/theme/XP/supporter/badges like the other login methods — was previously silently overwriting the user's real cloud profile with defaults on next auto-sync
3. `logout()` now clears `_youtubeKey`/`_supporterTierKey`/`_unlockedSupporterTiersKey`/`_riderXpKey` (previously leaked across accounts on a shared device)
4. `deleteAccount()` now returns success/failure instead of throwing uncaught; UI shows a retry-oriented error
5. Bug reports use the real installation id instead of hardcoded `'tester_user_uid'`
6. `LocalBugOutbox.saveReport()` rethrows on failure instead of swallowing it; UI shows an error snackbar on submit failure
7. *(false positive — already fixed by the other session, no action)*
8/8b. Document expiry reminder now scheduled against the document's real persisted id (`addDocument()` now returns it); `deleteDocument()` cancels the reminder
9. Documents expiring in <30 days now get a near-term fallback reminder instead of none
10. Wear-per-ride now accumulates via persisted fractional carry fields (`chainWearCarry` etc. on `MotorcycleProfile`/`MotorcycleEntity`) instead of each ride's delta being rounded to 0 for typical short/commute distances
11. Maintenance calendar checks now use a real `wearUpdatedAtIso` timestamp (stamped on every wear-affecting change) instead of a permanently-fixed "installed 90 days ago"
12. *(false positive, see above — no action)*
13. Notification timezone was hardcoded to `Europe/Istanbul` for every user; added the `flutter_timezone` package (user confirmed the new dependency first) and now reads the real device IANA timezone
14. `TaxRecord.dueDate` now uses `tryParse` + fallback instead of unguarded `parse` (could crash Documents/Insights on malformed data)
15. Insights cost ledger no longer shows a hardcoded fake date ("11 Jul 2026") on every entry — `CostEntry` now has a real `dateIso` field
16. `ServiceRecord.cost`'s currency-blind regex ($/€ treated as TRY) — documented as a known limitation inline, full fix (needs a currency field) explicitly out of scope for this pass

**Done (commits `329e390`, `fa5f2f2`, `bbb33e6`), all verified with `flutter analyze` (0 errors, 324 issues) + `flutter test` (93/93):**
17. `TextEditingController`s in `_showAddBikeSheet`/`_showEditBikeSheet` (`garage_screen.dart`) now disposed on sheet close (`.then()` for the fire-and-forget add sheet; inline after `await` for the edit sheet).
18. `RideStateNotifier.endRide()` now returns `bool` (saved/discarded) instead of `void`. All 4 call sites (`rides_screen.dart`, `apex_dashboard_screen.dart`, `group_ride_lobby_screen.dart` x2) now show a snackbar when a ride is silently discarded as too short/slow — previously one group-ride path could show a false "completed" success message even when the ride was discarded internally, and a zero-duration/≤0.05km edge case wasn't covered by any caller's own pre-check.

**Skipped, by explicit user decision (not a false positive — deliberately deferred):**
19. Hardcoded colors bypassing `ApexColors` tokens. Investigation found most of `insights_screen.dart`'s ~90 hardcoded `Color(0xFF...)` values do NOT exactly match `ApexColors.dark`'s hex values (e.g. `0xFF1E293B` vs the token's `0xFF1F2937`) — this looks like a deliberate separate "slate" visual language, not simple oversight, and part of the file also uses a third distinct near-black/OLED palette. Converting either risks a real visual regression with no way to screenshot-verify in this environment. User was asked how to proceed (exact-match-only vs. nearest-token-for-everything vs. skip) and chose **skip for now** — revisit in a session where visual verification (device/emulator) is available. `apex_limelight_navigation_bar.dart:53` and the 2 spots in `garage_screen.dart` are in the same boat, untouched.

**Done (commit `bbb33e6`):**
20. `apex_app_shell.dart`'s `compactNavigation` now uses `ApexBreakpoints.compact` (420) instead of a hardcoded `430`, resolving the constant/behavior drift. `insights_screen.dart`'s unused `apex_breakpoints.dart` import (no breakpoint logic in that file to wire it to) was removed rather than given speculative usage.

**Second-pass audit is now closed out**: 19 of 20 items fixed and committed; #19 explicitly deferred by user choice, not forgotten — see above for exactly what to ask before touching it again.

**Side task, same session:** built a debug APK (`flutter build apk --debug`) and installed it on the user's connected LG G5 (`LGH85092a403f4`, `com.apexflow.app`) for manual testing, at the user's request when they had to leave for work — this used the code state as of commit `f1c0120` (through item #16 only); items 17/18/20 (post-#16 fixes) are NOT yet on that installed build.

---

**All 6 items on the user's original issue list are fixed and committed** (`ce6131b`, `443ea27`, `aece0d1`, `e107a75`, `5ba660d`, `e2eb1d0` — see `progress.md` for the full per-item detail; this was a prior, separate pass, now superseded as "done" — the second-pass audit above is the current active work). Two things remain genuinely open from that pass, both requiring the user's own action, not more code:
1. Deploy `firestore.rules` (items #3/#5) — never run this session; needs `firebase deploy --only firestore:rules` after the user verifies in Firebase Console Rules Playground (no local Java 21+ for the emulator).
2. Swap the RevenueCat sandbox API key for the production key (item #2) before any real release build, and decide whether to add a "Restore Purchases" UI entry point and/or the optional Pub/Sub real-time notifications (both deferred, not blocking).

RevenueCat dashboard setup (item #2) was done live with the user via a long screen-sharing-by-screenshot session — see the "RevenueCat Dashboard Setup Walkthrough" section below for the exact gotchas hit, useful if this needs revisiting (e.g. adding App Store/iOS later).

After the 6-item fix list, also did two rounds of repo file cleanup at the user's request (commits `d50f8e5`, `49b6ac0`):
- `assets/images/`: removed 5 files confirmed unreferenced anywhere in `lib/` or `pubspec.yaml` (`accident_form_eu_back.jpg`, `accident_form_eu_front.jpg`, `accident_form_tr.jpg` — the accident-report feature actually uses `assets/templates/*.pdf`/`*.png` instead; `app_logo_transparent.png`; `motorcycle_vector.png` — an old dashboard illustration removed in an earlier design pass per DEVLOG history, now gone from the repo too). Deliberately kept: `assets/images/Apex Flow Final Logo/` (brand asset archive — only one file in it is code-referenced, but the SVG masters/exports are intentional design assets, not dead weight) and `assets/word documents/*.docx`/`*.md`/`*.png` (active design reference docs).
- Repo root: removed `analyze_output.txt`, `build_log.txt` (stale logs), `ApexFlow-Source-Code.zip` (57MB redundant full-source backup — **still present in git history**, only removed from the working tree; a history rewrite would need separate explicit approval), and four one-off dev scripts (`draw_icon.py`, `extract_vector.py`, `generate_icon.py`, `fix_strings.dart`) not imported by the app.
- **Not done**: a full `lib/` sweep for unused/dead Dart files — user flagged limited time (12 min) as insufficient for that safely; explicitly deferred to a future session rather than rushed.

## Branch / Commit
- Branch: `main`, pushed and in sync with `origin/main` (`github.com/Madeforth/Madeforth-Apex-Flow.git`) as of the last push — **verify with `git status`/`git log origin/main..HEAD` before assuming, several commits have landed since (see above) and push cadence in this session is only ever done when the user explicitly asks.**
- HEAD (as of this update): `49b6ac0` — "chore: remove stale logs, one-off scripts, and a redundant source zip". Earlier history: `d50f8e5` (unused images), `8e83b04`/`e2eb1d0`/`5ba660d`/`e107a75`/`aece0d1`/`ce6131b`/`443ea27` (the 6-item fix list), `faa045d` and earlier (memory bank init/docs cleanup — see `git log` for full history, not duplicated here).
- GitHub CLI (`gh`) auth: active account switched mid-session from `Krator7` (stale) to `Madeforth` (matches repo owner; scopes include `repo` + `workflow`). `Krator7` remains logged in but inactive. `gh auth setup-git` was run so `git push` uses the `gh`-managed credential instead of prompting Git Credential Manager interactively (which fails in this non-interactive shell).
- Remaining untracked files (deliberately NOT committed — see Security note below): `assets/word documents/key.properties`, `assets/word documents/upload-keystore.jks`.

## Decisions Made This Session
- Populated all 6 core Memory Bank files from direct repo inspection (pubspec.yaml, PHASE_LOCK.md, AGENTS.md, README.md, firestore.rules, lib/ structure, git log, TODO.md) rather than from assumption or the README's Turkish marketing claims alone.
- Flagged README's "Closed Beta active / 12/12 bridges connected / 0 critical errors" as an unverified documentation claim, not confirmed repo state — see `progress.md`.
- Preserved CLAUDE.md's stated precedence: where `AGENTS.md` (older, narrower scope — excludes social features) conflicts with CLAUDE.md's current approved scope (which includes friends/group rides/leaderboards), CLAUDE.md wins. Recorded in `projectbrief.md`.
- Did not run `flutter analyze` / `flutter test` this session (no code change made) — verification gate status is therefore "not verified," not "passing," pending an actual task.

## Blockers
None currently. No active implementation task.

## Update (same session, 2026-08-04) — Docs Cleanup
User asked to read all `.md` files in the repo, fold anything important into the Memory Bank, and clean up the rest. Read all ~20 `.md` files (root, `docs/`, `assets/word documents/`). Findings folded into Memory Bank:
- `systemPatterns.md`: Rider Card spec pointer, Speed Telemetry Engine V2 pipeline summary, AHRS pocket-mode mechanism (ties to the pocket-telemetry-zeroing risk), Android package ID, typography spec pointer.
- `techContext.md`: iOS native build/runtime gotchas (iCloud build-path signing failure, `home_widget` duplicate-plugin crash fix, Firebase iOS App ID format, `GMSServices` init requirement, foreground notification delegate), Google Play Closed Testing facts (package `com.apexflow.app`, tester/promotion thresholds).
- `progress.md`: Phase 9.1 optimization items listed as "claimed done per PHASE_LOCK.md/commit 887ad57, not independently verified in code."

After explicit per-file confirmation via AskUserQuestion, deleted 9 stale/conflicting `.md` files (git-tracked, recoverable via history if needed):
- `docs/APEXFLOW_MVP_FIRST_CODEX_EXECUTION_BIBLE.md` (explicitly banned social/friends/leaderboard features that CLAUDE.md now approves — superseded by its own generated `AGENTS.md`/`DESIGN_RULES.md`/`PHASE_LOCK.md`)
- `docs/ROADMAP_PHASES.md` (out of sync with `PHASE_LOCK.md` — showed Phase 8 as next when Phase 9.1 is marked complete)
- `docs/HANDOFF_FOR_AI.md`, `docs/MISSION_VISION.md`, `docs/DEVELOPER_GOALS.md` (content superseded by `projectbrief.md`/`productContext.md`/`progress.md`; contained stale Phase 1-7 / "73/73 tests" claims)
- `docs/DEVELOPER_REQUESTS.md` (stale rules: "Firestore backup-only" contradicts current `firestore.rules` scope; Chrome-only preview note outdated)
- `docs/DEVLOG.md` (historical dev journal — user chose to remove in favor of Memory Bank + git log)
- `PHASE_9.1_NEXT_TASKS.md`, `PHASE_9_OPTIMIZATIONS_ROADMAP.md` (planning docs for work `PHASE_LOCK.md` marks complete; summarized into `progress.md` instead)

Kept untouched (still current/active, or explicitly required by CLAUDE.md): `AGENTS.md`, `DESIGN_RULES.md`, `PHASE_LOCK.md`, `AHRS_POCKET_MATH.md`, `IOS_DEPLOYMENT_NOTES.md`, `docs/APEXFLOW_SPEED_TELEMETRY_ENGINE_V2.md`, `docs/RIDER_CARD_SPECS.md`, `docs/COMPANY_PROFILE.md`, `docs/MARKETING_DESIGNS.md`, `docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md`, `docs/google_closed_testing.md`, `docs/README.md`, `assets/word documents/APEX_FLOW_PREMIUM_TYPOGRAPHY_SYSTEM_ANTIGRAVITY_SPEC_V1.md`, `TODO.md`, root `README.md`, and all `.txt` architecture specs in `docs/` (out of scope — user asked about `.md` files only).

Updated dangling references: `docs/README.md` reading order and root `README.md` documentation links now point to `memory-bank/` instead of the deleted files.

## Update (same session, 2026-08-04) — Pushed to GitHub, Tracked Release Assets, Found Secret-Exposure Risk
- Committed and pushed the memory-bank init + docs cleanup (`347ae4b`).
- Committed and pushed `CLAUDE.md`, `.github/workflows/closed-test-deploy.yml`, `docs/google_closed_testing.md`, `distribution/whatsnew/*` (`faa045d`) — these were pre-existing untracked files from the user's in-progress Closed Beta release setup, now version-controlled.
- **Security finding, resolved**: `assets/word documents/key.properties` and `assets/word documents/upload-keystore.jks` were unguarded by `.gitignore` (only `/android/key.properties` was covered). Fixed in commit `2f53bfd` by broadening the rule to `key.properties` / `*.jks` / `*.keystore` (unanchored, so it catches any location). User confirmed these `assets/word documents/` files are the current, actively-used signing config — not stale duplicates, kept on disk intentionally, just correctly excluded from git now. The plaintext password value seen in the file during this session's read has since been rotated per the user, so it is no longer live/sensitive, but was never committed or written into any repo file regardless.

## RevenueCat Dashboard Setup Walkthrough (2026-08-05, done live with user via screenshots)
Recorded in case this needs revisiting — e.g. adding the iOS app, redoing permissions, or debugging why an entitlement isn't unlocking.
- Google Cloud project `apexflow-revenuecat` created specifically for the RevenueCat service account (kept separate from the Firebase project `apex-flow-7baea`, which is on a different Google account than the Play Console developer account "Madeforth" — do not assume they can share a GCP project).
- Service account `revenuecat-service@apexflow-revenuecat.iam.gserviceaccount.com` created in that project, JSON key downloaded and uploaded to RevenueCat's "Service Account Credentials JSON" field under Apex Flow → Apps → Apex Flow (Play Store).
- **The permission grant took 3 iterations before "Check credentials" passed** — if this ever needs redoing, grant all of these on the service account in Play Console → Kullanıcılar ve izinler (Users and permissions) in one pass, not incrementally:
  1. "Finansal verileri, siparişleri ve iptal anketine verilen yanıtları görüntüleme" (View financial data, orders, and cancellation survey responses)
  2. "Siparişleri ve abonelikleri yönetme" (Manage orders and subscriptions) — easy to miss, it's what unlocked "Can validate Google Play subscription purchases" specifically; the other two RevenueCat checks passed without it.
  3. Explicit app-level access to "Apex Flow" (not just account-level permissions).
  4. Also required in Google Cloud Console for the `apexflow-revenuecat` project: enable both the "Google Play Android Developer API" and the "Cloud Pub/Sub API".
  5. Google's permission propagation had a real delay (order of an hour, not instant) even after everything above was correctly granted — if "Check credentials" fails right after granting, wait before assuming something is misconfigured.
- Products were added via RevenueCat's "Import Products" (Product catalog → Products → Apex Flow (Play Store) → + New → Import Products), NOT the manual form — manual entry needs a Play Console "Base plan ID" that isn't visible from the app side, so always prefer Import here.
- The Entitlements list page can show stale data ("Add your first product" even after a product was actually attached, confirmed by opening the entitlement's own detail page) — hit refresh/F5 before concluding an attach failed.
- A leftover "Apex Flow Pro" entitlement + "Test Store" app/products exist from RevenueCat's own onboarding default setup — harmless (Test Store never fires on real devices), left in place rather than deleted.
- Skipped by user's choice: "Google developer notifications" (Pub/Sub real-time purchase events) — the topic-ID field requires a pre-existing Pub/Sub topic and the "Connect to Google" button stayed disabled when typing a new name; not investigated further since it's optional.

## Next Step
Both the second-pass (19/20) and third-pass (24/24) audits are closed out on `agent/fix-safety-persistence-maps`. Two color/design-token findings remain deliberately deferred (prior #19 in Insights, plus this pass's nav-bar-color/wrong-cyan/profile_hub-slate findings) — both need real visual verification (device/emulator) not available in this environment; do not guess-fix them without that.

Remaining open items:
1. This branch needs to be merged/rebased into `main` at some point (never done this session) — ask the user how they want that handled given the other concurrent session's commit (`8bcf84e`) is also on it.
2. `firestore.rules`' new `exists()` check on `parking_notifications` create (this pass's A3) is prepared but **not deployed** — needs Rules Playground verification first, same caveat as the earlier `firestore.rules` changes (no local Java 21+ for the emulator).
3. The LG G5 install (`com.apexflow.app`) only reflects code through commit `f1c0120` (second-pass item #16) — none of this session's later fixes (second-pass #17-20, all of third-pass A/B/C) are on the installed build; rebuild+reinstall if the user wants to test them physically.
4. Real FCM push notifications for parking alerts (owner's app backgrounded/killed) is a known, explicitly out-of-scope gap — needs a Cloud Function trigger, new server-side work, not a quick fix.

Longer-term deferred item (separate from the above): a full `lib/` sweep for unused/dead Dart files (not just assets) — explicitly postponed in an earlier session under a tight time budget, not started.

Several local commits may be unpushed on whichever branch is current — check `git status` / `git log origin/<branch>..HEAD`. Push only when the user asks, per this session's established pattern; this applies doubly now given the shared-branch situation — do not push without confirming the other session isn't also mid-commit.
Read only the Memory Bank / source files relevant to the active step — this file plus `progress.md` should be sufficient to resume; `projectbrief.md`/`productContext.md`/`systemPatterns.md`/`techContext.md` are reference, not required reading every session.
