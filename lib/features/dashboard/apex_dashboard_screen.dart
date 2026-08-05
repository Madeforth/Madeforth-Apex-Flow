import 'dart:math' as math;
import 'package:apexflow/rides/presentation/widgets/start_ride_sheet.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_breakpoints.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/features/dashboard/dashboard_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';
import 'package:apexflow/rides/application/ride_detection_state.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/rituals/presentation/daily_machine_check_screen.dart';
import 'package:apexflow/rituals/presentation/ride_readiness_screen.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:apexflow/notifications/application/notification_state.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ApexDashboardScreen extends ConsumerWidget {
  const ApexDashboardScreen({
    super.key,
    required this.strings,
    this.onOpenRides,
    this.onOpenGarage,
    this.onOpenPartStatus,
    this.onOpenServiceEntry,
    this.onOpenFuel,
    this.onOpenInsights,
    this.onOpenNotifications,
  });

  final AppStrings strings;
  final VoidCallback? onOpenRides;
  final VoidCallback? onOpenGarage;
  final VoidCallback? onOpenPartStatus;
  final VoidCallback? onOpenServiceEntry;
  final VoidCallback? onOpenFuel;
  final VoidCallback? onOpenInsights;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateProvider);
    final garage = ref.watch(garageStateProvider);
    final hasBike = garage.motorcycles.isNotEmpty;

    if (garage.isHydrating) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B121A),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: context.colors.cyan),
          ),
        ),
      );
    }

    if (!hasBike) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B121A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(ApexSpacing.x2),
            child: Column(
              children: [
                _TopBar(
                  ref: ref,
                  unreadCount: ref.watch(unreadNotificationCountProvider),
                  onOpenNotifications: onOpenNotifications,
                ),
                const SizedBox(height: ApexSpacing.x2),
                ApexStatePanel(
                  icon: Icons.two_wheeler_outlined,
                  title: tInline(
                    strings.languageCode,
                    'Makine hafızası henüz oluşmadı',
                    'Machine memory is not established yet',
                    'Der Maschinenspeicher ist noch nicht eingerichtet',
                  ),
                  message: tInline(
                    strings.languageCode,
                    'İlk motosikleti ekleyerek servis hafızasını ve Harmony hesabını başlat.',
                    'Add the first motorcycle to start service memory and Harmony.',
                    'Fügen Sie das erste Motorrad hinzu, um den Servicespeicher und Harmony zu starten.',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B121A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TopBar(
              ref: ref,
              unreadCount: ref.watch(unreadNotificationCountProvider),
              onOpenNotifications: onOpenNotifications,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: _BikeSelectorDropdown(garage: garage, ref: ref),
            ),
            const SizedBox(height: 24),
            _MainStatusSection(
              state: state,
              strings: strings,
              onWeatherTap: () =>
                  showWeatherSheet(context, ref, strings.languageCode == 'tr'),
            ),
            const SizedBox(height: 32),
            _StartRideAction(
              strings: strings,
              isRideActive: ref.watch(rideStateProvider).isRideActive,
              onStartRide: () {
                final rideState = ref.read(rideStateProvider);
                if (rideState.isRideActive) {
                  final tr = strings.locale.languageCode == 'tr';
                  final de = strings.locale.languageCode == 'de';
                  final gpsResult = RideLocationService().stopTracking(
                    isTurkish: tr,
                  );

                  final distanceKm = gpsResult.hasGpsData
                      ? double.parse(gpsResult.distanceKm.toStringAsFixed(2))
                      : 0.0;
                  final averageSpeedKmh = gpsResult.hasGpsData
                      ? double.parse(
                          gpsResult.averageSpeedKmh.toStringAsFixed(1),
                        )
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
                    return;
                  }

                  final telemetry = gpsResult.telemetry;
                  final saved = ref
                      .read(rideStateProvider.notifier)
                      .endRide(
                        distanceKm: distanceKm,
                        durationMinutes: durationMinutes,
                        averageSpeedKmh: averageSpeedKmh,
                        mood: rideState.activeMood,
                        mechanicalObservation: tInline(
                          AppStrings.currentLanguageCode,
                          'Sürüş Tamamlandı',
                          'Ride completed',
                          'Fahrt abgeschlossen',
                        ),
                        maxSpeedKmh: gpsResult.hasGpsData
                            ? gpsResult.maxSpeedKmh
                            : 0.0,
                        maxLeanAngle: telemetry?.maxLeanAngle ?? 0.0,
                        hardAccelerations:
                            telemetry?.rapidAccelerationEvents ?? 0,
                        hardBrakes: telemetry?.hardBrakingEvents ?? 0,
                        harmonyScore: telemetry?.smoothnessScore ?? 0,
                      );
                  if (!saved) {
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
                } else {
                  showQuickStartRideSheet(context, ref, strings);
                }
              },
            ),
            const SizedBox(height: 24),
            _WarningBanner(
              strings: strings,
              onOpenGarage: onOpenGarage,
              onOpenServiceEntry: onOpenServiceEntry,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DailyMachineCheckScreen(strings: strings),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.t(
                        tr: 'Kontrol Listesini Aç',
                        en: 'Open Checklist',
                        de: 'Checkliste öffnen',
                      ),
                      style: TextStyle(
                        color: context.colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: context.colors.cyan,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _MachineHealthRow(state: state, strings: strings),
            const SizedBox(height: 24),
            _AttentionRequiredList(
              state: state,
              strings: strings,
              onOpenPartStatus: onOpenPartStatus,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  if (onOpenGarage != null) {
                    onOpenGarage!.call();
                  } else {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.t(
                              tr: 'Garaj modülü yükleniyor...',
                              en: 'Garage module loading...',
                              de: 'Garage-Modul wird geladen...',
                            ),
                          ),
                        ),
                      );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.t(
                        tr: 'Tüm bileşenleri görüntüle',
                        en: 'View all components',
                        de: 'Alle Komponenten ansehen',
                      ),
                      style: TextStyle(
                        color: context.colors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: context.colors.cyan,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.ref,
    required this.unreadCount,
    this.onOpenNotifications,
  });

  final WidgetRef ref;
  final int unreadCount;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Apex Flow',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        if (onOpenNotifications != null)
          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount.toString(),
                style: const TextStyle(fontSize: 9),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: context.colors.cyan,
              ),
            ),
            onPressed: onOpenNotifications,
          ),
      ],
    );
  }
}

class _BikeSelectorDropdown extends StatefulWidget {
  const _BikeSelectorDropdown({required this.garage, required this.ref});
  final GarageState garage;
  final WidgetRef ref;

  @override
  State<_BikeSelectorDropdown> createState() => _BikeSelectorDropdownState();
}

class _BikeSelectorDropdownState extends State<_BikeSelectorDropdown> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: widget.garage.activeBike.id,
      color: const Color(
        0xFF0F172A,
      ), // Minimal dark slate, matches bg-background
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // Design Rules: 4-6 radius
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      offset: const Offset(0, 48),
      onOpened: () {
        setState(() {
          _isOpen = true;
        });
      },
      onCanceled: () {
        setState(() {
          _isOpen = false;
        });
      },
      onSelected: (id) {
        setState(() {
          _isOpen = false;
        });
        final bike = widget.garage.motorcycles.firstWhere((b) => b.id == id);
        widget.ref.read(garageStateProvider.notifier).setActiveMotorcycle(bike);
      },
      itemBuilder: (context) {
        return widget.garage.motorcycles.map((bike) {
          final isSelected = bike.id == widget.garage.activeBike.id;
          return PopupMenuItem<String>(
            value: bike.id,
            height: 48,
            padding: EdgeInsets
                .zero, // Zero padding to let Container handle highlights
            child: Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.cyan.withValues(alpha: 0.1) // bg-primary/10
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.two_wheeler,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bike.model,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.cyan
                            : Colors.white70, // text-primary or white
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      color: Colors.cyan, // ml-auto text-primary check icon
                      size: 18,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(6), // Design Rules: 4-6 radius
          border: Border.all(
            color: _isOpen
                ? Colors.white.withValues(
                    alpha: 0.25,
                  ) // Highlighted border when open
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.two_wheeler, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              widget.garage.activeBike.model,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0.0, // Rotates 180 degrees when open
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainStatusSection extends StatelessWidget {
  const _MainStatusSection({
    required this.state,
    required this.strings,
    required this.onWeatherTap,
  });
  final DashboardState state;
  final AppStrings strings;
  final VoidCallback onWeatherTap;

  @override
  Widget build(BuildContext context) {
    final score = state.readiness.score;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.t(
                  tr: 'Sürüşe Hazır',
                  en: 'Ready to Ride',
                  de: 'Fahrbereit',
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$score/100',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFACC15), // Yellow
                    ),
                  ),
                  const Text(
                    ' · ',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  Text(
                    strings.t(
                      tr: 'Bakım öneriliyor',
                      en: 'Maintenance suggested',
                      de: 'Wartung empfohlen',
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: onWeatherTap,
                    child: Row(
                      children: [
                        Icon(
                          _weatherIcon(state.weather.condition),
                          size: 16,
                          color: context.colors.cyan,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_conditionLabel(state.weather.condition, strings.languageCode)} · ${state.weather.tempC}°C',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54,
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
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(110, 110),
                painter: _ScoreGaugePainter(
                  score: score,
                  color: const Color(0xFFFACC15),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(
                width: 90,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
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

  IconData _weatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain')) return Icons.water_drop_outlined;
    if (lower.contains('cloud')) return Icons.cloud_outlined;
    if (lower.contains('clear') || lower.contains('sun'))
      return Icons.wb_sunny_outlined;
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
}

class _ScoreGaugePainter extends CustomPainter {
  _ScoreGaugePainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
  });

  final int score;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Start angle: bottom-left (approx 135 degrees = 3pi/4)
    // Sweep angle: 270 degrees (3pi/2)
    final startAngle = math.pi * 0.75;
    final sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final progressSweep = sweepAngle * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}

class _StartRideAction extends StatefulWidget {
  const _StartRideAction({
    required this.strings,
    required this.onStartRide,
    required this.isRideActive,
  });
  final AppStrings strings;
  final VoidCallback onStartRide;
  final bool isRideActive;

  @override
  State<_StartRideAction> createState() => _StartRideActionState();
}

class _StartRideActionState extends State<_StartRideAction>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    // Brief delay for visual effect, then trigger action
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        widget.onStartRide();
        // Reset pressed state after action
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _isPressed = false);
        });
      }
    });
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.isRideActive
        ? const Color(0xFFEF4444)
        : const Color(0xFF0EA5E9);

    final buttonText = widget.isRideActive
        ? widget.strings.t(
            tr: 'Sürüşü Bitir',
            en: 'End Ride',
            de: 'Fahrt beenden',
          )
        : widget.strings.t(
            tr: 'Sürüşü Başlat',
            en: 'Start Ride',
            de: 'Fahrt starten',
          );

    return Column(
      children: [
        GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: buttonColor, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Idle state: text + arrow on right (slides right & fades) ──
                AnimatedOpacity(
                  opacity: _isPressed ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 280),
                  child: AnimatedSlide(
                    offset: _isPressed ? const Offset(0.3, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!widget.isRideActive) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Pressed state: text + arrow (slides in from left) ──
                AnimatedOpacity(
                  opacity: _isPressed ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    offset: _isPressed ? Offset.zero : const Offset(-0.2, 0),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF10B981),
                size: 14,
              ), // Green
              const SizedBox(width: 6),
              Text(
                widget.strings.t(
                  tr: 'Kritik arıza algılanmadı',
                  en: 'No critical issues detected',
                  de: 'Keine kritischen Probleme erkannt',
                ),
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.strings,
    this.onOpenGarage,
    this.onOpenServiceEntry,
  });
  final AppStrings strings;
  final VoidCallback? onOpenGarage;
  final VoidCallback? onOpenServiceEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Dark card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFACC15),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                strings.t(
                  tr: 'Servis süresi aşıldı',
                  en: 'Service overdue',
                  de: 'Service überfällig',
                ),
                style: const TextStyle(
                  color: Color(0xFFFACC15),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            strings.t(
              tr: 'Sürüşe devam edebilirsiniz.\nUzun rota öncesinde servis önerilir.',
              en: 'You can continue riding.\nService is suggested before long routes.',
              de: 'Sie können weiterfahren.\nEin Service vor langen Strecken wird empfohlen.',
            ),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (onOpenServiceEntry != null) {
                  onOpenServiceEntry!.call();
                } else if (onOpenGarage != null) {
                  onOpenGarage!.call();
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.t(
                      tr: 'Servis Planla',
                      en: 'Plan Service',
                      de: 'Service planen',
                    ),
                    style: const TextStyle(
                      color: Color(0xFFFACC15),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFACC15),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MachineHealthRow extends StatelessWidget {
  const _MachineHealthRow({required this.state, required this.strings});
  final DashboardState state;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.t(
            tr: 'Makine Sağlığı',
            en: 'Machine Health',
            de: 'Maschinenzustand',
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HealthColumn(
                icon: Icons.sync,
                label: strings.t(tr: 'Uyum', en: 'Sync', de: 'Harmonie'),
                value: '${state.harmony.score}%',
                valueColor: const Color(0xFFFACC15),
              ),
              _Divider(),
              _HealthColumn(
                icon: Icons.water_drop_outlined,
                label: strings.t(tr: 'Yağ', en: 'Oil', de: 'Öl'),
                value: state.bike.oilHealthPercent == -1
                    ? '—'
                    : '${state.bike.oilHealthPercent}%',
                valueColor: const Color(0xFF10B981),
              ),
              _Divider(),
              _HealthColumn(
                icon: Icons.battery_charging_full,
                label: strings.t(tr: 'Akü', en: 'Battery', de: 'Batterie'),
                value: state.bike.batteryHealthPercent == -1
                    ? '—'
                    : '${state.bike.batteryHealthPercent}%',
                valueColor: const Color(0xFF10B981),
              ),
              _Divider(),
              _HealthColumn(
                icon: Icons.build_outlined,
                label: strings.t(tr: 'Servis', en: 'Service', de: 'Service'),
                value: state.bike.kmUntilService < 0
                    ? '${-state.bike.kmUntilService} '
                    : '${state.bike.kmUntilService} ',
                suffix: state.bike.kmUntilService < 0
                    ? strings.t(
                        tr: 'km gecikti',
                        en: 'km overdue',
                        de: 'km überfällig',
                      )
                    : 'km',
                valueColor: state.bike.kmUntilService < 0
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFACC15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _HealthColumn extends StatelessWidget {
  const _HealthColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.suffix = '',
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: valueColor, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (suffix.isNotEmpty)
              Text(
                suffix,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}

class _AttentionRequiredList extends StatelessWidget {
  const _AttentionRequiredList({
    required this.state,
    required this.strings,
    this.onOpenPartStatus,
  });
  final DashboardState state;
  final AppStrings strings;
  final VoidCallback? onOpenPartStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              strings.t(
                tr: 'Dikkat Gerektirenler',
                en: 'Attention Required',
                de: 'Aufmerksamkeit erforderlich',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _AttentionRow(
                icon: Icons.radio_button_unchecked,
                label: strings.t(tr: 'Lastikler', en: 'Tires', de: 'Reifen'),
                percent: state.bike.tireWearPercent == -1
                    ? 50
                    : state.bike.tireWearPercent,
                strings: strings,
                onTap: onOpenPartStatus,
              ),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
              _AttentionRow(
                icon: Icons.album_outlined,
                label: strings.t(tr: 'Frenler', en: 'Brakes', de: 'Bremsen'),
                percent: state.bike.brakeWearPercent == -1
                    ? 50
                    : state.bike.brakeWearPercent,
                strings: strings,
                onTap: onOpenPartStatus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.icon,
    required this.label,
    required this.percent,
    required this.strings,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int percent;
  final AppStrings strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Determine color and status word based on percent
    // In design, 50% is Yellow (Orta)
    final isCritical = percent < 20;
    final color = isCritical
        ? const Color(0xFFEF4444)
        : const Color(0xFFFACC15);
    final statusText = isCritical
        ? strings.t(tr: 'Kritik', en: 'Critical', de: 'Kritisch')
        : strings.t(tr: 'Orta', en: 'Moderate', de: 'Mittel');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFACC15), size: 24),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '%$percent',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}
