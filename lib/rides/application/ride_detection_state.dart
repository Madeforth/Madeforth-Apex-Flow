import 'dart:async';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideDetectionState {
  const RideDetectionState({
    required this.autoRideDetectionEnabled,
    required this.mockBluetoothConnected,
    required this.mockMotionDetected,
    required this.dismissed,
  });

  final bool autoRideDetectionEnabled;
  final bool mockBluetoothConnected;
  final bool mockMotionDetected;
  final bool dismissed;

  RideDetectionState copyWith({
    bool? autoRideDetectionEnabled,
    bool? mockBluetoothConnected,
    bool? mockMotionDetected,
    bool? dismissed,
  }) {
    return RideDetectionState(
      autoRideDetectionEnabled:
          autoRideDetectionEnabled ?? this.autoRideDetectionEnabled,
      mockBluetoothConnected:
          mockBluetoothConnected ?? this.mockBluetoothConnected,
      mockMotionDetected: mockMotionDetected ?? this.mockMotionDetected,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

final rideDetectionProvider =
    NotifierProvider<RideDetectionController, RideDetectionState>(
      RideDetectionController.new,
    );

class RideDetectionController extends Notifier<RideDetectionState> {
  static const _storageKey = 'ride_detection.enabled.v1';

  bool _mounted = true;

  @override
  RideDetectionState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    return const RideDetectionState(
      autoRideDetectionEnabled: false,
      mockBluetoothConnected: false,
      mockMotionDetected: false,
      dismissed: false,
    );
  }

  Future<void> _hydrate() async {
    final enabled = await ApexKvStore.getBool(_storageKey) ?? false;
    if (!_mounted) return;
    state = state.copyWith(autoRideDetectionEnabled: enabled);
  }

  Future<void> setAutoRideDetectionEnabled(bool enabled) async {
    state = state.copyWith(
      autoRideDetectionEnabled: enabled,
      dismissed: enabled ? state.dismissed : false,
    );
    await ApexKvStore.setBool(_storageKey, enabled);
  }

  void setMockBluetoothConnected(bool connected) {
    state = state.copyWith(
      mockBluetoothConnected: connected,
      dismissed: connected ? false : state.dismissed,
    );
  }

  void setMockMotionDetected(bool detected) {
    state = state.copyWith(
      mockMotionDetected: detected,
      dismissed: detected ? false : state.dismissed,
    );
  }

  void dismissPrompt() {
    state = state.copyWith(dismissed: true);
  }

  void resetPrompt() {
    state = state.copyWith(dismissed: false);
  }
}
