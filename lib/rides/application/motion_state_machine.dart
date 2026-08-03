import '../domain/speed_telemetry_models.dart';

class MotionStateMachine {
  MotionStateMachine({this.config = const TelemetryConfig()});

  final TelemetryConfig config;

  MotionState _currentState = MotionState.stopped;

  DateTime? _candidateStateStart;
  MotionState? _candidateState;

  Duration _movingDuration = Duration.zero;
  DateTime? _lastMovingTimestamp;

  MotionState get currentState => _currentState;
  Duration get movingDuration => _movingDuration;

  void update({
    required double filteredSpeedMps,
    required double uncertaintyMps,
    required DateTime timestamp,
  }) {
    final lowerBound = filteredSpeedMps - uncertaintyMps;
    final upperBound = filteredSpeedMps + uncertaintyMps;

    MotionState targetState = _currentState;

    if (lowerBound > config.motionEnterSpeedMps) {
      targetState = MotionState.moving;
    } else if (upperBound < config.motionExitSpeedMps) {
      targetState = MotionState.stopped;
    } else {
      targetState = MotionState.uncertain;
    }

    if (targetState != _currentState && targetState != MotionState.uncertain) {
      if (_candidateState != targetState) {
        _candidateState = targetState;
        _candidateStateStart = timestamp;
      } else if (_candidateStateStart != null) {
        final holdSeconds =
            timestamp.difference(_candidateStateStart!).inMilliseconds / 1000.0;
        final requiredHold = targetState == MotionState.moving
            ? config.motionEnterHoldSeconds
            : config.motionExitHoldSeconds;

        if (holdSeconds >= requiredHold) {
          _currentState = targetState;
          _candidateState = null;

          if (_currentState == MotionState.moving) {
            // Retroactive start correction
            _lastMovingTimestamp = _candidateStateStart;
          }
        }
      }
    } else {
      _candidateState = null;
      _candidateStateStart = null;
    }

    // Accumulate moving duration
    if (_currentState == MotionState.moving) {
      if (_lastMovingTimestamp != null) {
        final dt = timestamp.difference(_lastMovingTimestamp!);
        if (!dt.isNegative && dt.inSeconds <= 10) {
          _movingDuration += dt;
        }
      }
      _lastMovingTimestamp = timestamp;
    } else {
      _lastMovingTimestamp = null;
    }
  }

  void reset() {
    _currentState = MotionState.stopped;
    _candidateStateStart = null;
    _candidateState = null;
    _movingDuration = Duration.zero;
    _lastMovingTimestamp = null;
  }
}
