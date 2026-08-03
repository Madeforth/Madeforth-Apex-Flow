import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class TelemetryAnalysis {
  const TelemetryAnalysis({
    required this.inferredMoodEN,
    required this.inferredMoodTR,
    required this.hardBrakingEvents,
    required this.rapidAccelerationEvents,
    required this.smoothnessScore,
    required this.insightTR,
    required this.insightEN,
    this.maxLeanAngle = 0.0,
  });

  final String inferredMoodEN;
  final String inferredMoodTR;
  final int hardBrakingEvents;
  final int rapidAccelerationEvents;
  final int smoothnessScore; // 0 to 100
  final String insightTR;
  final String insightEN;
  final double maxLeanAngle;
}

class RideTelemetryAnalyzer {
  const RideTelemetryAnalyzer();

  /// Analyzes the raw GPS positions to determine the true riding style and physics-based lean angle.
  TelemetryAnalysis analyze(
    List<Position> positions,
    double maxSpeedKmh, {
    double? fusedMaxLeanAngle,
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

    double maxLean = 0.0;
    const double g = 9.81; // Gravity m/s^2

    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];

      final dt = curr.timestamp.difference(prev.timestamp).inSeconds.toDouble();
      if (dt <= 0 || dt > 10) continue;

      // Calculate physics metrics for acceleration/braking
      final dv = curr.speed - prev.speed; // m/s
      final acceleration = dv / dt; // m/s^2

      if (acceleration < -3.5) {
        hardBrakingCount++;
      } else if (acceleration > 3.0) {
        rapidAccelCount++;
      }

      totalAccelerationDiff += acceleration.abs();
      validIntervals++;
    }

    // High-Precision Differential Geometry Trajectory Curvature Engine
    if (positions.length >= 3) {
      final p0 = positions[0];
      final lat0 = p0.latitude;
      final lon0 = p0.longitude;
      const double cosLat = 111320.0;
      final double cosScale = math.cos(lat0 * math.pi / 180.0) * cosLat;

      for (int i = 1; i < positions.length - 1; i++) {
        final pPrev = positions[i - 1];
        final pCurr = positions[i];
        final pNext = positions[i + 1];

        if (pCurr.accuracy > 20.0 ||
            pPrev.accuracy > 20.0 ||
            pNext.accuracy > 20.0)
          continue;

        final dt1 =
            pCurr.timestamp.difference(pPrev.timestamp).inMilliseconds / 1000.0;
        final dt2 =
            pNext.timestamp.difference(pCurr.timestamp).inMilliseconds / 1000.0;

        if (dt1 <= 0.1 || dt2 <= 0.1 || dt1 > 5.0 || dt2 > 5.0) continue;

        // Convert Lat/Lon to Local Metric Coordinates (x, y)
        final x0 = (pPrev.longitude - lon0) * cosScale;
        final y0 = (pPrev.latitude - lat0) * cosLat;
        final x1 = (pCurr.longitude - lon0) * cosScale;
        final y1 = (pCurr.latitude - lat0) * cosLat;
        final x2 = (pNext.longitude - lon0) * cosScale;
        final y2 = (pNext.latitude - lat0) * cosLat;

        // Velocity components (dx/dt, dy/dt)
        final vx1 = (x1 - x0) / dt1;
        final vy1 = (y1 - y0) / dt1;
        final vx2 = (x2 - x1) / dt2;
        final vy2 = (y2 - y1) / dt2;

        final speed = math.sqrt(vx1 * vx1 + vy1 * vy1);
        if (speed < 4.5) continue; // Ignore low speed noise (< 16 km/h)

        // Acceleration components (d^2x/dt^2, d^2y/dt^2)
        final dtAvg = (dt1 + dt2) / 2.0;
        final ax = (vx2 - vx1) / dtAvg;
        final ay = (vy2 - vy1) / dtAvg;

        // Trajectory Curvature Formula: kappa = |vx*ay - vy*ax| / (vx^2 + vy^2)^(3/2)
        final num = (vx1 * ay - vy1 * ax).abs();
        final den = math.pow(vx1 * vx1 + vy1 * vy1, 1.5).toDouble();

        if (den > 0.001) {
          final kappa = num / den;
          // Centripetal acceleration: a_c = v^2 * kappa
          final ac = speed * speed * kappa;

          // Physical Lean Angle: theta = arctan(a_c / g)
          final leanRad = math.atan(ac / g);
          final leanDeg = leanRad * (180.0 / math.pi);

          if (!leanDeg.isNaN && !leanDeg.isInfinite && leanDeg > maxLean) {
            maxLean = leanDeg;
          }
        }
      }
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

    if (maxLean > 35.0) {
      // If lean angle > 35 deg, user gets "Cornering Master" / "Speed Demon"
      moodEN = 'Aggressive (Speed Demon)';
      moodTR = 'Saldırgan (Viraj Avcısı)';
      insightEN =
          'Max lean angle of ${maxLean.toStringAsFixed(1)}° detected. Great cornering!';
      insightTR =
          'Maksimum ${maxLean.toStringAsFixed(1)}° yatış açısı tespit edildi. Viraj ustası!';
    } else if (smoothnessScore < 60 || hardEvents > 4 || maxSpeedKmh > 130) {
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
      maxLeanAngle: fusedMaxLeanAngle != null && fusedMaxLeanAngle > maxLean
          ? fusedMaxLeanAngle
          : maxLean,
    );
  }
}
