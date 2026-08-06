import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/features/support/bug_report/application/diagnostic_collector.dart';
import 'package:apexflow/features/support/bug_report/data/local_bug_outbox.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report_enums.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        diagnostic: diagnostic,
        createdAtIso: now.toIso8601String(),
        updatedAtIso: now.toIso8601String(),
      );

      // Save locally to outbox — throws on failure (e.g. storage full),
      // which the outer catch below turns into a surfaced error instead of
      // a false "submitted" result.
      await LocalBugOutbox.saveReport(report);

      // Dispatch to the server, which drafts the Firestore doc that the
      // dispatchBugReportToDiscord trigger picks up. Without this call the
      // report never leaves the device — it only ever sat in the local
      // outbox above (AF-AG-016 diagnosis, 2026-08-06).
      final finalReport = await _dispatchToServer(report);
      await LocalBugOutbox.removeReport(report.internalBugId);
      await LocalBugOutbox.saveReport(finalReport);

      state = state.copyWith(
        isSubmitting: false,
        lastSubmittedReport: finalReport,
      );
      return finalReport;
    } catch (e) {
      // The local copy (with client-generated ids) is already saved above,
      // so the report isn't lost — but it hasn't reached Discord, so this
      // must not be reported to the caller as a success.
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  /// Calls the createBugReportDraft Cloud Function and returns [local]
  /// updated with the server-issued ids (the server is the source of truth
  /// for internalBugId/humanBugId — it never accepts client-chosen ones).
  Future<BugReport> _dispatchToServer(BugReport local) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Not signed in — cannot reach the bug report server.');
    }

    final callable = FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).httpsCallable('createBugReportDraft');

    final result = await callable.call<Map<String, dynamic>>({
      'category': local.category.name,
      'priority': local.priority.name,
      'title': local.title,
      'whatHappened': local.whatHappened,
      'expectedBehavior': local.expectedBehavior,
      'stepsToReproduce': local.stepsToReproduce,
      'idempotencyKey': local.idempotencyKey,
      'diagnostic': local.diagnostic?.toJson(),
    });

    final data = result.data;
    return BugReport(
      internalBugId: data['internalBugId'] as String,
      humanBugId: data['humanBugId'] as String,
      reporterUid: local.reporterUid,
      category: local.category,
      priority: local.priority,
      status: local.status,
      title: local.title,
      whatHappened: local.whatHappened,
      expectedBehavior: local.expectedBehavior,
      stepsToReproduce: local.stepsToReproduce,
      idempotencyKey: local.idempotencyKey,
      diagnostic: local.diagnostic,
      createdAtIso: (data['createdAtIso'] as String?) ?? local.createdAtIso,
      updatedAtIso: local.updatedAtIso,
    );
  }
}

final bugReportControllerProvider =
    StateNotifierProvider<BugReportController, BugReportSubmissionState>(
      (ref) => BugReportController(),
    );
