import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('daily check updates the same day instead of duplicating it', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(ritualsStateProvider.notifier);

    container.read(ritualsStateProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    controller.addDailyCheck(
      const DailyCheckEntry(
        isoDate: '2026-06-03',
        tiresOk: true,
        chainOk: true,
        oilOk: true,
        brakesOk: true,
        lightsOk: true,
        batteryOk: true,
        note: 'Initial morning pass.',
        loggedAtIso: '2026-06-03T06:30:00.000Z',
      ),
    );

    controller.addDailyCheck(
      const DailyCheckEntry(
        isoDate: '2026-06-03',
        tiresOk: false,
        chainOk: true,
        oilOk: true,
        brakesOk: true,
        lightsOk: true,
        batteryOk: true,
        note: 'Front tire wants follow-up.',
        loggedAtIso: '2026-06-03T08:15:00.000Z',
      ),
    );

    final state = container.read(ritualsStateProvider);
    expect(state.dailyChecks.length, 1);
    expect(state.dailyChecks.single.note, 'Front tire wants follow-up.');
    expect(state.dailyChecks.single.tiresOk, isFalse);
    expect(state.dailyChecks.single.loggedAtIso, '2026-06-03T08:15:00.000Z');
  });
}
