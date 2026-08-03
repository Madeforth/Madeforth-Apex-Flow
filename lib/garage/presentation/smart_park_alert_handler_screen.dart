import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/notifications/apex_notification_service.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class SmartParkAlertHandlerScreen extends StatefulWidget {
  const SmartParkAlertHandlerScreen({
    super.key,
    required this.riderTag,
    required this.strings,
  });

  final String riderTag;
  final AppStrings strings;

  @override
  State<SmartParkAlertHandlerScreen> createState() =>
      _SmartParkAlertHandlerScreenState();
}

class _SmartParkAlertHandlerScreenState
    extends State<SmartParkAlertHandlerScreen> {
  bool _isSending = false;
  String? _successMessage;

  Future<void> _sendAlert(String type, String bodyTr, String bodyEn) async {
    setState(() {
      _isSending = true;
      _successMessage = null;
    });

    HapticFeedback.heavyImpact();

    final tr = widget.strings.locale.languageCode == 'tr';
    final title = tInline(
      widget.strings.languageCode,
      'Akıllı Park Uyarısı',
      'Smart Park Alert',
      'Smart-Park-Alarm',
    );
    final body = tr ? bodyTr : bodyEn;

    try {
      await ApexNotificationService.instance.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: title,
        body: body,
      );

      setState(() {
        _isSending = false;
        _successMessage = tInline(
          widget.strings.languageCode,
          'Bildirim başarıyla sahibine gönderildi!',
          'Notification sent successfully to the owner!',
          'Benachrichtigung erfolgreich an den Eigentümer gesendet!',
        );
      });
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tInline(
                widget.strings.languageCode,
                'Hata oluştu, tekrar deneyin.',
                'Error sending alert, try again.',
                'Beim Senden der Benachrichtigung ist ein Fehler aufgetreten. Versuchen Sie es erneut.',
              ),
            ),
            backgroundColor: context.colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          tInline(
            widget.strings.languageCode,
            'Park Uyarısı Gönder',
            'Send Park Alert',
            'Parkalarm senden',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Akıllı Park İrtibat',
                  'Smart Park Contact',
                  'Smart Park-Kontakt',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Aşağıdaki seçeneklerden birini seçerek motosiklet sahibi olan ${widget.riderTag} kullanıcısına anonim bir acil durum uyarısı gönderebilirsiniz.',
                  'Select one of the options below to send an anonymous emergency warning to motorcycle owner ${widget.riderTag}.',
                  'Wählen Sie eine der folgenden Optionen aus, um eine anonyme Notfallwarnung an den Motorradbesitzer ${widget.riderTag} zu senden.',
                ),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.cyan.withValues(alpha: 0.1),
                    border: Border.all(
                      color: context.colors.cyan.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: context.colors.cyan,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tInline(
                                widget.strings.languageCode,
                                'Başarılı',
                                'Success',
                                'Erfolg',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _successMessage!,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Expanded(
                child: ListView(
                  children: [
                    _AlertOptionCard(
                      title: tInline(
                        widget.strings.languageCode,
                        'Motor Devrildi!',
                        'Bike Tipped Over!',
                        'Fahrrad umgekippt!',
                      ),
                      subtitle: tInline(
                        widget.strings.languageCode,
                        'Motosikletin yan yattığını veya devrildiğini bildirir.',
                        'Report that the bike is on its side or has fallen.',
                        'Melden Sie, dass das Fahrrad auf der Seite liegt oder heruntergefallen ist.',
                      ),
                      color: Colors.redAccent,
                      icon: Icons.error_outline,
                      isSending: _isSending,
                      onTap: () => _sendAlert(
                        'tipped_over',
                        'Apex Flow Akıllı Park: Biri motorunuzun devrildiğini bildirdi!',
                        'Apex Flow Smart Park: Someone reported your bike is tipped over!',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AlertOptionCard(
                      title: tInline(
                        widget.strings.languageCode,
                        'Hatalı Park / Engelleme',
                        'Bad Parking / Blocked',
                        'Schlechter Parkplatz / blockiert',
                      ),
                      subtitle: tInline(
                        widget.strings.languageCode,
                        'Motosikletin başka araçların çıkışını engellediğini bildirir.',
                        'Report that the bike is blocking other vehicles\' exit.',
                        'Melden Sie, dass das Fahrrad die Ausfahrt anderer Fahrzeuge blockiert.',
                      ),
                      color: Colors.orangeAccent,
                      icon: Icons.warning_amber_outlined,
                      isSending: _isSending,
                      onTap: () => _sendAlert(
                        'bad_parking',
                        'Apex Flow Akıllı Park: Biri hatalı park uyarısı gönderdi!',
                        'Apex Flow Smart Park: Someone sent a bad parking warning!',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AlertOptionCard(
                      title: tInline(
                        widget.strings.languageCode,
                        'Çekici Tehlikesi!',
                        'Towing Danger!',
                        'Abschleppgefahr!',
                      ),
                      subtitle: tInline(
                        widget.strings.languageCode,
                        'Motosikletin çekilmek üzere olduğunu veya zabıta uyarısı olduğunu bildirir.',
                        'Report that the bike is about to be towed or police warning.',
                        'Melden Sie, dass das Fahrrad abgeschleppt werden soll, oder warnen Sie die Polizei.',
                      ),
                      color: Colors.amber,
                      icon: Icons.local_shipping_outlined,
                      isSending: _isSending,
                      onTap: () => _sendAlert(
                        'towing',
                        'Apex Flow Akıllı Park: Motorunuzun çekilmek üzere olduğunu bildiren acil uyarı!',
                        'Apex Flow Smart Park: Emergency warning that your bike is about to be towed!',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertOptionCard extends StatelessWidget {
  const _AlertOptionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.isSending,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSending ? null : onTap,
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.elevated,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
