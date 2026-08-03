import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class DailyMachineCheckScreen extends ConsumerStatefulWidget {
  const DailyMachineCheckScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<DailyMachineCheckScreen> createState() =>
      _DailyMachineCheckScreenState();
}

class _DailyMachineCheckScreenState
    extends ConsumerState<DailyMachineCheckScreen> {
  bool? tiresOk;
  bool? brakesOk;
  bool? chainOk;
  bool? oilOk;
  bool? batteryOk;
  bool? lightsOk;

  bool _seededTodayEntry = false;
  final TextEditingController note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';
    final de = widget.strings.locale.languageCode == 'de';
    final langCode = widget.strings.languageCode;
    final rituals = ref.watch(ritualsStateProvider);
    final garage = ref.watch(garageStateProvider);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayEntry = rituals.dailyChecks.cast<DailyCheckEntry?>().firstWhere(
      (entry) => entry?.isoDate == today,
      orElse: () => null,
    );
    final hasTodayEntry = todayEntry != null;

    if (todayEntry != null && !_seededTodayEntry) {
      _seededTodayEntry = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          tiresOk = todayEntry.tiresOk;
          chainOk = todayEntry.chainOk;
          oilOk = todayEntry.oilOk;
          brakesOk = todayEntry.brakesOk;
          batteryOk = todayEntry.batteryOk;
          lightsOk = todayEntry.lightsOk;
          note.text = todayEntry.note;
        });
      });
    }

    final checkedCount = [
      tiresOk,
      brakesOk,
      chainOk,
      oilOk,
      batteryOk,
      lightsOk,
    ].where((e) => e != null).length;
    final remainingCount = 6 - checkedCount;
    final progress = checkedCount / 6.0;
    final isComplete = remainingCount == 0;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (garage.activeBike.model.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: context.colors.cyan.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    garage.activeBike.model,
                    style: TextStyle(
                      color: context.colors.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            Text(
              tInline(
                langCode,
                'PRE-RIDE ROUTINE',
                'PRE-RIDE ROUTINE',
                'PRE-RIDE ROUTINE',
              ),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tInline(
                langCode,
                'Günlük Makine Kontrolü',
                'Daily Machine Check',
                'Täglicher Maschinencheck',
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tInline(
                langCode,
                'Sürüşten önce hızlı bir güvenlik kontrolü.',
                'A quick safety check before you ride.',
                'Ein kurzer Sicherheitscheck vor der Fahrt.',
              ),
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar
            ApexPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr
                            ? '$checkedCount / 6 kontrol edildi'
                            : (de
                                  ? '$checkedCount von 6 geprüft'
                                  : '$checkedCount of 6 checked'),
                        style: TextStyle(
                          color: context.colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: context.colors.elevated,
                    color: context.colors.cyan,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checks List
            ApexPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _CheckItem(
                    index: 1,
                    title: tInline(langCode, 'Lastikler', 'Tires', 'Reifen'),
                    subtitle: tInline(
                      langCode,
                      'Basınç ve aşınma',
                      'Pressure and visible wear',
                      'Druck und sichtbarer Verschleiß',
                    ),
                    icon: Icons.tire_repair,
                    status: tiresOk,
                    isLast: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => tiresOk = _toggle(tiresOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                  _CheckItem(
                    index: 2,
                    title: tInline(langCode, 'Frenler', 'Brakes', 'Bremsen'),
                    subtitle: tInline(
                      langCode,
                      'Kol hissi ve balata',
                      'Lever feel and pad response',
                      'Hebelgefühl und Belagantwort',
                    ),
                    icon: Icons.speed,
                    status: brakesOk,
                    isLast: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => brakesOk = _toggle(brakesOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                  _CheckItem(
                    index: 3,
                    title: tInline(langCode, 'Zincir', 'Chain', 'Kette'),
                    subtitle: tInline(
                      langCode,
                      'Gerginlik ve yağlama',
                      'Tension and lubrication',
                      'Spannung und Schmierung',
                    ),
                    icon: Icons.settings_applications_outlined,
                    status: chainOk,
                    isLast: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => chainOk = _toggle(chainOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                  _CheckItem(
                    index: 4,
                    title: tInline(langCode, 'Yağ', 'Oil', 'Öl'),
                    subtitle: tInline(
                      langCode,
                      'Seviye ve görünür kaçak',
                      'Level and visible leaks',
                      'Füllstand und sichtbare Lecks',
                    ),
                    icon: Icons.water_drop_outlined,
                    status: oilOk,
                    isLast: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => oilOk = _toggle(oilOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                  _CheckItem(
                    index: 5,
                    title: tInline(langCode, 'Akü', 'Battery', 'Batterie'),
                    subtitle: tInline(
                      langCode,
                      'Şarj ve terminaller',
                      'Charge and terminals',
                      'Ladung und Klemmen',
                    ),
                    icon: Icons.battery_charging_full,
                    status: batteryOk,
                    isLast: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => batteryOk = _toggle(batteryOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                  _CheckItem(
                    index: 6,
                    title: tInline(
                      langCode,
                      'Aydınlatma',
                      'Lights & signals',
                      'Beleuchtung',
                    ),
                    subtitle: tInline(
                      langCode,
                      'Far, stop, sinyaller',
                      'Headlight, brake light, indicators',
                      'Scheinwerfer, Bremslicht, Blinker',
                    ),
                    icon: Icons.lightbulb_outline,
                    status: lightsOk,
                    isLast: true,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => lightsOk = _toggle(lightsOk));
                    },
                    tr: tr,
                    de: de,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note
            Text(
              tInline(
                langCode,
                'Sürüş notu (opsiyonel)',
                'Ride note (optional)',
                'Fahrtnotiz (optional)',
              ),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: note,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: tInline(
                  langCode,
                  'Hatırlamak istediğiniz bir şey var mı?',
                  'Anything you want to remember?',
                  'Etwas, woran Sie sich erinnern möchten?',
                ),
                hintStyle: TextStyle(
                  color: context.colors.textSecondary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Status
            if (!isComplete)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.colors.cyan.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: context.colors.cyan,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr
                                ? '$remainingCount kontrol kaldı'
                                : (de
                                      ? '$remainingCount Checks ausstehend'
                                      : '$remainingCount checks remaining'),
                            style: TextStyle(
                              color: context.colors.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tInline(
                              langCode,
                              'Sürüşe hazır olmak için kalan öğeleri tamamlayın.',
                              'Complete the highlighted items to update ride readiness.',
                              'Vervollständigen Sie die markierten Elemente.',
                            ),
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

            const SizedBox(height: 16),

            // Complete Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplete
                      ? context.colors.cyan
                      : context.colors.elevated,
                  foregroundColor: isComplete
                      ? context.colors.onAccent
                      : context.colors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: isComplete
                    ? () => _saveAndExit(today, hasTodayEntry)
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tInline(
                        langCode,
                        'Kontrolü Tamamla',
                        'Complete check',
                        'Check abschließen',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isComplete) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save and finish later
            Center(
              child: TextButton(
                onPressed: () => _saveAndExit(today, hasTodayEntry),
                child: Text(
                  tInline(
                    langCode,
                    'Kaydet ve sonra devam et',
                    'Save and finish later',
                    'Speichern und später beenden',
                  ),
                  style: TextStyle(
                    color: context.colors.cyan,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  bool? _toggle(bool? current) {
    if (current == null) return true;
    if (current == true) return false;
    return true; // or null if we want 3 states loop, but typically you just toggle good/bad once touched
  }

  void _saveAndExit(String today, bool hasTodayEntry) {
    HapticFeedback.selectionClick();
    ref
        .read(ritualsStateProvider.notifier)
        .addDailyCheck(
          DailyCheckEntry(
            isoDate: today,
            tiresOk: tiresOk ?? false,
            chainOk: chainOk ?? false,
            oilOk: oilOk ?? false,
            brakesOk: brakesOk ?? false,
            lightsOk: lightsOk ?? false,
            batteryOk: batteryOk ?? false,
            note: note.text.trim(),
            loggedAtIso: DateTime.now().toUtc().toIso8601String(),
          ),
        );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            hasTodayEntry
                ? tInline(
                    widget.strings.languageCode,
                    'Bugünün kontrolü güncellendi.',
                    'Today\'s check was updated.',
                    'Der heutige Check wurde aktualisiert.',
                  )
                : tInline(
                    widget.strings.languageCode,
                    'Kontrol kaydedildi.',
                    'Check saved.',
                    'Check gespeichert.',
                  ),
          ),
        ),
      );
    Navigator.of(context).pop();
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.isLast,
    required this.onTap,
    required this.tr,
    required this.de,
  });

  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool? status;
  final bool isLast;
  final VoidCallback onTap;
  final bool tr;
  final bool de;

  @override
  Widget build(BuildContext context) {
    final color = status == null
        ? context.colors.textSecondary
        : (status == true ? context.colors.healthy : const Color(0xFFF1C40F));

    final statusText = status == null
        ? (tr ? 'Kontrol edilmedi' : (de ? 'Nicht geprüft' : 'Not checked'))
        : (status == true
              ? (tr ? 'İyi' : (de ? 'Gut' : 'Good'))
              : (tr ? 'Dikkat' : (de ? 'Überprüfen' : 'Needs attention')));

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            // Timeline line & status ring
            SizedBox(
              width: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLast)
                    Positioned(
                      top: 36,
                      bottom: -36,
                      child: Container(
                        width: 1,
                        color: status == true
                            ? context.colors.healthy
                            : context.colors.border,
                      ),
                    ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: status == true
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: context.colors.healthy,
                          )
                        : null,
                  ),
                ],
              ),
            ),

            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: context.colors.textSecondary),
            ),
            const SizedBox(width: 16),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$index. $title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Status Right Side
            Flexible(
              child: Text(
                statusText,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: status == null
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: status == true
                  ? Icon(Icons.check, size: 14, color: context.colors.healthy)
                  : null,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
