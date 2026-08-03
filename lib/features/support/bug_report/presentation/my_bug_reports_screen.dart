import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/features/support/bug_report/application/my_bug_reports_controller.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:apexflow/features/support/bug_report/presentation/bug_report_detail_screen.dart';
import 'package:apexflow/features/support/bug_report/presentation/bug_report_screen.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBugReportsScreen extends ConsumerWidget {
  const MyBugReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = AppStrings.currentLanguageCode;
    final state = ref.watch(myBugReportsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tInline(lang, 'Raporlarım', 'My Reports', 'Meine Berichte'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.colors.cyan,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BugReportScreen()),
          ).then(
            (_) => ref.read(myBugReportsControllerProvider.notifier).refresh(),
          );
        },
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(
          tInline(lang, 'Yeni Rapor', 'New Report', 'Neuer Bericht'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(myBugReportsControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(ApexSpacing.x2),
            children: [
              if (state.isLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (state.reports.isEmpty) ...[
                ApexStatePanel(
                  icon: Icons.bug_report_outlined,
                  title: tInline(
                    lang,
                    'Henüz bildirilmiş bug yok',
                    'No reported bugs yet',
                    'Noch keine gemeldeten Fehler',
                  ),
                  message: tInline(
                    lang,
                    'Bir sorunla karşılaştığınızda "Yeni Rapor" butonuna basarak Madeforth QA ekibine iletebilirsiniz.',
                    'When you encounter an issue, tap "New Report" to notify Madeforth QA.',
                    'Wenn Sie ein Problem feststellen, tippen Sie auf "Neuer Bericht", um Madeforth QA zu benachrichtigen.',
                  ),
                ),
              ] else ...[
                for (final report in state.reports) ...[
                  _ReportCard(report: report, lang: lang),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.lang});

  final BugReport report;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, report.status.code);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BugReportDetailScreen(report: report),
          ),
        );
      },
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: ApexPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    report.status.getLabel(lang),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  report.humanBugId,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.muted,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report.whatHappened,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String code) {
    switch (code) {
      case 'submitted':
        return Colors.blue;
      case 'new':
        return Colors.orange;
      case 'needs_info':
        return Colors.amber;
      case 'confirmed':
        return Colors.purpleAccent;
      case 'in_progress':
        return context.colors.cyan;
      case 'ready_for_retest':
        return Colors.tealAccent;
      case 'fixed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return context.colors.cyan;
    }
  }
}
