import 'dart:math' as math;

enum ComponentType {
  engineOil,
  brakePadsFront,
  brakePadsRear,
  tiresFront,
  tiresRear,
  chainSprocket,
  sparkPlugs,
  airFilter,
}

enum ComponentStatus {
  rhythm, // Ritminde (Optimal)
  watch, // Bakım Yakın
  due, // Bakım Zamanı
  overdue, // Gecikti
  inspectNow, // Fiziksel Kontrol Gerekli
  replaceDue, // Değişim Gerekli
  unknown, // Veri Yetersiz
}

enum InspectionResult { good, attentionNeeded, criticalReplaceRequired }

class ServiceRule {
  const ServiceRule({
    required this.componentType,
    this.intervalKm,
    this.intervalDays,
    this.inspectionEveryKm,
    this.inspectionEveryDays,
    this.warningFraction = 0.80,
    this.physicalMeasurementRequired = false,
    required this.sourceLabel,
  });

  final ComponentType componentType;
  final int? intervalKm;
  final int? intervalDays;
  final int? inspectionEveryKm;
  final int? inspectionEveryDays;
  final double warningFraction;
  final bool physicalMeasurementRequired;
  final String sourceLabel;
}

class ComponentAssessment {
  const ComponentAssessment({
    required this.componentType,
    this.serviceProgress,
    this.estimatedConsumption,
    required this.status,
    required this.confidence,
    required this.reasons,
    required this.nextAction,
    this.calculationVersion = 2,
    required this.calculatedAtUtc,
  });

  final ComponentType componentType;
  final double? serviceProgress;
  final double? estimatedConsumption;
  final ComponentStatus status;
  final double confidence; // 0.0 to 1.0
  final List<String> reasons;
  final String nextAction;
  final int calculationVersion;
  final DateTime calculatedAtUtc;

  String get confidenceLabel {
    if (confidence >= 0.80) return 'Yüksek Güven';
    if (confidence >= 0.55) return 'Orta Güven';
    if (confidence >= 0.30) return 'Düşük Güven';
    return 'Veri Yetersiz';
  }

  String get statusLabel {
    switch (status) {
      case ComponentStatus.rhythm:
        return 'Ritminde';
      case ComponentStatus.watch:
        return 'Bakım Yakın';
      case ComponentStatus.due:
        return 'Bakım Zamanı';
      case ComponentStatus.overdue:
        return 'Gecikti';
      case ComponentStatus.inspectNow:
        return 'Fiziksel Kontrol Gerekli';
      case ComponentStatus.replaceDue:
        return 'Değişim Gerekli';
      case ComponentStatus.unknown:
        return 'Veri Eksik';
    }
  }
}

class MaintenanceEngineV2 {
  const MaintenanceEngineV2();

  /// Default manufacturer rules for standard motorcycle models
  static Map<ComponentType, ServiceRule> getDefaultRules() {
    return {
      ComponentType.engineOil: const ServiceRule(
        componentType: ComponentType.engineOil,
        intervalKm: 5000,
        intervalDays: 365,
        inspectionEveryKm: 1000,
        sourceLabel: 'Üretici Standart Bakım Planı',
      ),
      ComponentType.brakePadsFront: const ServiceRule(
        componentType: ComponentType.brakePadsFront,
        intervalKm: 10000,
        inspectionEveryKm: 2500,
        physicalMeasurementRequired: true,
        sourceLabel: 'Üretici Standart Bakım Planı',
      ),
      ComponentType.brakePadsRear: const ServiceRule(
        componentType: ComponentType.brakePadsRear,
        intervalKm: 10000,
        inspectionEveryKm: 2500,
        physicalMeasurementRequired: true,
        sourceLabel: 'Üretici Standart Bakım Planı',
      ),
      ComponentType.tiresFront: const ServiceRule(
        componentType: ComponentType.tiresFront,
        intervalKm: 15000,
        intervalDays: 1460, // 4 years max
        inspectionEveryKm: 1500,
        physicalMeasurementRequired: true,
        sourceLabel: 'Lastik Standart Güvenlik Planı',
      ),
      ComponentType.tiresRear: const ServiceRule(
        componentType: ComponentType.tiresRear,
        intervalKm: 12000,
        intervalDays: 1460,
        inspectionEveryKm: 1500,
        physicalMeasurementRequired: true,
        sourceLabel: 'Lastik Standart Güvenlik Planı',
      ),
      ComponentType.chainSprocket: const ServiceRule(
        componentType: ComponentType.chainSprocket,
        intervalKm: 20000,
        inspectionEveryKm: 500, // Chain lube every 500km
        sourceLabel: 'D.I.D Zincir Bakım Rehberi',
      ),
      ComponentType.sparkPlugs: const ServiceRule(
        componentType: ComponentType.sparkPlugs,
        intervalKm: 12000,
        sourceLabel: 'Üretici Standart Bakım Planı',
      ),
      ComponentType.airFilter: const ServiceRule(
        componentType: ComponentType.airFilter,
        intervalKm: 12000,
        intervalDays: 730,
        sourceLabel: 'Üretici Standart Bakım Planı',
      ),
    };
  }

  /// Calculates component assessment based on distance, time, measurements, and optional telemetry stress index.
  static ComponentAssessment assess({
    required ComponentType type,
    required ServiceRule rule,
    required double currentOdometerKm,
    required double installedOdometerKm,
    required DateTime installedAtUtc,
    DateTime? lastInspectedAtUtc,
    InspectionResult? lastInspectionResult,
    double? telemetryStressIndex, // 0.0 to 1.0, advisory uplift max 10%
  }) {
    final now = DateTime.now().toUtc();
    final distanceDriven = math.max(
      0.0,
      currentOdometerKm - installedOdometerKm,
    );
    final daysElapsed = math.max(0, now.difference(installedAtUtc).inDays);

    final distanceProgress = rule.intervalKm != null && rule.intervalKm! > 0
        ? distanceDriven / rule.intervalKm!
        : null;
    final timeProgress = rule.intervalDays != null && rule.intervalDays! > 0
        ? daysElapsed / rule.intervalDays!
        : null;

    double? rawServiceProgress;
    if (distanceProgress != null && timeProgress != null) {
      rawServiceProgress = math.max(distanceProgress, timeProgress);
    } else {
      rawServiceProgress = distanceProgress ?? timeProgress;
    }

    final reasons = <String>[];

    // Section 7: Telemetry Stress Uplift (Capped at max 10% advisory shift)
    double? estimatedConsumption = rawServiceProgress;
    if (rawServiceProgress != null &&
        telemetryStressIndex != null &&
        telemetryStressIndex > 0) {
      final maxUplift = (type == ComponentType.engineOil) ? 0.05 : 0.10;
      final stressUplift = math.min(
        maxUplift,
        telemetryStressIndex * maxUplift,
      );
      estimatedConsumption = rawServiceProgress * (1.0 + stressUplift);
      if (stressUplift > 0.02) {
        reasons.add(
          'Yoğun sürüş temposu ve telemetri uyarısı göz önüne alındı (+${(stressUplift * 100).toStringAsFixed(1)}%)',
        );
      }
    }

    // Determine status
    ComponentStatus status = ComponentStatus.rhythm;
    String nextAction = 'Planlanan servis zamanına daha var.';

    if (lastInspectionResult == InspectionResult.criticalReplaceRequired) {
      status = ComponentStatus.replaceDue;
      reasons.add('Son fiziksel kontrolde değişim gerektiği kaydedildi.');
      nextAction = 'Bileşeni en kısa sürede değiştirin.';
    } else if (lastInspectionResult == InspectionResult.attentionNeeded) {
      status = ComponentStatus.inspectNow;
      reasons.add('Son kontrolde dikkat gerektiren bulgu saptandı.');
      nextAction = 'Fiziksel kontrolü tekrarlayın.';
    } else if (rawServiceProgress != null) {
      if (rawServiceProgress >= 1.0) {
        status = ComponentStatus.overdue;
        reasons.add('Servis aralığı doldu (100% kullanım).');
        nextAction = 'Servis bakımını gerçekleştirin.';
      } else if (rawServiceProgress >= rule.warningFraction) {
        status = ComponentStatus.watch;
        final remainingKm = rule.intervalKm != null
            ? math.max(0, (rule.intervalKm! - distanceDriven).round())
            : null;
        if (remainingKm != null) {
          reasons.add('Servis aralığına yaklaşık $remainingKm km kaldı.');
        }
        nextAction = 'Rutin bakımı planlayın.';
      } else {
        reasons.add(
          'Servis aralığının %${(rawServiceProgress * 100).round()}\'i kullanıldı.',
        );
      }
    }

    // Confidence calculation (Section 10)
    double confidence = 0.85;
    if (lastInspectedAtUtc == null && rule.physicalMeasurementRequired) {
      confidence -= 0.25;
      reasons.add('Fiziksel ölçüm kaydı eksik.');
    }

    return ComponentAssessment(
      componentType: type,
      serviceProgress: rawServiceProgress,
      estimatedConsumption: estimatedConsumption,
      status: status,
      confidence: math.max(0.20, confidence),
      reasons: reasons,
      nextAction: nextAction,
      calculatedAtUtc: now,
    );
  }
}
