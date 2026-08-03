import 'package:flutter/material.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/presentation/tr_accident_wizard_screen.dart';
import 'package:apexflow/garage/presentation/eu_accident_wizard_screen.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class AccidentRegionSelectorScreen extends StatelessWidget {
  const AccidentRegionSelectorScreen({super.key, required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(
            strings.languageCode,
            'Kaza Tutanağı Türü',
            'Accident Report Type',
            'Unfallberichtstyp',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: context.colors.caution,
            ),
            const SizedBox(height: 24),
            Text(
              tInline(
                strings.languageCode,
                'Lütfen kazanın gerçekleştiği bölgeye uygun tutanak standartını seçin.',
                'Please select the accident report standard appropriate for the region.',
                'Bitte wählen Sie den entsprechenden Unfallberichtsstandard aus.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrAccidentWizardScreen(strings: strings),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'TÜRKİYE (SBM Standartı)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EuAccidentWizardScreen(strings: strings),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'EUROPEAN UNION (EAS Standard)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
