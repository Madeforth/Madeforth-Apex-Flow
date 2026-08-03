import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('garage hydration completes when no local state exists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(garageStateProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(garageStateProvider).isHydrating, isFalse);
  });

  test('garage mutations stay scoped to the selected motorcycle', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(garageStateProvider.notifier);

    await Future<void>.delayed(Duration.zero);
    controller.addMotorcycle(
      name: 'Night Vector',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
    );
    final first = container.read(garageStateProvider).activeBike;

    controller.addMotorcycle(
      name: 'Touring Base',
      model: 'Honda Transalp',
      odometerKm: 4200,
    );
    final second = container.read(garageStateProvider).activeBike;

    controller.setActiveMotorcycle(first);
    controller.updateComponentHealth(
      chainWearPercent: 44,
      tireWearPercent: 36,
      brakeWearPercent: 29,
      oilHealthPercent: 68,
      batteryHealthPercent: 91,
    );

    controller.setActiveMotorcycle(second);
    controller.addServiceRecord(
      type: 'diy',
      label: 'Break-in inspection',
      odometerKm: 4500,
      note: 'Initial service interval closed.',
    );

    final state = container.read(garageStateProvider);
    final updatedFirst = state.motorcycles.firstWhere((b) => b.id == first.id);
    final updatedSecond = state.motorcycles.firstWhere(
      (b) => b.id == second.id,
    );

    expect(updatedFirst.chainWearPercent, 44);
    expect(updatedFirst.lastServiceKm, 18420);
    expect(updatedSecond.chainWearPercent, -1);
    expect(updatedSecond.lastServiceKm, 4500);
    expect(state.activeBike.id, second.id);
  });

  test('archived motorcycles can be restored and selected by stable id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(garageStateProvider.notifier);

    controller.addMotorcycle(
      name: 'Night Vector',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
    );
    final first = container.read(garageStateProvider).activeBike;

    controller.addMotorcycle(
      name: 'Touring Base',
      model: 'Honda Transalp',
      odometerKm: 4200,
    );
    final second = container.read(garageStateProvider).activeBike;

    controller.toggleArchive(second);
    expect(container.read(garageStateProvider).activeBike.id, first.id);
    expect(
      container
          .read(garageStateProvider)
          .motorcycles
          .firstWhere((b) => b.id == second.id)
          .archived,
      isTrue,
    );

    controller.toggleArchive(second);
    controller.setActiveMotorcycle(second);

    final state = container.read(garageStateProvider);
    expect(state.activeBike.id, second.id);
    expect(state.activeBike.archived, isFalse);
  });

  test(
    'motorcycle service window exposes stable, due soon, and overdue states',
    () {
      const base = MotorcycleProfile(
        id: 'bike-test',
        name: 'Night Vector',
        model: 'Yamaha MT-07',
        odometerKm: 10000,
        lastServiceKm: 6000,
        chainWearPercent: 20,
        tireWearPercent: 20,
        brakeWearPercent: 20,
        oilHealthPercent: 90,
        batteryHealthPercent: 90,
        serviceIntervalKm: 6000,
      );

      expect(base.kmSinceService, 4000);
      expect(base.kmUntilService, 2000);
      expect(base.serviceWindowState, ServiceWindowState.stable);

      final dueSoon = base.copyWith(odometerKm: 11550);
      expect(dueSoon.kmUntilService, 450);
      expect(dueSoon.serviceWindowState, ServiceWindowState.dueSoon);

      final overdue = base.copyWith(odometerKm: 12220);
      expect(overdue.kmUntilService, -220);
      expect(overdue.serviceWindowState, ServiceWindowState.overdue);
    },
  );

  test('odometer sync only moves the active motorcycle forward', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(garageStateProvider.notifier);

    await Future<void>.delayed(Duration.zero);
    controller.addMotorcycle(
      name: 'Night Vector',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
    );
    final first = container.read(garageStateProvider).activeBike;

    controller.addMotorcycle(
      name: 'Touring Base',
      model: 'Honda Transalp',
      odometerKm: 4200,
    );
    final second = container.read(garageStateProvider).activeBike;

    controller.setActiveMotorcycle(first);
    controller.syncOdometer(18600);
    controller.syncOdometer(18300);

    final state = container.read(garageStateProvider);
    final updatedFirst = state.motorcycles.firstWhere(
      (bike) => bike.id == first.id,
    );
    final untouchedSecond = state.motorcycles.firstWhere(
      (bike) => bike.id == second.id,
    );

    expect(updatedFirst.odometerKm, 18600);
    expect(untouchedSecond.odometerKm, 4200);
    expect(state.activeBike.odometerKm, 18600);
  });
}
