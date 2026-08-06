import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/features/support/bug_report/application/diagnostic_collector.dart';
import 'package:apexflow/features/support/bug_report/data/local_bug_outbox.dart';
import 'package:apexflow/features/support/bug_report/domain/attachment_reference.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugReportSubmissionState {
  const BugReportSubmissionState({
    this.isSubmitting = false,
    this.error,
    this.lastSubmittedReport,
  });

  final bool isSubmitting;
  final String? error;
  final BugReport? lastSubmittedReport;

  BugReportSubmissionState copyWith({
    bool? isSubmitting,
    String? error,
    BugReport? lastSubmittedReport,
  }) {
    return BugReportSubmissionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      lastSubmittedReport: lastSubmittedReport ?? this.lastSubmittedReport,
    );
  }
}

class BugReportController extends StateNotifier<BugReportSubmissionState> {
  BugReportController() : super(const BugReportSubmissionState());

  Future<BugReport?> submitReport({
    required String title,
    required String whatHappened,
    required String expectedBehavior,
    required String stepsToReproduce,
    required BugCategory category,
    required bool attachDiagnostics,
    required String locale,
    List<AttachmentReference> attachments = const [],
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final now = DateTime.now().toLocal();
      final nowMs = now.millisecondsSinceEpoch;
      final internalBugId = 'bug_$nowMs';
      final humanBugId = 'AFB-2026-${(nowMs % 900000 + 100000)}';
      final idempotencyKey = 'idempotency_$nowMs';

      final diagnostic = attachDiagnostics
          ? await DiagnosticCollector.collect(locale: locale)
          : null;

      final reporterUid = await FirebaseService.instance
          .getOrCreateInstallationId();

      final report = BugReport(
        internalBugId: internalBugId,
        humanBugId: humanBugId,
        reporterUid: reporterUid,
        category: category,
        priority: category == BugCategory.crashFreeze
            ? BugPriority.p1
            : BugPriority.p2,
        status: BugStatus.submitted,
        title: title.trim(),
        whatHappened: whatHappened.trim(),
        expectedBehavior: expectedBehavior.trim(),
        stepsToReproduce: stepsToReproduce.trim(),
        idempotencyKey: idempotencyKey,
        attachments: attachments,
        diagnostic: diagnostic,
        createdAtIso: now.toIso8601String(),
        updatedAtIso: now.toIso8601String(),
      );

      // Save locally to outbox — throws on failure (e.g. storage full),
      // which the outer catch below turns into a surfaced error instead of
      // a false "submitted" result.
      await LocalBugOutbox.saveReport(report);

      state = state.copyWith(isSubmitting: false, lastSubmittedReport: report);
      return report;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final bugReportControllerProvider =
    StateNotifierProvider<BugReportController, BugReportSubmissionState>(
      (ref) => BugReportController(),
    );
