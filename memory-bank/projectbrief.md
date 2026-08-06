# Project Brief

## Mission
Apex Flow is a Flutter "Machine Relationship OS" for motorcycle riders — a premium app unifying maintenance intelligence, ride rituals, and rider-to-machine bond tracking. Product loop: **Ride -> Observe -> Maintain -> Improve Harmony**.

## Platforms & Markets
- Primary target: Android / Google Play Store.
- Secondary: iOS (App Store) — build present in repo (`ios/`), not the launch priority.
- Localization: Turkish, English, German (`lib/core/i18n`).
- Primary market signal: Turkish pricing shown first in README (₺), suggesting Turkey as initial market with US/EU pricing also defined.

## Current Stage (per README, unverified beyond doc claim)
- `pubspec.yaml` version: `1.0.0+27`.
- README states Closed Beta (Google Play Closed Testing) began 2026-08-04, 6 Android test devices, Discord for feedback. This is a documentation claim — not independently verified against Play Console state.

## Approved Scope (current, per CLAUDE.md — supersedes older restrictive docs)
Garage, maintenance, readiness/rituals, rides/telemetry, documents, weather, notifications, insights, rider identity/profile, friends, group rides, leaderboards, parking QR contact, premium/supporter flows.

Note: `AGENTS.md` (older doc, excluded social/community, gamification, and limited scope to a smaller MVP feature set) was deleted 2026-08-06 as part of a repo-cleanup pass — user explicitly approved its removal, its content was already stale/superseded, and CLAUDE.md was and remains the sole higher-authority current source. Social/friends/leaderboard/group-ride features are in scope and must not be removed or reverted without explicit user approval, per CLAUDE.md's Design Authority section.

## Non-Goals (still locked per `PHASE_LOCK.md`)
- Advanced AI / predictive analytics beyond lightweight MVP signals.
- Gamification systems beyond activity-focused leaderboards.
- Heavy telemetry dashboards.
- Smart notification expansion and widgets are considered finalized for this phase.

## Monetization (per README, unverified against live store config)
- Monthly / Yearly subscription via `purchases_flutter` (RevenueCat).
- Supporter tiers 1-3 (cosmetic rider card themes/badges).
- CLAUDE.md flags: `purchases_flutter` being installed does not mean real billing is complete — treat as unverified until confirmed against Store/RevenueCat entitlements.

## Authoritative Docs Hierarchy (for conflicts)
1. User's explicit current instruction.
2. `CLAUDE.md` + `activeContext.md` decisions.
3. Verified current code/tests/rules/manifests/runtime behavior.
4. Remaining Memory Bank files.
5. Phase/spec docs, README, old logs/comments. (`AGENTS.md` deleted 2026-08-06, see note above.)
