import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/harmony_engine/harmony_engine.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cleanRide = RideSession(
    distanceKm: 24,
    durationMinutes: 35,
    averageSpeedKmh: 52,
    mood: 'Calm',
    mechanicalObservation: 'Smooth response.',
  );

  const baseBike = MotorcycleProfile(
    id: 'bike-harmony',
    name: 'Night Vector',
    model: 'Yamaha MT-07',
    odometerKm: 10000,
    lastServiceKm: 9800,
    chainWearPercent: 14,
    tireWearPercent: 18,
    brakeWearPercent: 12,
    oilHealthPercent: 94,
    batteryHealthPercent: 92,
  );

  test('well maintained machine stays in zen or stable range', () {
    final snapshot = const HarmonyEngine().evaluate(baseBike, cleanRide);

    expect(snapshot.score, greaterThanOrEqualTo(90));
    expect(snapshot.level, HarmonyLevel.zen);
    expect(
      snapshot.insight,
      'Machine rhythm is clean. Maintain current ritual cadence.',
    );
  });

  test('overdue service window lowers score and drives service insight', () {
    final overdueBike = baseBike.copyWith(
      odometerKm: 17000,
      lastServiceKm: 9800,
    );
    final snapshot = const HarmonyEngine().evaluate(overdueBike, cleanRide);

    expect(snapshot.score, lessThan(80));
    expect(snapshot.insight, contains('Service window is overdue'));
  });

  test('ride observations influence the next harmony signal', () {
    const chainRide = RideSession(
      distanceKm: 18,
      durationMinutes: 27,
      averageSpeedKmh: 44,
      mood: 'Focused',
      mechanicalObservation: 'Chain felt dry on roll-off.',
    );
    final snapshot = const HarmonyEngine().evaluate(baseBike, chainRide);

    expect(snapshot.insight, contains('Chain signal'));
    expect(snapshot.score, lessThan(100));
  });
}
