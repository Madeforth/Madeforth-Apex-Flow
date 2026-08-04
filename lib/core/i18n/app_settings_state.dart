import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/core/storage/migration_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class AppSettingsState {
  const AppSettingsState({
    required this.locale,
    required this.onboardingDone,
    this.distanceUnit = 'km',
    this.volumeUnit = 'liters',
    this.currencySymbol = '\$',
  });

  final Locale locale;
  final bool onboardingDone;
  final String distanceUnit; // 'km' or 'mi'
  final String volumeUnit; // 'liters' or 'gallons'
  final String currencySymbol;

  bool get isTurkish => locale.languageCode == 'tr';

  double toDisplayDistance(double km) {
    if (distanceUnit == 'mi') {
      return km * 0.62137119;
    }
    return km;
  }

  double toKmDistance(double displayDistance) {
    if (distanceUnit == 'mi') {
      return displayDistance * 1.609344;
    }
    return displayDistance;
  }

  String formatDistance(double km) {
    final val = toDisplayDistance(km);
    final unitLabel = distanceUnit == 'mi' ? 'mi' : 'km';
    return '${val.toStringAsFixed(0)} $unitLabel';
  }

  double toDisplayVolume(double liters) {
    if (volumeUnit == 'gallons') {
      return liters * 0.26417205;
    }
    return liters;
  }

  double toLitersVolume(double displayVolume) {
    if (volumeUnit == 'gallons') {
      return displayVolume * 3.78541178;
    }
    return displayVolume;
  }

  String formatVolume(double liters) {
    final val = toDisplayVolume(liters);
    final unitLabel = volumeUnit == 'gallons'
        ? (tInline(AppStrings.currentLanguageCode, 'gal', 'gal', 'Gal'))
        : 'L';
    return '${val.toStringAsFixed(1)} $unitLabel';
  }

  AppSettingsState copyWith({
    Locale? locale,
    bool? onboardingDone,
    String? distanceUnit,
    String? volumeUnit,
    String? currencySymbol,
  }) {
    return AppSettingsState(
      locale: locale ?? this.locale,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettingsState> {
  static const _localeKey = 'app.locale_code';
  static const _onboardingKey = 'app.onboarding_done.v1';
  static const _distanceUnitKey = 'app.distance_unit';
  static const _volumeUnitKey = 'app.volume_unit';

  bool _mounted = true;

  @override
  AppSettingsState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    return const AppSettingsState(locale: Locale('en'), onboardingDone: false);
  }

  void setLocale(Locale locale) {
    AppStrings.currentLanguageCode = locale.languageCode;
    state = state.copyWith(locale: locale);
    unawaited(_persist());
  }

  void setDistanceUnit(String unit) {
    state = state.copyWith(distanceUnit: unit);
    unawaited(_persist());
  }

  void setVolumeUnit(String unit) {
    state = state.copyWith(volumeUnit: unit);
    unawaited(_persist());
  }

  void completeOnboarding() {
    state = state.copyWith(onboardingDone: true);
    unawaited(_persist());
  }

  void resetOnboarding() {
    state = state.copyWith(onboardingDone: false);
    unawaited(_persist());
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    await ApexKvStore.init();
    if (!_mounted) return;

    try {
      await db.init().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint(
            '[AppSettings] DB init timed out, falling back to KV store',
          );
        },
      );
      if (!_mounted) return;

      await MigrationService.checkAndMigrate(db).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('[AppSettings] Migration timed out');
        },
      );

      await MigrationService.checkAndBackfillOwnerId(db).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('[AppSettings] Owner-id backfill timed out');
        },
      );
    } catch (e) {
      // DB init failed (e.g. Isar schema mismatch) – continue with KV store only
      debugPrint('[AppSettings] DB init failed, continuing without DB: $e');
    }
    if (!_mounted) return;

    final code = await ApexKvStore.getString(_localeKey);
    if (!_mounted) return;

    final rememberMe = (await ApexKvStore.getBool('auth.remember_me')) ?? true;
    var done = (await ApexKvStore.getBool(_onboardingKey)) ?? false;

    if (done && !rememberMe) {
      if (Firebase.apps.isNotEmpty) {
        try {
          if (FirebaseAuth.instance.currentUser != null) {
            await FirebaseAuth.instance.signOut();
          }
        } catch (_) {}
      }
      done = false;
      await ApexKvStore.setBool(_onboardingKey, false);
    }
    if (!_mounted) return;

    final distUnit = await ApexKvStore.getString(_distanceUnitKey) ?? 'km';
    final volUnit = await ApexKvStore.getString(_volumeUnitKey) ?? 'liters';

    // Auto-detect currency symbol based on system locale
    final deviceLocale = PlatformDispatcher.instance.locale;
    String currencySym = '\$';
    try {
      final localeString =
          deviceLocale.countryCode != null &&
              deviceLocale.countryCode!.isNotEmpty
          ? '${deviceLocale.languageCode}_${deviceLocale.countryCode}'
          : deviceLocale.languageCode;
      final format = NumberFormat.simpleCurrency(locale: localeString);
      currencySym = format.currencySymbol;
    } catch (_) {}

    // Auto-language logic: TR if locale is 'tr', English fallback for any other language
    Locale targetLocale;
    if (code != null && code.isNotEmpty) {
      targetLocale = Locale(code);
    } else {
      final deviceLanguage = PlatformDispatcher.instance.locale.languageCode
          .toLowerCase();
      String targetCode = 'en';
      if (deviceLanguage == 'tr') targetCode = 'tr';
      if (deviceLanguage == 'de') targetCode = 'de';
      targetLocale = Locale(targetCode);
    }

    AppStrings.currentLanguageCode = targetLocale.languageCode;

    state = state.copyWith(
      locale: targetLocale,
      onboardingDone: done,
      distanceUnit: distUnit,
      volumeUnit: volUnit,
      currencySymbol: currencySym,
    );
  }

  Future<void> _persist() async {
    final localeCode = state.locale.languageCode;
    final onboardingDone = state.onboardingDone;
    await ApexKvStore.setString(_localeKey, localeCode);
    await ApexKvStore.setBool(_onboardingKey, onboardingDone);
    await ApexKvStore.setString(_distanceUnitKey, state.distanceUnit);
    await ApexKvStore.setString(_volumeUnitKey, state.volumeUnit);
  }
}
