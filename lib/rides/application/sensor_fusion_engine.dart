import 'dart:math' as math;

/// SensorFusionEngine implements a Complementary Filter to combine
/// high-frequency Gyroscope data (susceptible to drift) with
/// low-frequency GPS kinematic lean angle (accurate but slow).
class SensorFusionEngine {
  SensorFusionEngine({this.alpha = 0.98, this.mountingOrientationOffset = 0.0});

  /// The alpha coefficient for the Complementary Filter.
  /// Typically 0.98, meaning 98% trust in Gyro (short term) and 2% trust in GPS (long term).
  final double alpha;

  /// The zero-calibration offset applied to correct the phone's mounting angle on the handlebars.
  double mountingOrientationOffset;

  double _currentFusedAngle = 0.0;
  DateTime? _lastGyroTime;

  /// Retrieves the current fused lean angle (in degrees).
  double get currentLeanAngle => _currentFusedAngle;

  /// Calibrates the zero point of the gyroscope based on the current resting angle.
  /// Call this when the motorcycle is perfectly upright before a ride.
  void calibrateZeroOffset(double restingRollAngle) {
    mountingOrientationOffset = restingRollAngle;
    _currentFusedAngle = 0.0;
  }

  /// Updates the fused lean angle using incoming raw gyroscope data (roll rate).
  /// [gyroRollRate] must be in degrees per second.
  /// [timestamp] is the exact time the sensor reading was taken.
  void updateWithGyro(double gyroRollRate, DateTime timestamp) {
    if (_lastGyroTime == null) {
      _lastGyroTime = timestamp;
      return;
    }

    final dt = timestamp.difference(_lastGyroTime!).inMilliseconds / 1000.0;
    if (dt <= 0) return;

    // Integrate gyro data over time: newAngle = oldAngle + (rate * dt)
    final gyroDelta = gyroRollRate * dt;

    // We only integrate; GPS will correct the absolute value
    _currentFusedAngle += gyroDelta;

    _lastGyroTime = timestamp;
  }

  /// Updates the fused lean angle with a new absolute GPS reading.
  /// [gpsLeanAngle] must be the calculated kinematic lean angle in degrees.
  /// This corrects the gyroscope drift.
  void updateWithGPS(double gpsLeanAngle) {
    // Complementary Filter:
    // Fused = alpha * (Fused from Gyro Integration) + (1 - alpha) * Absolute GPS Angle
    _currentFusedAngle =
        (alpha * _currentFusedAngle) + ((1.0 - alpha) * gpsLeanAngle);
  }

  /// Calculates the GPS Kinematic Lean Angle based on speed and heading rate.
  /// [speedMs] is GPS speed in meters per second.
  /// [headingRateRadS] is the rate of heading change in radians per second.
  static double calculateGpsKinematicAngle(
    double speedMs,
    double headingRateRadS,
  ) {
    const double g = 9.81; // Gravity m/s^2

    // Ignore noise at very low speeds (< 20 km/h approx 5.5 m/s)
    if (speedMs < 5.5) return 0.0;

    // ay = v * omega
    final ay = (speedMs * headingRateRadS).abs();

    // theta = arctan(ay / g)
    final leanRad = math.atan(ay / g);
    final leanDeg = leanRad * (180.0 / math.pi);

    return leanDeg.isNaN || leanDeg.isInfinite ? 0.0 : leanDeg;
  }
}
