import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/insights/application/insights_state.dart';
import 'package:apexflow/shared/design/slate_palette.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/features/dashboard/dashboard_state.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/garage/presentation/garage_passport_screen.dart';
import 'package:apexflow/garage/presentation/part_status_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insightsStateProvider);
    final garageState = ref.watch(garageStateProvider);
    final dashboard = ref.watch(dashboardStateProvider);
    final rideState = ref.watch(rideStateProvider);
    final settings = ref.watch(appSettingsProvider);
    final currencySymbol = settings.currencySymbol;
    final tr = strings.locale.languageCode == 'tr';

    return Scaffold(
      backgroundColor:
          SlatePalette.surfaceDeep, // Very dark background matching the image
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            24,
            16,
            ApexSpacing.navBarClearance,
          ),
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.insightsTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.insightsSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GaragePassportScreen(strings: strings),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: SlatePalette.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SlatePalette.border),
                        ),
                        child: Row(
                          children: [
                            Text(
                              garageState.activeBike?.name ?? 'RKS SRK 250 RR',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GaragePassportScreen(strings: strings),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SlatePalette.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SlatePalette.border),
                        ),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sync Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SlatePalette.surface,
                borderRadius: BorderRadius.circular(ApexSpacing.radius),
                border: Border.all(color: SlatePalette.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_sync_outlined,
                    color: context.colors.cyan,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Analizler güncel',
                            'Insights up to date',
                            'Erkenntnisse auf dem neuesten Stand',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Yerel garaj ve sürüş kayıtlarına dayanır.',
                            'Based on your local garage and ride records.',
                            'Basierend auf Ihren lokalen Werkstatt- und Fahrtaufzeichnungen.',
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SlatePalette.surfaceDeep,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SlatePalette.border),
                    ),
                    child: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Çevrimdışı',
                        'Offline',
                        'Offline',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Maintenance Overview Card
            _SectionTitle(
              title: tInline(
                AppStrings.currentLanguageCode,
                'Bakım özeti',
                'Maintenance overview',
                'Wartungsübersicht',
              ),
            ),
            _MaintenanceOverviewCard(
              tr: tr,
              harmonyScore: dashboard.harmony.score,
              activeMoto: garageState.activeBike,
            ),
            const SizedBox(height: 16),

            // 3 Stat Cards Row — IntrinsicHeight keeps all three the same
            // height once a title wraps to two lines.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.build_outlined,
                      iconColor: context.colors.cyan,
                      title: tInline(
                        AppStrings.currentLanguageCode,
                        'Sıradaki servis',
                        'Next service',
                        'Nächster Service',
                      ),
                      value:
                          '${settings.formatNumber((garageState.activeBike?.lastServiceKm ?? 0) + (garageState.activeBike?.serviceIntervalKm ?? 2500))} km',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: context.colors.cyan,
                      title: tInline(
                        AppStrings.currentLanguageCode,
                        'Toplam kayıtlı',
                        'Total recorded',
                        'Insgesamt erfasst',
                      ),
                      value: settings.formatCurrency(state.totalCostTry),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.add_road_outlined,
                      iconColor: context.colors.cyan,
                      title: tInline(
                        AppStrings.currentLanguageCode,
                        'Sürüş kaydı',
                        'Ride records',
                        'Fahrtaufzeichnungen',
                      ),
                      value: '${rideState.sessions.length}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent ride impact
            _SectionTitle(
              title: tInline(
                AppStrings.currentLanguageCode,
                'Son sürüş etkisi',
                'Recent ride impact',
                'Auswirkungen der letzten Fahrt',
              ),
            ),
            _RecentRideImpactCard(
              state: state,
              tr: tr,
              sessions: rideState.sessions,
            ),
            const SizedBox(height: 24),

            // Upcoming maintenance
            _SectionTitle(
              title: tInline(
                AppStrings.currentLanguageCode,
                'Yaklaşan bakım',
                'Upcoming maintenance',
                'Anstehende Wartung',
              ),
            ),
            _UpcomingMaintenanceCard(
              state: state,
              tr: tr,
              activeMoto: garageState.activeBike,
            ),
            const SizedBox(height: 24),

            // Cost ledger
            _SectionTitle(
              title: tInline(
                AppStrings.currentLanguageCode,
                'Maliyet defteri',
                'Cost ledger',
                'Kostenbuch',
              ),
            ),
            _CostLedgerCard(state: state, tr: tr, strings: strings),
            const SizedBox(height: 40),

            // Parts Wishlist (Kept from original design logic but updated styling)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              spacing: 8,
              children: [
                _SectionTitle(title: strings.partsWishlist),
                GestureDetector(
                  onTap: () => _showAddPartSheet(context, ref, tr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colors.cyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: context.colors.cyan),
                        const SizedBox(width: 4),
                        Text(
                          strings.addPart,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: context.colors.cyan,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (state.partsWishlist.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Parça listesi boş. Yakında almayı planladığın parçaları linkiyle ekleyebilirsin.',
                    'Your parts wishlist is empty. Add parts you plan to buy, optionally with a link.',
                    'Ihre Ersatzteil-Wunschliste ist leer. Fügen Sie Teile hinzu, die Sie kaufen möchten, optional mit einem Link.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.35,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: SlatePalette.surface,
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: SlatePalette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.partsWishlist.asMap().entries.map((entry) {
                    final index = entry.key;
                    final part = entry.value;
                    return Column(
                      children: [
                        _WishlistRow(
                          part: part,
                          tr: tr,
                          settings: settings,
                          onDelete: () {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(insightsStateProvider.notifier)
                                .removeWishlistPart(part);
                            _showSnack(
                              context,
                              tInline(
                                AppStrings.currentLanguageCode,
                                'Parça listeden kaldırıldı.',
                                'Part removed from wishlist.',
                                'Teil von der Wunschliste entfernt.',
                              ),
                            );
                          },
                        ),
                        if (index < state.partsWishlist.length - 1)
                          Divider(color: SlatePalette.border, height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  // --- Keep original Add Part Logic ---
  Future<void> _showAddPartSheet(
    BuildContext context,
    WidgetRef ref,
    bool tr,
  ) async {
    HapticFeedback.selectionClick();
    final name = TextEditingController();
    final note = TextEditingController();
    final url = TextEditingController();
    final price = TextEditingController();
    final strings = AppStrings(Localizations.localeOf(context));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: SlatePalette.surfaceDeep, // Dark surface
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Parça Ekle',
                      'Add Part',
                      'Teil hinzufügen',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: SlatePalette.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SlatePalette.border),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Input fields
              _buildPremiumTextField(
                context: context,
                controller: name,
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Parça adı',
                  'Part name',
                  'Teilename',
                ),
                icon: Icons.settings_outlined,
              ),
              const SizedBox(height: 16),
              _buildPremiumTextField(
                context: context,
                controller: note,
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Not',
                  'Note',
                  'Notiz',
                ),
                icon: Icons.notes,
              ),
              const SizedBox(height: 16),
              _buildPremiumTextField(
                context: context,
                controller: url,
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Link',
                  'Link',
                  'Link',
                ),
                icon: Icons.link,
              ),
              const SizedBox(height: 16),
              _buildPremiumTextField(
                context: context,
                controller: price,
                label: tInline(
                  AppStrings.currentLanguageCode,
                  'Tahmini fiyat (TRY)',
                  'Estimated price (TRY)',
                  'Geschätzter Preis (TRY)',
                ),
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              // Save Button
              GestureDetector(
                onTap: () {
                  final partName = name.text.trim();
                  if (partName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Parça adı boş olamaz.',
                            'Part name cannot be empty.',
                            'Teilename darf nicht leer sein.',
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  final rawUrl = url.text.trim();
                  if (rawUrl.isNotEmpty && Uri.tryParse(rawUrl) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Link geçerli görünmüyor.',
                            'Link looks invalid.',
                            'Der Link sieht ungültig aus.',
                          ),
                        ),
                      ),
                    );
                    return;
                  }
                  final parsedPrice =
                      double.tryParse(price.text.trim().replaceAll(',', '.')) ??
                      0.0;

                  ref
                      .read(insightsStateProvider.notifier)
                      .addWishlistPart(
                        name: partName,
                        note: note.text,
                        url: rawUrl,
                        priceTry: parsedPrice,
                      );
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.colors.cyan,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Parçayı kaydet',
                      'Save part',
                      'Teil speichern',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SlatePalette.surfaceDeep,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SlatePalette.surface,
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(color: SlatePalette.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: SlatePalette.mutedText),
          prefixIcon: Icon(icon, color: SlatePalette.mutedText, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// --- Helper Components ---

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MaintenanceOverviewCard extends StatelessWidget {
  final bool tr;
  final int harmonyScore;
  final MotorcycleProfile? activeMoto;

  const _MaintenanceOverviewCard({
    required this.tr,
    required this.harmonyScore,
    required this.activeMoto,
  });

  @override
  Widget build(BuildContext context) {
    final currentKm = activeMoto?.odometerKm ?? 0;
    final lastServiceKm = activeMoto?.lastServiceKm ?? 0;
    final interval = activeMoto?.serviceIntervalKm ?? 2500;
    final nextService = lastServiceKm + interval;
    final remaining = nextService - currentKm;
    final progress = (currentKm - lastServiceKm) / interval;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final numberFormat = NumberFormat.decimalPattern(
      AppStrings.currentLanguageCode,
    );
    final intervalText = numberFormat.format(interval);
    final remainingText = numberFormat.format(remaining.abs());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SlatePalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SlatePalette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gauge
          Column(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      color: SlatePalette.border,
                      strokeCap: StrokeCap.round,
                    ),
                    CircularProgressIndicator(
                      value: harmonyScore / 100,
                      strokeWidth: 8,
                      color: SlatePalette.caution, // Yellow-ish
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$harmonyScore',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Makine\ndurumu',
                              'Machine\ncondition',
                              'Maschinen\nzustand',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 10,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SlatePalette.cautionBackground, // Dark yellow bg
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SlatePalette.caution, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: SlatePalette.caution,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Dikkat',
                        'Attention',
                        'Achtung',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SlatePalette.caution,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Right Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Servis aralığı yaklaşıyor',
                    'Service interval is approaching',
                    'Serviceintervall nähert sich',
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    remaining < 0
                        ? 'Mevcut $intervalText km aralığında $remainingText km aşıldı.'
                        : 'Mevcut $intervalText km aralığında $remainingText km kaldı.',
                    remaining < 0
                        ? '$remainingText km overdue in the current\n$intervalText km interval.'
                        : '$remainingText km remaining in the current\n$intervalText km interval.',
                    remaining < 0
                        ? '$remainingText km überfällig im aktuellen\n$intervalText km Intervall.'
                        : '$remainingText km verbleibend im aktuellen\n$intervalText km Intervall.',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 6,
                    backgroundColor: SlatePalette.border,
                    color: SlatePalette.caution,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${numberFormat.format(currentKm - lastServiceKm)} / $intervalText km',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final currentInterval =
                            activeMoto?.serviceIntervalKm ?? 2500;
                        int newInterval = currentInterval;
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return StatefulBuilder(
                              builder: (ctx, setState) {
                                return AlertDialog(
                                  backgroundColor: SlatePalette.surface,
                                  title: Text(
                                    tInline(
                                      AppStrings.currentLanguageCode,
                                      'Bakım Aralığı',
                                      'Service Interval',
                                      'Wartungsintervall',
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tInline(
                                          AppStrings.currentLanguageCode,
                                          'Servis periyodunu belirleyin (km)',
                                          'Set service interval (km)',
                                          'Wartungsintervall festlegen (km)',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        '$newInterval km',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: context.colors.cyan,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Slider(
                                        value: newInterval.toDouble(),
                                        min: 1000,
                                        max: 15000,
                                        divisions: 28,
                                        activeColor: context.colors.cyan,
                                        onChanged: (val) {
                                          setState(
                                            () => newInterval = val.toInt(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(
                                        tInline(
                                          AppStrings.currentLanguageCode,
                                          'İptal',
                                          'Cancel',
                                          'Abbrechen',
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  context.colors.textSecondary,
                                            ),
                                      ),
                                    ),
                                    Consumer(
                                      builder: (context, ref, child) {
                                        return ElevatedButton(
                                          onPressed: () {
                                            final bike = activeMoto;
                                            if (bike != null) {
                                              ref
                                                  .read(
                                                    garageStateProvider
                                                        .notifier,
                                                  )
                                                  .updateMotorcycle(
                                                    bike: bike.copyWith(
                                                      serviceIntervalKm:
                                                          newInterval,
                                                    ),
                                                    name: bike.name,
                                                    model: bike.model,
                                                    odometerKm: bike.odometerKm,
                                                  );
                                            }
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  tInline(
                                                    AppStrings
                                                        .currentLanguageCode,
                                                    'Aralık güncellendi',
                                                    'Interval updated',
                                                    'Intervall aktualisiert',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                context.colors.cyan,
                                          ),
                                          child: Text(
                                            tInline(
                                              AppStrings.currentLanguageCode,
                                              'Kaydet',
                                              'Save',
                                              'Speichern',
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: context.colors.cyan,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Düzenle',
                              'Edit',
                              'Bearbeiten',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.colors.cyan,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SlatePalette.surface,
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: SlatePalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
              // Three of these sit side by side, so a single line clips
              // longer localized titles ("Sıradaki servis",
              // "Fahrtaufzeichnungen") mid-word.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRideImpactCard extends StatelessWidget {
  final InsightsState state;
  final bool tr;
  final List<RideSession> sessions;

  const _RecentRideImpactCard({
    required this.state,
    required this.tr,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final hasSession = sessions.isNotEmpty;
    final latestSession = hasSession ? sessions.first : null;
    final hasPattern = state.patternSignals.isNotEmpty;

    // Determine the content to show, or fallbacks if empty
    final pattern = hasPattern
        ? state.patternSignals.first
        : PatternSignal(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Sürüş Akışı Dengeli',
              'Smooth Riding Harmony',
              'Ausgeglichener Fahrfluss',
            ),
            evidenceCount: 0,
            recommendation: tInline(
              AppStrings.currentLanguageCode,
              'Sert hızlanma veya frenleme paterni algılanmadı. Akıcı sürüşe devam edin.',
              'No harsh acceleration or braking patterns detected. Maintain smooth transitions.',
              'Keine harten Beschleunigungs- oder Bremsmuster erkannt. Fließende Fahrweise fortsetzen.',
            ),
          );

    final distanceStr = latestSession != null
        ? '${latestSession.distanceKm.toStringAsFixed(1)} km'
        : tInline(
            AppStrings.currentLanguageCode,
            'Kayıt yok',
            'No rides',
            'Keine Fahrten',
          );

    final iconColor = hasPattern ? SlatePalette.danger : context.colors.healthy;
    final iconBgColor = hasPattern
        ? SlatePalette.dangerBackground.withValues(alpha: 0.5)
        : SlatePalette.successBackground.withValues(alpha: 0.5);
    final iconBorderColor = hasPattern
        ? SlatePalette.dangerDeep.withValues(alpha: 0.5)
        : SlatePalette.successDeep.withValues(alpha: 0.5);
    final iconData = hasPattern
        ? Icons.settings_backup_restore
        : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SlatePalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SlatePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBorderColor),
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateLine(pattern.label, tr),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Son sürüş · $distanceStr',
                        'Last ride · $distanceStr',
                        'Letzte Fahrt · $distanceStr',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _translateLine(pattern.recommendation, tr),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showRecentRideImpactDetails(context, pattern, tr),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SlatePalette.dangerDeep),
                  ),
                  child: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'İncele',
                      'Review',
                      'Überprüfen',
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: SlatePalette.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: context.colors.textSecondary,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart mock/visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(20, (index) {
              // Creating a simple pattern similar to the image
              double height = 2;
              Color color = SlatePalette.border;

              if (index >= 5 && index <= 15) {
                height = (index == 9 || index == 13)
                    ? 14
                    : ((index == 10 || index == 14) ? 10 : 4);
                if (index < 9)
                  color = context.colors.cyan;
                else if (index < 13)
                  color = SlatePalette.caution; // yellow
                else
                  color = SlatePalette.danger; // red
              }

              return Container(
                width: 10,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Divider(color: SlatePalette.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'Daha fazla sürüş kaydedildikçe aşınma tahminleri iyileşir.',
                    'Wear estimates improve as more rides are recorded.',
                    'Die Verschleißschätzungen verbessern sich, je mehr Fahrten aufgezeichnet werden.',
                  ),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingMaintenanceCard extends StatelessWidget {
  final InsightsState state;
  final bool tr;
  final MotorcycleProfile? activeMoto;

  const _UpcomingMaintenanceCard({
    required this.state,
    required this.tr,
    required this.activeMoto,
  });

  @override
  Widget build(BuildContext context) {
    // Generate items if empty for the sake of the redesign
    final items = state.maintenanceCalendar.isNotEmpty
        ? state.maintenanceCalendar
        : [
            MaintenanceItem(
              task: tInline(
                AppStrings.currentLanguageCode,
                'Fren kontrolü',
                'Brake inspection',
                'Bremsprüfung',
              ),
              dueDateIso: '',
              note: tInline(
                AppStrings.currentLanguageCode,
                'Bu hafta öneriliyor',
                'Suggested this week',
                'Diese Woche empfohlen',
              ),
            ),
          ];

    final currentKm = activeMoto?.odometerKm ?? 0;
    final lastServiceKm = activeMoto?.lastServiceKm ?? 0;
    final interval = activeMoto?.serviceIntervalKm ?? 2500;
    final remaining = (lastServiceKm + interval) - currentKm;

    return Container(
      decoration: BoxDecoration(
        color: SlatePalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SlatePalette.border),
      ),
      child: Column(
        children: [
          // Fixed Next Service item to match design
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SlatePalette.cautionBackground.withValues(
                      alpha: 0.5,
                    ), // dark yellow
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SlatePalette.caution.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: SlatePalette.caution,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Servis aralığı',
                          'Service interval',
                          'Serviceintervall',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          remaining < 0
                              ? '${remaining.abs()} km gecikti'
                              : '$remaining km kaldı',
                          remaining < 0
                              ? '${remaining.abs()} km overdue'
                              : '$remaining km remaining',
                          remaining < 0
                              ? '${remaining.abs()} km überfällig'
                              : 'Noch $remaining km',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: SlatePalette.border, height: 1),
          // Dynamic items
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SlatePalette.surfaceDeep.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: SlatePalette.border),
                    ),
                    child: Icon(
                      Icons.settings_suggest_outlined,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _translateLine(item.task, tr),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _translateLine(item.note, tr),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CostLedgerCard extends ConsumerWidget {
  final InsightsState state;
  final bool tr;
  final AppStrings strings;

  const _CostLedgerCard({
    required this.state,
    required this.tr,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final currencySymbol = settings.currencySymbol;
    return Container(
      decoration: BoxDecoration(
        color: SlatePalette.oledBackground,
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        border: Border.all(color: SlatePalette.oledBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.rail,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SlatePalette.oledBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: context.colors.cyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.formatCurrency(state.totalCostTry),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Bu ay kaydedilen',
                          'Recorded this month',
                          'Diesen Monat aufgezeichnet',
                        ),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showLedgerSheet(context, state, tr, settings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.cyan.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: context.colors.cyan,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      tInline(
                        AppStrings.currentLanguageCode,
                        'Defteri gör',
                        'View ledger',
                        'Ansehen',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.colors.cyan,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showAddCostSheet(context, ref, strings),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: context.colors.cyan.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.cyan,
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: context.colors.cyan,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (state.costLedger.isNotEmpty) ...[
            Divider(
              color: SlatePalette.oledBorder,
              height: 0.5,
              thickness: 0.5,
            ),
            ...state.costLedger.map((entry) {
              // Creating the sub-progress bar logic
              final percent = state.totalCostTry > 0
                  ? (entry.amountTry / state.totalCostTry)
                  : 1.0;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          entry.category.toLowerCase().contains('fuel')
                              ? Icons.water_drop_outlined
                              : Icons.settings,
                          color: context.colors.cyan,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_translateLine(entry.category, tr)} · ${_formatCostEntryDate(entry.dateIso)}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(
                          settings.formatCurrency(entry.amountTry),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _translateLine(entry.category, tr),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 3,
                        backgroundColor: SlatePalette.oledBorder,
                        color: context.colors.cyan,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Henüz maliyet kaydı yok.',
                  'No cost entries yet.',
                  'Noch keine Kosteneinträge.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Helpers
void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

// Cost ledger bottom sheet — shows all entries
void _showLedgerSheet(
  BuildContext context,
  InsightsState state,
  bool tr,
  AppSettingsState settings,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollCtrl) {
          return Container(
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: context.colors.border, width: 0.5),
                left: BorderSide(color: context.colors.border, width: 0.5),
                right: BorderSide(color: context.colors.border, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.muted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: context.colors.cyan,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Maliyet Defteri',
                          'Cost Ledger',
                          'Kostenbuch',
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        settings.formatCurrency(state.totalCostTry),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: context.colors.cyan,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(
                  color: SlatePalette.oledBorder,
                  height: 0.5,
                  thickness: 0.5,
                ),
                Expanded(
                  child: state.costLedger.isEmpty
                      ? Center(
                          child: Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Henüz kayıt yok.',
                              'No entries yet.',
                              'Noch keine Einträge.',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: context.colors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          itemCount: state.costLedger.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: SlatePalette.oledBorder,
                            height: 0.5,
                            thickness: 0.5,
                          ),
                          itemBuilder: (_, i) {
                            final e = state.costLedger[i];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: SlatePalette.oledBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: SlatePalette.oledBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: Icon(
                                  e.category.toLowerCase().contains('fuel')
                                      ? Icons.water_drop_outlined
                                      : Icons.settings_outlined,
                                  color: context.colors.cyan,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                _translateLine(e.category, tr),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: context.colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              trailing: Text(
                                settings.formatCurrency(e.amountTry),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: context.colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Add cost entry bottom sheet
Future<void> _showAddCostSheet(
  BuildContext context,
  WidgetRef ref,
  AppStrings strings,
) async {
  final currencySymbol = ref.read(appSettingsProvider).currencySymbol;
  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String selectedCategory = 'Fuel';
  final categories = ['Fuel', 'Service', 'Tyre', 'Insurance', 'Other'];

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(color: context.colors.border, width: 0.5),
                  left: BorderSide(color: context.colors.border, width: 0.5),
                  right: BorderSide(color: context.colors.border, width: 0.5),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.muted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'YENİ MALİYET KAYDI',
                      'NEW COST ENTRY',
                      'NEUER KOSTENEINTRAG',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category selector
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final sel = cat == selectedCategory;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(
                                      0xFF06B6D4,
                                    ).withValues(alpha: 0.12)
                                  : SlatePalette.oledBackground,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: sel
                                    ? context.colors.cyan
                                    : SlatePalette.oledBorder,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              cat == 'Fuel'
                                  ? tInline(
                                      AppStrings.currentLanguageCode,
                                      'Yakıt',
                                      'Fuel',
                                      'Kraftstoff',
                                    )
                                  : cat == 'Service'
                                  ? tInline(
                                      AppStrings.currentLanguageCode,
                                      'Servis',
                                      'Service',
                                      'Service',
                                    )
                                  : cat == 'Tyre'
                                  ? tInline(
                                      AppStrings.currentLanguageCode,
                                      'Lastik',
                                      'Tyre',
                                      'Reifen',
                                    )
                                  : cat == 'Insurance'
                                  ? tInline(
                                      AppStrings.currentLanguageCode,
                                      'Sigorta',
                                      'Insurance',
                                      'Versicherung',
                                    )
                                  : tInline(
                                      AppStrings.currentLanguageCode,
                                      'Diğer',
                                      'Other',
                                      'Sonstiges',
                                    ),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: sel
                                        ? context.colors.cyan
                                        : context.colors.textSecondary,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: tInline(
                        AppStrings.currentLanguageCode,
                        'Açıklama',
                        'Description',
                        'Beschreibung',
                      ),
                      filled: true,
                      fillColor: SlatePalette.oledBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          '${tInline(AppStrings.currentLanguageCode, 'Tutar', 'Amount', 'Betrag')} ($currencySymbol)',
                      filled: true,
                      fillColor: SlatePalette.oledBackground,
                      prefixText: '$currencySymbol ',
                      prefixStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: context.colors.cyan,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.cyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ApexSpacing.radius,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final amount = double.tryParse(
                          amountCtrl.text.trim().replaceAll(',', '.'),
                        );
                        if (descCtrl.text.trim().isEmpty ||
                            amount == null ||
                            !amount.isFinite ||
                            amount <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(strings.insightsCostInvalid),
                            ),
                          );
                          return;
                        }

                        try {
                          await ref
                              .read(insightsStateProvider.notifier)
                              .addCostEntry(
                                label: descCtrl.text,
                                category: selectedCategory,
                                amountTry: amount,
                              );
                        } catch (_) {
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(strings.insightsCostSaveFailed),
                            ),
                          );
                          return;
                        }

                        if (!ctx.mounted || !context.mounted) return;
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.insightsCostSaved)),
                        );
                      },
                      child: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'KAYDET',
                          'SAVE',
                          'SPEICHERN',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
  descCtrl.dispose();
  amountCtrl.dispose();
}

const _costEntryMonthsTr = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];
const _costEntryMonthsEn = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatCostEntryDate(String dateIso) {
  final date = DateTime.tryParse(dateIso);
  if (date == null) return '';
  final months = AppStrings.currentLanguageCode == 'tr'
      ? _costEntryMonthsTr
      : _costEntryMonthsEn;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _translateLine(String line, bool tr) {
  // Simple check for localization if line is a raw internal string
  if (line == 'Brake load increased')
    return tInline(
      AppStrings.currentLanguageCode,
      'Fren yükü arttı',
      'Brake load increased',
      'Bremslast erhöht',
    );
  if (line == 'One hard-braking pattern was recorded.')
    return tInline(
      AppStrings.currentLanguageCode,
      'Sert frenleme modeli algılandı.',
      'One hard-braking pattern was recorded.',
      'Ein starkes Bremsmuster wurde erfasst.',
    );
  if (line == 'Fuel')
    return tInline(
      AppStrings.currentLanguageCode,
      'Yakıt',
      'Fuel',
      'Kraftstoff',
    );
  if (line == 'Service')
    return tInline(
      AppStrings.currentLanguageCode,
      'Servis',
      'Service',
      'Service',
    );
  return line;
}

class _WishlistRow extends StatelessWidget {
  const _WishlistRow({
    required this.part,
    required this.tr,
    required this.onDelete,
    required this.settings,
  });

  final WishlistPart part;
  final bool tr;
  final VoidCallback onDelete;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: context.colors.cyan,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (part.note.isNotEmpty)
                  Text(
                    part.note,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (part.priceTry != null && part.priceTry! > 0) ...[
            Text(
              settings.formatCurrency(part.priceTry!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: SlatePalette.danger,
              size: 18,
            ),
            tooltip: tr ? 'Sil' : 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

void _showRecentRideImpactDetails(
  BuildContext context,
  PatternSignal pattern,
  bool tr,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          border: Border(
            top: BorderSide(color: context.colors.border, width: 0.5),
            left: BorderSide(color: context.colors.border, width: 0.5),
            right: BorderSide(color: context.colors.border, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SlatePalette.oledMutedText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.settings_backup_restore,
                  color: SlatePalette.danger,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'SON SÜRÜŞ ETKİSİ DETAYLARI',
                    'RECENT RIDE IMPACT DETAILS',
                    'LETZTE FAHRTWIRKUNGSDETAILS',
                  ),
                  style: const TextStyle(
                    color: SlatePalette.oledMutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _translateLine(pattern.label, tr),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _translateLine(pattern.recommendation, tr),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SlatePalette.oledMutedText,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: context.colors.border, height: 0.5, thickness: 0.5),
            const SizedBox(height: 16),
            _buildDetailRow(
              tInline(
                AppStrings.currentLanguageCode,
                'Sürüş Mesafesi',
                'Ride Distance',
                'Fahrstrecke',
              ),
              '12.4 km',
              context,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              tInline(
                AppStrings.currentLanguageCode,
                'Algılanan Süreç',
                'Detected Pattern',
                'Erkanntes Muster',
              ),
              tInline(
                AppStrings.currentLanguageCode,
                'Sert Frenleme',
                'Hard Braking',
                'Starkes Bremsen',
              ),
              context,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              tInline(
                AppStrings.currentLanguageCode,
                'Tahmini Aşınma',
                'Est. Pad Wear',
                'Geschätzter Bremsverschleiß',
              ),
              '+1.5%',
              context,
              valColor: SlatePalette.danger,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.elevated,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    side: BorderSide(color: context.colors.border, width: 0.5),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'KAPAT',
                    'CLOSE',
                    'SCHLIESSEN',
                  ),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow(
  String label,
  String value,
  BuildContext context, {
  Color? valColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: SlatePalette.oledMutedText),
      ),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: valColor ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
