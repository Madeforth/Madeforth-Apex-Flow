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
      expect(state.motionDetected, isFalse);
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

      final state = container.read(rideDetectionProvider);
      expect(state.autoRideDetectionEnabled, isTrue);

      // Verify key was set in SharedPrefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('ride_detection.enabled.v1'), isTrue);
    },
  );

  test('dismissPrompt sets dismissed without touching other fields', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(rideDetectionProvider.notifier);
    await controller.setAutoRideDetectionEnabled(true);

    controller.dismissPrompt();
    final state = container.read(rideDetectionProvider);
    expect(state.dismissed, isTrue);
    expect(state.autoRideDetectionEnabled, isTrue);
  });

  test('disabling detection clears motionDetected and dismissed', () async {
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(rideDetectionProvider.notifier);
    await controller.setAutoRideDetectionEnabled(true);
    controller.dismissPrompt();
    await controller.setAutoRideDetectionEnabled(false);

    final state = container.read(rideDetectionProvider);
    expect(state.autoRideDetectionEnabled, isFalse);
    expect(state.motionDetected, isFalse);
    expect(state.dismissed, isFalse);
  });
}
