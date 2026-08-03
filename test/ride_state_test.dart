import 'package:apexflow/rides/application/ride_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ride hydration completes when an active ride has no sessions yet',
    () async {
      SharedPreferences.setMockInitialValues({
        'rides.is_active': true,
        'rides.active_mood': 'Focused',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rideStateProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(rideStateProvider);
      expect(state.isHydrating, isFalse);
      expect(state.isRideActive, isTrue);
      expect(state.activeMood, 'Focused');
      expect(state.sessions, isEmpty);
    },
  );
}
