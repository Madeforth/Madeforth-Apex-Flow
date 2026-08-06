import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:apexflow/core/design/apex_theme.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/core/services/purchases_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/features/shell/apex_app_shell.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:apexflow/features/splash/presentation/apex_splash_screen.dart';
import 'package:apexflow/garage/presentation/smart_park_alert_handler_screen.dart';
import 'package:apexflow/settings/application/theme_mode_provider.dart';
import 'package:apexflow/notifications/presentation/global_notification_overlay.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class GlobalThemeToggle extends ConsumerWidget {
  const GlobalThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(showThemeToggleProvider);
    if (!isVisible) return const SizedBox.shrink();

    final mode = ref.watch(themeModeProvider);
    IconData icon;
    if (mode == ThemeMode.light)
      icon = Icons.light_mode;
    else if (mode == ThemeMode.dark)
      icon = Icons.dark_mode;
    else
      icon = Icons.brightness_auto;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () =>
              ref.read(themeModeProvider.notifier).toggleTheme(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // All initialization wrapped in safety net — runApp() MUST always be reached
  try {
    await ApexKvStore.init().timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('ApexKvStore init error: $e');
  }

  try {
    await ApexNotificationService.instance.init().timeout(
      const Duration(seconds: 2),
    );
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  // Initialize Firebase with your project credentials
  try {
    FirebaseOptions options;
    if (!kIsWeb && Platform.isIOS) {
      options = const FirebaseOptions(
        apiKey: "AIzaSyDKgscj4FChM7qcdE0eSX3YMNz9CYH_aDk",
        appId: "1:29839209813:ios:d5ddb728b3ba9723796bdc",
        messagingSenderId: "29839209813",
        projectId: "apex-flow-7baea",
        storageBucket: "apex-flow-7baea.firebasestorage.app",
        iosBundleId: "com.apexflow.app",
        iosClientId:
            "29839209813-vn573s42fhmbm69ejf6lal4e6fi32ahk.apps.googleusercontent.com",
      );
    } else {
      options = const FirebaseOptions(
        apiKey: "AIzaSyDxClr18Z0pme38vsrs8KWpyIwKfurZ5eE",
        authDomain: "apex-flow-7baea.firebaseapp.com",
        projectId: "apex-flow-7baea",
        storageBucket: "apex-flow-7baea.firebasestorage.app",
        messagingSenderId: "29839209813",
        appId: "1:29839209813:web:e918a9629c631cdf796bdc",
        measurementId: "G-RBF4QRGFWR",
      );
    }

    await Firebase.initializeApp(
      options: options,
    ).timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    await PurchasesService.instance.init().timeout(const Duration(seconds: 3));
    final ownerId = await FirebaseService.instance
        .getOrCreateInstallationId()
        .timeout(const Duration(seconds: 3));
    await PurchasesService.instance.logIn(ownerId);
  } catch (e) {
    debugPrint('Purchases init error: $e');
  }

  runApp(const ApexFlowRoot());
}

class ApexFlowApp extends ConsumerWidget {
  const ApexFlowApp({super.key, this.showSplash = true});

  final bool showSplash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final locale = settings.locale;
    final strings = AppStrings(locale);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Apex Flow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ApexTheme.light,
      darkTheme: ApexTheme.dark,
      builder: (context, child) {
        return Stack(
          children: [if (child != null) child, GlobalNotificationOverlay()],
        );
      },
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: showSplash
          ? const ApexSplashScreen()
          : (settings.onboardingDone
                ? const ApexAppShell()
                : OnboardingScreen(strings: strings)),
      onGenerateRoute: (settingsRoute) {
        final name = settingsRoute.name;
        if (name != null &&
            (name.contains('/alert') || name.startsWith('apexflow://alert'))) {
          String riderTag = 'Rider';
          try {
            final uri = Uri.parse(name);
            riderTag =
                uri.queryParameters['rider'] ??
                uri.queryParameters['id'] ??
                'Rider';
          } catch (_) {}

          return MaterialPageRoute<void>(
            builder: (context) => SmartParkAlertHandlerScreen(
              riderTag: Uri.decodeComponent(riderTag),
              strings: strings,
            ),
          );
        }
        return null;
      },
    );
  }
}

class ApexFlowRoot extends StatelessWidget {
  const ApexFlowRoot({
    super.key,
    this.overrides = const [],
    this.showSplash = true,
  });

  final List<Override> overrides;
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: ApexFlowApp(showSplash: showSplash),
    );
  }
}
