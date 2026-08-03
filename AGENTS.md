# ApexFlow - Codex Working Agreement

This repository is a Flutter (Riverpod) MVP for a calm, premium motorcycle OS.

## Product Guardrails (Non-Negotiable)
- Do not overengineer. Prefer simple, reliable flows.
- Every feature must support the core loop: Ride -> Observe -> Maintain -> Improve Harmony.
- Do not add: social/community, chatbots, heavy analytics, gamification, cyberpunk visuals.
- First release scope stays focused on: Garage, Maintenance, Harmony, Ride Readiness, Daily Check, Weather, Memory Timeline, Smart Notifications, max 2 widgets.

## Architecture Rules
- Feature-first modular structure. Keep ownership within feature folders.
- Prefer Riverpod state + local-first persistence; avoid global singletons.
- Centralize user-facing copy in i18n (no scattered literals across screens).
- Keep domain models immutable where practical.

## Design Rules (Summary)
- Calm, industrial, premium. Human-crafted, not template-like.
- Radius: 4-6 only. Spacing: 8pt system.
- No glow, no glassmorphism, no oversized shadows.
- Responsive by default: stacked layouts on narrow widths, no overflows.

## Testing Rules
- After meaningful UI/state changes, run:
  - `flutter analyze`
  - `flutter test`
- Do not merge/continue phases with failing tests or analysis warnings.

## Roadmap Restrictions
- Do not jump ahead to future phases.
- Keep a phase lock file (`PHASE_LOCK.md`) updated when phase changes.

## Refactoring & UI Changes (Strict Rule)
- When updating the design of any screen, ALL existing functionality MUST be preserved and fully functional.
- Do not introduce empty callback functions `() {}` for buttons or actions that were previously functional.
- Retroactively check and restore any previously working logic if a redesign accidentally drops functionality.

## Bug Report & Discord QA Engine (Master Spec Rule)
- When starting work on Bug Reports or Madeforth Discord QA Engine, AI agents MUST strictly follow [docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md](file:///Users/otelgrafik/Developer/ApexFlow-main-1607/docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md).
- Follow all 27 sections, Firestore ↔ Discord bidirectional synchronization workflows, App Check security rules, and Definition of Done criteria without deviation.
