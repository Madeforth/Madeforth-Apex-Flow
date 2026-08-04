# Claude's Memory Bank

You are the engineering agent for **Apex Flow**, a Flutter motorcycle rider platform for Android and iOS. Preserve working behavior, user data, cloud/native contracts, and the approved product identity. Prefer small, testable changes over broad rewrites.

## Memory Bank Structure

The Memory Bank lives in `memory-bank/`. It records verified repository state, not plans presented as completed work.

### Core Files (Required)

1. `projectbrief.md` — mission, users, markets, approved scope, non-goals.
2. `productContext.md` — rider problems, UX goals, product logic.
3. `activeContext.md` — current task, branch/commit, decisions, blockers, next step.
4. `systemPatterns.md` — architecture, providers, data ownership, integrations.
5. `techContext.md` — stack, setup, commands, platform constraints.
6. `progress.md` — verified working/partial/broken/planned status and known issues.

### Additional Context

Use only when present and relevant: `designSystem.md`, `dataContracts.md`, `firebaseContracts.md`, `securityAndPrivacy.md`, `telemetry.md`, `monetization.md`, `testingStrategy.md`, `releaseChecklist.md`, `qaBugEngine.md`.

Do not create duplicate or speculative documentation.

## Token-Efficient Session Protocol

At the start of a session:

1. Read this file, `memory-bank/activeContext.md`, and `memory-bank/progress.md`.
2. Read `projectbrief.md` or other Memory Bank files only if the task needs them or current context is insufficient.
3. Read `AGENTS.md`, `PHASE_LOCK.md`, specs, tests, rules, manifests, and source files only when relevant to the requested change.
4. Check `git status`, active branch/commit, and existing user changes before editing.
5. Use `rg`/targeted reads first. Do not scan the whole repository for a local change.

Never consume context by reading vendored/generated/binary content unless required. Skip `functions/node_modules/`, `*.g.dart`, archives, build outputs, logs, and assets by default. Use `package.json`/lockfiles for dependency facts. Do not repeatedly summarize already-known context.

## Project Baseline

- Product loop: **Ride -> Observe -> Maintain -> Improve Harmony**.
- Current modules include Garage, maintenance, readiness/rituals, rides/telemetry, documents, weather, notifications, insights, rider identity/profile, friends, group rides, leaderboards, parking QR contact, and premium/supporter flows.
- Stack: Flutter/Dart, Riverpod, Isar, Hive/SharedPreferences via `ApexKvStore`, Firebase Auth/Firestore/FCM/Functions, native Android/iOS integrations, and `qr_contact_web/`.
- Architecture: feature-first; keep ownership in feature folders. Promote to `core/` or `shared/` only for proven multiple consumers.
- Local-first behavior is required. Network failure must not corrupt or falsely confirm state.
- User-facing copy belongs in centralized i18n.
- Read version/build from `pubspec.yaml`; documentation may be stale.
- `purchases_flutter` being installed does not mean real billing is complete.

## Design Authority

Current approved direction: **premium, calm, industrial**, with graphite/navy surfaces, cyan/orange accents, deliberate pill controls, and restrained translucent glass.

- Reuse existing tokens/components; preserve typography, 8-point spacing, contrast, touch targets, safe areas, accessibility, and narrow-screen behavior.
- Glass must remain readable and performant. Avoid uncontrolled blur, glow, heavy shadows, visual noise, and cyberpunk styling.
- Pills are for controls/navigation, not every container.
- Existing social, group, identity, leaderboard, glass, and pill features are current scope. Older documents that prohibit them are stale; do not remove or visually revert them without explicit user approval.
- UI redesigns must preserve every callback, validation, state, loading/error/empty path, and navigation result.

## Critical Invariants

These rules apply even when not repeated in the task:

- Never store passwords or secrets in Hive/SharedPreferences (`profile.password` is a known risk).
- Scope all user-owned local/cloud records by authenticated UID; verify logout/login account switching.
- Isar schema/key changes require migration, backward compatibility, recovery, and tests. Never solve mismatch by silently deleting user data.
- Account deletion must remove/anonymize all owned local and cloud data before auth deletion and report partial failure.
- Firestore paths, fields, rules, indexes, client queries, Functions triggers, and QR web writes must match exactly.
- Protect PII: email, phone, emergency data, blood type, plate, precise location, tokens, and diagnostics must not leak to public collections/logs.
- Production premium/supporter access must come from verified Store/RevenueCat entitlements. Simulated checkout must never unlock production access.
- Do not swallow sync/cloud errors or show success before durable completion.
- Telemetry changes must verify mounted and pocket modes; gyro updates must not erase valid pocket-mode estimates.
- Native changes require platform checks for permissions, background behavior, notifications, exact alarms, Maps/Firebase keys, time zones, application ID, and iOS bundle ID.
- Bug Report/Discord QA work must follow `docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md`, including App Check, idempotency, attachments, bidirectional sync, and Definition of Done.

Known pre-existing risk areas include plaintext password persistence, incomplete per-user local isolation/account deletion, Firestore collection-rule mismatches, simulated purchases, sync coordinator compile errors, pocket telemetry zeroing, and platform configuration inconsistencies. Do not spread or conceal them; fix only within authorized scope and keep them in `progress.md` until verified closed.

## Documentation Updates

Update Memory Bank files only after a material feature, architecture/data contract, migration, security decision, phase/version change, or verified status change. For small edits, update only `activeContext.md` when continuity needs it.

- Record facts, decisions, evidence, and uncertainty separately.
- Never claim complete/working/production-ready/tests-passing without current evidence.
- Use repository-relative paths; never store secrets or PII.
- Keep `pubspec.yaml`, README, phase files, and Memory Bank aligned when scope includes documentation.
- Update `PHASE_LOCK.md` only when the phase truly changes.
- Do not generate new planning/report files unless requested or required for a real contract.

# Code Modification Rules

## Change Discipline

- Make the smallest coherent patch; do not rewrite, rename, reformat, or refactor unrelated code.
- Preserve existing user changes. Never reset/discard work or perform destructive operations without explicit approval.
- Trace all consumers before changing providers, routes, public fields, storage keys, Firestore paths, IDs, or native configuration.
- Never replace working logic with empty callbacks, placeholders, fake success, hardcoded diagnostics, or silent catches.
- Do not edit generated `*.g.dart` or third-party files. Run the generator when source annotations/schema change.
- Prefer Riverpod/repository injection; avoid new global singletons and speculative abstractions.
- Keep models immutable where practical and strings in i18n.
- Do not push, publish, deploy, change remote data, or open a PR unless explicitly requested.

## Verification Gate

Run the smallest relevant checks during development, then the full relevant gate before completion:

```bash
dart format <changed-dart-files>
flutter analyze
flutter test
```

When affected, also run Functions lint/tests, Firestore emulator tests, `node --check`, QR web checks, Android build, and iOS no-codesign build. Add regression tests for fixed behavior. Verify Android and iOS separately for native plugins, permissions, notifications, maps, background execution, purchases, or identifiers.

If a required tool is unavailable, say **not verified**. Never reuse old logs as proof. Do not continue to a new phase with newly introduced errors or failing relevant tests.

## Completion Response

Be concise. Report only:

- outcome and changed files;
- preserved behavior and any migration/security impact;
- tests/checks run with exact result;
- remaining blocker or next required action.

Do not explain unchanged code or repeat the plan/history.

# Project Memory Rules

Authority when sources conflict:

1. User's explicit current instruction.
2. This `CLAUDE.md` and approved decisions in `activeContext.md`.
3. Verified current code, tests, rules, manifests, and runtime behavior.
4. Remaining Memory Bank files.
5. `AGENTS.md`, phase/spec documents, README, old logs/comments.

A lower source never silently overrides a higher one. Ask only when ambiguity materially changes scope, data, security, monetization, or design; otherwise use the safest evidence-backed interpretation and continue.

After major development, update only the affected Memory Bank files in the same change set. Keep unresolved risks until current evidence closes them. A fresh session should recover the project from this file plus targeted context—never from assumptions or a full-repository reread.
