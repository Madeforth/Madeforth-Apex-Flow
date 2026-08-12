import 'package:apexflow/rides/application/ride_location_service.dart';
import 'package:apexflow/rides/application/ride_telemetry_analyzer.dart';

/// Minimum distance for a ride to be kept, in kilometres.
const double kRideMinimumDistanceKm = 0.1;

/// Minimum average speed for a ride to be kept, in km/h.
const double kRideMinimumAverageSpeedKmh = 1.0;

/// The rounded, display-ready metrics of a finished ride plus the decision on
/// whether it is substantial enough to store.
class RideCompletionMetrics {
  const RideCompletionMetrics({
    required this.distanceKm,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.durationMinutes,
    required this.shouldDiscard,
    this.telemetry,
  });

  final double distanceKm;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final int durationMinutes;

  /// True when the ride must not be stored and the rider should be told it
  /// was too short or that no movement was detected.
  final bool shouldDiscard;

  final TelemetryAnalysis? telemetry;
}

/// Turns a raw [RideLocationResult] into the metrics every end-ride screen
/// needs, applying the shared rounding and the single discard rule.
///
/// Solo and group rides use the same rule on purpose: the same engine measures
/// them and the same record stores them, so a group ride was being thrown away
/// at 400 m while an identical solo ride was kept. The rule is an AND — a ride
/// is only discarded when it covered no real distance *and* was effectively
/// stationary — so a short but genuinely moving ride survives.
///
/// [allowWithoutGps] bypasses the discard rule for widget tests, which end a
/// ride without a location provider.
RideCompletionMetrics resolveRideCompletion(
  RideLocationResult result, {
  bool allowWithoutGps = false,
}) {
  final distanceKm = result.hasGpsData
      ? double.parse(result.distanceKm.toStringAsFixed(2))
      : 0.0;
  final averageSpeedKmh = result.hasGpsData
      ? double.parse(result.averageSpeedKmh.toStringAsFixed(1))
      : 0.0;
  final maxSpeedKmh = result.hasGpsData ? result.maxSpeedKmh : 0.0;
  final durationMinutes = result.hasGpsData ? result.activeDurationMinutes : 0;

  // Without GPS every metric above is zero, so this rule already covers the
  // "no location data at all" case.
  var shouldDiscard =
      distanceKm < kRideMinimumDistanceKm &&
      averageSpeedKmh < kRideMinimumAverageSpeedKmh;

  if (allowWithoutGps) {
    shouldDiscard = false;
  }

  return RideCompletionMetrics(
    distanceKm: distanceKm,
    averageSpeedKmh: averageSpeedKmh,
    maxSpeedKmh: maxSpeedKmh,
    durationMinutes: durationMinutes,
    shouldDiscard: shouldDiscard,
    telemetry: result.telemetry,
  );
}
