import 'package:apexflow/rituals/application/rituals_state.dart';

class RideReadinessSnapshot {
  const RideReadinessSnapshot({required this.score, required this.factors});

  final int score;
  final List<ReadinessFactor> factors;
}

class ReadinessFactor {
  const ReadinessFactor({
    required this.label,
    required this.delta,
    required this.note,
  });

  final String label;
  final int delta;
  final String note;
}

enum WeatherFreshness { fresh, aging, stale }

RideReadinessSnapshot evaluateRideReadiness({
  required int harmonyScore,
  required WeatherSnapshot weather,
  required DailyCheckEntry? todayCheck,
  DateTime? now,
}) {
  final timestamp = now ?? DateTime.now();
  final factors = <ReadinessFactor>[
    ReadinessFactor(
      label: 'Harmony',
      delta: 0,
      note: harmonyScore >= 70
          ? 'Machine state is within riding range.'
          : 'Machine state asks for a calmer route.',
    ),
  ];

  var adjustment = 0;
  final weatherDelta = _weatherDelta(weather, timestamp);
  adjustment += weatherDelta;
  factors.add(
    ReadinessFactor(
      label: 'Weather',
      delta: weatherDelta,
      note: _weatherNote(weather, timestamp),
    ),
  );

  final checkDelta = _dailyCheckDelta(todayCheck);
  adjustment += checkDelta;
  factors.add(
    ReadinessFactor(
      label: 'Daily check',
      delta: checkDelta,
      note: _dailyCheckNote(todayCheck),
    ),
  );

  return RideReadinessSnapshot(
    score: (harmonyScore + adjustment).clamp(0, 100),
    factors: factors,
  );
}

double weatherFreshnessRatio(WeatherSnapshot weather, {DateTime? now}) {
  final observedAt = weather.observedAt;
  if (observedAt == null) return 1.0;
  final ageHours =
      (now ?? DateTime.now()).difference(observedAt).inMinutes / 60.0;
  if (ageHours <= 2.0) return 1.0;
  if (ageHours <= 4.0)
    return 1.0 - (0.25 * ((ageHours - 2.0) / 2.0)); // 1.0 -> 0.75
  if (ageHours <= 6.0)
    return 0.75 - (0.35 * ((ageHours - 4.0) / 2.0)); // 0.75 -> 0.40
  return 0.0; // > 6 hours: stale weather suspended
}

WeatherFreshness weatherFreshnessFor(WeatherSnapshot weather, {DateTime? now}) {
  final ratio = weatherFreshnessRatio(weather, now: now);
  if (ratio >= 0.75) return WeatherFreshness.fresh;
  if (ratio > 0.0) return WeatherFreshness.aging;
  return WeatherFreshness.stale;
}

int _weatherDelta(WeatherSnapshot weather, DateTime now) {
  var delta = 0;
  if (weather.precipChancePercent >= 60) {
    delta -= 8;
  } else if (weather.precipChancePercent >= 35) {
    delta -= 4;
  }
  if (weather.windKph >= 40) {
    delta -= 6;
  } else if (weather.windKph >= 28) {
    delta -= 3;
  }
  if (weather.tempC <= 3 || weather.tempC >= 36) {
    delta -= 4;
  }
  switch (weatherFreshnessFor(weather, now: now)) {
    case WeatherFreshness.fresh:
      break;
    case WeatherFreshness.aging:
      delta -= 2;
      break;
    case WeatherFreshness.stale:
      delta -= 5;
      break;
  }
  return delta;
}

String _weatherNote(WeatherSnapshot weather, DateTime now) {
  switch (weatherFreshnessFor(weather, now: now)) {
    case WeatherFreshness.stale:
      return 'Weather snapshot is stale. Refresh before heading out.';
    case WeatherFreshness.aging:
      return 'Weather snapshot is aging. Refresh if the route may stretch.';
    case WeatherFreshness.fresh:
      break;
  }
  if (weather.precipChancePercent >= 60) {
    return 'Rain risk is high. Keep the route short and visible.';
  }
  if (weather.windKph >= 40) {
    return 'Wind is strong. Avoid exposed roads.';
  }
  if (weather.tempC <= 3 || weather.tempC >= 36) {
    return 'Temperature is outside the comfort window.';
  }
  return 'Weather is inside the normal riding window.';
}

int _dailyCheckDelta(DailyCheckEntry? check) {
  if (check == null) {
    return -3;
  }
  final failed = [
    check.tiresOk,
    check.chainOk,
    check.oilOk,
    check.brakesOk,
    check.lightsOk,
  ].where((ok) => !ok).length;
  if (failed == 0) {
    return 4;
  }
  return -(failed * 5).clamp(5, 20);
}

String _dailyCheckNote(DailyCheckEntry? check) {
  if (check == null) {
    return 'Daily machine check has not been logged yet.';
  }
  final failed = [
    check.tiresOk,
    check.chainOk,
    check.oilOk,
    check.brakesOk,
    check.lightsOk,
  ].where((ok) => !ok).length;
  if (failed == 0) {
    return 'Daily check is clean.';
  }
  return '$failed check item needs attention before riding.';
}
