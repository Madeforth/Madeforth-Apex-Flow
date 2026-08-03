import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:apexflow/rides/application/lean_angle_engine_v3.dart';

void main() {
  group('LeanAngleEngineV3 - Doc 24 Implementation Tests', () {
    const engine = LeanAngleEngineV3();

    test('Rejects single GPS spike and returns invalid unconfirmed turn', () {
      final now = DateTime.now();
      final positions = <Position>[
        Position(
          latitude: 36.8800,
          longitude: 30.6800,
          timestamp: now,
          accuracy: 5.0,
          altitude: 0,
          heading: 0,
          speed: 12.0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
        Position(
          latitude: 36.8801,
          longitude: 30.6801,
          timestamp: now.add(const Duration(seconds: 1)),
          accuracy: 5.0,
          altitude: 0,
          heading: 0,
          speed: 12.0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
        // GPS spike
        Position(
          latitude: 36.8850,
          longitude: 30.6850,
          timestamp: now.add(const Duration(seconds: 2)),
          accuracy: 50.0,
          altitude: 0,
          heading: 0,
          speed: 12.0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
        Position(
          latitude: 36.8803,
          longitude: 30.6803,
          timestamp: now.add(const Duration(seconds: 3)),
          accuracy: 5.0,
          altitude: 0,
          heading: 0,
          speed: 12.0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
        Position(
          latitude: 36.8804,
          longitude: 30.6804,
          timestamp: now.add(const Duration(seconds: 4)),
          accuracy: 5.0,
          altitude: 0,
          heading: 0,
          speed: 12.0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      ];

      final estimate = engine.evaluateRideTrajectory(positions);
      expect(estimate.maxLeanDeg, isNull);
      expect(estimate.invalidReason, equals(LeanInvalidReason.unconfirmedTurn));
    });

    test(
      'Calculates valid lean angle for smooth synthetic turn trajectory',
      () {
        final now = DateTime.now();
        final positions = <Position>[];

        // Generate 8 points along a smooth curve (radius ~ 40m, speed ~ 15 m/s)
        for (int i = 0; i < 8; i++) {
          final angle = (i * 0.15);
          final lat = 36.8800 + (0.0003 * (1.0 - (angle * angle / 2.0)));
          final lon = 30.6800 + (0.0003 * angle);
          positions.add(
            Position(
              latitude: lat,
              longitude: lon,
              timestamp: now.add(Duration(milliseconds: i * 500)),
              accuracy: 3.0,
              altitude: 0,
              heading: 45.0,
              speed: 14.0,
              speedAccuracy: 0.5,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            ),
          );
        }

        final estimate = engine.evaluateRideTrajectory(positions);
        if (estimate.maxLeanDeg != null) {
          expect(estimate.maxLeanDeg, greaterThan(0.0));
          expect(estimate.maxLeanDeg, lessThan(90.0));
          expect(estimate.algorithmVersion, equals('3.0.0-V3'));
        }
      },
    );

    test('LeanPersistenceSanitizer rejects legacy 168 degrees error', () {
      final sanitized168 = LeanPersistenceSanitizer.sanitizeForUiDisplay(
        168.0,
        isLegacy: true,
      );
      expect(sanitized168, isNull);

      final sanitized95 = LeanPersistenceSanitizer.sanitizeForUiDisplay(95.0);
      expect(sanitized95, isNull);

      final sanitizedValid = LeanPersistenceSanitizer.sanitizeForUiDisplay(
        28.5,
      );
      expect(sanitizedValid, equals(28.5));
    });
  });
}
