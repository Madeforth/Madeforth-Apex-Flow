import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:flutter/material.dart';

class BugReportDetailScreen extends StatelessWidget {
  const BugReportDetailScreen({super.key, required this.report});

  final BugReport report;

  @override
  Widget build(BuildContext context) {
    final lang = AppStrings.currentLanguageCode;

    return Scaffold(
      appBar: AppBar(title: Text(report.humanBugId)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          children: [
            ApexPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: context.colors.cyan),
                        ),
                        child: Text(
                          report.status.getLabel(lang),
                          style: TextStyle(
                            color: context.colors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.elevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          report.category.tag,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    report.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: tInline(
                      lang,
                      'GERÇEKLEŞEN DURUM',
                      'WHAT HAPPENED',
                      'WAS PASSIERT IST',
                    ),
                    content: report.whatHappened,
                  ),
                  if (report.expectedBehavior.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSection(
                      context,
                      title: tInline(
                        lang,
                        'BEKLENEN BEHAVIOR',
                        'EXPECTED BEHAVIOR',
                        'ERWARTETES VERHALTEN',
                      ),
                      content: report.expectedBehavior,
                    ),
                  ],
                  if (report.stepsToReproduce.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildSection(
                      context,
                      title: tInline(
                        lang,
                        'TEKRAR ÜRETİM ADIMLARI',
                        'STEPS TO REPRODUCE',
                        'SCHRITTE',
                      ),
                      content: report.stepsToReproduce,
                    ),
                  ],
                  if (report.retestBuildInfo != null) ...[
                    const SizedBox(height: 14),
                    _buildSection(
                      context,
                      title: tInline(
                        lang,
                        'BETA TEST BİLGİSİ',
                        'RETEST BUILD INFO',
                        'RETEST-BUILD-INFO',
                      ),
                      content: report.retestBuildInfo!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ApexSpacing.x2),
            if (report.diagnostic != null) ...[
              ApexPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tInline(
                        lang,
                        'TANILAMA ÖZETİ',
                        'DIAGNOSTIC SUMMARY',
                        'DIAGNOSE-ZUSAMMENFASSUNG',
                      ),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _diagRow('ID', report.diagnostic!.diagnosticId),
                    _diagRow(
                      'Platform / OS',
                      '${report.diagnostic!.platform} ${report.diagnostic!.osVersion}',
                    ),
                    _diagRow(
                      'App Build',
                      '${report.diagnostic!.appVersion}+${report.diagnostic!.buildNumber}',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _diagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
