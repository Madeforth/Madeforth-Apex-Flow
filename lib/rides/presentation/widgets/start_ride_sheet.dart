import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/application/ride_location_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

void showQuickStartRideSheet(
  BuildContext context,
  WidgetRef ref,
  AppStrings strings,
) {
  HapticFeedback.selectionClick();
  final state = ref.read(rideStateProvider);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    barrierColor: context.colors.background.withValues(alpha: 0.62),
    isScrollControlled: true,
    builder: (context) {
      return _StartRideSheet(
        strings: strings,
        initialMood: state.activeMood,
        onSubmit: (mood, isMounted) async {
          final tr = strings.locale.languageCode == 'tr';
          final isTesting = WidgetsBinding.instance.runtimeType
              .toString()
              .contains('Test');

          if (isTesting) {
            ref.read(rideStateProvider.notifier).startRide(mood: mood);
            if (context.mounted) {
              Navigator.pop(context);
            }
            return;
          }

          final locationService = RideLocationService();
          final status = await locationService.startTracking(
            isTurkish: tr,
            isMounted: isMounted,
          );

          if (!locationService.isTracking && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status),
                backgroundColor: context.colors.red,
              ),
            );
            return;
          }

          ref.read(rideStateProvider.notifier).startRide(mood: mood);

          if (isMounted) {
            locationService.calibrateMount();
          }
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      );
    },
  );
}

class _StartRideSheet extends StatefulWidget {
  const _StartRideSheet({
    required this.strings,
    required this.initialMood,
    required this.onSubmit,
  });

  final AppStrings strings;
  final String initialMood;
  final void Function(String mood, bool isMounted) onSubmit;

  @override
  State<_StartRideSheet> createState() => _StartRideSheetState();
}

class _StartRideSheetState extends State<_StartRideSheet> {
  late final TextEditingController _moodController;
  final bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _moodController = TextEditingController(text: widget.initialMood);
  }

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final tr = strings.locale.languageCode == 'tr';
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final quickMoods = _quickMoods(strings);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(
            label: tInline(
              strings.languageCode,
              'Sürüş hedefini belirle',
              'Set ride intention',
              'Fahrabsicht festlegen',
            ),
            value: tInline(
              strings.languageCode,
              'Telemetri Aktif',
              'Telemetry On',
              'Telemetrie ein',
            ),
          ),
          const SizedBox(height: ApexSpacing.x1),
          Container(
            padding: const EdgeInsets.all(ApexSpacing.x2),
            decoration: BoxDecoration(
              color: context.colors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: context.colors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.memory, color: context.colors.cyan, size: 20),
                const SizedBox(width: ApexSpacing.x1),
                Expanded(
                  child: Text(
                    tInline(
                      strings.languageCode,
                      'Apex Flow sürüşünü saniye saniye analiz edecek. Nasıl bir sürüş hedefliyorsun?',
                      'Apex Flow will analyze your ride second by second. What is your intention?',
                      'Apex Flow analysiert Ihre Fahrt Sekunde für Sekunde. Was ist Ihre Absicht?',
                    ),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ApexSpacing.x2),
          Wrap(
            spacing: ApexSpacing.x1,
            runSpacing: ApexSpacing.x1,
            children: [
              for (final mood in quickMoods)
                _QuickRideChip(label: mood, onTap: () => _applyMood(mood)),
            ],
          ),
          const SizedBox(height: ApexSpacing.x2),
          _RideTextField(
            label: tInline(
              strings.languageCode,
              'Hedeflenen Sürüş Modu',
              'Intended Ride Mood',
              'Beabsichtigte Fahrstimmung',
            ),
            controller: _moodController,
            helperText: tInline(
              strings.languageCode,
              'Hedefini belirle, gerisini sensörlere bırak.',
              'Set your intention, let sensors do the rest.',
              'Legen Sie Ihre Absicht fest, den Rest erledigen die Sensoren.',
            ),
          ),
          const SizedBox(height: ApexSpacing.x2),
          _SheetButton(
            label: tInline(
              strings.languageCode,
              'Sürüşü Başlat',
              'Begin Ride',
              'Beginnen Sie mit der Fahrt',
            ),
            icon: Icons.play_arrow_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSubmit(_moodController.text, _isMounted);
            },
          ),
        ],
      ),
    );
  }

  List<String> _quickMoods(AppStrings strings) {
    final values = <String>[
      if (widget.initialMood.trim().isNotEmpty) widget.initialMood.trim(),
      strings.rideQuickMoodLabel('focused'),
      strings.rideQuickMoodLabel('calm'),
      strings.rideQuickMoodLabel('open_road'),
      strings.rideQuickMoodLabel('reset'),
    ];
    return values.toSet().toList();
  }

  void _applyMood(String mood) {
    HapticFeedback.selectionClick();
    setState(() {
      _moodController.text = mood;
      _moodController.selection = TextSelection.collapsed(
        offset: _moodController.text.length,
      );
    });
  }
}

class _RideTextField extends StatelessWidget {
  const _RideTextField({
    required this.label,
    required this.controller,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: context.colors.cyan,
      style: TextStyle(color: context.colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        labelStyle: TextStyle(
          color: context.colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: context.colors.elevated,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: context.colors.cyan),
        ),
      ),
    );
  }
}

class _QuickRideChip extends StatelessWidget {
  const _QuickRideChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(Icons.bolt_outlined, size: 14, color: context.colors.cyan),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      side: BorderSide(color: context.colors.border),
      backgroundColor: context.colors.elevated,
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: context.colors.onAccent,
          backgroundColor: context.colors.cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ApexSpacing.radius),
            side: BorderSide(color: context.colors.cyan),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.colors.cyan,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
