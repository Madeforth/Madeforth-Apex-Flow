import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/features/support/bug_report/application/bug_report_controller.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report_enums.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugReportScreen extends ConsumerStatefulWidget {
  const BugReportScreen({super.key});

  @override
  ConsumerState<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends ConsumerState<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _whatHappenedCtrl = TextEditingController();
  final _expectedCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();

  BugCategory _selectedCategory = BugCategory.uiLayout;
  bool _attachDiagnostics = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _whatHappenedCtrl.dispose();
    _expectedCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(bugReportControllerProvider.notifier);
    final report = await controller.submitReport(
      title: _titleCtrl.text,
      whatHappened: _whatHappenedCtrl.text,
      expectedBehavior: _expectedCtrl.text,
      stepsToReproduce: _stepsCtrl.text,
      category: _selectedCategory,
      attachDiagnostics: _attachDiagnostics,
      locale: AppStrings.currentLanguageCode,
    );

    if (!mounted) return;

    if (report != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              AppStrings.currentLanguageCode,
              'Rapor alındı: ${report.humanBugId}',
              'Report submitted: ${report.humanBugId}',
              'Bericht eingereicht: ${report.humanBugId}',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppStrings.currentLanguageCode;
    final submissionState = ref.watch(bugReportControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(
            lang,
            'Bug Raporu Oluştur',
            'Create Bug Report',
            'Fehlerbericht erstellen',
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(ApexSpacing.x2),
            children: [
              // RIDER SAFETY WARNING BANNER
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tInline(
                          lang,
                          'Motosiklet hareket hâlindeyken rapor oluşturmayın. Güvenli şekilde durduktan sonra devam edin.',
                          'Do not submit reports while riding. Stop safely before proceeding.',
                          'Erstellen Sie keine Berichte während der Fahrt. Halten Sie sicher an, bevor Sie fortfahren.',
                        ),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ApexSpacing.x2),

              // CATEGORY SELECTOR
              ApexPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tInline(lang, 'KATEGORİ', 'CATEGORY', 'KATEGORIE'),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<BugCategory>(
                      value: _selectedCategory,
                      dropdownColor: context.colors.surface,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: context.colors.elevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ApexSpacing.radius,
                          ),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      items: BugCategory.values.map((cat) {
                        final label = lang == 'tr'
                            ? cat.labelTr
                            : (lang == 'de' ? cat.labelDe : cat.labelEn);
                        return DropdownMenuItem(value: cat, child: Text(label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ApexSpacing.x2),

              // DETAILS FORM
              ApexPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tInline(
                        lang,
                        'SORUN DETAYLARI',
                        'ISSUE DETAILS',
                        'PROBLEM-DETAILS',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDeco(
                        tInline(
                          lang,
                          'Başlık (Örn: Yatış açısı 168° gösteriyor)',
                          'Title (e.g. Lean angle shows 168°)',
                          'Titel',
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? tInline(
                              lang,
                              'Başlık yazın',
                              'Enter a title',
                              'Titel eingeben',
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _whatHappenedCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDeco(
                        tInline(
                          lang,
                          'Gerçekte ne oldu? (Ne gördünüz / yaşadınız)',
                          'What actually happened?',
                          'Was ist passiert?',
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? tInline(
                              lang,
                              'Açıklama girin',
                              'Enter details',
                              'Details eingeben',
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _expectedCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDeco(
                        tInline(
                          lang,
                          'Ne olması gerekiyordu? (Beklenen davranış)',
                          'What was expected to happen?',
                          'Was wurde erwartet?',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _stepsCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDeco(
                        tInline(
                          lang,
                          'Tekrar üretim adımları (1. Butona bas 2. Ekranı kaydır...)',
                          'Steps to reproduce (1. Tap button 2. Scroll...)',
                          'Schritte zur Reproduktion',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ApexSpacing.x2),

              // DIAGNOSTIC CONSENT CARD
              ApexPanel(
                child: Row(
                  children: [
                    Icon(
                      Icons.perm_device_information,
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
                              lang,
                              'Sistem Tanılama Bilgileri',
                              'Attach System Diagnostics',
                              'Systemdiagnose anhaengen',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tInline(
                              lang,
                              'Cihaz modeli, OS sürümü ve anonimleştirilmiş telemetri özetini rapora ekler.',
                              'Includes device model, OS version, and safe telemetry summary.',
                              'Enthaelt Geraetemodell, OS-Version und Telemetrie-Zusammenfassung.',
                            ),
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _attachDiagnostics,
                      activeColor: context.colors.cyan,
                      onChanged: (val) =>
                          setState(() => _attachDiagnostics = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ApexSpacing.x3),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: submissionState.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  child: submissionState.isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          tInline(
                            lang,
                            'Raporu Gönder (Madeforth QA)',
                            'Submit Report (Madeforth QA)',
                            'Bericht senden (Madeforth QA)',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: context.colors.textSecondary.withValues(alpha: 0.6),
        fontSize: 13,
      ),
      filled: true,
      fillColor: context.colors.elevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        borderSide: BorderSide(color: context.colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
        borderSide: BorderSide(color: context.colors.cyan),
      ),
    );
  }
}
