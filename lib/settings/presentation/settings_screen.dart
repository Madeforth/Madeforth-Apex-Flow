import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/shared/design/slate_palette.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
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
  bool _isSavingFriendVisibility = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ApexSpacing.x2,
            ApexSpacing.x2,
            ApexSpacing.x2,
            ApexSpacing.navBarClearance,
          ),
          children: [
            Text(
              widget.strings.settingsTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Uygulama tercihleri ve sürücü profili.',
                'App preferences and rider profile.',
                'App-Einstellungen und Fahrerprofil.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

            // 0. Notifications settings card
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.strings.settingsNotificationTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.strings.settingsNotificationDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.textSecondary,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Arkadaşlarla Bilgi Paylaşımı',
                      'Information Shared with Friends',
                      'Mit Freunden geteilte Informationen',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Açtığınız bilgiler yalnızca Apex Flow arkadaşlarınıza gösterilir. E-postanız paylaşılmaz.',
                      'Enabled information is shown only to your Apex Flow friends. Your email is never shared.',
                      'Aktivierte Informationen werden nur Ihren Apex-Flow-Freunden gezeigt. Ihre E-Mail-Adresse wird nie geteilt.',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  _FriendVisibilitySwitch(
                    icon: Icons.bloodtype_outlined,
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Kan grubu',
                      'Blood type',
                      'Blutgruppe',
                    ),
                    value: userProfile.shareBloodType,
                    onChanged: (value) =>
                        _updateFriendVisibility(shareBloodType: value),
                  ),
                  _FriendVisibilitySwitch(
                    icon: Icons.phone_outlined,
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Telefon numarası',
                      'Phone number',
                      'Telefonnummer',
                    ),
                    value: userProfile.sharePhone,
                    onChanged: (value) =>
                        _updateFriendVisibility(sharePhone: value),
                  ),
                  _FriendVisibilitySwitch(
                    icon: Icons.contact_emergency_outlined,
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Acil durum telefonu',
                      'Emergency phone',
                      'Notfallnummer',
                    ),
                    value: userProfile.shareEmergency,
                    onChanged: (value) =>
                        _updateFriendVisibility(shareEmergency: value),
                  ),
                  _FriendVisibilitySwitch(
                    icon: Icons.pin_outlined,
                    title: tInline(
                      AppStrings.currentLanguageCode,
                      'Plaka',
                      'License plate',
                      'Kennzeichen',
                    ),
                    value: userProfile.shareLicensePlate,
                    onChanged: (value) =>
                        _updateFriendVisibility(shareLicensePlate: value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),

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
                      'Support & Madeforth-QA',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.textSecondary,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x2),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.https('apex-flow-privacy-7baea.web.app', '/', {
                          'lang': AppStrings.currentLanguageCode,
                        }),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                      label: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Gizlilik Politikasını Oku',
                          'Read Privacy Policy',
                          'Datenschutzerklärung lesen',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () =>
                          _showDeleteAccountConfirmationDialog(context, ref),
                      icon: const Icon(Icons.delete_forever_outlined, size: 18),
                      label: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Hesabımı ve Tüm Verilerimi Sil',
                          'Delete My Account & All Data',
                          'Mein Konto & alle Daten löschen',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                  final uri = Uri.parse('https://discord.gg/madeforth');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Discord Topluluğumuza Katıl',
                    'Join Our Discord Community',
                    'Tritt unserer Discord-Community bei',
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
                      'v1.0.0 (Build 34)',
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
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _updateFriendVisibility({
    bool? sharePhone,
    bool? shareEmergency,
    bool? shareBloodType,
    bool? shareLicensePlate,
  }) async {
    if (_isSavingFriendVisibility) return;
    setState(() => _isSavingFriendVisibility = true);
    try {
      final success = await ref
          .read(userProfileProvider.notifier)
          .updateFriendVisibility(
            sharePhone: sharePhone,
            shareEmergency: shareEmergency,
            shareBloodType: shareBloodType,
            shareLicensePlate: shareLicensePlate,
          );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Paylaşım tercihi kaydedilemedi. Bağlantınızı kontrol edip tekrar deneyin.',
                'Sharing preference could not be saved. Check your connection and try again.',
                'Die Freigabeeinstellung konnte nicht gespeichert werden. Prüfen Sie Ihre Verbindung und versuchen Sie es erneut.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingFriendVisibility = false);
    }
  }

  void _showDeleteAccountConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: SlatePalette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Hesabınızı Silmek İstediğinize Emin Misiniz?',
                    'Are You Sure You Want to Delete Your Account?',
                    'Möchten Sie Ihr Konto wirklich löschen?',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          content: Builder(
            builder: (context) {
              final activeEmail =
                  FirebaseAuth.instance.currentUser?.email ?? '';
              return Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Bu işlem geri alınamaz! Şu an oturum açtığınız ($activeEmail) hesabınız, Firebase üzerindeki verileriniz, garajınızdaki motosikletler ve tüm sürüş geçmişiniz kalıcı olarak silinecektir.',
                  'This action cannot be undone! Your currently logged in account ($activeEmail), Firebase cloud data, garage motorcycles, and ride history will be permanently deleted.',
                  'Diese Aktion kann nicht rückgängig gemacht werden! Ihr derzeit angemeldetes Konto ($activeEmail), Ihre Cloud-Daten und Ihr Verlauf werden dauerhaft gelöscht.',
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: SlatePalette.mutedText),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Vazgeç',
                  'Cancel',
                  'Abbrechen',
                ),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Silme isteği işleniyor. Oturum ekranı açılana kadar bekleyin...',
                        'Deletion is in progress. Wait until the sign-in screen appears...',
                        'Löschung läuft. Warten Sie, bis der Anmeldebildschirm erscheint...',
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                final success = await ref
                    .read(userProfileProvider.notifier)
                    .deleteAccount();
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: SlatePalette.emerald,
                      content: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Hesabınız ve verileriniz kalıcı olarak silindi.',
                          'Your account and data were permanently deleted.',
                          'Ihr Konto und Ihre Daten wurden dauerhaft gelöscht.',
                        ),
                      ),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Hesap silinemedi. Lütfen çıkış yapıp tekrar giriş yaptıktan sonra tekrar deneyin.',
                        'Account deletion failed. Please sign out, sign back in, and try again.',
                        'Kontolöschung fehlgeschlagen. Bitte melden Sie sich ab, erneut an und versuchen Sie es erneut.',
                      ),
                    ),
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Kalıcı Olarak Sil',
                  'Delete Permanently',
                  'Dauerhaft löschen',
                ),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FriendVisibilitySwitch extends StatelessWidget {
  const _FriendVisibilitySwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Semantics(
        label: title,
        toggled: value,
        button: true,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: context.colors.cyan, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Transform.scale(
                    scale: 0.86,
                    child: Switch.adaptive(
                      value: value,
                      activeTrackColor: context.colors.cyan,
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
          color: context.colors.navChip, // Navbar background
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
                        ? context.colors.cyan.withValues(
                            alpha: 0.14,
                          ) // Liquid-like highlight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? context
                                  .colors
                                  .cyan // Selected tab text color
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
