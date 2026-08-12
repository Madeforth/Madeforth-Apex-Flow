import 'package:flutter_test/flutter_test.dart';

import 'package:apexflow/rides/application/ride_completion.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';

RideLocationResult result({
  required double distanceKm,
  required double averageSpeedKmh,
  double maxSpeedKmh = 0,
  bool hasGpsData = true,
  int activeDurationMinutes = 5,
}) {
  return RideLocationResult(
    distanceKm: distanceKm,
    averageSpeedKmh: averageSpeedKmh,
    maxSpeedKmh: maxSpeedKmh,
    hasGpsData: hasGpsData,
    statusMessage: '',
    activeDurationMinutes: activeDurationMinutes,
  );
}

void main() {
  group('Ride discard policy', () {
    test('keeps a genuine commute', () {
      final metrics = resolveRideCompletion(
        result(distanceKm: 18.734, averageSpeedKmh: 62.44, maxSpeedKmh: 130.2),
      );

      expect(metrics.shouldDiscard, isFalse);
      expect(metrics.distanceKm, 18.73);
      expect(metrics.averageSpeedKmh, 62.4);
      expect(metrics.maxSpeedKmh, 130.2);
      expect(metrics.durationMinutes, 5);
    });

    test('keeps a short ride that still moved', () {
      // Below the distance minimum but clearly not stationary: the rule is
      // deliberately an AND, so this must survive.
      final metrics = resolveRideCompletion(
        result(distanceKm: 0.08, averageSpeedKmh: 24.0),
      );

      expect(metrics.shouldDiscard, isFalse);
    });

    test('discards a stationary ride', () {
      final metrics = resolveRideCompletion(
        result(distanceKm: 0.02, averageSpeedKmh: 0.4),
      );

      expect(metrics.shouldDiscard, isTrue);
    });

    test('zeroes every metric when there is no GPS data', () {
      final metrics = resolveRideCompletion(
        result(
          distanceKm: 9.9,
          averageSpeedKmh: 55.0,
          maxSpeedKmh: 120.0,
          hasGpsData: false,
        ),
      );

      expect(metrics.distanceKm, 0.0);
      expect(metrics.averageSpeedKmh, 0.0);
      expect(metrics.maxSpeedKmh, 0.0);
      expect(metrics.durationMinutes, 0);
      expect(metrics.shouldDiscard, isTrue);
    });
  });

  group('Group rides use the same rule', () {
    test('a 420 m group ride is kept, exactly like a solo one', () {
      // This used to be discarded by a separate 0.5 km group threshold even
      // though the same engine measured it into the same record.
      final metrics = resolveRideCompletion(
        result(distanceKm: 0.42, averageSpeedKmh: 30.0),
      );

      expect(metrics.shouldDiscard, isFalse);
      expect(metrics.distanceKm, 0.42);
    });

    test('allowWithoutGps keeps the widget-test path alive', () {
      final metrics = resolveRideCompletion(
        result(distanceKm: 0.0, averageSpeedKmh: 0.0, hasGpsData: false),
        allowWithoutGps: true,
      );

      expect(metrics.shouldDiscard, isFalse);
    });
  });
}
