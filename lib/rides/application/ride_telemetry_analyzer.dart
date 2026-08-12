import 'package:geolocator/geolocator.dart';
import 'package:apexflow/rides/domain/speed_telemetry_models.dart';

class TelemetryAnalysis {
  const TelemetryAnalysis({
    required this.inferredMoodEN,
    required this.inferredMoodTR,
    required this.hardBrakingEvents,
    required this.rapidAccelerationEvents,
    required this.smoothnessScore,
    required this.insightTR,
    required this.insightEN,
  });

  final String inferredMoodEN;
  final String inferredMoodTR;
  final int hardBrakingEvents;
  final int rapidAccelerationEvents;
  final int smoothnessScore; // 0 to 100
  final String insightTR;
  final String insightEN;
}

class RideTelemetryAnalyzer {
  const RideTelemetryAnalyzer();

  /// Analyzes the raw GPS positions to determine the true riding style.
  /// [speedEstimates] should be ValidatedSpeedEngine's own Kalman-filtered,
  /// NIS-gated per-sample speed series — hard-braking/rapid-acceleration
  /// detection is derived from that instead of raw `Position.speed` so it
  /// stays consistent with the distance/max-speed numbers computed from the
  /// same filtered series, rather than reacting to raw GPS noise.
  TelemetryAnalysis analyze(
    List<Position> positions,
    double maxSpeedKmh, {
    List<SpeedEstimate> speedEstimates = const [],
  }) {
    if (positions.length < 3) {
      return const TelemetryAnalysis(
        inferredMoodEN: 'Focused',
        inferredMoodTR: 'Odaklı',
        hardBrakingEvents: 0,
        rapidAccelerationEvents: 0,
        smoothnessScore: 90,
        insightTR: 'Yeterli telemetri verisi yok.',
        insightEN: 'Insufficient telemetry data.',
      );
    }

    int hardBrakingCount = 0;
    int rapidAccelCount = 0;
    double totalAccelerationDiff = 0.0;
    int validIntervals = 0;

    // Only samples the Kalman filter actually accepted — outlier spikes
    // (GPS noise, not real braking/acceleration) are already excluded.
    final acceptedEstimates = speedEstimates
        .where((e) => e.acceptedForDistance)
        .toList();

    for (int i = 1; i < acceptedEstimates.length; i++) {
      final prev = acceptedEstimates[i - 1];
      final curr = acceptedEstimates[i];

      final dt =
          curr.timestamp.difference(prev.timestamp).inMilliseconds / 1000.0;
      if (dt <= 0 || dt > 10) continue;

      // Calculate physics metrics for acceleration/braking from the same
      // filtered speed series distance/max-speed are computed from.
      final dv = curr.speedMps - prev.speedMps; // m/s
      final acceleration = dv / dt; // m/s^2

      if (acceleration < -3.5) {
        hardBrakingCount++;
      } else if (acceleration > 3.0) {
        rapidAccelCount++;
      }

      totalAccelerationDiff += acceleration.abs();
      validIntervals++;
    }

    final avgAccel = validIntervals > 0
        ? totalAccelerationDiff / validIntervals
        : 0.0;
    final hardEvents = hardBrakingCount + rapidAccelCount;
    int smoothnessScore = (100 - (avgAccel * 25) - (hardEvents * 5))
        .round()
        .clamp(0, 100);

    if (maxSpeedKmh > 140) {
      smoothnessScore -= 15;
    }
    smoothnessScore = smoothnessScore.clamp(0, 100);

    String moodEN = 'Focused';
    String moodTR = 'Odaklı';
    String insightEN = '';
    String insightTR = '';

    if (smoothnessScore < 60 || hardEvents > 4 || maxSpeedKmh > 130) {
      moodEN = 'Aggressive';
      moodTR = 'Saldırgan';
      insightEN =
          'Telemetry detected hard braking or rapid acceleration. Ride was aggressive.';
      insightTR =
          'Telemetri ani fren veya sert hızlanma tespit etti. Sürüş agresifti.';
    } else if (smoothnessScore > 85 && hardEvents == 0 && maxSpeedKmh < 90) {
      moodEN = 'Relaxed';
      moodTR = 'Sakin';
      insightEN = 'Smooth and consistent telemetry. Ride was relaxed.';
      insightTR = 'Pürüzsüz ve tutarlı telemetri. Sürüş sakindi.';
    } else {
      moodEN = 'Focused';
      moodTR = 'Odaklı';
      insightEN = 'Balanced acceleration and braking. Good rhythm.';
      insightTR = 'Dengeli ivmelenme ve frenleme. İyi bir ritim.';
    }

    return TelemetryAnalysis(
      inferredMoodEN: moodEN,
      inferredMoodTR: moodTR,
      hardBrakingEvents: hardBrakingCount,
      rapidAccelerationEvents: rapidAccelCount,
      smoothnessScore: smoothnessScore,
      insightTR: insightTR,
      insightEN: insightEN,
    );
  }
}
