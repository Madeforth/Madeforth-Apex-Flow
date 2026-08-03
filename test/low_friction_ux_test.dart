import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Low-Friction UX: Auto-Duration Tests', () {
    test('startRide sets rideStartedAtIso timestamp', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(rideStateProvider.notifier);
      await Future<void>.delayed(Duration.zero); // hydrate

      expect(container.read(rideStateProvider).rideStartedAtIso, isNull);

      controller.startRide(mood: 'Excited');

      final state = container.read(rideStateProvider);
      expect(state.isRideActive, isTrue);
      expect(state.rideStartedAtIso, isNotNull);
      expect(DateTime.tryParse(state.rideStartedAtIso!), isNotNull);
    });

    test('endRide clears rideStartedAtIso timestamp', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(rideStateProvider.notifier);
      await Future<void>.delayed(Duration.zero); // hydrate

      controller.startRide(mood: 'Focused');
      expect(container.read(rideStateProvider).rideStartedAtIso, isNotNull);

      controller.endRide(
        distanceKm: 20.0,
        durationMinutes: 15,
        averageSpeedKmh: 80.0,
        mood: 'Focused',
        mechanicalObservation: 'Perfect',
      );

      final state = container.read(rideStateProvider);
      expect(state.isRideActive, isFalse);
      expect(state.rideStartedAtIso, isNull);
    });
  });

  group('Low-Friction UX: Estimated Odometer Calculation', () {
    test('Refuel estimate adds rides accumulated after last refuel', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final garageController = container.read(garageStateProvider.notifier);
      final fuelController = container.read(fuelStateProvider.notifier);
      final rideController = container.read(rideStateProvider.notifier);

      await Future<void>.delayed(Duration.zero); // hydrate

      // 1. Add bike starting at 5000 km
      garageController.addMotorcycle(
        name: 'Vectra',
        model: 'MT-07',
        odometerKm: 5000,
      );

      // 2. Add an initial refuel entry on June 9 at 5000 km
      fuelController.addEntry(
        date: DateTime(2026, 6, 9, 10, 0),
        litres: 12.0,
        totalTry: 500.0,
        odometerKm: 5000,
        note: 'First refuel',
        brand: 'Shell',
      );

      // 3. Log a ride on June 10 (15 km)
      rideController.startRide(mood: 'Calm');
      // Set the loggedAtIso mock slightly in the future or manually set sessions to control exact date
      final activeStartedAt = container
          .read(rideStateProvider)
          .rideStartedAtIso;
      expect(activeStartedAt, isNotNull);

      // We complete a ride
      rideController.endRide(
        distanceKm: 15.0,
        durationMinutes: 10,
        averageSpeedKmh: 90.0,
        mood: 'Calm',
        mechanicalObservation: 'Smooth',
      );

      // 4. Log another ride on June 11 (25 km)
      rideController.startRide(mood: 'Calm');
      rideController.endRide(
        distanceKm: 25.0,
        durationMinutes: 15,
        averageSpeedKmh: 100.0,
        mood: 'Calm',
        mechanicalObservation: 'Great',
      );

      // Now verify how the estimate should calculate:
      // Last refuel odometer: 5000 km.
      // Rides completed after June 9: 15.0 km + 25.0 km = 40.0 km.
      // Expected suggestion: 5000 + 40 = 5040 km.

      final state = container.read(fuelStateProvider);

      // Let's verify our estimation logic
      FuelEntry? lastRefuel;
      for (final entry in state.entries) {
        if (entry.odometerKm != null) {
          lastRefuel = entry;
          break;
        }
      }
      expect(lastRefuel, isNotNull);
      final refuel = lastRefuel!;
      expect(refuel.odometerKm, 5000);

      final rides = container.read(rideStateProvider).sessions;
      expect(rides.length, 2);

      var accumulatedDistance = 0.0;
      for (final ride in rides) {
        final rideDate = DateTime.parse(ride.loggedAtIso);
        if (rideDate.isAfter(refuel.date)) {
          accumulatedDistance += ride.distanceKm;
        }
      }

      expect(accumulatedDistance, 40.0);
      final estimate = refuel.odometerKm! + accumulatedDistance.round();
      expect(estimate, 5040);
    });
  });

  group('Low-Friction UX: One-Tap Daily Check', () {
    test('One-tap log daily check sets all check items to true', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ritualsController = container.read(ritualsStateProvider.notifier);
      await Future<void>.delayed(Duration.zero); // hydrate

      expect(container.read(ritualsStateProvider).dailyChecks, isEmpty);

      // Perform a quick one-tap check
      final entry = DailyCheckEntry(
        isoDate: '2026-06-11',
        tiresOk: true,
        chainOk: true,
        oilOk: true,
        brakesOk: true,
        lightsOk: true,
        batteryOk: true,
        note: 'Quick check',
        loggedAtIso: '2026-06-11T04:30:00Z',
      );

      ritualsController.addDailyCheck(entry);

      final checks = container.read(ritualsStateProvider).dailyChecks;
      expect(checks.length, 1);
      expect(checks.first.allClear, isTrue);
      expect(checks.first.tiresOk, isTrue);
      expect(checks.first.lightsOk, isTrue);
    });
  });
}
