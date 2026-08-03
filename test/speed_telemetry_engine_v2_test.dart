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
  });
}
