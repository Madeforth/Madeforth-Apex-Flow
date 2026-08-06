import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/rides/application/ride_detection_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/presentation/widgets/start_ride_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Small bottom banner shown app-wide when [RideDetectionController]
/// flags sustained motion while auto-detection is on and no ride is active
/// yet. Deliberately asks for confirmation rather than auto-starting a
/// ride — motion alone (e.g. walking, being a car passenger) can't reliably
/// tell a real ride apart on its own.
class RideDetectionPromptBanner extends ConsumerWidget {
  const RideDetectionPromptBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detection = ref.watch(rideDetectionProvider);
    final isRideActive = ref.watch(
      rideStateProvider.select((s) => s.isRideActive),
    );
    final strings = AppStrings(ref.watch(appSettingsProvider).locale);

    final shouldShow =
        detection.autoRideDetectionEnabled &&
        detection.motionDetected &&
        !detection.dismissed &&
        !isRideActive;

    if (!shouldShow) return const SizedBox.shrink();

    return Positioned(
      left: 12,
      right: 12,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.colors.cyan.withValues(alpha: 0.4),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 16),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.motorcycle, color: context.colors.cyan, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tInline(
                          strings.languageCode,
                          'Hareket algılandı',
                          'Motion detected',
                          'Bewegung erkannt',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: context.colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tInline(
                          strings.languageCode,
                          'Sürüşe mi başlıyorsun?',
                          'Are you starting a ride?',
                          'Beginnst du eine Fahrt?',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(rideDetectionProvider.notifier).dismissPrompt();
                  },
                  child: Text(
                    tInline(strings.languageCode, 'Hayır', 'No', 'Nein'),
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(rideDetectionProvider.notifier).dismissPrompt();
                    showQuickStartRideSheet(context, ref, strings);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.cyan,
                    foregroundColor: context.colors.onAccent,
                  ),
                  child: Text(
                    tInline(strings.languageCode, 'Başlat', 'Start', 'Starten'),
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
