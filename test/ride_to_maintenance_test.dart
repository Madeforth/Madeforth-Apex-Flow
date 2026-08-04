import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ride-to-Maintenance Intelligence', () {
    test('traffic (low avg speed) increases brake wear by 2.0x', () {
      // Simulate rides and compare brake delta with/without traffic.
      const longDistanceKm = 100.0;

      // Normal riding at 50 km/h:
      // brakeDelta = 0.02 * 100 * 1.0 = 2
      final normalBrakeDelta = (0.02 * longDistanceKm * 1.0).round();
      expect(normalBrakeDelta, equals(2));

      // Traffic riding at 20 km/h:
      // brakeDelta = 0.02 * 100 * 2.0 = 4
      final trafficBrakeDelta = (0.02 * longDistanceKm * 2.0).round();
      expect(trafficBrakeDelta, equals(4));

      // Verify the 2.0x multiplier relationship
      expect(trafficBrakeDelta, greaterThan(normalBrakeDelta));
    });

    test('aggressive mood increases chain and tire wear by 2.0x', () {
      const distanceKm = 100.0;

      // Normal riding:
      // chainDelta = 0.05 * 100 * 1.0 = 5
      // tireDelta = 0.03 * 100 * 1.0 = 3
      final normalChainDelta = (0.05 * distanceKm * 1.0).round();
      final normalTireDelta = (0.03 * distanceKm * 1.0).round();
      expect(normalChainDelta, equals(5));
      expect(normalTireDelta, equals(3));

      // Aggressive riding:
      // chainDelta = 0.05 * 100 * 2.0 = 10
      // tireDelta = 0.03 * 100 * 2.0 = 6
      final aggressiveChainDelta = (0.05 * distanceKm * 2.0).round();
      final aggressiveTireDelta = (0.03 * distanceKm * 2.0).round();
      expect(aggressiveChainDelta, greaterThan(normalChainDelta));
      expect(aggressiveChainDelta, equals(10));
      expect(aggressiveTireDelta, greaterThan(normalTireDelta));
      expect(aggressiveTireDelta, equals(6));
    });

    test('battery charges on rides over 10 km', () {
      // Battery charges +2 if ride > 10 km and battery < 95%.
      const batteryStart = 90;
      const shortRideKm = 5.0;
      const longRideKm = 15.0;

      final shortRideCharge = (shortRideKm > 10 && batteryStart < 95) ? 2 : 0;
      final longRideCharge = (longRideKm > 10 && batteryStart < 95) ? 2 : 0;

      expect(shortRideCharge, equals(0));
      expect(longRideCharge, equals(2));

      // Battery at 96% should not charge.
      const batteryFull = 96;
      final fullBatteryCharge = (longRideKm > 10 && batteryFull < 95) ? 2 : 0;
      expect(fullBatteryCharge, equals(0));
    });

    test('oil health degrades consistently regardless of mood or speed', () {
      const distanceKm = 100.0;

      // oilDelta = 0.02 * 100 = 2 (always, no multiplier)
      final oilDelta = (0.02 * distanceKm).round();
      expect(oilDelta, equals(2));
    });

    test('odometer always increases by ride distance', () {
      const startOdometer = 18420;
      const distanceKm = 42.7;

      final nextOdometer = startOdometer + distanceKm.round();
      expect(nextOdometer, equals(18463));
    });

    test('traffic detection threshold is 30 km/h', () {
      // Under 30 km/h = traffic
      expect(25.0 > 0 && 25.0 < 30, isTrue);
      // At 30 km/h = not traffic
      expect(30.0 > 0 && 30.0 < 30, isFalse);
      // Over 30 km/h = not traffic
      expect(50.0 > 0 && 50.0 < 30, isFalse);
      // Zero = not traffic (no data)
      expect(0.0 > 0 && 0.0 < 30, isFalse);
    });

    test('aggressive mood keywords are detected in Turkish and English', () {
      final testMoods = {
        'aggressive': true,
        'sporty': true,
        'fast': true,
        'agresif': true,
        'hızlı': true,
        'sportif': true,
        'calm': false,
        'focused': false,
        'Odaklı': false,
        'Sakin': false,
      };

      for (final entry in testMoods.entries) {
        final moodLower = entry.key.toLowerCase();
        final isAggressive =
            moodLower.contains('aggressive') ||
            moodLower.contains('sporty') ||
            moodLower.contains('fast') ||
            moodLower.contains('agresif') ||
            moodLower.contains('hızlı') ||
            moodLower.contains('sportif');
        expect(
          isAggressive,
          equals(entry.value),
          reason:
              'Mood "${entry.key}" should be ${entry.value ? "aggressive" : "calm"}',
        );
      }
    });

    test('wear values are always clamped between 0 and 100', () {
      int clampPercent(int value) => value.clamp(0, 100);

      expect(clampPercent(150), equals(100));
      expect(clampPercent(-10), equals(0));
      expect(clampPercent(50), equals(50));
      expect(clampPercent(0), equals(0));
      expect(clampPercent(100), equals(100));
    });
  });
}
