# Active Context

## Current Task
Working through a 6-item issue list the user identified from their own review (all verified real against code — see `progress.md`). Fix order agreed with user: #4 compile errors → #1 plaintext password → #3 Firestore rules mismatch → #5 account deletion → #6 local data isolation → #2 simulated purchases. Items #4 and #1 are done and committed (`ce6131b`, `443ea27`); about to start #3, which needs a design decision (see Next Step) so it will be proposed before editing `firestore.rules`.

## Branch / Commit
- Branch: `main`, pushed and in sync with `origin/main` (`github.com/Madeforth/Madeforth-Apex-Flow.git`).
- HEAD: `faa045d` — "chore: track Closed Beta release assets and CLAUDE.md governance file" (prior: `347ae4b` memory bank init/docs cleanup, prior: `e1e57e9` README update — see `git log` for full history, not duplicated here).
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

## Next Step
Continuing the 6-item fix list (see `progress.md` for full detail on each). Immediate next: **#3 Firestore collection/rules mismatch** — needs a design decision before editing `firestore.rules`, since two different data-ownership shapes currently coexist in the code: (a) flat top-level collections (`bikes`, `rides`, `friendships`, `lobbies`, `parking_notifications`) filtered client-side by a `userId`/`userA`/`userB` field, used by `firebase_service.dart`; (b) `users/{uid}/{entityType}/{entityId}` subcollections, used only by the still-unwired `sync_coordinator.dart`. Plan to propose picking (a) as canonical (it's what's actually live/used) and writing owner-scoped rules for the 5 flat collections, rather than trying to support both shapes. Will present this before touching the rules file, since Firestore rule changes are hard to reverse quickly against a live closed-beta app.
After #3: #5 (account deletion completeness, depends on #3), then #6 (Isar `userId` migration — largest single item), then #2 (real purchase integration — flagged as partially blocked on external store/RevenueCat setup the user must do).

Several local commits are unpushed (memory bank + `.gitignore` fix + the two code fixes above). Push only when the user asks, per this session's established pattern.
Read only the Memory Bank / source files relevant to the active step — this file plus `progress.md` should be sufficient to resume; `projectbrief.md`/`productContext.md`/`systemPatterns.md`/`techContext.md` are reference, not required reading every session.
