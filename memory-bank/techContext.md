# Tech Context

## Stack
- Flutter 3.41.4 (stable channel), Dart SDK `^3.11.1` (env installed: Dart 3.11.1).
- State: `flutter_riverpod ^2.6.1`.
- Local storage: `isar ^3.1.0+1` (+ `isar_flutter_libs`, `isar_generator`), `hive ^2.2.3` / `hive_flutter ^1.1.0`, `shared_preferences ^2.5.3` — accessed via `ApexKvStore`.
- Cloud: `firebase_core ^3.1.0`, `cloud_firestore ^5.0.1`, `firebase_auth ^5.1.0`, `firebase_messaging ^15.2.10`, `google_sign_in ^6.2.1`.
- Purchases: `purchases_flutter ^10.4.0` (RevenueCat) — installed, not proof of complete billing (CLAUDE.md).
- Location/Maps: `geolocator ^13.0.2`, `google_maps_flutter ^2.11.0`.
- Media/OCR/QR: `image_picker`, `camera`, `google_mlkit_text_recognition`, `google_mlkit_barcode_scanning`, `qr_flutter`.
- PDF/Docs: `pdf ^3.12.0`, `printing ^5.14.3`, `signature ^6.3.0`.
- Notifications: `flutter_local_notifications ^18.0.1`, `timezone ^10.0.0`, `home_widget ^0.6.0` (widgets).
- Sensors: `sensors_plus ^7.1.0` (telemetry / pocket-mode AHRS).
- Codegen: `build_runner ^2.4.9`, `hive_generator ^2.0.1`, `isar_generator ^3.1.0+1`, `freezed_annotation ^3.1.0`.
- Lints: `flutter_lints ^6.0.0` (see `analysis_options.yaml`).
- Icons/splash: `flutter_launcher_icons ^0.13.1`, `flutter_native_splash ^2.4.1`.
- App version: `pubspec.yaml` → `1.0.0+27`.

## Setup / Commands
```bash
flutter pub get
flutter analyze
flutter test
dart format <changed-dart-files>
```
- After changing Isar/Hive schema annotations, regenerate: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Functions (Node, `functions/`) have their own lint/test — run when Functions code changes; do not assume Node deps are installed without checking `functions/node_modules`.
- Firestore emulator tests: run when `firestore.rules` or Functions triggers change.
- Native builds: Android build and iOS no-codesign build should be verified separately when native/plugin config changes (permissions, notifications, Maps/Firebase keys, application ID / bundle ID).

## Platform Constraints
- Android primary target (Google Play). iOS present but secondary.
- Signing artifacts present in repo root (untracked): `assets/word documents/key.properties`, `assets/word documents/upload-keystore.jks` — treat as sensitive; never print contents or commit assumptions about their validity without checking with the user.
- `distribution/` and `.github/workflows/closed-test-deploy.yml` exist untracked as of 2026-08-04 — likely in-progress Closed Beta CI/release setup; do not assume it is finished or correct without reading it first.

## iOS Native Gotchas (from `IOS_DEPLOYMENT_NOTES.md` — read that file in full before native iOS work)
- Do not build from a folder synced by iCloud Drive (e.g. Desktop) — Finder metadata added during sync breaks Xcode code-signing (`resource fork... detritus not allowed`). Build from a non-synced path (e.g. `~/Developer/...`).
- `home_widget`'s implicit background Flutter engine previously conflicted with `CameraPlugin` registration ("Duplicate plugin key") and crashed the app on launch — the fix removed `FlutterImplicitEngineDelegate` / `didInitializeImplicitFlutterEngine` from `AppDelegate.swift` so only one engine registers plugins. If re-adding any background-engine mechanism, check for this regression.
- Firebase iOS App ID must contain `:ios:`, not `:web:` — a copy-pasted web App ID causes a native startup failure.
- `GMSServices.provideAPIKey(...)` must be called explicitly in `AppDelegate.swift` (iOS does not auto-read the Maps key from a manifest the way Android does); missing this crashes any screen that renders `google_maps_flutter`.
- Foreground local notifications need `UNUserNotificationCenter.current().delegate` set in `AppDelegate.swift`, or they're silently swallowed while the app is active.

## Google Play Closed Testing (from `docs/google_closed_testing.md`, dated 2026-08-04)
- Android application ID: `com.apexflow.app`.
- Release build: `flutter build appbundle --release --build-number=<N> --build-name=<version>`.
- Closed testing requires ≥20 testers (email list or Google Group); promotion to open testing per that doc's checklist needs ≥14 days, crash rate <2%, ANR <0.5%.
- A GitHub Actions workflow template for AAB upload to Play Console is documented there and appears to correspond to the untracked `.github/workflows/closed-test-deploy.yml` noted in `progress.md` — verify the actual workflow file matches the documented secrets (`KEYSTORE_BASE64`, `KEY_PROPERTIES`, `PLAY_STORE_SERVICE_ACCOUNT_JSON`) before relying on it.

## Repo Layout Notes
- `lib/` mixes flat legacy feature folders and a newer `lib/features/` tree (see systemPatterns.md for the overlap caveat on `documents`).
- Root-level docs of note: `PHASE_LOCK.md` (phase gating), `DESIGN_RULES.md`, `IOS_DEPLOYMENT_NOTES.md`, `AHRS_POCKET_MATH.md` (telemetry math), `docs/` (mission/vision, roadmap, rider card specs, devlog, Discord QA bug report master spec, `docs/google_closed_testing.md`). (`AGENTS.md`, an older/narrower-scope doc superseded by CLAUDE.md, was deleted 2026-08-06 as part of a repo-cleanup pass — see `activeContext.md`.)
