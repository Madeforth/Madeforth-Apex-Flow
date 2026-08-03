import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class MachineMemoryScreen extends ConsumerWidget {
  const MachineMemoryScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = strings.locale.languageCode == 'tr';
    final garage = ref.watch(garageStateProvider);
    final rides = ref.watch(rideStateProvider);
    final rituals = ref.watch(ritualsStateProvider);
    final isHydrating =
        garage.isHydrating || rides.isHydrating || rituals.isHydrating;
    final events = _buildEvents(
      garage: garage,
      rides: rides,
      rituals: rituals,
      tr: tr,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(
            AppStrings.currentLanguageCode,
            'Makine Hafızası',
            'Machine Memory',
            'Maschinenspeicher',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Birleşik zaman çizelgesi',
                            'Unified timeline',
                            'Einheitliche Zeitleiste',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _MemoryPill(
                        label: tInline(
                          AppStrings.currentLanguageCode,
                          '${events.length} kayıt',
                          '${events.length} logs',
                          '${events.length} Protokolle',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ApexSpacing.x1),
                  Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Servis, sürüş ve günlük kontrol kayıtları tek makine hafızasında tutulur.',
                      'Service, ride, and daily check entries live in one machine memory.',
                      'Service-, Fahrt- und tägliche Check-Einträge leben in einem Maschinenspeicher.',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: ApexSpacing.x2),
                  _MemorySummary(
                    tr: tr,
                    serviceCount: garage.serviceRecords.length,
                    rideCount: rides.sessions.length,
                    checkCount: rituals.dailyChecks.length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            if (isHydrating) ...[
              ApexStatePanel(
                icon: Icons.timeline_outlined,
                title: tInline(
                  AppStrings.currentLanguageCode,
                  'Hafıza hazırlanıyor',
                  'Preparing memory',
                  'Gedächtnis vorbereiten',
                ),
                message: tInline(
                  AppStrings.currentLanguageCode,
                  'Servis, sürüş ve kontrol kayıtları yerelden okunuyor.',
                  'Service, ride, and check entries are loading from local storage.',
                  'Service-, Fahrt- und Scheckeinträge werden aus dem lokalen Speicher geladen.',
                ),
                loading: true,
              ),
              const SizedBox(height: ApexSpacing.x2),
            ],
            if (events.isEmpty)
              ApexStatePanel(
                icon: Icons.timeline_outlined,
                title: tInline(
                  AppStrings.currentLanguageCode,
                  'Hafıza boş',
                  'Memory is empty',
                  'Der Speicher ist leer',
                ),
                message: tInline(
                  AppStrings.currentLanguageCode,
                  'İlk servis, sürüş veya günlük kontrol kaydı burada görünecek.',
                  'Your first service, ride, or daily check will appear here.',
                  'Hier erscheint Ihr erster Service, Ihre erste Fahrt oder Ihr erster täglicher Check.',
                ),
              )
            else
              ApexPanel(
                child: Column(
                  children: [
                    for (var i = 0; i < events.length; i++) ...[
                      _TimelineRow(event: events[i], tr: tr),
                      if (i != events.length - 1)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            color: context.colors.border,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _MemorySummary extends StatelessWidget {
  const _MemorySummary({
    required this.tr,
    required this.serviceCount,
    required this.rideCount,
    required this.checkCount,
  });

  final bool tr;
  final int serviceCount;
  final int rideCount;
  final int checkCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ApexSpacing.x1,
      runSpacing: ApexSpacing.x1,
      children: [
        _MemoryPill(
          label: tInline(
            AppStrings.currentLanguageCode,
            '$serviceCount servis',
            '$serviceCount service',
            '$serviceCount-Dienst',
          ),
        ),
        _MemoryPill(
          label: tInline(
            AppStrings.currentLanguageCode,
            '$rideCount sürüş',
            '$rideCount ride',
            '$rideCount Fahrt',
          ),
        ),
        _MemoryPill(
          label: tInline(
            AppStrings.currentLanguageCode,
            '$checkCount kontrol',
            '$checkCount check',
            '$checkCount-Prüfung',
          ),
        ),
      ],
    );
  }
}

class _MemoryPill extends StatelessWidget {
  const _MemoryPill({required this.label});

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.inkSoft,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.tr});

  final _MemoryEvent event;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.elevated,
              borderRadius: BorderRadius.circular(ApexSpacing.radius),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(event.icon, size: 16, color: context.colors.cyan),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    event.kindLabel,
                    style: TextStyle(
                      color: context.colors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                event.subtitle,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  height: 1.35,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(event.occurredAt, tr),
                style: TextStyle(
                  color: context.colors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemoryEvent {
  const _MemoryEvent({
    required this.occurredAt,
    required this.icon,
    required this.kindLabel,
    required this.title,
    required this.subtitle,
  });

  final DateTime occurredAt;
  final IconData icon;
  final String kindLabel;
  final String title;
  final String subtitle;
}

List<_MemoryEvent> _buildEvents({
  required GarageState garage,
  required RideState rides,
  required RitualsState rituals,
  required bool tr,
}) {
  final events = <_MemoryEvent>[
    for (final record in garage.serviceRecords)
      _MemoryEvent(
        occurredAt: _parseDate(record.loggedAtIso),
        icon: Icons.build_outlined,
        kindLabel: tInline(
          AppStrings.currentLanguageCode,
          'SERVİS',
          'SERVICE',
          'SERVICE',
        ),
        title: record.label,
        subtitle: '${record.odometerKm} km • ${record.note}',
      ),
    for (final ride in rides.sessions)
      _MemoryEvent(
        occurredAt: _parseDate(ride.loggedAtIso),
        icon: Icons.route_outlined,
        kindLabel: tInline(
          AppStrings.currentLanguageCode,
          'SÜRÜŞ',
          'RIDE',
          'FAHRT',
        ),
        title: tInline(
          AppStrings.currentLanguageCode,
          '${ride.distanceKm.toStringAsFixed(1)} km sürüş notu',
          '${ride.distanceKm.toStringAsFixed(1)} km ride reflection',
          '${ride.distanceKm.toStringAsFixed(1)} km Fahrtreflexion',
        ),
        subtitle: _buildRideSubtitle(ride),
      ),
    for (final check in rituals.dailyChecks)
      _MemoryEvent(
        occurredAt: check.loggedAt,
        icon: Icons.fact_check_outlined,
        kindLabel: tInline(
          AppStrings.currentLanguageCode,
          'KONTROL',
          'CHECK',
          'ÜBERPRÜFEN',
        ),
        title: tInline(
          AppStrings.currentLanguageCode,
          'Günlük makine kontrolü',
          'Daily machine check',
          'Täglicher Maschinencheck',
        ),
        subtitle: _dailyCheckSubtitle(check, tr),
      ),
  ];

  events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  return events.take(30).toList();
}

String _buildRideSubtitle(dynamic ride) {
  final unit = tInline(AppStrings.currentLanguageCode, 'dk', 'min', 'Min.');
  final mood = _translateMood(ride.mood.toString());
  final obs = _translateObservation(ride.mechanicalObservation.toString());
  return '${ride.durationMinutes} $unit • $mood • $obs';
}

String _translateMood(String mood) {
  final clean = mood.toLowerCase().trim();
  if (clean == 'sakin' || clean == 'calm' || clean == 'ruhig') {
    return tInline(AppStrings.currentLanguageCode, 'Sakin', 'Calm', 'Ruhig');
  }
  if (clean == 'odaklı' ||
      clean == 'odakli' ||
      clean == 'focused' ||
      clean == 'fokussiert') {
    return tInline(
      AppStrings.currentLanguageCode,
      'Odaklı',
      'Focused',
      'Fokussiert',
    );
  }
  if (clean == 'sportif' || clean == 'sporty' || clean == 'sportlich') {
    return tInline(
      AppStrings.currentLanguageCode,
      'Sportif',
      'Sporty',
      'Sportlich',
    );
  }
  return mood;
}

String _translateObservation(String obs) {
  final clean = obs.trim();
  if (clean == 'Ride completed' ||
      clean == 'Sürüş Tamamlandı' ||
      clean == 'Sürüş tamamlandı' ||
      clean == 'Fahrt abgeschlossen') {
    return tInline(
      AppStrings.currentLanguageCode,
      'Sürüş Tamamlandı',
      'Ride completed',
      'Fahrt abgeschlossen',
    );
  }
  return obs;
}

String _dailyCheckSubtitle(DailyCheckEntry check, bool tr) {
  final allClear =
      check.tiresOk &&
      check.chainOk &&
      check.oilOk &&
      check.brakesOk &&
      check.lightsOk;
  final status = allClear
      ? (tInline(
          AppStrings.currentLanguageCode,
          'Tüm kontroller temiz',
          'All checks clear',
          'Alle Prüfungen in Ordnung',
        ))
      : (tInline(
          AppStrings.currentLanguageCode,
          'Takip isteyen kontrol var',
          'Follow-up needed',
          'Nachbereitung erforderlich',
        ));
  if (check.note.trim().isEmpty) {
    return status;
  }
  return '$status • ${check.note.trim()}';
}

DateTime _parseDate(String input) {
  return DateTime.tryParse(input)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDate(DateTime date, bool tr) {
  if (date.year <= 1970) {
    return tInline(
      AppStrings.currentLanguageCode,
      'Eski kayıt',
      'Legacy entry',
      'Legacy-Eintrag',
    );
  }
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final de = AppStrings.currentLanguageCode == 'de';
  if (tr || de) {
    return '$day.$month.${date.year} • $hour:$minute';
  }
  return '$month/$day/${date.year} • $hour:$minute';
}
