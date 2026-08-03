import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/features/dashboard/apex_dashboard_screen.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/fuel/presentation/fuel_screen.dart';
import 'package:apexflow/garage/presentation/garage_screen.dart';
import 'package:apexflow/garage/presentation/part_status_screen.dart';
import 'package:apexflow/insights/presentation/insights_screen.dart';
import 'package:apexflow/rides/presentation/rides_screen.dart';
import 'package:apexflow/settings/presentation/settings_screen.dart';
import 'package:apexflow/features/documents/presentation/document_vault_screen.dart';
import 'package:apexflow/profile/presentation/profile_hub_screen.dart';
import 'package:apexflow/notifications/presentation/notifications_screen.dart';
import 'package:apexflow/rides/presentation/group_ride_lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/shared/widgets/apex_limelight_navigation_bar.dart';

class ApexAppShell extends ConsumerStatefulWidget {
  const ApexAppShell({super.key});

  @override
  ConsumerState<ApexAppShell> createState() => _ApexAppShellState();
}

class _ApexAppShellState extends ConsumerState<ApexAppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appSettingsProvider).locale;
    final strings = AppStrings(locale);
    final compactNavigation = MediaQuery.sizeOf(context).width < 430;
    final pages = <Widget>[
      ApexDashboardScreen(
        strings: strings,
        onOpenRides: () => setState(() => _index = 3),
        onOpenGarage: () => setState(() => _index = 1),
        onOpenPartStatus: () => setState(() => _index = 10),
        onOpenServiceEntry: () {
          final state = ref.read(garageStateProvider);
          showServiceEntrySheet(context, ref, state, strings);
        },
        onOpenFuel: () => setState(() => _index = 5),
        onOpenInsights: () => setState(() => _index = 6),
        onOpenNotifications: () => setState(() => _index = 8),
      ),
      GarageScreen(
        strings: strings,
        onOpenPartStatus: () => setState(() => _index = 10),
        onOpenNotifications: () => setState(() => _index = 8),
      ),
      DocumentVaultScreen(strings: strings),
      RidesScreen(strings: strings),
      GroupRideLobbyScreen(strings: strings),
      FuelScreen(strings: strings),
      InsightsScreen(strings: strings),
      ProfileHubScreen(
        strings: strings,
        onOpenSettings: () => setState(() => _index = 9),
        onOpenNotifications: () => setState(() => _index = 8),
      ),
      NotificationsScreen(strings: strings),
      SettingsScreen(strings: strings),
      PartStatusScreen(
        strings: strings,
        onBack: () => setState(() => _index = 1), // Go back to garage
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Page content fills entire screen
          pages[_index],
          // Floating navbar overlaid at bottom — no rectangular divider
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: ApexLimelightNavigationBar(
              height: 56,
              compactNavigation: compactNavigation,
              selectedIndex: _index == 0
                  ? 0
                  : ((_index == 1 || _index == 2 || _index == 5 || _index == 10)
                        ? 1
                        : ((_index == 3 || _index == 4)
                              ? 2
                              : (_index == 6 ? 3 : 4))),
              onDestinationSelected: (index) {
                final targetIndex = index == 0
                    ? 0
                    : (index == 1 ? 1 : (index == 2 ? 3 : (index == 3 ? 6 : 7)));
                setState(() => _index = targetIndex);
              },
              destinations: [
                ApexLimelightDestination(
                  icon: Icons.space_dashboard_outlined,
                  selectedIcon: Icons.space_dashboard,
                  label: strings.navHome,
                ),
                ApexLimelightDestination(
                  icon: Icons.two_wheeler_outlined,
                  selectedIcon: Icons.two_wheeler,
                  label: strings.navGarage,
                ),
                ApexLimelightDestination(
                  icon: Icons.route_outlined,
                  selectedIcon: Icons.route,
                  label: strings.navRides,
                ),
                ApexLimelightDestination(
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                  label: strings.navInsights,
                ),
                ApexLimelightDestination(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: tInline(
                    strings.languageCode,
                    'Profil',
                    'Profile',
                    'Profil',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
