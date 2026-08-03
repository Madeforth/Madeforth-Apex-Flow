import 'dart:math' as math;
import 'package:apexflow/garage/domain/maintenance_engine_v2.dart';

enum HarmonyBand {
  inHarmony, // Ritminde (85-100)
  balanced, // Dengeli (70-84)
  attention, // İlgi İstiyor (50-69)
  serviceFocus, // Bakım Odağı (0-49)
  building, // Veri Hazırlanıyor (null)
}

class PillarResult {
  const PillarResult({
    required this.name,
    this.score,
    required this.confidence,
    required this.weight,
    required this.reasons,
  });

  final String name;
  final double? score;
  final double confidence;
  final double weight;
  final List<String> reasons;
}

class HarmonyResultV2 {
  const HarmonyResultV2({
    this.rawScore,
    this.displayScore,
    required this.band,
    required this.confidence,
    required this.pillars,
    required this.topDrivers,
    required this.criticalFlags,
    this.calculationVersion = 2,
    required this.calculatedAtUtc,
  });

  final double? rawScore;
  final double? displayScore;
  final HarmonyBand band;
  final double confidence; // 0.0 to 1.0
  final List<PillarResult> pillars;
  final List<String> topDrivers;
  final List<String> criticalFlags;
  final int calculationVersion;
  final DateTime calculatedAtUtc;

  String get bandLabel {
    switch (band) {
      case HarmonyBand.inHarmony:
        return 'Ritminde';
      case HarmonyBand.balanced:
        return 'Dengeli';
      case HarmonyBand.attention:
        return 'İlgi İstiyor';
      case HarmonyBand.serviceFocus:
        return 'Bakım Odağı';
      case HarmonyBand.building:
        return 'Skor Hazırlanıyor';
    }
  }

  String get confidenceLabel {
    if (confidence >= 0.80) return 'Yüksek Güven';
    if (confidence >= 0.60) return 'İyi Güven';
    if (confidence >= 0.40) return 'Gelişen Veri';
    return 'Düşük Güven';
  }
}

class HarmonyEngineV2 {
  const HarmonyEngineV2();

  /// Calculates V2 Harmony Result using 4 pillars and exponential moving average (EMA alpha = 0.25)
  static HarmonyResultV2 calculate({
    required List<ComponentAssessment> componentAssessments,
    required int totalCompletedServices,
    required int overdueServicesCount,
    required int totalPreRideChecksCount,
    required int passedPreRideChecksCount,
    required int openMechanicalObservationsCount,
    double? previousDisplayScore,
  }) {
    final now = DateTime.now().toUtc();
    final criticalFlags = <String>[];
    final topDrivers = <String>[];

    // Pillar 1: Component Readiness (Weight: 35)
    double componentScoreSum = 0.0;
    double componentConfSum = 0.0;
    int validComponents = 0;

    for (final ca in componentAssessments) {
      if (ca.status == ComponentStatus.replaceDue ||
          ca.status == ComponentStatus.inspectNow) {
        criticalFlags.add(
          '${ca.componentType.name}: Fiziksel kontrol veya değişim gerekiyor.',
        );
      }
      final caScore = ca.serviceProgress != null
          ? math.max(0.0, 100.0 - (ca.serviceProgress! * 100.0))
          : 85.0;
      componentScoreSum += caScore;
      componentConfSum += ca.confidence;
      validComponents++;
    }

    final p1Score = validComponents > 0
        ? componentScoreSum / validComponents
        : null;
    final p1Conf = validComponents > 0
        ? componentConfSum / validComponents
        : 0.30;

    final p1Pillar = PillarResult(
      name: 'Component Readiness',
      score: p1Score,
      confidence: p1Conf,
      weight: 35.0,
      reasons: validComponents > 0
          ? ['$validComponents garaj bileşeni değerlendirildi.']
          : ['Bileşen verisi eksik.'],
    );

    // Pillar 2: Maintenance Discipline (Weight: 30)
    final p2Score = overdueServicesCount > 0
        ? math.max(20.0, 100.0 - (overdueServicesCount * 25.0))
        : 95.0;
    final p2Conf = totalCompletedServices > 0 ? 0.90 : 0.50;

    final p2Pillar = PillarResult(
      name: 'Maintenance Discipline',
      score: p2Score,
      confidence: p2Conf,
      weight: 30.0,
      reasons: overdueServicesCount > 0
          ? ['$overdueServicesCount gecikmiş servis kaydı var.']
          : ['Zamanında yapılmış servis kayıtları mevcut.'],
    );

    // Pillar 3: Pre-Ride Consistency (Weight: 20)
    double? p3Score;
    double p3Conf = 0.40;
    if (totalPreRideChecksCount > 0) {
      p3Score = math.min(
        100.0,
        (passedPreRideChecksCount / totalPreRideChecksCount) * 100.0,
      );
      p3Conf = math.min(0.95, 0.50 + (totalPreRideChecksCount * 0.05));
    }

    final p3Pillar = PillarResult(
      name: 'Pre-Ride Consistency',
      score: p3Score,
      confidence: p3Conf,
      weight: 20.0,
      reasons: totalPreRideChecksCount > 0
          ? ['$totalPreRideChecksCount sürüş öncesi kontrol gerçekleştirildi.']
          : ['Henüz sürüş öncesi kontrol yapılmadı.'],
    );

    // Pillar 4: Observation Resolution (Weight: 15)
    final p4Score = openMechanicalObservationsCount > 0
        ? math.max(40.0, 100.0 - (openMechanicalObservationsCount * 20.0))
        : 100.0;
    final p4Conf = 0.80;

    final p4Pillar = PillarResult(
      name: 'Observation Resolution',
      score: p4Score,
      confidence: p4Conf,
      weight: 15.0,
      reasons: openMechanicalObservationsCount > 0
          ? [
              '$openMechanicalObservationsCount açık mekanik gözlem kaydı bulunuyor.',
            ]
          : ['Açık mekanik gözlem kaydı bulunmuyor.'],
    );

    final pillars = [p1Pillar, p2Pillar, p3Pillar, p4Pillar];

    // Section 5.1: Available Weight Normalization
    double weightedScoreSum = 0.0;
    double totalEffectiveWeight = 0.0;

    for (final p in pillars) {
      if (p.score != null) {
        final effWeight = p.weight * p.confidence;
        weightedScoreSum += p.score! * effWeight;
        totalEffectiveWeight += effWeight;
      }
    }

    double? rawScore;
    double? displayScore;
    HarmonyBand band = HarmonyBand.building;
    double overallConfidence = 0.30;

    if (totalEffectiveWeight >= 30.0) {
      rawScore = weightedScoreSum / totalEffectiveWeight;
      overallConfidence = totalEffectiveWeight / 100.0;

      // Section 11: EMA Smoothing (alpha = 0.25)
      if (previousDisplayScore != null && previousDisplayScore > 0) {
        displayScore = (0.25 * rawScore) + (0.75 * previousDisplayScore);
      } else {
        displayScore = rawScore;
      }

      final scoreForBand = displayScore;
      if (scoreForBand >= 85.0) {
        band = HarmonyBand.inHarmony;
      } else if (scoreForBand >= 70.0) {
        band = HarmonyBand.balanced;
      } else if (scoreForBand >= 50.0) {
        band = HarmonyBand.attention;
      } else {
        band = HarmonyBand.serviceFocus;
      }

      // Populate drivers
      if (p2Score >= 90) topDrivers.add('Bakımlar zamanında yapılıyor.');
      if (p4Score == 100) topDrivers.add('Açık mekanik sorun bulunmuyor.');
      if (overdueServicesCount > 0)
        topDrivers.add('$overdueServicesCount servis bakımı zamanı geçti.');
    }

    return HarmonyResultV2(
      rawScore: rawScore,
      displayScore: displayScore,
      band: band,
      confidence: math.max(0.20, math.min(1.0, overallConfidence)),
      pillars: pillars,
      topDrivers: topDrivers,
      criticalFlags: criticalFlags,
      calculatedAtUtc: now,
    );
  }
}
