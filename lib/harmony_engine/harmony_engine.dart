import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/rides/domain/ride_session.dart';

enum HarmonyLevel {
  zen('Zen State'),
  stable('Stable State'),
  drift('Mechanical Drift'),
  critical('Critical Instability'),
  collapse('Collapse State');

  const HarmonyLevel(this.label);

  /// Legacy English label — kept for anything not yet migrated to
  /// [localizedLabel]. Prefer [localizedLabel] for any user-facing text.
  final String label;

  String localizedLabel(String languageCode) {
    switch (this) {
      case HarmonyLevel.zen:
        return tInline(languageCode, 'Zen Durumu', 'Zen State', 'Zen-Zustand');
      case HarmonyLevel.stable:
        return tInline(
          languageCode,
          'Stabil Durum',
          'Stable State',
          'Stabiler Zustand',
        );
      case HarmonyLevel.drift:
        return tInline(
          languageCode,
          'Mekanik Sapma',
          'Mechanical Drift',
          'Mechanische Drift',
        );
      case HarmonyLevel.critical:
        return tInline(
          languageCode,
          'Kritik Dengesizlik',
          'Critical Instability',
          'Kritische Instabilität',
        );
      case HarmonyLevel.collapse:
        return tInline(
          languageCode,
          'Çöküş Durumu',
          'Collapse State',
          'Kollapszustand',
        );
    }
  }
}

enum HarmonyInsightKey {
  overdue,
  dueSoon,
  chainWear,
  brakeWear,
  tireWear,
  oilHealth,
  clean,
  stableWithWearSignals,
}

String harmonyInsightText(HarmonyInsightKey key, String languageCode) {
  switch (key) {
    case HarmonyInsightKey.overdue:
      return tInline(
        languageCode,
        'Servis penceresi gecikti. Uzun sürüşten önce bu aralığı kapatın.',
        'Service window is overdue. Close the interval before the next long ride.',
        'Das Servicefenster ist überfällig. Schließen Sie das Intervall vor der nächsten langen Fahrt ab.',
      );
    case HarmonyInsightKey.dueSoon:
      return tInline(
        languageCode,
        'Servis penceresi yaklaşıyor. Bir sonraki kontrolü yakın tutun.',
        'Service window is approaching. Keep the next check close.',
        'Das Servicefenster naht. Behalten Sie die nächste Kontrolle im Blick.',
      );
    case HarmonyInsightKey.chainWear:
      return tInline(
        languageCode,
        'Zincir sinyali aktif. Önce yağlama ve boşluk kontrolü yapılmalı.',
        'Chain signal is active. Lubrication and slack check should come first.',
        'Kettensignal aktiv. Schmierung und Spielkontrolle sollten zuerst erfolgen.',
      );
    case HarmonyInsightKey.brakeWear:
      return tInline(
        languageCode,
        'Fren hissi dikkat gerektiriyor. Balata ve kol tepkisini inceleyin.',
        'Brake feel needs attention. Inspect pads and lever response.',
        'Das Bremsgefühl braucht Aufmerksamkeit. Beläge und Hebelreaktion prüfen.',
      );
    case HarmonyInsightKey.tireWear:
      return tInline(
        languageCode,
        'Lastik aşınması bir sonraki bakım işlemini şekillendiriyor.',
        'Tire wear is shaping the next maintenance action.',
        'Der Reifenverschleiß bestimmt die nächste Wartungsmaßnahme.',
      );
    case HarmonyInsightKey.oilHealth:
      return tInline(
        languageCode,
        'Yağ sağlığı düşüyor. Aralık genişlemeden servis planlayın.',
        'Oil health is drifting. Plan service before the interval expands.',
        'Der Ölzustand verschlechtert sich. Planen Sie den Service, bevor sich das Intervall verlängert.',
      );
    case HarmonyInsightKey.clean:
      return tInline(
        languageCode,
        'Makine ritmi temiz. Mevcut ritüel temposunu koruyun.',
        'Machine rhythm is clean. Maintain current ritual cadence.',
        'Der Maschinenrhythmus ist sauber. Behalten Sie das aktuelle Ritualtempo bei.',
      );
    case HarmonyInsightKey.stableWithWearSignals:
      return tInline(
        languageCode,
        'Bakım tutarlılığı stabil, ancak aşınma sinyalleri izlenmeli.',
        'Maintenance consistency is stable, but wear signals need monitoring.',
        'Die Wartungskonsistenz ist stabil, aber Verschleißsignale müssen beobachtet werden.',
      );
  }
}

class HarmonySnapshot {
  const HarmonySnapshot({
    required this.score,
    required this.level,
    required this.insightKey,
  });

  final int score;
  final HarmonyLevel level;
  final HarmonyInsightKey insightKey;
}

class HarmonyEngine {
  const HarmonyEngine();

  HarmonySnapshot evaluate(MotorcycleProfile bike, RideSession latestRide) {
    final servicePenalty = _servicePenalty(bike);
    final wearPenalty = _wearPenalty(bike);
    final oilPenalty = ((100 - bike.oilHealthPercent) / 7).round();
    final batteryPenalty = ((100 - bike.batteryHealthPercent) / 12).round();
    final ridePenalty = _ridePenalty(latestRide);
    final smoothnessBonus = _smoothnessBonus(latestRide);
    final score =
        (100 -
                servicePenalty -
                wearPenalty -
                oilPenalty -
                batteryPenalty +
                smoothnessBonus -
                ridePenalty)
            .clamp(0, 100);

    return HarmonySnapshot(
      score: score,
      level: _levelFor(score),
      insightKey: _insightKeyFor(score, bike, latestRide),
    );
  }

  int _servicePenalty(MotorcycleProfile bike) {
    final base = (bike.serviceProgress * 24).round();
    final overduePenalty = bike.serviceWindowState == ServiceWindowState.overdue
        ? ((bike.kmUntilService.abs() / 250).round()).clamp(2, 14)
        : 0;
    return base + overduePenalty;
  }

  int _wearPenalty(MotorcycleProfile bike) {
    return ((bike.chainWearPercent +
                bike.tireWearPercent +
                bike.brakeWearPercent) /
            12)
        .round();
  }

  int _ridePenalty(RideSession latestRide) {
    final note = latestRide.mechanicalObservation.toLowerCase();
    final observationPenalty =
        note.contains('brake') ||
            note.contains('chain') ||
            note.contains('tire') ||
            note.contains('oil')
        ? 4
        : 0;

    final mood = latestRide.mood.toLowerCase();
    final pacePenalty =
        latestRide.averageSpeedKmh > 105 || latestRide.maxSpeedKmh > 130
        ? 5
        : 0;

    final isAggressive =
        mood.contains('saldırgan') ||
        mood.contains('aggressive') ||
        latestRide.maxLeanAngle > 45.0 ||
        latestRide.hardBrakes > 3;
    final telemetryPenalty = isAggressive ? 6 : 0;

    return observationPenalty + pacePenalty + telemetryPenalty;
  }

  int _smoothnessBonus(RideSession latestRide) {
    if (latestRide.distanceKm <= 0) {
      return 0;
    }

    final mood = latestRide.mood.toLowerCase();
    final baseBonus = latestRide.averageSpeedKmh <= 92 ? 3 : 0;

    final isRelaxed =
        mood.contains('sakin') ||
        mood.contains('relaxed') ||
        (latestRide.maxLeanAngle > 0 &&
            latestRide.maxLeanAngle < 30.0 &&
            latestRide.hardBrakes == 0 &&
            latestRide.hardAccelerations <= 1);
    final telemetryBonus = isRelaxed ? 5 : 0;

    return baseBonus + telemetryBonus;
  }

  HarmonyLevel _levelFor(int score) {
    if (score >= 90) {
      return HarmonyLevel.zen;
    }
    if (score >= 70) {
      return HarmonyLevel.stable;
    }
    if (score >= 50) {
      return HarmonyLevel.drift;
    }
    if (score >= 30) {
      return HarmonyLevel.critical;
    }
    return HarmonyLevel.collapse;
  }

  HarmonyInsightKey _insightKeyFor(
    int score,
    MotorcycleProfile bike,
    RideSession latestRide,
  ) {
    final note = latestRide.mechanicalObservation.toLowerCase();
    if (bike.serviceWindowState == ServiceWindowState.overdue) {
      return HarmonyInsightKey.overdue;
    }
    if (bike.serviceWindowState == ServiceWindowState.dueSoon) {
      return HarmonyInsightKey.dueSoon;
    }
    if (bike.chainWearPercent > 44 || note.contains('chain')) {
      return HarmonyInsightKey.chainWear;
    }
    if (bike.brakeWearPercent > 50 || note.contains('brake')) {
      return HarmonyInsightKey.brakeWear;
    }
    if (bike.tireWearPercent > 55 || note.contains('tire')) {
      return HarmonyInsightKey.tireWear;
    }
    if (bike.oilHealthPercent < 64 || note.contains('oil')) {
      return HarmonyInsightKey.oilHealth;
    }
    if (score >= 90) {
      return HarmonyInsightKey.clean;
    }
    return HarmonyInsightKey.stableWithWearSignals;
  }
}
