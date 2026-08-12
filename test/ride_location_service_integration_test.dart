import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/rides/application/ride_completion.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';

/// Feeds a scripted position stream through the real `RideLocationService`,
/// so the whole chain — platform settings, engine, snapshotting, merge and
/// discard policy — is exercised, not just the engine in isolation.
class _ScriptedGeolocator extends GeolocatorPlatform {
  _ScriptedGeolocator(this._controller);

  final StreamController<Position> _controller;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      _controller.stream;
}

Position fix({
  required DateTime timestamp,
  required double lonDeg,
  required double speedMps,
}) {
  return Position(
    longitude: lonDeg,
    latitude: 41.0,
    timestamp: timestamp,
    accuracy: 6.0,
    altitude: 40.0,
    altitudeAccuracy: 3.0,
    heading: 90.0,
    headingAccuracy: 5.0,
    speed: speedMps,
    speedAccuracy: 1.0,
  );
}

/// Emits [seconds] of 1 Hz fixes at [speedMps] starting from [from]/[startLon].
/// Returns the longitude reached, so a resumed segment can continue from it.
Future<double> emitRide(
  StreamController<Position> controller, {
  required DateTime from,
  required double startLon,
  required int seconds,
  required double speedMps,
}) async {
  const metresPerDegree = 111320.0;
  final lonPerMetre =
      1.0 / (metresPerDegree * math.cos(41.0 * math.pi / 180.0));

  var lon = startLon;
  for (var second = 0; second < seconds; second++) {
    controller.add(
      fix(
        timestamp: from.add(Duration(seconds: second)),
        lonDeg: lon,
        speedMps: speedMps,
      ),
    );
    lon += speedMps * lonPerMetre;
    // Let the service's listener and its async snapshot write run.
    await Future<void>.delayed(Duration.zero);
  }
  return lon;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<Position> controller;

  // flutter_test reports Android, so the service takes its Android branch and
  // asks permission_handler for the battery-optimisation exemption. Answer it
  // instead of letting a MissingPluginException abort ride tracking.
  const permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );

  setUp(() {
    controller = StreamController<Position>.broadcast();
    GeolocatorPlatform.instance = _ScriptedGeolocator(controller);

    binding.defaultBinaryMessenger.setMockMethodCallHandler(permissionChannel, (
      call,
    ) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          return 1; // PermissionStatus.granted
        case 'requestPermissions':
          return <int, int>{
            for (final p in [28]) p: 1,
          };
        default:
          return null;
      }
    });
  });

  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      permissionChannel,
      null,
    );
    await controller.close();
  });

  test('a 130 km/h commute is tracked and kept end to end', () async {
    SharedPreferences.setMockInitialValues({
      'rides.is_active': true,
      'rides.started_at_iso': DateTime.now().toUtc().toIso8601String(),
    });
    await ApexKvStore.init(useFallback: true);

    final service = RideLocationService();
    await service.startTracking(isTurkish: true);
    expect(service.isTracking, isTrue);

    final start = DateTime.now().toUtc();
    await emitRide(
      controller,
      from: start,
      startLon: 29.0,
      seconds: 300, // 5 minutes
      speedMps: 36.1, // 130 km/h
    );

    final result = service.stopTracking(isTurkish: true);

    // 300 s at 36.1 m/s = 10.83 km.
    expect(result.hasGpsData, isTrue);
    expect(result.distanceKm, closeTo(10.83, 0.4));
    expect(result.averageSpeedKmh, closeTo(130.0, 6.0));
    expect(result.maxSpeedKmh, closeTo(130.0, 6.0));

    // And the screens must keep it.
    final metrics = resolveRideCompletion(result);
    expect(metrics.shouldDiscard, isFalse);
    expect(metrics.distanceKm, greaterThan(10.0));
  });

  test('a ride interrupted by a process kill keeps its distance', () async {
    final startedAtIso = DateTime.now().toUtc().toIso8601String();
    SharedPreferences.setMockInitialValues({
      'rides.is_active': true,
      'rides.started_at_iso': startedAtIso,
    });
    await ApexKvStore.init(useFallback: true);

    final service = RideLocationService();

    // Segment one: three minutes of riding, then the OS kills the app.
    await service.startTracking(isTurkish: true);
    final start = DateTime.now().toUtc();
    final lonAfterFirst = await emitRide(
      controller,
      from: start,
      startLon: 29.0,
      seconds: 180,
      speedMps: 36.1,
    );
    // Give the last checkpoint write a chance to land.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // Relaunch: the ride flag is still set, so tracking resumes. This is the
    // step that used to wipe every kilometre ridden so far.
    await service.startTracking(isTurkish: true);
    await emitRide(
      controller,
      from: start.add(const Duration(seconds: 180)),
      startLon: lonAfterFirst,
      seconds: 180,
      speedMps: 36.1,
    );

    final result = service.stopTracking(isTurkish: true);

    // Both segments must be present: 360 s at 36.1 m/s = 13.0 km. The
    // checkpoint granularity is 10 s, so allow for the final unsaved window.
    expect(result.distanceKm, greaterThan(11.5));
    expect(result.distanceKm, closeTo(13.0, 1.5));
    expect(result.maxSpeedKmh, closeTo(130.0, 6.0));

    final metrics = resolveRideCompletion(result);
    expect(metrics.shouldDiscard, isFalse);

    // The snapshot must not outlive the ride.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getString('rides.telemetry_snapshot'), isNull);
  });
}
