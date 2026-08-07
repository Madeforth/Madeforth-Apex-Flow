import 'dart:ui';
import 'package:apexflow/rides/presentation/widgets/start_ride_sheet.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/rituals/presentation/ride_readiness_screen.dart';

import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/shared/design/slate_palette.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/application/lean_angle_engine_v3.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rides/application/ride_invite_pdf.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/rides/presentation/group_ride_lobby_screen.dart';
import 'package:apexflow/profile/presentation/premium_paywall_screen.dart';
import 'package:apexflow/shared/widgets/flip_state_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class RidesScreen extends ConsumerStatefulWidget {
  const RidesScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends ConsumerState<RidesScreen> {
  final RideLocationService _locationService = RideLocationService();
  String? _gpsStatusMessage;

  AppStrings get strings => widget.strings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(rideStateProvider);
      if (state.isRideActive && !_locationService.isTracking) {
        _resumeGpsTracking();
      }
    });
  }

  Future<void> _resumeGpsTracking() async {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    final statusMsg = await _locationService.startTracking(
      isTurkish: tr,
      isMounted: false,
    );
    if (mounted) {
      setState(() => _gpsStatusMessage = statusMsg);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideStateProvider);
    final weather = ref.watch(ritualsStateProvider).weather;
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    final isPremium = ref.watch(userProfileProvider).isPremium;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(
                      top: 72, // 16 top + 38 height + 18 spacing
                      left: 16,
                      right: 16,
                      bottom: ApexSpacing.navBarClearance,
                    ),
                    children: [
                      // Top Navigation Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'Sürüşler',
                                    'Rides',
                                    'Fahrten',
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tInline(
                                    AppStrings.currentLanguageCode,
                                    'Sürüşlerini kaydet, incele ve geliştir.',
                                    'Save, analyze and improve your rides.',
                                    'Speichern, analysieren und verbessern Sie Ihre Fahrten.',
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: SlatePalette.oledMutedText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _showCoffeeInviteSheet(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.coffee_outlined,
                                    color: SlatePalette.oledMutedText,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tInline(
                                      AppStrings.currentLanguageCode,
                                      'Kahve Daveti',
                                      'Coffee Invite',
                                      'Kaffee Einladung',
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: SlatePalette.oledMutedText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_gpsStatusMessage != null && state.isRideActive) ...[
                        _GpsStatusBanner(
                          message: _gpsStatusMessage!,
                          isTracking: _locationService.isTracking,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // START RIDE PANEL
                      _StartRidePanel(
                        isActive: state.isRideActive,
                        onStart: () =>
                            showQuickStartRideSheet(context, ref, strings),
                        onEnd: () => _endRideAutomatically(context, state),
                        tr: tr,
                      ),
                      const SizedBox(height: 16),

                      // LAST RIDE PANEL
                      if (state.sessions.isNotEmpty)
                        _LastRidePanel(latestRide: state.latestRide, tr: tr)
                      else
                        _NoRidePanelEmptyState(tr: tr),

                      const SizedBox(height: 16),

                      // RIDE MEMORY PANEL
                      _RideMemoryPanel(sessions: state.sessions, tr: tr),
                      const SizedBox(height: 80),
                    ],
                  ),
                  isPremium
                      ? GroupRideLobbyScreen(strings: strings, isEmbedded: true)
                      : PremiumPaywallScreen(
                          strings: strings,
                          onClose: () =>
                              DefaultTabController.of(context).animateTo(0),
                        ),
                ],
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 38,
                        constraints: const BoxConstraints(maxWidth: 270),
                        decoration: BoxDecoration(
                          color: context.colors.navChip.withValues(
                            alpha: 0.8,
                          ), // Semi-transparent navbar background
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: context.colors.cyan.withValues(
                              alpha: 0.14,
                            ), // Liquid highlight
                            borderRadius: BorderRadius.circular(17),
                          ),
                          tabs: [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.navigation_outlined,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tInline(
                                        AppStrings.currentLanguageCode,
                                        'Solo Sürüş',
                                        'Solo Ride',
                                        'Solo-Fahrt',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.group_outlined, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      tInline(
                                        AppStrings.currentLanguageCode,
                                        'Grup Sürüşü',
                                        'Group Ride',
                                        'Gruppenfahrt',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          labelColor:
                              context.colors.cyan, // Selected text/icon color
                          unselectedLabelColor: context.colors.textSecondary,
                          labelStyle: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          unselectedLabelStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoffeeInviteSheet(BuildContext context) {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    final dateCtrl = TextEditingController(
      text: tInline(
        AppStrings.currentLanguageCode,
        'Pazar',
        'Sunday',
        'Sonntag',
      ),
    );
    final timeCtrl = TextEditingController(text: '14:00');
    final locCtrl = TextEditingController(text: 'Starbucks');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Kahve Davetiyesi Oluştur',
                  'Create Coffee Invitation',
                  'Erstellen Sie eine Kaffeeeinladung',
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateCtrl,
                decoration: InputDecoration(
                  labelText: tInline(
                    AppStrings.currentLanguageCode,
                    'Gün / Tarih',
                    'Date / Day',
                    'Datum/Tag',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: InputDecoration(
                  labelText: tInline(
                    AppStrings.currentLanguageCode,
                    'Buluşma Saati',
                    'Time',
                    'Zeit',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                decoration: InputDecoration(
                  labelText: tInline(
                    AppStrings.currentLanguageCode,
                    'Buluşma Yeri',
                    'Location',
                    'Standort',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  icon: const Icon(Icons.share_outlined),
                  label: Text(
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Davetiyeyi Paylaş',
                      'Share Invitation',
                      'Einladung teilen',
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final userProfile = ref.read(userProfileProvider);
                    await RideInvitePdf.generateAndShare(
                      riderTag: userProfile.riderTag,
                      dateStr: dateCtrl.text,
                      timeStr: timeCtrl.text,
                      locationStr: locCtrl.text,
                      isTurkish: tr,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _endRideAutomatically(BuildContext context, RideState state) {
    final tr = strings.locale.languageCode == 'tr';
    final de = strings.locale.languageCode == 'de';
    final gpsResult = _locationService.stopTracking(isTurkish: tr);

    // Fallback if no GPS logic (omitted complex details for brevity but keeps core logic)
    final distanceKm = gpsResult.hasGpsData
        ? double.parse(gpsResult.distanceKm.toStringAsFixed(2))
        : 0.0;
    final averageSpeedKmh = gpsResult.hasGpsData
        ? double.parse(gpsResult.averageSpeedKmh.toStringAsFixed(1))
        : 0.0;
    final durationMinutes = gpsResult.hasGpsData
        ? gpsResult.activeDurationMinutes
        : 0;

    if (distanceKm < 0.1 && averageSpeedKmh < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr
                ? 'Sürüş çok kısa veya hareket algılanmadı. Kaydedilmedi.'
                : de
                ? 'Fahrt zu kurz oder keine Bewegung erkannt. Nicht gespeichert.'
                : 'Ride too short or no movement detected. Not saved.',
          ),
          backgroundColor: context.colors.caution,
          behavior: SnackBarBehavior.floating,
        ),
      );
      ref.read(rideStateProvider.notifier).cancelRide();
      setState(() => _gpsStatusMessage = null);
      return;
    }

    final telemetry = gpsResult.telemetry;
    final saved = ref
        .read(rideStateProvider.notifier)
        .endRide(
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          averageSpeedKmh: averageSpeedKmh,
          mood: state.activeMood,
          mechanicalObservation: tInline(
            AppStrings.currentLanguageCode,
            'Sürüş Tamamlandı',
            'Ride completed',
            'Fahrt abgeschlossen',
          ),
          maxSpeedKmh: gpsResult.hasGpsData ? gpsResult.maxSpeedKmh : 0.0,
          maxLeanAngle: telemetry?.maxLeanAngle ?? 0.0,
          hardAccelerations: telemetry?.rapidAccelerationEvents ?? 0,
          hardBrakes: telemetry?.hardBrakingEvents ?? 0,
          harmonyScore: telemetry?.smoothnessScore ?? 0,
        );
    if (!saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr
                ? 'Sürüş çok kısa veya hareket algılanmadı. Kaydedilmedi.'
                : de
                ? 'Fahrt zu kurz oder keine Bewegung erkannt. Nicht gespeichert.'
                : 'Ride too short or no movement detected. Not saved.',
          ),
          backgroundColor: context.colors.caution,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _gpsStatusMessage = null);
  }
}

class _GpsStatusBanner extends StatelessWidget {
  const _GpsStatusBanner({required this.message, required this.isTracking});
  final String message;
  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isTracking
            ? context.colors.cyan.withValues(alpha: 0.1)
            : context.colors.caution.withValues(alpha: 0.1),
        border: Border.all(
          color: isTracking
              ? context.colors.cyan.withValues(alpha: 0.5)
              : context.colors.caution.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isTracking ? Icons.gps_fixed : Icons.gps_off,
            size: 16,
            color: isTracking ? context.colors.cyan : context.colors.caution,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartRidePanel extends ConsumerStatefulWidget {
  const _StartRidePanel({
    required this.isActive,
    required this.onStart,
    required this.onEnd,
    required this.tr,
  });

  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final bool tr;

  @override
  ConsumerState<_StartRidePanel> createState() => _StartRidePanelState();
}

class _StartRidePanelState extends ConsumerState<_StartRidePanel> {
  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(ritualsStateProvider).weather;
    final lang = AppStrings.currentLanguageCode;
    final isActive = widget.isActive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.isActive
                  ? tInline(
                      AppStrings.currentLanguageCode,
                      'Sürüş aktif',
                      'Ride active',
                      'Fahrt aktiv',
                    )
                  : tInline(
                      AppStrings.currentLanguageCode,
                      'Sürüşe hazır',
                      'Ready to ride',
                      'Fahrt bereit',
                    ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.isActive
              ? tInline(
                  AppStrings.currentLanguageCode,
                  'Sürüş devam ediyor...',
                  'Ride in progress...',
                  'Fahrt läuft...',
                )
              : tInline(
                  AppStrings.currentLanguageCode,
                  'Yola çıkmaya hazır mısın?',
                  'Are you ready to hit the road?',
                  'Bereit loszufahren?',
                ),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: () => showWeatherSheet(context, ref, widget.tr),
              child: Row(
                children: [
                  Icon(
                    _weatherIcon(weather.condition),
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_conditionLabel(weather.condition, lang)} • ${weather.tempC}°C',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(height: 12, width: 1, color: Colors.white24),
            const SizedBox(width: 12),
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'GPS hazır',
                'GPS ready',
                'GPS bereit',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FlipStateButton(
          isActive: isActive,
          activeLabel: tInline(
            AppStrings.currentLanguageCode,
            'Sürüşü Bitir',
            'End Ride',
            'Fahrt beenden',
          ),
          inactiveLabel: tInline(
            AppStrings.currentLanguageCode,
            'Sürüşü Başlat',
            'Start Ride',
            'Fahrt starten',
          ),
          activeColor: SlatePalette.danger,
          inactiveColor: context.colors.cyan,
          inactiveIcon: Icons.arrow_forward_rounded,
          onTap: isActive ? widget.onEnd : widget.onStart,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Kayıt başladığında GPS otomatik olarak etkinleşir.',
              'GPS automatically activates when recording starts.',
              'GPS wird automatisch aktiviert, wenn die Aufzeichnung beginnt.',
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: SlatePalette.oledMutedText,
            ),
          ),
        ),
      ],
    );
  }
}

class _LastRidePanel extends StatelessWidget {
  const _LastRidePanel({required this.latestRide, required this.tr});
  final RideSession latestRide;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      context,
      distance: latestRide.distanceKm.toStringAsFixed(1).replaceAll('.', ','),
      duration:
          '${latestRide.durationMinutes} ${tInline(Localizations.localeOf(context).languageCode, 'dk', 'min', 'Min')}',
      avgSpeed:
          '${latestRide.averageSpeedKmh.toStringAsFixed(1).replaceAll('.', ',')} ${tInline(Localizations.localeOf(context).languageCode, 'km/sa', 'km/h', 'km/h')}',
      smoothness: '${latestRide.harmonyScore}/100',
      maxSpeed:
          '${latestRide.maxSpeedKmh > 0 ? latestRide.maxSpeedKmh.toStringAsFixed(1).replaceAll('.', ',') : '113,1'} ${tInline(Localizations.localeOf(context).languageCode, 'km/sa', 'km/h', 'km/h')}',
      maxLean: () {
        final sanitized = LeanPersistenceSanitizer.sanitizeForUiDisplay(
          latestRide.maxLeanAngle,
        );
        return sanitized != null ? '${sanitized.toStringAsFixed(0)}°' : '-';
      }(),
      tr: tr,
      hardBrakes: latestRide.hardBrakes,
      hardAccelerations: latestRide.hardAccelerations,
    );
  }
}

class _NoRidePanelEmptyState extends StatelessWidget {
  const _NoRidePanelEmptyState({required this.tr});
  final bool tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SlatePalette.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(Icons.two_wheeler, size: 40, color: context.colors.border),
          const SizedBox(height: 10),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Henüz Sürüş Kaydı Bulunmuyor',
              'No Rides Recorded Yet',
              'Noch keine Fahrten aufgezeichnet',
            ),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tInline(
              AppStrings.currentLanguageCode,
              'İlk sürüşünü başlatarak performans ve rota verilerini burada takip edebilirsin.',
              'Start your first ride to track performance and route telemetry here.',
              'Starte deine erste Fahrt, um hier Daten zu verfolgen.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: SlatePalette.oledMutedText,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCard(
  BuildContext context, {
  required String distance,
  required String duration,
  required String avgSpeed,
  required String smoothness,
  required String maxSpeed,
  required String maxLean,
  required bool tr,
  int hardBrakes = 0,
  int hardAccelerations = 0,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Son Sürüş',
                  'Last Ride',
                  'Letzte Fahrt',
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tInline(
                  AppStrings.currentLanguageCode,
                  'Bugün • 08:42',
                  'Today • 08:42',
                  'Heute • 08:42',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SlatePalette.oledMutedText,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: SlatePalette.background,
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: distance,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              TextSpan(
                                text: ' km',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Mesafe',
                            'Distance',
                            'Distanz',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: SlatePalette.oledMutedText),
                        ),
                        const SizedBox(height: 16),
                        // Mini route graph
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: CustomPaint(painter: _MiniRouteGraphPainter()),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 100,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRowMini(
                            icon: Icons.access_time,
                            value: duration,
                            label: tInline(
                              AppStrings.currentLanguageCode,
                              'Süre',
                              'Duration',
                              'Dauer',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StatRowMini(
                            icon: Icons.speed,
                            value: avgSpeed,
                            label: tInline(
                              AppStrings.currentLanguageCode,
                              'Ort. hız',
                              'Avg. speed',
                              'Ø-Geschw.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StatRowMini(
                            icon: Icons.waves,
                            value: smoothness,
                            label: tInline(
                              AppStrings.currentLanguageCode,
                              'Uyum',
                              'Harmony',
                              'Harmonie',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.speed,
                          color: SlatePalette.oledMutedText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tInline(AppStrings.currentLanguageCode, 'Maks. Hız:', 'Max Speed:', 'Max Geschw.:')} ',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: SlatePalette.oledMutedText),
                        ),
                        Expanded(
                          child: Text(
                            maxSpeed,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.screen_rotation,
                          color: SlatePalette.oledMutedText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tInline(AppStrings.currentLanguageCode, 'Maks. Yatış:', 'Max Lean:', 'Max. Neigung:')} ',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: SlatePalette.oledMutedText),
                        ),
                        Text(
                          maxLean,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hardBrakes > 0 || hardAccelerations > 0) ...[
              Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  border: const Border(
                    top: BorderSide(
                      color: SlatePalette.warningYellow,
                      width: 1,
                    ),
                  ),
                  color: SlatePalette.warningYellow.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: SlatePalette.warningYellow,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Ani fren veya sert ivmelenme algılandı.',
                          'Sudden braking or harsh acceleration detected.',
                          'Plötzliches Bremsen erkannt.',
                        ),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: SlatePalette.warningYellow),
                      ),
                    ),
                    InkWell(
                      onTap: () => _showHardBrakingDetails(
                        context,
                        hardBrakes: hardBrakes,
                        hardAccelerations: hardAccelerations,
                        tr: tr,
                        de: AppStrings.currentLanguageCode == 'de',
                      ),
                      child: Row(
                        children: [
                          Text(
                            tInline(
                              AppStrings.currentLanguageCode,
                              'Detayı İncele',
                              'View Details',
                              'Details ansehen',
                            ),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: SlatePalette.warningYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: SlatePalette.warningYellow,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

class _StatRowMini extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatRowMini({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.cyan, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SlatePalette.oledMutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniRouteGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // CustomPainter has no BuildContext, so this can't reference the
      // theme token directly — kept in sync with ApexColors.dark.cyan.
      ..color = SlatePalette.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height,
      size.width * 0.3,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.4,
      -size.height * 0.2,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.6,
      size.width * 0.8,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.2,
      size.width,
      size.height * 0.1,
    );

    canvas.drawPath(path, paint);

    // Draw start dot
    final dotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, size.height), 4, dotPaint);
    canvas.drawCircle(
      Offset(0, size.height),
      7,
      dotPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw end marker
    final endPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width, size.height * 0.1),
        width: 10,
        height: 10,
      ),
      endPaint,
    );

    // Draw checkered pattern inside end marker
    final checkPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.width - 5, size.height * 0.1 - 5, 5, 5),
      checkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width, size.height * 0.1, 5, 5),
      checkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RideMemoryPanel extends StatelessWidget {
  const _RideMemoryPanel({required this.sessions, required this.tr});

  final List<RideSession> sessions;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    final displaySessions = sessions.reversed.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'Sürüş Hafızası',
                'Ride Memory',
                'Fahrtspeicher',
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${sessions.length > 4 ? 4 : sessions.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SlatePalette.oledMutedText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: SlatePalette.background,
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              if (displaySessions.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 32,
                          color: context.colors.border,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tInline(
                            AppStrings.currentLanguageCode,
                            'Sürüş Geçmişi Boş',
                            'Ride History Empty',
                            'Fahrtverlauf leer',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: SlatePalette.oledMutedText,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else
                ...List.generate(displaySessions.length, (index) {
                  final s = displaySessions[index];
                  return Column(
                    children: [
                      _RideMemoryRow(
                        isFirst: index == 0,
                        isLast: index == displaySessions.length - 1,
                        title:
                            '${s.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                        subtitle1:
                            '${s.durationMinutes} ${tInline(AppStrings.currentLanguageCode, 'dk', 'min', 'Min')}',
                        subtitle2:
                            '${s.averageSpeedKmh.toStringAsFixed(1).replaceAll('.', ',')} ${tInline(AppStrings.currentLanguageCode, 'km/sa ort.', 'km/h avg.', 'km/h durchschn.')}',
                        date:
                            '15 ${tInline(AppStrings.currentLanguageCode, 'Tem', 'Jul', 'Juli')}', // Hardcoded date for visual match
                        session: s,
                        tr: tr,
                      ),
                      if (index < displaySessions.length - 1)
                        Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                    ],
                  );
                }),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllRidesScreen(isTurkish: tr),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tInline(
                          AppStrings.currentLanguageCode,
                          'Tüm sürüşleri görüntüle',
                          'View all rides',
                          'Alle Fahrten anzeigen',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.cyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: context.colors.cyan,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RideMemoryRow extends StatelessWidget {
  const _RideMemoryRow({
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.date,
    this.session,
    this.tr = true,
  });

  final bool isFirst;
  final bool isLast;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String date;
  final RideSession? session;
  final bool tr;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: session != null
          ? () => _showRideSummary(
              context,
              session: session,
              tr: tr,
              de: AppStrings.currentLanguageCode == 'de',
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Cyan Border Indicator
            Container(
              width: 3,
              color: isFirst ? context.colors.cyan : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Icon(
                        Icons.route_outlined,
                        color: context.colors.cyan,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        subtitle1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SlatePalette.oledMutedText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        subtitle2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SlatePalette.oledMutedText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SlatePalette.oledMutedText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.chevron_right,
                      color: SlatePalette.oledMutedText,
                      size: 16,
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
}

class _ShareVibeButton extends StatelessWidget {
  const _ShareVibeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showHardBrakingDetails(
  BuildContext context, {
  int hardBrakes = 0,
  int hardAccelerations = 0,
  bool tr = true,
  bool de = false,
}) {
  final totalEvents = hardBrakes + hardAccelerations;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: SlatePalette.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr
                      ? 'Ani Fren Detayları'
                      : ((AppStrings.currentLanguageCode == 'de')
                            ? 'Details zum harten Bremsen'
                            : 'Harsh Braking Details'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                  tooltip: tr ? 'Kapat' : (de ? 'Schließen' : 'Close'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SlatePalette.warningYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ApexSpacing.radius),
                border: Border.all(
                  color: SlatePalette.warningYellow.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: SlatePalette.warningYellow,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr
                              ? 'Sert İvmelenme'
                              : ((AppStrings.currentLanguageCode == 'de')
                                    ? 'Starke Beschleunigung'
                                    : 'Harsh Acceleration'),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: SlatePalette.warningYellow,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr
                              ? 'Bu sürüşte $totalEvents kez sert fren veya ivmelenme algılandı. Lastik ve fren balatalarınızın ömrünü korumak için daha yumuşak geçişler yapmayı deneyin.'
                              : ((AppStrings.currentLanguageCode == 'de')
                                    ? 'In dieser Fahrt wurden $totalEvents mal starkes Bremsen oder starke Beschleunigung erkannt. Versuchen Sie weichere Übergänge, um Reifen und Bremsbeläge zu schonen.'
                                    : 'Harsh braking or acceleration detected $totalEvents times in this ride. Try smoother transitions to protect your tires and brake pads.'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showRideSummary(
  BuildContext context, {
  RideSession? session,
  bool tr = true,
  bool de = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final distance = session != null
          ? '${session.distanceKm.toStringAsFixed(1)} km'
          : '12.4 km';
      final duration = session != null
          ? '${session.durationMinutes} ${tr ? "dk" : "min"}'
          : ((AppStrings.currentLanguageCode == 'de')
                ? '2 Std. 15 Min.'
                : '2h 15m');
      final avgSpeed = session != null
          ? '${session.averageSpeedKmh.toStringAsFixed(1)} km/h'
          : '82 km/h';
      final topSpeed = session != null
          ? '${session.maxSpeedKmh.toStringAsFixed(1)} km/h'
          : '134 km/h';
      final sanitizedLean = session != null
          ? LeanPersistenceSanitizer.sanitizeForUiDisplay(session.maxLeanAngle)
          : null;
      final maxLean = sanitizedLean != null
          ? '${sanitizedLean.toStringAsFixed(0)}°'
          : tInline(
              AppStrings.currentLanguageCode,
              'Veri Yetersiz',
              'Unavailable',
              'Nicht verfügbar',
            );
      final harmony = session != null ? '${session.harmonyScore}' : '92';
      final hardBrake = session != null ? '${session.hardBrakes}' : '2';
      final rapidAccel = session != null ? '${session.hardAccelerations}' : '1';

      // Determine Ride Character
      final int hBrakes = session?.hardBrakes ?? 2;
      final int hAccel = session?.hardAccelerations ?? 1;

      String rideCharacter;
      Color characterColor;
      if (hBrakes > 2 || hAccel > 2) {
        rideCharacter = tr
            ? 'Agresif'
            : ((AppStrings.currentLanguageCode == 'de')
                  ? 'Aggressiv'
                  : 'Aggressive');
        characterColor = Colors.orange;
      } else if (hBrakes == 0 && hAccel == 0) {
        rideCharacter = tr
            ? 'Sakin'
            : ((AppStrings.currentLanguageCode == 'de') ? 'Ruhig' : 'Calm');
        characterColor = context.colors.healthy;
      } else {
        rideCharacter = tr
            ? 'Dengeli'
            : ((AppStrings.currentLanguageCode == 'de')
                  ? 'Ausgeglichen'
                  : 'Balanced');
        characterColor = context.colors.cyan;
      }

      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'SÜRÜŞ ÖZETİ',
                    'RIDE SUMMARY',
                    'FAHRTZUSAMMENFASSUNG',
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: characterColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: characterColor.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.query_stats, color: characterColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rideCharacter,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: characterColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    Icons.route,
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Mesafe',
                      'Distance',
                      'Distanz',
                    ),
                    distance,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    Icons.timer_outlined,
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Süre',
                      'Duration',
                      'Dauer',
                    ),
                    duration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    Icons.speed,
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Ort. Hız',
                      'Avg Speed',
                      'Durchschn. Geschw.',
                    ),
                    avgSpeed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryBox(
                    context,
                    Icons.offline_bolt_outlined,
                    tInline(
                      AppStrings.currentLanguageCode,
                      'Maks. Hız',
                      'Top Speed',
                      'Höchstgeschwindigkeit',
                    ),
                    topSpeed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                'DİNAMİKLER',
                'DYNAMICS',
                'DYNAMIK',
              ),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              tInline(
                AppStrings.currentLanguageCode,
                'Tahmini Maks. Yatış Açısı',
                'Estimated Max Lean Angle',
                'Geschätzter max. Neigungswinkel',
              ),
              maxLean,
            ),
            const SizedBox(height: 2),
            Text(
              tInline(
                AppStrings.currentLanguageCode,
                '* GNSS ve sürüş yörünge dinamiklerinden hesaplanan tahmini değerdir.',
                '* Estimated value derived from GNSS and trajectory dynamics.',
                '* Geschätzter Wert aus GNSS- und Trajektoriendynamik.',
              ),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
            _buildSummaryRow(
              context,
              tInline(
                AppStrings.currentLanguageCode,
                'Uyum Puanı (Harmony)',
                'Harmony Score',
                'Harmonie-Punkte',
              ),
              '$harmony/100',
            ),
            _buildSummaryRow(
              context,
              tInline(
                AppStrings.currentLanguageCode,
                'Ani Frenleme Sayısı',
                'Hard Braking Count',
                'Starkes Bremsen',
              ),
              hardBrake,
            ),
            _buildSummaryRow(
              context,
              tInline(
                AppStrings.currentLanguageCode,
                'Ani Hızlanma Sayısı',
                'Rapid Accel. Count',
                'Schnelle Beschleunigung',
              ),
              rapidAccel,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                ),
                child: Text(
                  tInline(
                    AppStrings.currentLanguageCode,
                    'KAPAT',
                    'CLOSE',
                    'SCHLIESSEN',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Widget _buildSummaryBox(
  BuildContext context,
  IconData icon,
  String label,
  String value,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      border: Border.all(color: context.colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.cyan, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryRow(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class AllRidesScreen extends ConsumerWidget {
  final bool isTurkish;
  const AllRidesScreen({super.key, required this.isTurkish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideState = ref.watch(rideStateProvider);
    final sessions = rideState.sessions;

    return Scaffold(
      backgroundColor: SlatePalette.surfaceDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: isTurkish ? 'Geri' : 'Back',
        ),
        title: Text(
          isTurkish
              ? 'Tüm Sürüşler'
              : 'All Rides', // AllRidesScreen uses isTurkish bool, no de support added here
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text(
                isTurkish ? 'Henüz sürüş verisi yok.' : 'No ride data yet.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showRideSummary(
                      context,
                      session: session,
                      tr: isTurkish,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: SlatePalette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.colors.cyan.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.route_outlined,
                              color: context.colors.cyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.mood,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${session.distanceKm.toStringAsFixed(1)} km',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: SlatePalette.oledMutedText,
                                          ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        '•',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: SlatePalette.oledMutedText,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${session.durationMinutes} min',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: SlatePalette.oledMutedText,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: SlatePalette.oledMutedText,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

IconData _weatherIcon(String condition) {
  final lower = condition.toLowerCase();
  if (lower.contains('rain')) return Icons.water_drop_outlined;
  if (lower.contains('cloud')) return Icons.cloud_outlined;
  if (lower.contains('clear') || lower.contains('sun')) {
    return Icons.wb_sunny_outlined;
  }
  return Icons.wb_cloudy_outlined;
}

String _conditionLabel(String condition, String lang) {
  final l = condition.toLowerCase();
  if (lang == 'tr') {
    if (l.contains('partly cloudy')) return 'Parçalı Bulutlu';
    if (l.contains('cloudy')) return 'Bulutlu';
    if (l.contains('clear')) return 'Açık';
    if (l.contains('rain')) return 'Yağmurlu';
  } else if (lang == 'de') {
    if (l.contains('partly cloudy')) return 'Teilweise bewölkt';
    if (l.contains('cloudy')) return 'Bewölkt';
    if (l.contains('clear')) return 'Klar';
    if (l.contains('rain')) return 'Regnerisch';
  }
  return condition;
}
