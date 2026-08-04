# System Patterns

## Architecture
- Feature-first modular structure. Top-level `lib/` mixes legacy flat feature folders (`garage/`, `rides/`, `documents/`, `fuel/`, `profile/`, `settings/`, `notifications/`, `rituals/`, `insights/`, `harmony_engine/`, `onboarding/`) and a newer `lib/features/` folder (`dashboard`, `documents`, `harmony`, `shell`, `splash`, `support`). There is some overlap (`documents` exists in both `lib/documents` and `lib/features/documents`) — verify which is authoritative before editing either.
- `lib/core/` holds cross-cutting concerns: `design/` (ApexTheme, colors, spacing, typography, breakpoints), `i18n/` (app_strings, app_settings_state), `services/` (`firebase_service.dart`), `storage/` (Isar + KV store + entities + migrations), `sync/` (sync coordinator, conflict resolver, sync models), `utils/`, `preview/`.
- State management: Riverpod (`flutter_riverpod: ^2.6.1`). Prefer Riverpod/repository injection; avoid new global singletons per CLAUDE.md.

## Data Ownership & Storage
- Local persistence: Isar (`isar_db_service.dart`, `in_memory_db_service.dart` for tests/stub, `isar_db_service_stub.dart`) plus `ApexKvStore` (`apex_kv_store.dart`) wrapping Hive/SharedPreferences for key-value data.
- Isar entities (`lib/core/storage/entities/`): `daily_check_entity`, `document_entity`, `friend_entity`, `motorcycle_entity`, `ride_session_entity`, `service_record_entity`, `tax_record_entity`. Each has a generated `.g.dart` — never hand-edit generated files; run `build_runner` after schema/annotation changes.
- `migration_service.dart` exists for Isar schema migration — any schema/key change must go through it with backward compatibility, per CLAUDE.md invariant (never silently delete user data on mismatch).
- Cloud: Firebase Auth + Cloud Firestore + FCM (`firebase_service.dart`), Cloud Functions (`functions/`).

## Firestore Data Contracts (verified from `firestore.rules`)
- `/users/{uid}` — private profile, owner read/write only, delete disabled (deletion routed through Cloud Functions).
- `/public_rider_cards/{uid}` — public read, write disabled client-side (backend-only writes).
- `/rider_tags/{tag}` — public read; write allowed only by the tag's owner (create/update guarded by `ownerId == auth.uid`).
- `/entitlements/{uid}` — owner read only, write disabled client-side (Store/RevenueCat webhook or backend writes only). Confirms CLAUDE.md invariant: client cannot self-grant premium.
- `/notification_tokens/{uid}/devices/{deviceId}` — no read, owner create/update/delete only (FCM tokens, PII-sensitive).
- `/parking_requests/{requestId}` — no client read/write; Callable Functions only.
- `/bug_reports/{bugId}` (+ `/events/{eventId}` subcollection) — client cannot create/update/delete directly (Callable Functions only); reporter can read own reports/events. Governs the Discord QA Bug Report Engine (see `docs/APEXFLOW_MADEFORTH_DISCORD_QA_BUG_REPORT_ENGINE_MASTER_SPEC.md`).
- Rules file continues past line 60 — re-read `firestore.rules` in full before modifying any collection's rule.

## Sync
- `lib/core/sync/`: `sync_coordinator.dart`, `sync_conflict_resolver.dart`, `sync_models.dart`. CLAUDE.md lists "sync coordinator compile errors" as a known pre-existing risk area — verify current compile state (`flutter analyze`) before assuming this file is healthy.

## Native Integrations
- Android + iOS projects present (`android/`, `ios/`). Native-adjacent packages: `geolocator`, `camera`, `permission_handler`, `home_widget` (widgets), `flutter_local_notifications` + `timezone` (exact alarms), `google_maps_flutter`, `sensors_plus` (telemetry/AHRS — see `AHRS_POCKET_MATH.md`), `google_mlkit_text_recognition` / `google_mlkit_barcode_scanning`, `purchases_flutter` (RevenueCat).
- QR/contact web companion: `qr_contact_web/` — writes must match Firestore field/path contracts exactly per CLAUDE.md.

## Design System
- `lib/core/design/apex_theme.dart`, `apex_colors.dart`, `apex_spacing.dart` (8pt grid), `apex_typography.dart`, `apex_breakpoints.dart`, `theme_extensions.dart`. Fonts: Geist / GeistMono (variable), plus Roboto fallback assets.
- Typography is governed by a dated, implementation-ready spec: `assets/word documents/APEX_FLOW_PREMIUM_TYPOGRAPHY_SYSTEM_ANTIGRAVITY_SPEC_V1.md` (V1.0, 2026-08-03 — one day before this memory bank's creation date, so treat as current/authoritative for type scale, not historical). Geist Sans/Mono in `pubspec.yaml` already matches this spec.
- Rider Card component (used in Profile and Friends/compact list contexts) has a detailed, still-current spec at `docs/RIDER_CARD_SPECS.md`: standard vs. compact layout dimensions, an 11-entry theme list (0 free, 1-2 premium, 3-9 paid, 10 supporter-exclusive "Apex Supporter"), 5 badge types (first_ride, mileage_100, speed_demon, night_rider, maintenance_master), and 3 supporter-tier visual effects (Pit Crew/Track Rider/Apex Founder). Read that file directly before touching rider card / friends card UI rather than duplicating the table here.

## Telemetry (Speed / AHRS)
- Two distinct telemetry concerns exist, each with its own doc — read the doc before touching either:
  - **Speed/GNSS engine** (`docs/APEXFLOW_SPEED_TELEMETRY_ENGINE_V2.md`): offline Kalman-filtered speed estimation from raw GNSS, NIS-based outlier rejection, trapezoidal distance integration, neighbor-verified `validatedMaxSpeedKmh` with no artificial speed cap. Has explicit "approved marketing statements" — do not claim exactness beyond what's documented there.
  - **Pocket-mode AHRS / lean angle** (`AHRS_POCKET_MATH.md`): dynamic gravity-vector estimation + gyroscope vector rejection to estimate body lean angle when the phone is in a pocket rather than mounted, with a complementary GPS filter (85/15 gyro/GPS in pocket mode, 98/2 when mounted). This is the mechanism behind the CLAUDE.md-flagged "pocket telemetry zeroing" risk — gyro-update logic must not overwrite a valid pocket-mode lean estimate with zero.
- `PHASE_9.1_NEXT_TASKS.md` / `PHASE_9_OPTIMIZATIONS_ROADMAP.md` describe telemetry-isolate throttling (100Hz→5Hz via buffered `Timer` in `telemetry_isolate.dart`), Weather API response caching (`shared_preferences`, 30 min TTL), and wiring Harmony Engine wear penalties to real telemetry (`maxLeanAngle > 45°` or `hardBrakes > 3` ⇒ aggressive-ride wear multiplier) instead of the rider's self-reported mood. `PHASE_LOCK.md` and commit `887ad57` mark Phase 9.1 as completed — this is a status claim, not independently verified in code this session (see `progress.md`).

## Android Package / Store Identity
- Android application ID: `com.apexflow.app` (per `docs/google_closed_testing.md`).
