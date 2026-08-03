import 'dart:convert';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:flutter/foundation.dart';

class LocalBugOutbox {
  static const String _outboxKey = 'apexflow_bug_reports_outbox';

  static Future<List<BugReport>> getQueuedReports() async {
    try {
      await ApexKvStore.init();
      final jsonStr = await ApexKvStore.getString(_outboxKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List<dynamic> list = jsonDecode(jsonStr);
      return list
          .map((e) => BugReport.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LocalBugOutbox] Error reading outbox: $e');
      return [];
    }
  }

  static Future<void> saveReport(BugReport report) async {
    try {
      final current = await getQueuedReports();
      final index = current.indexWhere(
        (e) => e.internalBugId == report.internalBugId,
      );
      if (index >= 0) {
        current[index] = report;
      } else {
        current.insert(0, report);
      }
      await ApexKvStore.init();
      final jsonStr = jsonEncode(current.map((e) => e.toJson()).toList());
      await ApexKvStore.setString(_outboxKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalBugOutbox] Error saving report: $e');
    }
  }

  static Future<void> removeReport(String internalBugId) async {
    try {
      final current = await getQueuedReports();
      current.removeWhere((e) => e.internalBugId == internalBugId);
      await ApexKvStore.init();
      final jsonStr = jsonEncode(current.map((e) => e.toJson()).toList());
      await ApexKvStore.setString(_outboxKey, jsonStr);
    } catch (e) {
      debugPrint('[LocalBugOutbox] Error removing report: $e');
    }
  }
}
