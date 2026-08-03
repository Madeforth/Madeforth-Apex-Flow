import 'dart:io';

class DiagnosticSummary {
  const DiagnosticSummary({
    required this.diagnosticId,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.locale,
    required this.batteryLevel,
    required this.isCharging,
    required this.networkType,
    required this.activeRideIdHash,
    required this.recentErrorLogs,
    required this.capturedAtIso,
  });

  final String diagnosticId;
  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String deviceModel;
  final String locale;
  final int batteryLevel;
  final bool isCharging;
  final String networkType;
  final String? activeRideIdHash;
  final List<String> recentErrorLogs;
  final String capturedAtIso;

  Map<String, dynamic> toJson() {
    return {
      'diagnosticId': diagnosticId,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'platform': platform,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'locale': locale,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'networkType': networkType,
      'activeRideIdHash': activeRideIdHash,
      'recentErrorLogs': recentErrorLogs,
      'capturedAtIso': capturedAtIso,
    };
  }

  factory DiagnosticSummary.fromJson(Map<String, dynamic> json) {
    return DiagnosticSummary(
      diagnosticId: json['diagnosticId'] as String? ?? 'AFD-0000',
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      buildNumber: json['buildNumber'] as String? ?? '1',
      platform: json['platform'] as String? ?? Platform.operatingSystem,
      osVersion: json['osVersion'] as String? ?? '',
      deviceModel: json['deviceModel'] as String? ?? '',
      locale: json['locale'] as String? ?? 'en',
      batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 100,
      isCharging: json['isCharging'] as bool? ?? false,
      networkType: json['networkType'] as String? ?? 'wifi',
      activeRideIdHash: json['activeRideIdHash'] as String?,
      recentErrorLogs:
          (json['recentErrorLogs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      capturedAtIso:
          json['capturedAtIso'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
