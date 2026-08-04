# Active Context

## Current Task
Memory Bank initialized and pushed; most recently, tracked previously-untracked Closed Beta release assets and flagged a signing-secret exposure risk. No implementation task in progress.

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
- **Security finding, not yet resolved**: `assets/word documents/key.properties` and `assets/word documents/upload-keystore.jks` are byte-identical duplicates of the real signing secrets at `android/key.properties` / `android/app/upload-keystore.jks`. The `android/` copies are correctly excluded by `.gitignore` (`/android/key.properties`); the `assets/word documents/` copies are **not covered by any gitignore rule** and were deliberately left untracked/uncommitted rather than added. `key.properties` contains a real plaintext keystore password (`storePassword=apexflow123`, `keyPassword=apexflow123`). Recommended fix (offered to user, not yet actioned): delete the `assets/word documents/` copies, or at minimum gitignore them — see `progress.md` known-risks.

## Next Step
Awaiting the user's next task. Two carry-over items to raise if not otherwise addressed:
1. The `assets/word documents/key.properties` + `upload-keystore.jks` exposure risk above — confirm with the user whether to delete or gitignore them.
2. Re-check `git status` before touching anything nearby.
Read only the Memory Bank / source files relevant to that specific task (per CLAUDE.md's token-efficient session protocol) — this file plus `progress.md` should be sufficient to resume; `projectbrief.md`/`productContext.md`/`systemPatterns.md`/`techContext.md` are reference, not required reading every session.
