import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/rides/application/ride_detection_state.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/features/support/bug_report/presentation/bug_report_screen.dart';
import 'package:apexflow/features/support/bug_report/presentation/my_bug_reports_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final detection = ref.watch(rideDetectionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            Text(
              widget.strings.settingsTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Uygulama tercihleri ve sürücü profili.',
                'App preferences and rider profile.',
                'App-Einstellungen und Fahrerprofil.',
              ),
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // 0. Notifications settings card
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.strings.settingsNotificationTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.strings.settingsNotificationDesc,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.cyan,
                        side: BorderSide(color: context.colors.border),
                      ),
                      onPressed: () async {
                        final granted = await ApexNotificationService.instance
                            .requestPermissions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                granted
                                    ? widget
                                          .strings
                                          .settingsNotificationPermissionGranted
                                    : widget
                                          .strings
                                          .settingsNotificationPermissionDenied,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        size: 16,
                      ),
                      label: Text(
                        widget.strings.settingsNotificationPermissionBtn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // 1. Language Preferences
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.strings.language,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  ApexSegmentedToggle(
                    options: [
                      MapEntry('en', widget.strings.english),
                      MapEntry('tr', widget.strings.turkish),
                      MapEntry('de', widget.strings.german),
                    ],
                    selected: settings.locale.languageCode,
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setLocale(Locale(value));
                    },
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  Text(
                    settings.locale.languageCode == 'tr'
                        ? 'Seçili dile göre uygulama metinleri anında güncellenir.'
                        : (settings.locale.languageCode == 'de'
                              ? 'App-Sprache wird sofort aktualisiert.'
                              : 'App language changes take effect instantly.'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // 2. Unit System Preferences
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Birim Sistemi',
                      'Unit System',
                      'Einheitensystem',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Mesafe Birimi',
                      'Distance Unit',
                      'Entfernungseinheit',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ApexSegmentedToggle(
                    options: [
                      MapEntry(
                        'km',
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Kilometre (km)',
                          'Kilometers (km)',
                          'Kilometer (km)',
                        ),
                      ),
                      MapEntry(
                        'mi',
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Mil (mi)',
                          'Miles (mi)',
                          'Meilen (mi)',
                        ),
                      ),
                    ],
                    selected: settings.distanceUnit,
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setDistanceUnit(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hacim Birimi',
                      'Volume Unit',
                      'Volumeneinheit',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ApexSegmentedToggle(
                    options: [
                      MapEntry(
                        'liters',
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Litre (L)',
                          'Liters (L)',
                          'Liter (L)',
                        ),
                      ),
                      MapEntry(
                        'gallons',
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Galon (gal)',
                          'Gallons (gal)',
                          'Gallonen (gal)',
                        ),
                      ),
                    ],
                    selected: settings.volumeUnit,
                    onChanged: (value) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setVolumeUnit(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            const SizedBox(height: ApexSpacing.x2),

            // 4. Automatic Ride Detection Settings
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.strings.settingsAutoRideTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.strings.settingsAutoRideDesc,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  SwitchListTile(
                    title: Text(
                      widget.strings.settingsAutoRideToggle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.white,
                      ),
                    ),
                    value: detection.autoRideDetectionEnabled,
                    onChanged: (value) {
                      ref
                          .read(rideDetectionProvider.notifier)
                          .setAutoRideDetectionEnabled(value);
                    },
                    activeThumbColor: context.colors.cyan,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // 5. Support & Madeforth QA Bug Report
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Destek ve Madeforth QA',
                      'Support & Madeforth QA',
                      'Support & Madeforth QA',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Karşılaştığınız sorunları Madeforth QA ekibine doğrudan iletin ve durumunu takip edin.',
                      'Report issues directly to Madeforth QA and track status.',
                      'Melden Sie Probleme direkt an Madeforth QA und verfolgen Sie den Status.',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyBugReportsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list_alt_outlined, size: 18),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Raporlarım',
                              'My Reports',
                              'Meine Berichte',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.cyan,
                            side: BorderSide(color: context.colors.cyan),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BugReportScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.bug_report_outlined, size: 18),
                          label: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Hata Bildir',
                              'Report Bug',
                              'Fehler melden',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.cyan,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Danger Zone / Account Management Panel
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hesap Yönetimi & Gizlilik',
                      'Account Management & Privacy',
                      'Konto-Verwaltung & Datenschutz',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Hesabınızı ve Firebase üzerindeki tüm verilerinizi kalıcı olarak silebilirsiniz.',
                      'Permanently delete your account and all associated cloud data.',
                      'Löschen Sie Ihr Konto und alle Cloud-Daten dauerhaft.',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x2),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showDeleteAccountConfirmationDialog(context, ref),
                      icon: const Icon(Icons.delete_forever_outlined, size: 18),
                      label: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Hesabımı ve Tüm Verilerimi Sil',
                          'Delete My Account & All Data',
                          'Mein Konto & alle Daten löschen',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Discord Community Button
            Center(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://discord.gg/madeforth',
                  );
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Discord Topluluğumuza Katıl',
                    'Join Our Discord Community',
                    'Tritt unserer Discord-Community bei',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.cyan,
                  side: BorderSide(
                    color: context.colors.cyan.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: ApexSpacing.x3),
            Center(
              child: Opacity(
                opacity: 0.55,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/madeforth_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'v1.0.0 (Build 1)',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.textSecondary.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Hesabınızı Silmek İstediğinize Emin Misiniz?',
                    'Are You Sure You Want to Delete Your Account?',
                    'Möchten Sie Ihr Konto wirklich löschen?',
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Builder(
            builder: (context) {
              final activeEmail = FirebaseAuth.instance.currentUser?.email ?? '';
              return Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Bu işlem geri alınamaz! Şu an oturum açtığınız ($activeEmail) hesabınız, Firebase üzerindeki verileriniz, garajınızdaki motosikletler ve tüm sürüş geçmişiniz kalıcı olarak silinecektir.',
                  'This action cannot be undone! Your currently logged in account ($activeEmail), Firebase cloud data, garage motorcycles, and ride history will be permanently deleted.',
                  'Diese Aktion kann nicht rückgängig gemacht werden! Ihr derzeit angemeldetes Konto ($activeEmail), Ihre Cloud-Daten und Ihr Verlauf werden dauerhaft gelöscht.',
                ),
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                tInline(AppStrings.currentLanguageCode, 'Vazgeç', 'Cancel', 'Abbrechen'),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Hesabınız ve tüm verileriniz Firebase\'den siliniyor...',
                        'Deleting your account and data from Firebase...',
                        'Wird gelöscht...',
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                await ref.read(userProfileProvider.notifier).deleteAccount();
              },
              child: Text(
                tInline(AppStrings.currentLanguageCode, 'Kalıcı Olarak Sil', 'Delete Permanently', 'Dauerhaft löschen'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ApexSegmentedToggle extends StatelessWidget {
  const ApexSegmentedToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<MapEntry<String, String>> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 48,
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F2B), // Navbar background
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: options.map((entry) {
            final isSelected = entry.key == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  onChanged(entry.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.cyan.withValues(alpha: 0.14) // Liquid-like highlight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? context.colors.cyan // Selected tab text color
                            : context.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
