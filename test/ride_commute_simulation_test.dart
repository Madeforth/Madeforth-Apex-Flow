import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:apexflow/rides/application/validated_speed_engine.dart';

/// End-to-end simulation of a realistic commute against the telemetry engine.
///
/// The two shipped regressions in this area both survived because the unit
/// tests fed the engine perfectly clean 1 Hz data. This test feeds it what a
/// phone actually produces: a slower cadence, varying accuracy, red lights,
/// outlier spikes and a tunnel-style outage.
void main() {
  group('Realistic commute simulation', () {
    /// Builds one sample moving due east at [speedMps] from [lonDeg].
    Position sample({
      required DateTime timestamp,
      required double lonDeg,
      required double speedMps,
      required double accuracy,
    }) {
      return Position(
        longitude: lonDeg,
        latitude: 41.0,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: 40.0,
        altitudeAccuracy: 3.0,
        heading: 90.0,
        headingAccuracy: 5.0,
        speed: speedMps,
        speedAccuracy: 1.2,
      );
    }

    test('a 20-minute commute with stops, noise and an outage is recorded', () {
      final engine = ValidatedSpeedEngine();
      final start = DateTime.utc(2026, 8, 12, 8, 0);
      engine.startRide(startTime: start);

      final random = math.Random(42);
      // Deterministic profile: accelerate, cruise at 130 km/h, three stops.
      double lon = 29.0;
      double expectedMeters = 0.0;
      var sequence = 0;

      double speedAt(int second) {
        if (second < 30) return math.min(36.1, second * 1.2); // ramp up
        if (second >= 300 && second < 360) return 0.0; // red light
        if (second >= 700 && second < 760) return 0.0; // second stop
        if (second >= 1000 && second < 1040) return 8.0; // traffic
        if (second >= 1170) {
          return math.max(0.0, math.min(36.1, (1200 - second) * 1.2));
        }
        return 36.1; // 130 km/h cruise
      }

      for (var second = 0; second < 1200; second += 4) {
        // A 40 s outage between 08:10:00 and 08:10:40 (tunnel).
        if (second >= 600 && second < 640) continue;

        final speed = speedAt(second);
        final metersThisStep = speed * 4.0;
        lon += metersThisStep / (111320.0 * math.cos(41.0 * math.pi / 180.0));
        expectedMeters += metersThisStep;

        // Accuracy wanders between 4 m and 38 m, always inside the engine's
        // 50 m rejection limit but often outside the analyzer's 45 m one.
        final accuracy = 4.0 + random.nextDouble() * 34.0;

        // Every ~50th sample is a GPS speed spike the engine must reject.
        final isSpike = sequence % 50 == 49;

        engine.processPosition(
          sample(
            timestamp: start.add(Duration(seconds: second)),
            lonDeg: lon,
            speedMps: isSpike ? speed + 55.0 : speed,
            accuracy: accuracy,
          ),
          rideId: 'commute',
          sequence: sequence,
        );
        sequence++;
      }

      final summary = engine.finalizeRide(
        endTime: start.add(const Duration(seconds: 1200)),
      );

      final expectedKm = expectedMeters / 1000.0;

      // The ride must be recorded at all — this is the exact assertion that
      // would have caught the shipped "no movement detected" bug.
      expect(summary.totalDistanceKm, greaterThan(0.1));

      // And it must be accurate, not merely non-zero: within 10% of truth.
      expect(summary.totalDistanceKm, closeTo(expectedKm, expectedKm * 0.10));
      expect(
        summary.coordinateDistanceKm,
        closeTo(expectedKm, expectedKm * 0.10),
      );

      // Spikes of +55 m/s (~198 km/h over the real speed) must not become the
      // reported maximum.
      expect(summary.validatedMaxSpeedKmh, isNotNull);
      expect(summary.validatedMaxSpeedKmh, closeTo(130.0, 12.0));

      // Stops must not be counted as moving time.
      expect(summary.movingDuration.inSeconds, lessThan(1200));
      expect(summary.movingDuration.inSeconds, greaterThan(700));
      expect(summary.movingAverageSpeedKmh, greaterThan(60.0));

      // The tunnel outage must be reported, not silently swallowed.
      expect(summary.hasTelemetryGaps, isTrue);
      expect(summary.telemetryCoverageRatio, greaterThan(0.7));
    });
  });
}
