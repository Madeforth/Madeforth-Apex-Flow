# Product Context

## Rider Problems Addressed
- Motorcycle maintenance tracking is fragmented (paper records, memory, dealer invoices).
- Riders lack a pre-ride safety habit — Ride Readiness / Daily Check provides a fast pre-ride checklist.
- Riders want an emotional/identity connection to their machine, not just a maintenance log — "Harmony Engine" and "Machine Memory Timeline" frame maintenance as relationship-building, not chores.
- Post-accident documentation is stressful — Digital Accident Report (Dijital Kaza Tutanağı) provides guided capture with PDF output.
- Document expiry (insurance, inspection, registration) tracking via Document Vault.
- Emergency preparedness — Digital SOS / Emergency Card with blood type and emergency contact, designed for lock-screen/widget visibility.

## Core Modules (per README + repo `lib/` structure)
- Dashboard + Harmony Engine (`lib/harmony_engine`, `lib/features/dashboard`) — machine health score, maintenance status, ride suggestions.
- Garage (`lib/garage`) — multi-motorcycle management, service records, part-life tracking.
- Rides / telemetry (`lib/rides`) — ride sessions, pocket/mounted telemetry.
- Rituals / Readiness (`lib/rituals`) — pre-ride daily check.
- Documents (`lib/documents`, `lib/features/documents`) — document vault, accident report PDF.
- Fuel (`lib/fuel`) — fuel tracking + receipt OCR (`google_mlkit_text_recognition`).
- Insights (`lib/insights`) — spend/analytics by category.
- Profile / Rider Identity (`lib/profile`) — rider ID card, themes, badges, appearance studio.
- Notifications (`lib/notifications`) — local notifications, document expiry reminders.
- Settings (`lib/settings`) — user profile state, app settings/i18n.
- Onboarding (`lib/onboarding`).
- Shell/Splash/Support (`lib/features/shell`, `lib/features/splash`, `lib/features/support`).

## UX Goals (per CLAUDE.md Design Authority)
- Premium, calm, industrial tone — graphite/navy surfaces, cyan/orange accents, deliberate pill controls, restrained translucent glass.
- Pills reserved for controls/navigation, not decorative containers.
- Glass must stay readable and performant — no uncontrolled blur/glow/heavy shadow/visual noise.
- Responsive: stacked layouts on narrow widths, no overflow, preserved touch targets/safe areas/accessibility.

## Product Logic Notes
- Local-first is a hard requirement: network failure must never corrupt or falsely confirm state (relevant to sync coordinator, Firestore writes, purchase flows).
- Social/community features (friends, group rides, leaderboards, location-based rider radar) are current approved scope per CLAUDE.md. (`AGENTS.md`, an older doc that predated and excluded them, was deleted 2026-08-06 — see `projectbrief.md`.)
