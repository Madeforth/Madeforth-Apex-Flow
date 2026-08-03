import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/rides/domain/ride_session.dart';

enum HarmonyLevel {
  zen('Zen State'),
  stable('Stable State'),
  drift('Mechanical Drift'),
  critical('Critical Instability'),
  collapse('Collapse State');

  const HarmonyLevel(this.label);
  final String label;
}

class HarmonySnapshot {
  const HarmonySnapshot({
    required this.score,
    required this.level,
    required this.insight,
  });

  final int score;
  final HarmonyLevel level;
  final String insight;
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
      insight: _insightFor(score, bike, latestRide),
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

  String _insightFor(
    int score,
    MotorcycleProfile bike,
    RideSession latestRide,
  ) {
    final note = latestRide.mechanicalObservation.toLowerCase();
    if (bike.serviceWindowState == ServiceWindowState.overdue) {
      return 'Service window is overdue. Close the interval before the next long ride.';
    }
    if (bike.serviceWindowState == ServiceWindowState.dueSoon) {
      return 'Service window is approaching. Keep the next check close.';
    }
    if (bike.chainWearPercent > 44 || note.contains('chain')) {
      return 'Chain signal is active. Lubrication and slack check should come first.';
    }
    if (bike.brakeWearPercent > 50 || note.contains('brake')) {
      return 'Brake feel needs attention. Inspect pads and lever response.';
    }
    if (bike.tireWearPercent > 55 || note.contains('tire')) {
      return 'Tire wear is shaping the next maintenance action.';
    }
    if (bike.oilHealthPercent < 64 || note.contains('oil')) {
      return 'Oil health is drifting. Plan service before the interval expands.';
    }
    if (score >= 90) {
      return 'Machine rhythm is clean. Maintain current ritual cadence.';
    }
    return 'Maintenance consistency is stable, but wear signals need monitoring.';
  }
}
