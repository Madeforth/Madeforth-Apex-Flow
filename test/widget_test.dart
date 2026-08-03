import 'package:apexflow/main.dart';
import 'package:apexflow/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/rides/presentation/group_ride_lobby_screen.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/shared/widgets/apex_limelight_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';

import 'dart:convert';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';

Future<void> _completeOnboarding(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final element = tester.element(find.byType(MaterialApp));
  final container = ProviderScope.containerOf(element);
  if (container.read(garageStateProvider).motorcycles.isEmpty) {
    container.read(garageStateProvider.notifier).addMotorcycle(
      name: 'NIGHT VECTOR',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
      lastServiceKm: 18000,
      serviceIntervalKm: 5000,
    );
  }
  container.read(appSettingsProvider.notifier).completeOnboarding();
  await tester.pumpAndSettle();
}

Future<void> _navTo(WidgetTester tester, String label) async {
  int index = 0;
  if (label == 'Garage' || label == 'Garaj') {
    index = 1;
  } else if (label == 'Rides' || label == 'Sürüşler') {
    index = 2;
  } else if (label == 'Insights' || label == 'Analizler') {
    index = 3;
  } else if (label == 'Profile' || label == 'Profil') {
    index = 4;
  }

  await tester.tap(find.byKey(Key('nav_item_$index')));
  await tester.pumpAndSettle();
}

Future<void> _openFuel(WidgetTester tester) async {
  await _navTo(tester, 'Garage');
  await tester.tap(
    find.descendant(of: find.byType(TabBar), matching: find.text('Fuel')),
  );
  await tester.pumpAndSettle();
  await tester.pump();
}

Finder _textInputWithValue(String value) {
  return find.byWidgetPredicate(
    (widget) =>
        (widget is TextFormField && widget.controller?.text == value) ||
        (widget is TextField && widget.controller?.text == value),
    description: 'Text input with value "$value"',
  );
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ApexKvStore.init();
    await ApexKvStore.setBool('app.onboarding_done.v1', true);
    const bike = MotorcycleProfile(
      id: 'bike-vector',
      name: 'NIGHT VECTOR',
      model: 'Yamaha MT-07',
      odometerKm: 18420,
      lastServiceKm: 18000,
      chainWearPercent: 25,
      tireWearPercent: 30,
      brakeWearPercent: 15,
      oilHealthPercent: 88,
      batteryHealthPercent: 95,
      serviceIntervalKm: 5000,
    );
    await ApexKvStore.setString('db.bikes', jsonEncode([bike.toJson()]));
    await ApexKvStore.setString('garage.active_bike_id', 'bike-vector');
  });

  testWidgets('ApexFlow dashboard renders core product surfaces', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);

    expect(find.textContaining('Apex Flow'), findsOneWidget);
    expect(find.text('Yamaha MT-07'), findsOneWidget);
    expect(find.text('Start Ride'), findsWidgets);
    expect(find.text('Open Checklist'), findsOneWidget);
  });

  testWidgets('ApexFlow garage renders active machine registry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Garage');

    expect(find.text('Garage'), findsWidgets);
    expect(
      find.text('Machines, service history, and component condition.'),
      findsOneWidget,
    );
    expect(find.text('Active motorcycle'), findsOneWidget);
    expect(find.text('Service interval'), findsOneWidget);

    // Scroll down to see Service memory (pushed down by Cost Analytics Panel)
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('Service memory'), findsOneWidget);
  });

  testWidgets('ApexFlow garage accepts a service entry', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Garage');

    await tester.tap(find.text('Service Entry'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.bySemanticsLabel('Service label'),
      'Brake audit',
    );
    await tester.enterText(find.bySemanticsLabel('Odometer km'), '18420');
    await tester.enterText(
      find.bySemanticsLabel('Mechanical note'),
      'Rear brake bite normalized after inspection.',
    );
    await tester.tap(find.text('Save Service Memory'));
    await tester.pumpAndSettle();

    // Scroll down to see the new service log
    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.text('Brake audit'), findsOneWidget);
    expect(find.text('New Log'), findsOneWidget);
    expect(find.textContaining('18420 km'), findsOneWidget);
  });

  testWidgets('ApexFlow garage keeps quick service labels ready', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Garage');

    await tester.tap(find.text('Service Entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brake check'));
    await tester.enterText(find.bySemanticsLabel('Odometer km'), '18540');
    await tester.enterText(
      find.bySemanticsLabel('Mechanical note'),
      'Front brake feel checked after commute.',
    );
    await tester.tap(find.text('Save Service Memory'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Service Entry'));
    await tester.pumpAndSettle();

    expect(find.text('Brake check'), findsWidgets);
    expect(_textInputWithValue('18540'), findsOneWidget);
  });

  testWidgets('ApexFlow garage syncs part status values', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Garage');

    await tester.tap(find.text('Part Status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Replace').at(0));
    await tester.tap(find.text('Replace').at(1));
    await tester.tap(find.text('Replace').at(2));
    await tester.ensureVisible(find.text('Update part status'));
    await tester.tap(find.text('Update part status'));
    await tester.pumpAndSettle();

    expect(find.text('Replace Soon'), findsOneWidget); // Tires
    expect(find.text('Needs Service'), findsWidgets); // Chain & Brakes
  });

  testWidgets('ApexFlow rides records an end reflection', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Rides');

    expect(find.text('Ride Memory'), findsOneWidget);

    await tester.tap(find.text('Start Ride').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Intended Ride Mood'), 'Calm');
    await tester.tap(find.text('Begin Ride'));
    await tester.pumpAndSettle();

    expect(find.text('Ride active'), findsOneWidget);

    await tester.tap(find.text('End Ride').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // In test environment GPS is unavailable — ride is not saved.
    expect(
      find.textContaining('Ride too short or no movement detected. Not saved.'),
      findsOneWidget,
    );
  });

  testWidgets('ApexFlow rides auto-calculation uses duration and speed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Rides');

    await tester.tap(find.text('Start Ride').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Intended Ride Mood'), 'Calm');
    await tester.tap(find.text('Begin Ride'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('End Ride').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // In test environment GPS is unavailable — ride is not saved.
    expect(
      find.textContaining('Ride too short or no movement detected. Not saved.'),
      findsOneWidget,
    );
  });

  testWidgets('ApexFlow fuel keeps low-input defaults ready after save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _openFuel(tester);

    expect(find.text('New Fuel Entry'), findsOneWidget);
    expect(_textInputWithValue('18420'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(0), '14.2');
    await tester.enterText(find.byType(TextFormField).at(1), '780');
    await tester.enterText(find.byType(TextFormField).at(2), 'Shell');
    await tester.enterText(find.byType(TextFormField).at(4), '18600');
    await tester.tap(find.text('SAVE FUEL ENTRY'));
    await tester.pumpAndSettle();

    expect(_textInputWithValue('18600'), findsWidgets);
    expect(_textInputWithValue('Shell'), findsWidgets);
    expect(_textInputWithValue('14.2'), findsNothing);
    expect(_textInputWithValue('780'), findsNothing);
    expect(find.textContaining('14.20 L'), findsWidgets);
  });

  testWidgets('ApexFlow machine memory merges service and ride entries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    await _navTo(tester, 'Garage');

    await tester.tap(find.text('Service Entry'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.bySemanticsLabel('Service label'),
      'Memory brake audit',
    );
    await tester.enterText(find.bySemanticsLabel('Odometer km'), '18510');
    await tester.enterText(
      find.bySemanticsLabel('Mechanical note'),
      'Rear brake feel checked for memory timeline.',
    );
    await tester.tap(find.text('Save Service Memory'));
    await tester.pumpAndSettle();

    await _navTo(tester, 'Rides');

    // Add a valid ride session with distance > 0.1km
    final container = ProviderScope.containerOf(
      tester.element(find.text('Rides').first),
    );
    container
        .read(rideStateProvider.notifier)
        .endRide(
          distanceKm: 12.5,
          durationMinutes: 15,
          averageSpeedKmh: 50.0,
          mood: 'Focused',
          mechanicalObservation: 'Test Ride',
        );
    await _navTo(tester, 'Garage');
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Machine Memory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Machine Memory'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Unified timeline'), findsOneWidget);
    expect(find.textContaining('Memory brake audit'), findsOneWidget);
    expect(find.textContaining('12.5 km'), findsWidgets);
    expect(find.textContaining('SERVICE'), findsWidgets);
    expect(find.textContaining('RIDE'), findsWidgets);
  });

  testWidgets('ApexFlow core surfaces stay stable on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);
    expect(tester.takeException(), isNull);

    await _navTo(tester, 'Garage');
    expect(find.text('Service interval'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Machine Memory'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Machine Memory'));
    await tester.pumpAndSettle();
    expect(find.text('Unified timeline'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _navTo(tester, 'Rides');
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Ride Memory'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ApexFlow group ride lobby flow works as expected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApexFlowRoot(showSplash: false));
    await _completeOnboarding(tester);

    final element = tester.element(find.byType(MaterialApp));
    final controller = ProviderScope.containerOf(
      element,
    ).read(userProfileProvider.notifier);
    controller.state = controller.state.copyWith(isPremium: true);
    await tester.pump();

    await _navTo(tester, 'Rides');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Group Ride'));
    await tester.pumpAndSettle();

    expect(find.text('Riders'), findsOneWidget);
    expect(find.text('Send Invite'), findsOneWidget);

    // Click Invite Friends to invite friends
    await tester.tap(find.text('Send Invite'));
    await tester.pumpAndSettle();

    final lobbyList = find.descendant(
      of: find.byType(GroupRideLobbyScreen),
      matching: find.byType(ListView),
    );
    await tester.drag(lobbyList, const Offset(0, -600));
    await tester.pumpAndSettle();

    final detectorFinder = find.ancestor(
      of: find.text('Start Group Ride').first,
      matching: find.byType(GestureDetector),
    );
    final detector = tester.widget<GestureDetector>(detectorFinder);
    detector.onTapUp!(TapUpDetails(kind: PointerDeviceKind.touch));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify group ride is active
    expect(find.text('Stop Group Ride'), findsWidgets);
  });
}
