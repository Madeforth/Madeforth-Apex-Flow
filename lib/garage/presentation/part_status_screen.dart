import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/design/apex_theme.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/application/garage_state.dart';

class PartStatusScreen extends ConsumerStatefulWidget {
  const PartStatusScreen({
    super.key,
    required this.strings,
    required this.onBack,
  });

  final AppStrings strings;
  final VoidCallback onBack;

  @override
  ConsumerState<PartStatusScreen> createState() => _PartStatusScreenState();
}

class _PartStatusScreenState extends ConsumerState<PartStatusScreen> {
  late double _chainWearPercent;
  late double _tireWearPercent;
  late double _brakeWearPercent;
  late double _oilHealthPercent;
  late double _batteryHealthPercent;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = ref.read(garageStateProvider);
      final bike = state.activeBike;
      _chainWearPercent = bike.chainWearPercent == -1
          ? 0.0
          : bike.chainWearPercent.toDouble();
      _tireWearPercent = bike.tireWearPercent == -1
          ? 0.0
          : bike.tireWearPercent.toDouble();
      _brakeWearPercent = bike.brakeWearPercent == -1
          ? 0.0
          : bike.brakeWearPercent.toDouble();
      _oilHealthPercent = bike.oilHealthPercent == -1
          ? 100.0
          : bike.oilHealthPercent.toDouble();
      _batteryHealthPercent = bike.batteryHealthPercent == -1
          ? 100.0
          : bike.batteryHealthPercent.toDouble();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textSecondary),
          onPressed: widget.onBack,
        ),
        title: Text(
          strings.garagePartStatusTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.garagePartStatusHelper,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: ApexSpacing.x4),
            _StatusSlider(
              title: strings.garageComponentEditorLabel('tire'),
              hint: strings.garageComponentEditorHint('tire'),
              componentKey: 'tire',
              value: _tireWearPercent,
              isHealth: false,
              onChanged: (val) => setState(() => _tireWearPercent = val),
            ),
            const SizedBox(height: ApexSpacing.x4),
            _StatusSlider(
              title: strings.garageComponentEditorLabel('chain'),
              hint: strings.garageComponentEditorHint('chain'),
              componentKey: 'chain',
              value: _chainWearPercent,
              isHealth: false,
              onChanged: (val) => setState(() => _chainWearPercent = val),
            ),
            const SizedBox(height: ApexSpacing.x4),
            _StatusSlider(
              title: strings.garageComponentEditorLabel('brake'),
              hint: strings.garageComponentEditorHint('brake'),
              componentKey: 'brake',
              value: _brakeWearPercent,
              isHealth: false,
              onChanged: (val) => setState(() => _brakeWearPercent = val),
            ),
            const SizedBox(height: ApexSpacing.x4),
            _StatusSlider(
              title: strings.garageComponentEditorLabel('oil'),
              hint: strings.garageComponentEditorHint('oil'),
              componentKey: 'oil',
              value: _oilHealthPercent,
              isHealth: true,
              onChanged: (val) => setState(() => _oilHealthPercent = val),
            ),
            const SizedBox(height: ApexSpacing.x4),
            _StatusSlider(
              title: strings.garageComponentEditorLabel('battery'),
              hint: strings.garageComponentEditorHint('battery'),
              componentKey: 'battery',
              value: _batteryHealthPercent,
              isHealth: true,
              onChanged: (val) => setState(() => _batteryHealthPercent = val),
            ),
            const SizedBox(height: ApexSpacing.x4),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.tune_outlined, size: 17),
                label: Text(strings.garagePartStatusSave),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.onAccent,
                  backgroundColor: context.colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    side: BorderSide(color: context.colors.cyan),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // Padding for navbar
          ],
        ),
      ),
    );
  }

  void _submit() {
    HapticFeedback.selectionClick();
    final bike = ref.read(garageStateProvider).activeBike;
    ref
        .read(garageStateProvider.notifier)
        .updateComponentHealth(
          chainWearPercent: _chainWearPercent.toInt(),
          tireWearPercent: _tireWearPercent.toInt(),
          brakeWearPercent: _brakeWearPercent.toInt(),
          oilHealthPercent: _oilHealthPercent.toInt(),
          batteryHealthPercent: _batteryHealthPercent.toInt(),
        );
    widget.onBack();
  }
}

class _StatusSlider extends StatelessWidget {
  const _StatusSlider({
    required this.title,
    required this.hint,
    required this.componentKey,
    required this.value,
    required this.isHealth,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final String componentKey;
  final double value;
  final bool isHealth;
  final ValueChanged<double> onChanged;

  String _getGuide(String component, int currentState) {
    switch (component) {
      case 'tire':
        if (currentState == 0)
          return tInline(
            AppStrings.currentLanguageCode,
            'Gözle görülür derin dişler, pürüzsüz yüzey.',
            'Visibly deep treads, smooth surface.',
            'Sichtbar tiefe Profile, glatte Oberfläche.',
          );
        if (currentState == 1)
          return tInline(
            AppStrings.currentLanguageCode,
            'Dişler silikleşmeye başlamış, ufak çatlaklar var.',
            'Treads starting to fade, minor cracks.',
            'Profile verblassen, leichte Risse.',
          );
        return tInline(
          AppStrings.currentLanguageCode,
          'Dümdüz olmuş, aşırı kabak veya teller görünüyor.',
          'Completely bald, or wires are showing.',
          'Völlig glatt, oder Drähte sichtbar.',
        );
      case 'chain':
        if (currentState == 0)
          return tInline(
            AppStrings.currentLanguageCode,
            'Zincir ıslak/yağlı duruyor, sarkma yok.',
            'Chain looks wet/lubricated, no sagging.',
            'Kette sieht nass/geschmiert aus, hängt nicht durch.',
          );
        if (currentState == 1)
          return tInline(
            AppStrings.currentLanguageCode,
            'Kuru görünüyor, zincir aşağı doğru hafif sarkmış.',
            'Looks dry, chain is slightly sagging.',
            'Sieht trocken aus, Kette hängt leicht durch.',
          );
        return tInline(
          AppStrings.currentLanguageCode,
          'Paslı lekeler var, kaskatı veya çok aşırı sarkık.',
          'Rusty spots, stiff links, or extremely sagging.',
          'Rostflecken, steife Glieder oder extrem durchhängend.',
        );
      case 'brake':
        if (currentState == 0)
          return tInline(
            AppStrings.currentLanguageCode,
            'Balata kalınlığı net görünüyor, fren kolu sert.',
            'Pad thickness is visible, brake lever feels firm.',
            'Belagdicke ist sichtbar, Bremshebel fühlt sich fest an.',
          );
        if (currentState == 1)
          return tInline(
            AppStrings.currentLanguageCode,
            'Fren yaparken ciyaklama/ötme sesi geliyor.',
            'Squeaking/chirping sound when braking.',
            'Quietschendes Geräusch beim Bremsen.',
          );
        return tInline(
          AppStrings.currentLanguageCode,
          'Balata tamamen bitik, metalin metale sürtme sesi var.',
          'Pads completely gone, metal grinding sound.',
          'Beläge komplett weg, metallisches Schleifgeräusch.',
        );
      case 'oil':
        if (currentState == 0)
          return tInline(
            AppStrings.currentLanguageCode,
            'Yağ camından bakınca rengi açık/altın sarısı.',
            'Looks clear/golden through the oil sight glass.',
            'Sieht klar/golden durch das Ölschauglas aus.',
          );
        if (currentState == 1)
          return tInline(
            AppStrings.currentLanguageCode,
            'Rengi koyulaşmış ama camda seviyesi normal.',
            'Color darkened but level is normal in the glass.',
            'Farbe abgedunkelt, aber Stand im Glas normal.',
          );
        return tInline(
          AppStrings.currentLanguageCode,
          'Simsiyah, camda yağ görünmüyor veya seviye çok dipte.',
          'Pitch black, no oil visible in glass, or very low.',
          'Pechschwarz, kein Öl im Glas sichtbar oder sehr niedrig.',
        );
      case 'battery':
        if (currentState == 0)
          return tInline(
            AppStrings.currentLanguageCode,
            'Kontak açılınca ekran ve farlar anında canlı yanıyor.',
            'Screen and lights turn on brightly instantly.',
            'Bildschirm und Lichter leuchten sofort hell auf.',
          );
        if (currentState == 1)
          return tInline(
            AppStrings.currentLanguageCode,
            'Marşa basarken ekran ışıkları çok kısılıyor/titriyor.',
            'Screen lights dim heavily/flicker when starting.',
            'Bildschirm dimmt stark/flackert beim Starten.',
          );
        return tInline(
          AppStrings.currentLanguageCode,
          'Kontak açılıyor ama marş hiç basmıyor, sadece tık sesi.',
          'Ignition turns on but starter won\'t crank, just clicks.',
          'Zündung geht an, aber Starter dreht nicht, klickt nur.',
        );
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map current value to 3 discrete states based on isHealth
    // State 0 = Good (İyi)
    // State 1 = Check (Kontrol)
    // State 2 = Replace (Değişim)
    int currentState;
    if (isHealth) {
      if (value > 70)
        currentState = 0; // Good
      else if (value > 30)
        currentState = 1; // Check
      else
        currentState = 2; // Replace
    } else {
      if (value < 30)
        currentState = 0; // Good
      else if (value < 70)
        currentState = 1; // Check
      else
        currentState = 2; // Replace
    }

    final guideText = _getGuide(componentKey, currentState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context,
                0,
                currentState,
                tInline(AppStrings.currentLanguageCode, 'İyi', 'Good', 'Gut'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOption(
                context,
                1,
                currentState,
                tInline(
                  AppStrings.currentLanguageCode,
                  'Kontrol',
                  'Check',
                  'Prüfen',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOption(
                context,
                2,
                currentState,
                tInline(
                  AppStrings.currentLanguageCode,
                  'Değişim',
                  'Replace',
                  'Ersetzen',
                ),
              ),
            ),
          ],
        ),
        if (guideText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: context.colors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    guideText,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    int stateValue,
    int currentState,
    String label,
  ) {
    final isSelected = stateValue == currentState;
    Color color;
    if (stateValue == 0)
      color = context.colors.healthy;
    else if (stateValue == 1)
      color = context.colors.caution;
    else
      color = context.colors.red;

    return InkWell(
      onTap: () {
        double newValue;
        if (isHealth) {
          if (stateValue == 0)
            newValue = 100;
          else if (stateValue == 1)
            newValue = 50;
          else
            newValue = 0;
        } else {
          if (stateValue == 0)
            newValue = 0;
          else if (stateValue == 1)
            newValue = 50;
          else
            newValue = 100;
        }
        onChanged(newValue);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : context.colors.surface,
          border: Border.all(color: isSelected ? color : context.colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
