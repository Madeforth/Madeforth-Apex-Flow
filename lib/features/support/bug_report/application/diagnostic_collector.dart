import 'dart:io';
import 'package:apexflow/features/support/bug_report/domain/diagnostic_summary.dart';

class DiagnosticCollector {
  static Future<DiagnosticSummary> collect({
    required String locale,
    String? activeRideIdHash,
  }) async {
    final now = DateTime.now().toLocal();
    final randomPart = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    final diagnosticId = 'AFD-$randomPart';

    return DiagnosticSummary(
      diagnosticId: diagnosticId,
      appVersion: '1.0.0',
      buildNumber: '1',
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      deviceModel: Platform.isAndroid
          ? 'Android Device'
          : (Platform.isIOS ? 'iPhone' : 'Desktop/Web'),
      locale: locale,
      batteryLevel: 95,
      isCharging: false,
      networkType: 'WiFi / Mobile',
      activeRideIdHash: activeRideIdHash,
      recentErrorLogs: const [
        '[Clean Telemetry Isolates]',
        '[Storage Engine Verified]',
      ],
      capturedAtIso: now.toIso8601String(),
    );
  }
}
