import 'dart:math' as math;
import '../domain/speed_telemetry_models.dart';

class SpeedKalmanFilter {
  SpeedKalmanFilter({this.config = const TelemetryConfig()}) {
    reset();
  }

  final TelemetryConfig config;

  double _v = 0.0; // velocity m/s
  double _a = 0.0; // acceleration m/s^2

  double _p11 = 4.0;
  double _p12 = 0.0;
  double _p21 = 0.0;
  double _p22 = 4.0;

  DateTime? _lastTimestamp;
  int _consecutiveNisRejections = 0;
  final List<double> _rejectionHistory = [];

  double get currentSpeedMps => _v;
  double get currentAccelerationMps2 => _a;
  double get speedUncertaintyMps => math.sqrt(math.max(0.1, _p11));
  DateTime? get lastTimestamp => _lastTimestamp;

  void reset({double initialSpeedMps = 0.0, DateTime? timestamp}) {
    _v = math.max(0.0, initialSpeedMps);
    _a = 0.0;
    _p11 = 4.0;
    _p12 = 0.0;
    _p21 = 0.0;
    _p22 = 4.0;
    _lastTimestamp = timestamp;
    _consecutiveNisRejections = 0;
    _rejectionHistory.clear();
  }

  /// Processes a new measurement z (in m/s) with measurement variance R (m^2/s^2).
  /// Returns a tuple containing [filteredSpeedMps, uncertaintyMps, nis, accepted].
  ({double speedMps, double uncertaintyMps, double nis, bool accepted}) update({
    required double measurementMps,
    required double varianceR,
    required DateTime timestamp,
  }) {
    if (_lastTimestamp == null) {
      reset(initialSpeedMps: measurementMps, timestamp: timestamp);
      return (
        speedMps: _v,
        uncertaintyMps: speedUncertaintyMps,
        nis: 0.0,
        accepted: true,
      );
    }

    final dt = timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;
    if (dt <= 0) {
      return (
        speedMps: _v,
        uncertaintyMps: speedUncertaintyMps,
        nis: 0.0,
        accepted: false,
      );
    }

    // 1. Predict Step
    final vPred = _v + _a * dt;
    final aPred = _a;

    const qProcess = 1.0;
    final dt2 = dt * dt;
    final dt3 = dt2 * dt;
    final dt4 = dt3 * dt;

    final q11 = qProcess * (dt4 / 4.0);
    final q12 = qProcess * (dt3 / 2.0);
    final q21 = q12;
    final q22 = qProcess * dt2;

    // P_pred = F * P * F^T + Q
    final p11Pred = _p11 + dt * (_p21 + _p12 + dt * _p22) + q11;
    final p12Pred = _p12 + dt * _p22 + q12;
    final p21Pred = _p21 + dt * _p22 + q21;
    final p22Pred = _p22 + q22;

    // 2. Innovation & NIS Gate Check
    final y = measurementMps - vPred; // innovation
    final S = p11Pred + varianceR; // innovation covariance
    final nis = S > 0 ? (y * y) / S : 0.0;

    // Check NIS Outlier Gate (NIS > 16.0 is a 4-sigma outlier)
    if (nis > config.normalizedInnovationGateSquared) {
      _consecutiveNisRejections++;
      _rejectionHistory.add(measurementMps);

      // Recapture Rule: If 3 consecutive measurements are consistent with each other,
      // recalibrate to the new speed level (real rapid acceleration/braking).
      if (_consecutiveNisRejections >= 3 && _rejectionHistory.length >= 3) {
        final recent = _rejectionHistory.sublist(_rejectionHistory.length - 3);
        final maxDiff =
            (recent[0] - recent[1]).abs() + (recent[1] - recent[2]).abs();

        if (maxDiff < 5.0) {
          // Consistent new speed level
          reset(initialSpeedMps: measurementMps, timestamp: timestamp);
          return (
            speedMps: _v,
            uncertaintyMps: speedUncertaintyMps,
            nis: nis,
            accepted: true,
          );
        }
      }

      // Reject single outlier spike, update predict state only
      _v = math.max(0.0, vPred);
      _a = aPred;
      _p11 = p11Pred;
      _p12 = p12Pred;
      _p21 = p21Pred;
      _p22 = p22Pred;
      _lastTimestamp = timestamp;

      return (
        speedMps: _v,
        uncertaintyMps: speedUncertaintyMps,
        nis: nis,
        accepted: false,
      );
    }

    // 3. Update Step (Accepted Measurement)
    _consecutiveNisRejections = 0;
    _rejectionHistory.clear();

    final k1 = p11Pred / S;
    final k2 = p21Pred / S;

    _v = math.max(0.0, vPred + k1 * y); // Physical lower bound v >= 0
    _a = aPred + k2 * y;

    _p11 = math.max(0.05, p11Pred - k1 * p11Pred);
    _p12 = p12Pred - k1 * p12Pred;
    _p21 = p21Pred - k2 * p11Pred;
    _p22 = math.max(0.05, p22Pred - k2 * p12Pred);

    _lastTimestamp = timestamp;

    return (
      speedMps: _v,
      uncertaintyMps: speedUncertaintyMps,
      nis: nis,
      accepted: true,
    );
  }
}
