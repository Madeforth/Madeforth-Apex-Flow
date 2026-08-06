import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

class RideDetectionState {
  const RideDetectionState({
    required this.autoRideDetectionEnabled,
    required this.motionDetected,
    required this.dismissed,
  });

  final bool autoRideDetectionEnabled;
  final bool motionDetected;
  final bool dismissed;

  RideDetectionState copyWith({
    bool? autoRideDetectionEnabled,
    bool? motionDetected,
    bool? dismissed,
  }) {
    return RideDetectionState(
      autoRideDetectionEnabled:
          autoRideDetectionEnabled ?? this.autoRideDetectionEnabled,
      motionDetected: motionDetected ?? this.motionDetected,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

final rideDetectionProvider =
    NotifierProvider<RideDetectionController, RideDetectionState>(
      RideDetectionController.new,
    );

/// Foreground-only motion-based ride detection: watches the accelerometer
/// (no GPS, no Bluetooth) and flags `motionDetected` once vibration/movement
/// stays above a vehicle-like threshold for a sustained period. Only runs
/// while the app is open and no ride is already active — it does not run as
/// a background service, so it won't detect a ride starting while the app
/// is fully closed.
class RideDetectionController extends Notifier<RideDetectionState> {
  static const _storageKey = 'ride_detection.enabled.v1';

  // accelerometerEventStream includes gravity (~9.8 m/s^2 at rest on one
  // axis); sustained deviation from that baseline indicates real movement
  // rather than the phone just sitting still or being picked up briefly.
  static const _motionDeviationThreshold = 3.0;
  static const _sustainedDuration = Duration(seconds: 8);

  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime? _motionStartedAt;
  bool _mounted = true;

  @override
  RideDetectionState build() {
    ref.onDispose(() {
      _mounted = false;
      _accelSub?.cancel();
    });

    ref.listen(rideStateProvider, (previous, next) {
      if (previous?.isRideActive != next.isRideActive) {
        _syncListening();
      }
    });

    unawaited(_hydrate());

    return const RideDetectionState(
      autoRideDetectionEnabled: false,
      motionDetected: false,
      dismissed: false,
    );
  }

  Future<void> _hydrate() async {
    final enabled = await ApexKvStore.getBool(_storageKey) ?? false;
    if (!_mounted) return;
    state = state.copyWith(autoRideDetectionEnabled: enabled);
    _syncListening();
  }

  void _syncListening() {
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return;

    final shouldListen =
        state.autoRideDetectionEnabled &&
        !ref.read(rideStateProvider).isRideActive;
    if (shouldListen && _accelSub == null) {
      _motionStartedAt = null;
      try {
        _accelSub = accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 500),
        ).listen(_onAccelEvent, onError: (_) {});
      } catch (_) {
        // No accelerometer available on this platform/device — auto
        // detection simply stays off, nothing else in the app depends on it.
      }
    } else if (!shouldListen && _accelSub != null) {
      _accelSub?.cancel();
      _accelSub = null;
      _motionStartedAt = null;
      if (state.motionDetected) {
        state = state.copyWith(motionDetected: false);
      }
    }
  }

  void _onAccelEvent(AccelerometerEvent event) {
    if (!_mounted) return;
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final deviation = (magnitude - 9.8).abs();
    final now = DateTime.now();

    if (deviation > _motionDeviationThreshold) {
      _motionStartedAt ??= now;
      if (!state.motionDetected &&
          now.difference(_motionStartedAt!) >= _sustainedDuration) {
        state = state.copyWith(motionDetected: true);
      }
    } else {
      _motionStartedAt = null;
      if (state.motionDetected) {
        // Motion actually stopped — re-arm so a later ride start prompts
        // again even if this one was dismissed.
        state = state.copyWith(motionDetected: false, dismissed: false);
      }
    }
  }

  Future<void> setAutoRideDetectionEnabled(bool enabled) async {
    state = state.copyWith(
      autoRideDetectionEnabled: enabled,
      motionDetected: enabled ? state.motionDetected : false,
      dismissed: enabled ? state.dismissed : false,
    );
    await ApexKvStore.setBool(_storageKey, enabled);
    _syncListening();
  }

  void dismissPrompt() {
    state = state.copyWith(dismissed: true);
  }
}
