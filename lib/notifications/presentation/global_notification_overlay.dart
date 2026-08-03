import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/notifications/application/parking_notification_state.dart';

class GlobalNotificationOverlay extends ConsumerWidget {
  const GlobalNotificationOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationAsync = ref.watch(parkingNotificationStreamProvider);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final tr = lang == 'tr';
    final de = lang == 'de';
    String t(String trStr, String enStr, String deStr) =>
        tr ? trStr : (de ? deStr : enStr);

    return notificationAsync.when(
      data: (data) {
        if (data == null)
          return const SizedBox.shrink(); // No unread notification

        final reason = data['reason'] as String? ?? 'Acil Durum';
        final docId = data['id'] as String;

        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: Colors.black.withOpacity(0.90),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t(
                      'ACİL PARK BİLDİRİMİ',
                      'EMERGENCY PARKING ALERT',
                      'NOTFALL-PARKBENACHRICHTIGUNG',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reason,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t(
                      'Aracınızın QR kodunu okutan bir kişi az önce bu bildirimi gönderdi.',
                      'Someone just scanned your vehicle\'s QR code and sent this alert.',
                      'Jemand hat gerade den QR-Code Ihres Fahrzeugs gescannt und diesen Alarm gesendet.',
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    t(
                      'CANLI CEVAP GÖNDER',
                      'SEND LIVE REPLY',
                      'LIVE-ANTWORT SENDEN',
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ReplyButton(
                    text: t(
                      'Hemen Geliyorum',
                      'I am coming right now',
                      'Ich komme sofort',
                    ),
                    onPressed: () => ref
                        .read(parkingNotificationProvider.notifier)
                        .replyToNotification(
                          docId,
                          t(
                            'Hemen Geliyorum',
                            'I am coming right now',
                            'Ich komme sofort',
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ReplyButton(
                    text: t(
                      'Haberim Var, Teşekkürler',
                      'I am aware, thanks',
                      'Ich weiß Bescheid, danke',
                    ),
                    onPressed: () => ref
                        .read(parkingNotificationProvider.notifier)
                        .replyToNotification(
                          docId,
                          t('Haberim Var', 'I am aware', 'Ich weiß Bescheid'),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ReplyButton(
                    text: t(
                      'Aracı Çekmeyin, Yoldayum',
                      'Do not tow, on my way',
                      'Nicht abschleppen, ich bin unterwegs',
                    ),
                    onPressed: () => ref
                        .read(parkingNotificationProvider.notifier)
                        .replyToNotification(
                          docId,
                          t(
                            'Çekmeyin, Yoldayum',
                            'Do not tow, on my way',
                            'Nicht abschleppen',
                          ),
                        ),
                    isUrgent: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({
    required this.text,
    required this.onPressed,
    this.isUrgent = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isUrgent
              ? Colors.redAccent.withOpacity(0.2)
              : const Color(0xFF1E1E1E),
          foregroundColor: isUrgent
              ? Colors.redAccent
              : Theme.of(context).colorScheme.primary,
          side: BorderSide(color: isUrgent ? Colors.redAccent : Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
