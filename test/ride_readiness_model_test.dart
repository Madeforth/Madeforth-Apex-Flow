import 'package:apexflow/rituals/application/ride_readiness_model.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const clearWeather = WeatherSnapshot(
    locationLabel: 'Istanbul',
    condition: 'Clear',
    tempC: 22,
    windKph: 18,
    precipChancePercent: 10,
    observedAtIso: '2026-05-31T08:00:00.000Z',
  );

  const cleanCheck = DailyCheckEntry(
    isoDate: '2026-05-31',
    tiresOk: true,
    chainOk: true,
    oilOk: true,
    brakesOk: true,
    lightsOk: true,
    batteryOk: true,
    note: '',
  );

  test('clean weather and daily check lift readiness slightly', () {
    final snapshot = evaluateRideReadiness(
      harmonyScore: 82,
      weather: clearWeather,
      todayCheck: cleanCheck,
      now: DateTime.utc(2026, 5, 31, 10),
    );

    expect(snapshot.score, 86);
    expect(snapshot.factors.length, 3);
    expect(snapshot.factors.last.delta, 4);
  });

  test(
    'rain and missing daily check reduce readiness without collapsing it',
    () {
      const rain = WeatherSnapshot(
        locationLabel: 'Istanbul',
        condition: 'Rain',
        tempC: 12,
        windKph: 20,
        precipChancePercent: 75,
        observedAtIso: '2026-05-31T08:00:00.000Z',
      );
      final snapshot = evaluateRideReadiness(
        harmonyScore: 78,
        weather: rain,
        todayCheck: null,
        now: DateTime.utc(2026, 5, 31, 10),
      );

      expect(snapshot.score, 67);
      expect(snapshot.factors[1].delta, -8);
      expect(snapshot.factors[2].delta, -3);
    },
  );

  test('failed daily check items apply a stronger caution', () {
    const check = DailyCheckEntry(
      isoDate: '2026-05-31',
      tiresOk: false,
      chainOk: true,
      oilOk: true,
      brakesOk: false,
      lightsOk: true,
      batteryOk: true,
      note: 'Front tire and rear brake need attention.',
    );
    final snapshot = evaluateRideReadiness(
      harmonyScore: 74,
      weather: clearWeather,
      todayCheck: check,
      now: DateTime.utc(2026, 5, 31, 10),
    );

    expect(snapshot.score, 64);
    expect(snapshot.factors.last.delta, -10);
    expect(snapshot.factors.last.note, startsWith('2 check item'));
  });

  test('stale weather snapshot lowers readiness until refreshed', () {
    const staleWeather = WeatherSnapshot(
      locationLabel: 'Istanbul',
      condition: 'Clear',
      tempC: 22,
      windKph: 18,
      precipChancePercent: 10,
      observedAtIso: '2026-05-30T07:00:00.000Z',
    );

    final snapshot = evaluateRideReadiness(
      harmonyScore: 82,
      weather: staleWeather,
      todayCheck: cleanCheck,
      now: DateTime.utc(2026, 5, 31, 10),
    );

    expect(snapshot.score, 81);
    expect(snapshot.factors[1].delta, -5);
    expect(
      snapshot.factors[1].note,
      'Weather snapshot is stale. Refresh before heading out.',
    );
  });
}
