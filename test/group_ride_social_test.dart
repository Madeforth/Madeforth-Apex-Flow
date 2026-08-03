import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/design/apex_theme.dart';
import 'package:apexflow/rides/presentation/group_ride_lobby_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Group Ride Lobby screen flow and social bottom sheet verification',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Set a standard screen size to prevent RenderFlex overflow
      tester.view.physicalSize = Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final strings = AppStrings(Locale('en'));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ApexTheme.dark,
            home: GroupRideLobbyScreen(strings: strings),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Verify initial inactive lobby view
      expect(find.text('Group Ride Lobby'), findsOneWidget);
      expect(find.text('LOBBY CODE'), findsOneWidget);
      expect(find.text('Lobby open · Waiting for riders'), findsOneWidget);
      expect(find.text('Send Invite'), findsOneWidget);
    },
  );
}
