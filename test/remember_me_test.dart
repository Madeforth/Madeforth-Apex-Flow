import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Remember Me Auto-Login Tests', () {
    test(
      'hydration preserves onboardingDone when remember_me is true',
      () async {
        SharedPreferences.setMockInitialValues({
          'app.onboarding_done.v1': true,
          'auth.remember_me': true,
          'app.migration_completed.v1': true,
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Trigger build and wait for async hydration to complete
        container.read(appSettingsProvider);

        // Multiple pump cycles to allow all async steps in _hydrate() to finish
        for (int i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
        }
        // Extra safety delay for Hive init fallback path
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(appSettingsProvider);
        expect(state.onboardingDone, isTrue);
      },
    );

    test(
      'hydration resets onboardingDone to false when remember_me is false',
      () async {
        SharedPreferences.setMockInitialValues({
          'app.onboarding_done.v1': true,
          'auth.remember_me': false,
          'app.migration_completed.v1': true,
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Trigger build and wait for async hydration to complete
        container.read(appSettingsProvider);

        // Multiple pump cycles to allow all async steps in _hydrate() to finish
        for (int i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
        }
        // Extra safety delay for Hive init fallback path
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final state = container.read(appSettingsProvider);
        expect(state.onboardingDone, isFalse);
      },
    );
  });
}
