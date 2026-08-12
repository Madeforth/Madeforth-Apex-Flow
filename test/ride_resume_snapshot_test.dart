import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ride telemetry survives a mid-ride process kill', () {
    test('resumed tracking carries the earlier segment forward', () async {
      final startedAtIso = DateTime.now()
          .toUtc()
          .subtract(const Duration(minutes: 20))
          .toIso8601String();

      SharedPreferences.setMockInitialValues({
        'rides.is_active': true,
        'rides.started_at_iso': startedAtIso,
        'rides.telemetry_snapshot': jsonEncode({
          'startedAtIso': startedAtIso,
          'distanceKm': 12.4,
          'movingDistanceKm': 12.0,
          'coordinateDistanceKm': 12.2,
          'movingSeconds': 900,
          'maxSpeedKmh': 130.0,
        }),
      });
      await ApexKvStore.init(useFallback: true);

      final service = RideLocationService();

      // GPS itself cannot start under the test harness, which is exactly the
      // worst case: the process was killed and the new segment contributes no
      // samples at all. The ride must still be recoverable.
      await service.startTracking(isTurkish: true);
      final result = service.stopTracking(isTurkish: true);

      expect(result.hasGpsData, isTrue);
      expect(result.distanceKm, closeTo(12.4, 0.01));
      expect(result.maxSpeedKmh, closeTo(130.0, 0.01));
      expect(result.activeDurationMinutes, 15);
      // 12.0 km over 900 s of moving time = 48 km/h.
      expect(result.averageSpeedKmh, closeTo(48.0, 0.5));

      // The snapshot must not survive into the next ride.
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      expect(prefs.getString('rides.telemetry_snapshot'), isNull);
    });

    test('a snapshot from a different ride is never inherited', () async {
      SharedPreferences.setMockInitialValues({
        'rides.is_active': true,
        'rides.started_at_iso': DateTime.now().toUtc().toIso8601String(),
        'rides.telemetry_snapshot': jsonEncode({
          'startedAtIso': '2020-01-01T00:00:00.000Z',
          'distanceKm': 999.0,
          'movingDistanceKm': 999.0,
          'coordinateDistanceKm': 999.0,
          'movingSeconds': 9000,
          'maxSpeedKmh': 300.0,
        }),
      });
      await ApexKvStore.init(useFallback: true);

      final service = RideLocationService();
      await service.startTracking(isTurkish: true);
      final result = service.stopTracking(isTurkish: true);

      expect(result.hasGpsData, isFalse);
      expect(result.distanceKm, 0);
      expect(result.maxSpeedKmh, 0);
    });
  });
}
