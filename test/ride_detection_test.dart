import 'package:apexflow/rides/application/ride_detection_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ride detection hydration completes when no local state exists',
    () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rideDetectionProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(rideDetectionProvider);
      expect(state.autoRideDetectionEnabled, isFalse);
      expect(state.mockBluetoothConnected, isFalse);
      expect(state.mockMotionDetected, isFalse);
      expect(state.dismissed, isFalse);
    },
  );

  test(
    'toggling autoRideDetectionEnabled persists and updates state',
    () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(rideDetectionProvider.notifier);
      await controller.setAutoRideDetectionEnabled(true);

      var state = container.read(rideDetectionProvider);
      expect(state.autoRideDetectionEnabled, isTrue);

      // Verify key was set in SharedPrefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ride_detection.enabled.v1'), isTrue);
    },
  );

  test(
    'simulation triggers and prompt dismissal update state correctly',
    () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(rideDetectionProvider.notifier);
      controller.setMockBluetoothConnected(true);

      var state = container.read(rideDetectionProvider);
      expect(state.mockBluetoothConnected, isTrue);
      expect(state.dismissed, isFalse);

      controller.dismissPrompt();
      state = container.read(rideDetectionProvider);
      expect(state.dismissed, isTrue);

      // Activating motion should reset dismissed status
      controller.setMockMotionDetected(true);
      state = container.read(rideDetectionProvider);
      expect(state.mockMotionDetected, isTrue);
      expect(state.dismissed, isFalse);
    },
  );
}
