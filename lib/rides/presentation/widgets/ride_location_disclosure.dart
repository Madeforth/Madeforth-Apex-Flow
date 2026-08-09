import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

const _privacyPolicyHost = 'apex-flow-privacy-7baea.web.app';

/// Shows Google's required prominent disclosure immediately before the first
/// Android/iOS location permission request. Once a device permission already
/// exists, the OS has recorded the user's choice and the dialog is not shown
/// on every ride.
Future<bool> confirmRideLocationUse(
  BuildContext context,
  String languageCode,
) async {
  if (kIsWeb) return true;

  LocationPermission permission;
  try {
    permission = await Geolocator.checkPermission();
  } catch (_) {
    // If the platform channel is not ready yet, fail closed and still show the
    // disclosure before RideLocationService attempts the OS permission flow.
    permission = LocationPermission.denied;
  }
  if (permission != LocationPermission.denied || !context.mounted) return true;

  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.location_on_outlined, color: context.colors.cyan),
          const SizedBox(width: ApexSpacing.x1),
          Expanded(
            child: Text(
              tInline(
                languageCode,
                'Sürüş Konumu',
                'Ride Location',
                'Fahrtstandort',
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tInline(
                languageCode,
                'Apex Flow, yalnızca sizin başlattığınız aktif sürüş sırasında kesin konumunuzu kullanır. Konum; mesafe, hız ve sürüş telemetrisi hesaplamak için işlenir.',
                'Apex Flow uses your precise location only during a ride you start. Location is processed to calculate distance, speed, and ride telemetry.',
                'Apex Flow verwendet Ihren genauen Standort nur während einer von Ihnen gestarteten Fahrt, um Distanz, Geschwindigkeit und Telemetrie zu berechnen.',
              ),
            ),
            const SizedBox(height: ApexSpacing.x1),
            Text(
              tInline(
                languageCode,
                'Ekran kilitlendiğinde veya uygulama küçültüldüğünde takip, görünür “Sürüş Devam Ediyor” bildirimiyle sürebilir. Sürüşü bitirdiğinizde takip hemen durur. Sürüş rota örnekleri cihazınızda kalır ve reklam için kullanılmaz.',
                'Tracking may continue with a visible “Ride in Progress” notification while the screen is locked or the app is minimized. It stops immediately when you end the ride. Ride route samples remain on your device and are not used for advertising.',
                'Bei gesperrtem Bildschirm oder minimierter App kann die Aufzeichnung mit einer sichtbaren Benachrichtigung fortgesetzt werden. Sie endet sofort mit dem Beenden der Fahrt. Routendaten bleiben auf Ihrem Gerät und werden nicht für Werbung verwendet.',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: ApexSpacing.x1),
            TextButton(
              onPressed: () => launchUrl(
                Uri.https(_privacyPolicyHost, '/', {'lang': languageCode}),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                tInline(
                  languageCode,
                  'Gizlilik Politikasını Oku',
                  'Read Privacy Policy',
                  'Datenschutzerklärung lesen',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            tInline(languageCode, 'Şimdi Değil', 'Not Now', 'Nicht jetzt'),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(tInline(languageCode, 'Devam Et', 'Continue', 'Weiter')),
        ),
      ],
    ),
  );

  return accepted ?? false;
}
