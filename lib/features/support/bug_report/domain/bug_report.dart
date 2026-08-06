import 'package:apexflow/features/support/bug_report/domain/bug_report_enums.dart';
import 'package:apexflow/features/support/bug_report/domain/diagnostic_summary.dart';

class BugReport {
  const BugReport({
    required this.internalBugId,
    required this.humanBugId,
    required this.reporterUid,
    required this.category,
    required this.priority,
    required this.status,
    required this.title,
    required this.whatHappened,
    required this.expectedBehavior,
    required this.stepsToReproduce,
    required this.idempotencyKey,
    required this.diagnostic,
    required this.createdAtIso,
    required this.updatedAtIso,
    this.retestBuildInfo,
    this.adminNote,
  });

  final String internalBugId;
  final String humanBugId; // e.g. AFB-2026-000123
  final String reporterUid;
  final BugCategory category;
  final BugPriority priority;
  final BugStatus status;
  final String title;
  final String whatHappened;
  final String expectedBehavior;
  final String stepsToReproduce;
  final String idempotencyKey;
  final DiagnosticSummary? diagnostic;
  final String createdAtIso;
  final String updatedAtIso;
  final String? retestBuildInfo;
  final String? adminNote;

  Map<String, dynamic> toJson() {
    return {
      'internalBugId': internalBugId,
      'humanBugId': humanBugId,
      'reporterUid': reporterUid,
      'category': category.name,
      'priority': priority.name,
      'status': status.code,
      'title': title,
      'whatHappened': whatHappened,
      'expectedBehavior': expectedBehavior,
      'stepsToReproduce': stepsToReproduce,
      'idempotencyKey': idempotencyKey,
      'diagnostic': diagnostic?.toJson(),
      'createdAtIso': createdAtIso,
      'updatedAtIso': updatedAtIso,
      'retestBuildInfo': retestBuildInfo,
      'adminNote': adminNote,
    };
  }

  factory BugReport.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'other';
    final prioStr = json['priority'] as String? ?? 'p2';
    final statusStr = json['status'] as String? ?? 'submitted';

    return BugReport(
      internalBugId: json['internalBugId'] as String? ?? '',
      humanBugId: json['humanBugId'] as String? ?? 'AFB-2026-000000',
      reporterUid: json['reporterUid'] as String? ?? '',
      category: BugCategory.values.firstWhere(
        (e) => e.name == catStr,
        orElse: () => BugCategory.other,
      ),
      priority: BugPriority.values.firstWhere(
        (e) => e.name == prioStr,
        orElse: () => BugPriority.p2,
      ),
      status: BugStatus.fromCode(statusStr),
      title: json['title'] as String? ?? '',
      whatHappened: json['whatHappened'] as String? ?? '',
      expectedBehavior: json['expectedBehavior'] as String? ?? '',
      stepsToReproduce: json['stepsToReproduce'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      diagnostic: json['diagnostic'] != null
          ? DiagnosticSummary.fromJson(
              Map<String, dynamic>.from(json['diagnostic'] as Map),
            )
          : null,
      createdAtIso:
          json['createdAtIso'] as String? ?? DateTime.now().toIso8601String(),
      updatedAtIso:
          json['updatedAtIso'] as String? ?? DateTime.now().toIso8601String(),
      retestBuildInfo: json['retestBuildInfo'] as String?,
      adminNote: json['adminNote'] as String?,
    );
  }
}
