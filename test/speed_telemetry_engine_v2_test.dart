import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:apexflow/rides/domain/speed_telemetry_models.dart';
import 'package:apexflow/rides/application/speed_kalman_filter.dart';
import 'package:apexflow/rides/application/motion_state_machine.dart';
import 'package:apexflow/rides/application/validated_speed_engine.dart';

void main() {
  group('SpeedKalmanFilter V2 Tests', () {
    test('filters speed smoothly and rejects single 4-sigma NIS outliers', () {
      final filter = SpeedKalmanFilter();
      final now = DateTime.now().toUtc();

      // Initial reading: 20 m/s (72 km/h)
      filter.update(measurementMps: 20.0, varianceR: 1.0, timestamp: now);
      expect(filter.currentSpeedMps, closeTo(20.0, 0.5));

      // Single GPS Spike: 80 m/s (288 km/h) - Should be rejected by NIS Gate!
      final spikeTime = now.add(const Duration(seconds: 1));
      final res = filter.update(
        measurementMps: 80.0,
        varianceR: 1.0,
        timestamp: spikeTime,
      );

      expect(res.accepted, isFalse);
      expect(
        filter.currentSpeedMps,
        lessThan(35.0),
      ); // Filter did NOT jump to 80 m/s!
    });
  });

  group('MotionStateMachine V2 Tests', () {
    test(
      'transitions between stopped and moving with hysteresis and hold times',
      () {
        final machine = MotionStateMachine();
        final now = DateTime.now().toUtc();

        expect(machine.currentState, MotionState.stopped);

        // Low speed < 1.5 m/s -> stays stopped
        machine.update(
          filteredSpeedMps: 1.0,
          uncertaintyMps: 0.1,
          timestamp: now,
        );
        expect(machine.currentState, MotionState.stopped);

        // High speed > 1.5 m/s held for 2 seconds -> transitions to moving
        machine.update(
          filteredSpeedMps: 10.0,
          uncertaintyMps: 0.5,
          timestamp: now.add(const Duration(seconds: 1)),
        );
        expect(machine.currentState, MotionState.stopped); // candidate state

        machine.update(
          filteredSpeedMps: 10.0,
          uncertaintyMps: 0.5,
          timestamp: now.add(const Duration(seconds: 3)),
        );
        expect(machine.currentState, MotionState.moving);
      },
    );
  });

  group('TelemetryConfig invariants', () {
    test('distance integration tolerates a slower-than-requested cadence', () {
      const config = TelemetryConfig();
      final requestedIntervalSeconds = config.desiredIntervalMs / 1000.0;

      // The integration window must survive several consecutive missed
      // samples. When it was narrower than the platform's actual delivery
      // interval, every segment was dropped and real rides finalized at 0 km.
      expect(
        config.maxDistanceIntegrationDtSeconds,
        greaterThanOrEqualTo(requestedIntervalSeconds * 4),
      );

      // The gap flag is a diagnostic and is allowed to be stricter, but it
      // must never be mistaken for the integration window again.
      expect(
        config.continuousDataGapSeconds,
        lessThan(config.maxDistanceIntegrationDtSeconds),
      );
    });
  });

  group('ValidatedSpeedEngine V2 Integration Tests', () {
    test('single GPS speed spike does not become validated max speed', () {
      final engine = ValidatedSpeedEngine();
      final now = DateTime.now().toUtc();

      engine.startRide(startTime: now);

      // Ride at 25 m/s (90 km/h) for 5 seconds
      for (int i = 0; i < 5; i++) {
        engine.processPosition(
          Position(
            longitude: 29.0 + (i * 0.0001),
            latitude: 41.0,
            timestamp: now.add(Duration(seconds: i)),
            accuracy: 5.0,
            altitude: 10.0,
            altitudeAccuracy: 1.0,
            heading: 90.0,
            headingAccuracy: 1.0,
            speed: 25.0, // 90 km/h
            speedAccuracy: 0.5,
          ),
          rideId: 'test_ride',
          sequence: i,
        );
      }

      // Single GPS Spike at second 6: 90 m/s (324 km/h)
      engine.processPosition(
        Position(
          longitude: 29.001,
          latitude: 41.0,
          timestamp: now.add(const Duration(seconds: 6)),
          accuracy: 5.0,
          altitude: 10.0,
          altitudeAccuracy: 1.0,
          heading: 90.0,
          headingAccuracy: 1.0,
          speed: 90.0, // 324 km/h spike!
          speedAccuracy: 0.5,
        ),
        rideId: 'test_ride',
        sequence: 6,
      );

      // Back to 25 m/s at second 7
      engine.processPosition(
        Position(
          longitude: 29.0011,
          latitude: 41.0,
          timestamp: now.add(const Duration(seconds: 7)),
          accuracy: 5.0,
          altitude: 10.0,
          altitudeAccuracy: 1.0,
          heading: 90.0,
          headingAccuracy: 1.0,
          speed: 25.0,
          speedAccuracy: 0.5,
        ),
        rideId: 'test_ride',
        sequence: 7,
      );

      final summary = engine.finalizeRide(
        endTime: now.add(const Duration(seconds: 8)),
      );

      expect(
        summary.validatedMaxSpeedKmh,
        closeTo(90.0, 5.0),
      ); // Validated max is 90 km/h!
      expect(
        summary.validatedMaxSpeedKmh,
        lessThan(150.0),
      ); // 324 km/h spike was rejected!
    });

    test('integrates distance when positions arrive at the platform sampling '
        'interval, not only at 1 Hz', () {
      // Android delivers positions no faster than
      // AndroidSettings.intervalDuration. A real 130 km/h commute sampled at
      // that cadence must still produce distance and speed — it used to
      // finalize at 0 km and get discarded as "no movement detected".
      const sampleGap = Duration(seconds: 4);
      const speedMps = 36.1; // 130 km/h

      final engine = ValidatedSpeedEngine();
      final now = DateTime.now().toUtc();
      engine.startRide(startTime: now);

      for (int i = 0; i < 20; i++) {
        engine.processPosition(
          Position(
            longitude: 29.0 + (i * 0.0017),
            latitude: 41.0,
            timestamp: now.add(sampleGap * i),
            accuracy: 8.0,
            altitude: 10.0,
            altitudeAccuracy: 1.0,
            heading: 90.0,
            headingAccuracy: 1.0,
            speed: speedMps,
            speedAccuracy: 0.5,
          ),
          rideId: 'test_ride',
          sequence: i,
        );
      }

      final summary = engine.finalizeRide(endTime: now.add(sampleGap * 20));

      expect(summary.acceptedSampleCount, greaterThanOrEqualTo(2));
      // 19 segments * 4 s * 36.1 m/s ~= 2.74 km
      expect(summary.totalDistanceKm, closeTo(2.74, 0.3));
      expect(summary.movingDistanceKm, greaterThan(2.0));
      // Independent fallback track must agree with the integrated distance.
      expect(summary.coordinateDistanceKm, closeTo(2.71, 0.3));
      expect(summary.movingAverageSpeedKmh, closeTo(130.0, 10.0));
      expect(summary.validatedMaxSpeedKmh, closeTo(130.0, 10.0));
    });
  });
}
