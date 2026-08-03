import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/garage/domain/garage_passport.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/profile/presentation/premium_paywall_screen.dart';

import 'package:apexflow/garage/application/garage_passport_pdf_service.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class GaragePassportScreen extends ConsumerWidget {
  const GaragePassportScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final settings = ref.watch(appSettingsProvider);
    ref.watch(garageStateProvider);
    ref.watch(rideStateProvider);
    final passport = ref.read(garageStateProvider.notifier).buildPassport();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.garagePassportTitle),
        actions: [
          IconButton(
            tooltip: tInline(
              AppStrings.currentLanguageCode,
              'PDF Olarak Paylaş',
              'Share as PDF',
              'Als PDF teilen',
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final isPremium = ref.read(userProfileProvider).isPremium;
              if (!isPremium) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PremiumPaywallScreen(strings: strings),
                  ),
                );
                return;
              }
              final path = await GaragePassportPdfService.generatePdf(
                passport,
                tr,
              );
              SharePlus.instance.share(
                ShareParams(
                  files: [XFile(path)],
                  text: tInline(
                    AppStrings.currentLanguageCode,
                    'Garaj Pasaportu',
                    'Garage Passport',
                    'Garagenpass',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
          ),
          IconButton(
            tooltip: strings.garagePassportShare,
            onPressed: () {
              HapticFeedback.mediumImpact();
              final isPremium = ref.read(userProfileProvider).isPremium;
              if (!isPremium) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PremiumPaywallScreen(strings: strings),
                  ),
                );
                return;
              }
              final text = passport.toShareableText(tr: tr);
              SharePlus.instance.share(ShareParams(text: text));
            },
            icon: const Icon(Icons.share_outlined, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            // Passport header stamp
            _PassportStamp(passport: passport, tr: tr, strings: strings),
            const SizedBox(height: ApexSpacing.x2),

            // Machine identity
            _MachineIdentityCard(
              passport: passport,
              strings: strings,
              settings: settings,
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Harmony status
            _HarmonyCard(passport: passport, strings: strings),
            const SizedBox(height: ApexSpacing.x2),

            // Component health
            _ComponentHealthCard(passport: passport, strings: strings),
            const SizedBox(height: ApexSpacing.x2),

            // Maintenance window
            _MaintenanceWindowCard(
              bike: passport.bike,
              strings: strings,
              settings: settings,
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Ride statistics
            _RideStatsCard(
              passport: passport,
              strings: strings,
              settings: settings,
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Service history
            _ServiceHistoryCard(
              passport: passport,
              strings: strings,
              settings: settings,
            ),
            const SizedBox(height: ApexSpacing.x2),

            // Generated timestamp
            _GeneratedFooter(passport: passport, strings: strings),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Passport Stamp ───────────────────

class _PassportStamp extends StatelessWidget {
  const _PassportStamp({
    required this.passport,
    required this.tr,
    required this.strings,
  });

  final GaragePassport passport;
  final bool tr;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return ApexPanel(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.cyan.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(ApexSpacing.radius),
              border: Border.all(
                color: context.colors.cyan.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: context.colors.cyan,
              size: 28,
            ),
          ),
          const SizedBox(height: ApexSpacing.x2),
          Text(
            strings.garagePassportTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.garagePassportSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Machine Identity ───────────────────

class _MachineIdentityCard extends StatelessWidget {
  const _MachineIdentityCard({
    required this.passport,
    required this.strings,
    required this.settings,
  });

  final GaragePassport passport;
  final AppStrings strings;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final bike = passport.bike;
    final odometerVal = settings
        .toDisplayDistance(bike.odometerKm.toDouble())
        .toStringAsFixed(0);
    final intervalVal = settings
        .toDisplayDistance(bike.serviceIntervalKm.toDouble())
        .toStringAsFixed(0);
    final distanceUnit = settings.distanceUnit;

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.two_wheeler_outlined,
            label: strings.garagePassportMachineId,
          ),
          const SizedBox(height: ApexSpacing.x2),
          _DataRow(
            label: tInline(
              AppStrings.currentLanguageCode,
              'İsim',
              'Name',
              'Name',
            ),
            value: bike.name,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _DataRow(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Model',
              'Model',
              'Modell',
            ),
            value: bike.model,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _DataRow(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Kilometre',
              'Odometer',
              'Kilometerzähler',
            ),
            value: '$odometerVal $distanceUnit',
          ),
          const SizedBox(height: ApexSpacing.x1),
          _DataRow(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Servis aralığı',
              'Service interval',
              'Serviceintervall',
            ),
            value: '$intervalVal $distanceUnit',
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Harmony Status ───────────────────

class _HarmonyCard extends StatelessWidget {
  const _HarmonyCard({required this.passport, required this.strings});

  final GaragePassport passport;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final score = passport.harmonyScore;
    final color = score >= 90
        ? context.colors.healthy
        : score >= 70
        ? context.colors.cyan
        : score >= 50
        ? context.colors.caution
        : context.colors.red;

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.auto_graph_outlined,
            label: strings.garagePassportHarmony,
          ),
          const SizedBox(height: ApexSpacing.x2),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: color.withValues(alpha: 0.28)),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: ApexSpacing.x2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passport.harmonyLevel,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      passport.harmonyInsight,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Component Health ───────────────────

class _ComponentHealthCard extends StatelessWidget {
  const _ComponentHealthCard({required this.passport, required this.strings});

  final GaragePassport passport;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final bike = passport.bike;

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.precision_manufacturing_outlined,
            label: strings.garagePassportComponentHealth,
          ),
          const SizedBox(height: ApexSpacing.x2),
          _ComponentBar(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Zincir',
              'Chain',
              'Kette',
            ),
            percent: bike.chainWearPercent,
            isWear: true,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _ComponentBar(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Lastik',
              'Tires',
              'Reifen',
            ),
            percent: bike.tireWearPercent,
            isWear: true,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _ComponentBar(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Fren',
              'Brakes',
              'Bremsen',
            ),
            percent: bike.brakeWearPercent,
            isWear: true,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _ComponentBar(
            label: tInline(AppStrings.currentLanguageCode, 'Yağ', 'Oil', 'Öl'),
            percent: bike.oilHealthPercent,
            isWear: false,
          ),
          const SizedBox(height: ApexSpacing.x1),
          _ComponentBar(
            label: tInline(
              AppStrings.currentLanguageCode,
              'Akü',
              'Battery',
              'Batterie',
            ),
            percent: bike.batteryHealthPercent,
            isWear: false,
          ),
        ],
      ),
    );
  }
}

class _ComponentBar extends StatelessWidget {
  const _ComponentBar({
    required this.label,
    required this.percent,
    required this.isWear,
  });

  final String label;
  final int percent;
  final bool isWear;

  @override
  Widget build(BuildContext context) {
    // For wear: higher is worse. For health: higher is better.
    final effectivePercent = isWear ? percent : (100 - percent);
    final color = effectivePercent < 30
        ? context.colors.healthy
        : effectivePercent < 60
        ? context.colors.caution
        : context.colors.red;

    final fillRatio = percent / 100;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fillRatio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: context.colors.rail,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        SizedBox(
          width: 36,
          child: Text(
            '$percent%',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────── Maintenance Window ───────────────────

class _MaintenanceWindowCard extends StatelessWidget {
  const _MaintenanceWindowCard({
    required this.bike,
    required this.strings,
    required this.settings,
  });

  final MotorcycleProfile bike;
  final AppStrings strings;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final windowState = bike.serviceWindowState;
    final color = switch (windowState) {
      ServiceWindowState.stable => context.colors.healthy,
      ServiceWindowState.dueSoon => context.colors.caution,
      ServiceWindowState.overdue => context.colors.red,
    };
    final label = switch (windowState) {
      ServiceWindowState.stable => tInline(
        AppStrings.currentLanguageCode,
        'Stabil',
        'Stable',
        'Im Rhythmus',
      ),
      ServiceWindowState.dueSoon => tInline(
        AppStrings.currentLanguageCode,
        'Yaklaşıyor',
        'Due soon',
        'Bald fällig',
      ),
      ServiceWindowState.overdue => tInline(
        AppStrings.currentLanguageCode,
        'Gecikmiş',
        'Overdue',
        'Überfällig',
      ),
    };

    final displaySince = settings
        .toDisplayDistance(bike.kmSinceService.toDouble())
        .toStringAsFixed(0);
    final displayInterval = settings
        .toDisplayDistance(bike.serviceIntervalKm.toDouble())
        .toStringAsFixed(0);
    final distanceUnit = settings.distanceUnit;

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.engineering_outlined,
            label: strings.garagePassportMaintenanceWindow,
          ),
          const SizedBox(height: ApexSpacing.x2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$displaySince / $displayInterval $distanceUnit',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: color.withValues(alpha: 0.30)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ApexSpacing.x1),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: bike.serviceProgress,
              minHeight: 6,
              backgroundColor: context.colors.rail,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Ride Statistics ───────────────────

class _RideStatsCard extends StatelessWidget {
  const _RideStatsCard({
    required this.passport,
    required this.strings,
    required this.settings,
  });

  final GaragePassport passport;
  final AppStrings strings;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final distanceUnit = settings.distanceUnit;
    final totalDistanceVal = settings
        .toDisplayDistance(passport.totalDistanceKm)
        .toStringAsFixed(1);
    final avgDistanceVal = settings
        .toDisplayDistance(passport.averageRideDistanceKm)
        .toStringAsFixed(1);

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.route_outlined,
            label: strings.garagePassportRideStats,
          ),
          const SizedBox(height: ApexSpacing.x2),
          if (passport.totalRides == 0)
            Text(
              strings.garagePassportNoRides,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.35,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _StatMetric(
                    label: strings.garagePassportTotalRides,
                    value: '${passport.totalRides}',
                  ),
                ),
                const SizedBox(width: ApexSpacing.x1),
                Expanded(
                  child: _StatMetric(
                    label: strings.garagePassportTotalDistance,
                    value: '$totalDistanceVal $distanceUnit',
                  ),
                ),
                const SizedBox(width: ApexSpacing.x1),
                Expanded(
                  child: _StatMetric(
                    label: strings.garagePassportAvgDistance,
                    value: '$avgDistanceVal $distanceUnit',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatMetric extends StatelessWidget {
  const _StatMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.colors.border, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: ApexSpacing.x1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────── Service History ───────────────────

class _ServiceHistoryCard extends StatelessWidget {
  const _ServiceHistoryCard({
    required this.passport,
    required this.strings,
    required this.settings,
  });

  final GaragePassport passport;
  final AppStrings strings;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final records = passport.serviceRecords;
    final display = records.take(10).toList();

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionHeader(
                  icon: Icons.build_outlined,
                  label: strings.garagePassportServiceHistory,
                ),
              ),
              if (records.isNotEmpty)
                _CountPill(
                  label: tInline(
                    AppStrings.currentLanguageCode,
                    '${records.length} kayıt',
                    '${records.length} logs',
                    '${records.length} Protokolle',
                  ),
                ),
            ],
          ),
          const SizedBox(height: ApexSpacing.x2),
          if (records.isEmpty)
            Text(
              strings.garagePassportNoService,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.35,
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < display.length; i++) ...[
                  _ServiceRow(record: display[i], tr: tr, settings: settings),
                  if (i != display.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: context.colors.border),
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.record,
    required this.tr,
    required this.settings,
  });

  final dynamic record;
  final bool tr;
  final AppSettingsState settings;

  @override
  Widget build(BuildContext context) {
    final displayOdometer = settings
        .toDisplayDistance((record.odometerKm as int).toDouble())
        .toStringAsFixed(0);
    final distanceUnit = settings.distanceUnit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(ApexSpacing.radius),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(
              Icons.build_outlined,
              size: 14,
              color: context.colors.cyan,
            ),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.label as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$displayOdometer $distanceUnit',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if ((record.note as String).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  record.note as String,
                  style: TextStyle(
                    color: context.colors.muted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          _formatDate(record.loggedAtIso as String, tr),
          style: TextStyle(
            color: context.colors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────── Generated Footer ───────────────────

class _GeneratedFooter extends StatelessWidget {
  const _GeneratedFooter({required this.passport, required this.strings});

  final GaragePassport passport;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    return Center(
      child: Text(
        '${strings.garagePassportGenerated}: '
        '${_formatDate(passport.generatedAtIso, tr)}',
        style: TextStyle(
          color: context.colors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────── Shared Primitives ───────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.cyan.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: context.colors.cyan),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        color: context.colors.elevated.withValues(alpha: 0.58),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.inkSoft,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _formatDate(String isoDate, bool tr) {
  final date = DateTime.tryParse(isoDate)?.toLocal();
  if (date == null || date.year <= 1970) {
    return tInline(
      AppStrings.currentLanguageCode,
      'Bilinmiyor',
      'Unknown',
      'Unbekannt',
    );
  }
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  if (tr) {
    return '$d.$m.${date.year} • $h:$min';
  }
  return '$m/$d/${date.year} • $h:$min';
}
