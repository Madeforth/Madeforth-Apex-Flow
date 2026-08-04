import 'dart:async';
import 'dart:convert';

import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyCheckEntry {
  const DailyCheckEntry({
    required this.isoDate,
    required this.tiresOk,
    required this.chainOk,
    required this.oilOk,
    required this.brakesOk,
    required this.lightsOk,
    required this.batteryOk,
    required this.note,
    this.loggedAtIso,
  });

  final String isoDate;
  final bool tiresOk;
  final bool chainOk;
  final bool oilOk;
  final bool brakesOk;
  final bool lightsOk;
  final bool batteryOk;
  final String note;
  final String? loggedAtIso;

  int get okCount => [
    tiresOk,
    chainOk,
    oilOk,
    brakesOk,
    lightsOk,
    batteryOk,
  ].where((value) => value).length;

  int get failedCount => 6 - okCount;

  bool get allClear => failedCount == 0;

  DateTime get loggedAt => _parseRitualDate(loggedAtIso ?? isoDate);

  Map<String, dynamic> toJson() => {
    'isoDate': isoDate,
    'tiresOk': tiresOk,
    'chainOk': chainOk,
    'oilOk': oilOk,
    'brakesOk': brakesOk,
    'lightsOk': lightsOk,
    'batteryOk': batteryOk,
    'note': note,
    'loggedAtIso': loggedAtIso,
  };

  factory DailyCheckEntry.fromJson(Map<String, dynamic> json) {
    return DailyCheckEntry(
      isoDate: json['isoDate'] as String? ?? '2026-01-01',
      tiresOk: json['tiresOk'] as bool? ?? true,
      chainOk: json['chainOk'] as bool? ?? true,
      oilOk: json['oilOk'] as bool? ?? true,
      brakesOk: json['brakesOk'] as bool? ?? true,
      lightsOk: json['lightsOk'] as bool? ?? true,
      batteryOk: json['batteryOk'] as bool? ?? true,
      note: json['note'] as String? ?? '',
      loggedAtIso: json['loggedAtIso'] as String?,
    );
  }
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locationLabel,
    required this.condition,
    required this.tempC,
    required this.windKph,
    required this.precipChancePercent,
    this.observedAtIso,
  });

  final String locationLabel;
  final String condition;
  final int tempC;
  final int windKph;
  final int precipChancePercent;
  final String? observedAtIso;

  DateTime? get observedAt {
    final raw = observedAtIso;
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }

  Map<String, dynamic> toJson() => {
    'locationLabel': locationLabel,
    'condition': condition,
    'tempC': tempC,
    'windKph': windKph,
    'precipChancePercent': precipChancePercent,
    'observedAtIso': observedAtIso,
  };

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      locationLabel: json['locationLabel'] as String? ?? '—',
      condition: json['condition'] as String? ?? '—',
      tempC: (json['tempC'] as num?)?.toInt() ?? 0,
      windKph: (json['windKph'] as num?)?.toInt() ?? 0,
      precipChancePercent: (json['precipChancePercent'] as num?)?.toInt() ?? 0,
      observedAtIso: json['observedAtIso'] as String?,
    );
  }
}

class RitualsState {
  const RitualsState({
    required this.isHydrating,
    required this.dailyChecks,
    required this.weather,
  });

  final bool isHydrating;
  final List<DailyCheckEntry> dailyChecks;
  final WeatherSnapshot weather;

  RitualsState copyWith({
    bool? isHydrating,
    List<DailyCheckEntry>? dailyChecks,
    WeatherSnapshot? weather,
  }) {
    return RitualsState(
      isHydrating: isHydrating ?? this.isHydrating,
      dailyChecks: dailyChecks ?? this.dailyChecks,
      weather: weather ?? this.weather,
    );
  }
}

final ritualsStateProvider = NotifierProvider<RitualsController, RitualsState>(
  RitualsController.new,
);

class RitualsController extends Notifier<RitualsState> {
  bool _mounted = true;
  String _ownerId = '';

  @override
  RitualsState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    return RitualsState(
      isHydrating: true,
      dailyChecks: const [],
      weather: WeatherSnapshot(
        locationLabel: 'Istanbul',
        condition: 'Clear',
        tempC: 22,
        windKph: 18,
        precipChancePercent: 10,
        observedAtIso: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  void addDailyCheck(DailyCheckEntry entry) {
    final nextChecks = [
      entry,
      ...state.dailyChecks.where((item) => item.isoDate != entry.isoDate),
    ]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    state = state.copyWith(dailyChecks: nextChecks);

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveDailyCheck(entry, userId: _ownerId));
  }

  void setWeather(WeatherSnapshot weather) {
    state = state.copyWith(weather: weather);
    unawaited(
      ApexKvStore.setString(
        'rituals.weather_json',
        jsonEncode(weather.toJson()),
      ),
    );

    final cond = weather.condition.toLowerCase();
    final isBad =
        cond.contains('yağış') ||
        cond.contains('rain') ||
        cond.contains('kar') ||
        cond.contains('snow') ||
        cond.contains('fırtına') ||
        cond.contains('thunderstorm') ||
        cond.contains('storm');

    if (isBad) {
      final strings = AppStrings(ref.read(appSettingsProvider).locale);
      final isRisk = cond.contains('riski') || cond.contains('risk');
      unawaited(
        ApexNotificationService.instance.showNotification(
          id: 999,
          title: isRisk
              ? strings.notifWeatherAlertTitle
              : strings.notifSevereWeatherTitle,
          body: strings.notifWeatherBody,
        ),
      );
    }
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    await db.init();
    try {
      _ownerId = await FirebaseService.instance.getOrCreateInstallationId();
    } catch (_) {}
    final checks = await db.getDailyChecks(userId: _ownerId);

    final weatherRaw = await ApexKvStore.getString('rituals.weather_json');

    if (!_mounted) return;

    final sortedChecks = List<DailyCheckEntry>.from(checks)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    WeatherSnapshot weather = state.weather;
    if (weatherRaw != null && weatherRaw.isNotEmpty) {
      try {
        weather = WeatherSnapshot.fromJson(
          jsonDecode(weatherRaw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    state = state.copyWith(
      isHydrating: false,
      dailyChecks: sortedChecks,
      weather: weather,
    );
  }
}

DateTime _parseRitualDate(String raw) {
  return DateTime.tryParse(raw)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
