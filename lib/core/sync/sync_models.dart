import 'dart:convert';
import 'package:crypto/crypto.dart';

enum SyncState {
  localOnly,
  pending,
  syncing,
  synced,
  conflict,
  failedPermanent,
}

enum SyncOperationType { upsert, delete }

enum SyncOperationState {
  pending,
  syncing,
  completed,
  failedTransient,
  failedPermanent,
}

enum SyncReason {
  localMutation,
  appForeground,
  authChange,
  networkRestored,
  userRequested,
  scheduledBackground,
}

class SyncableEntityMetadata {
  const SyncableEntityMetadata({
    required this.entityId,
    this.schemaVersion = 1,
    this.localRevision = 1,
    this.remoteRevision,
    required this.updatedAtUtc,
    required this.updatedByDeviceId,
    this.syncState = SyncState.pending,
    this.deleted = false,
    this.neverUpload = false,
  });

  final String entityId;
  final int schemaVersion;
  final int localRevision;
  final int? remoteRevision;
  final DateTime updatedAtUtc;
  final String updatedByDeviceId;
  final SyncState syncState;
  final bool deleted;
  final bool neverUpload;

  SyncableEntityMetadata copyWith({
    String? entityId,
    int? schemaVersion,
    int? localRevision,
    int? remoteRevision,
    DateTime? updatedAtUtc,
    String? updatedByDeviceId,
    SyncState? syncState,
    bool? deleted,
    bool? neverUpload,
  }) {
    return SyncableEntityMetadata(
      entityId: entityId ?? this.entityId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      localRevision: localRevision ?? this.localRevision,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      updatedByDeviceId: updatedByDeviceId ?? this.updatedByDeviceId,
      syncState: syncState ?? this.syncState,
      deleted: deleted ?? this.deleted,
      neverUpload: neverUpload ?? this.neverUpload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'schemaVersion': schemaVersion,
      'localRevision': localRevision,
      'remoteRevision': remoteRevision,
      'updatedAtUtc': updatedAtUtc.toIso8601String(),
      'updatedByDeviceId': updatedByDeviceId,
      'syncState': syncState.name,
      'deleted': deleted,
      'neverUpload': neverUpload,
    };
  }

  factory SyncableEntityMetadata.fromJson(Map<String, dynamic> json) {
    return SyncableEntityMetadata(
      entityId: json['entityId'] as String? ?? '',
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      localRevision: (json['localRevision'] as num?)?.toInt() ?? 1,
      remoteRevision: (json['remoteRevision'] as num?)?.toInt(),
      updatedAtUtc: json['updatedAtUtc'] != null
          ? DateTime.parse(json['updatedAtUtc'] as String)
          : DateTime.now().toUtc(),
      updatedByDeviceId: json['updatedByDeviceId'] as String? ?? 'device_local',
      syncState: SyncState.values.firstWhere(
        (e) => e.name == json['syncState'],
        orElse: () => SyncState.pending,
      ),
      deleted: json['deleted'] as bool? ?? false,
      neverUpload: json['neverUpload'] as bool? ?? false,
    );
  }
}

class SyncOperation {
  const SyncOperation({
    required this.operationId,
    required this.idempotencyKey,
    required this.entityType,
    required this.entityId,
    required this.type,
    required this.baseRemoteRevision,
    required this.targetLocalRevision,
    required this.payloadJson,
    required this.payloadSha256,
    required this.createdAtUtc,
    this.attemptCount = 0,
    this.nextAttemptAtUtc,
    this.lastErrorCode,
    this.state = SyncOperationState.pending,
  });

  final String operationId;
  final String idempotencyKey;
  final String entityType;
  final String entityId;
  final SyncOperationType type;
  final int baseRemoteRevision;
  final int targetLocalRevision;
  final String payloadJson;
  final String payloadSha256;
  final DateTime createdAtUtc;
  final int attemptCount;
  final DateTime? nextAttemptAtUtc;
  final String? lastErrorCode;
  final SyncOperationState state;

  static String computeSha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  SyncOperation copyWith({
    String? operationId,
    String? idempotencyKey,
    String? entityType,
    String? entityId,
    SyncOperationType? type,
    int? baseRemoteRevision,
    int? targetLocalRevision,
    String? payloadJson,
    String? payloadSha256,
    DateTime? createdAtUtc,
    int? attemptCount,
    DateTime? nextAttemptAtUtc,
    String? lastErrorCode,
    SyncOperationState? state,
  }) {
    return SyncOperation(
      operationId: operationId ?? this.operationId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      type: type ?? this.type,
      baseRemoteRevision: baseRemoteRevision ?? this.baseRemoteRevision,
      targetLocalRevision: targetLocalRevision ?? this.targetLocalRevision,
      payloadJson: payloadJson ?? this.payloadJson,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAtUtc: nextAttemptAtUtc ?? this.nextAttemptAtUtc,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'idempotencyKey': idempotencyKey,
      'entityType': entityType,
      'entityId': entityId,
      'type': type.name,
      'baseRemoteRevision': baseRemoteRevision,
      'targetLocalRevision': targetLocalRevision,
      'payloadJson': payloadJson,
      'payloadSha256': payloadSha256,
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'attemptCount': attemptCount,
      'nextAttemptAtUtc': nextAttemptAtUtc?.toIso8601String(),
      'lastErrorCode': lastErrorCode,
      'state': state.name,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      operationId: json['operationId'] as String? ?? '',
      idempotencyKey: json['idempotencyKey'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncOperationType.upsert,
      ),
      baseRemoteRevision: (json['baseRemoteRevision'] as num?)?.toInt() ?? 0,
      targetLocalRevision: (json['targetLocalRevision'] as num?)?.toInt() ?? 1,
      payloadJson: json['payloadJson'] as String? ?? '{}',
      payloadSha256: json['payloadSha256'] as String? ?? '',
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.parse(json['createdAtUtc'] as String)
          : DateTime.now().toUtc(),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      nextAttemptAtUtc: json['nextAttemptAtUtc'] != null
          ? DateTime.tryParse(json['nextAttemptAtUtc'] as String)
          : null,
      lastErrorCode: json['lastErrorCode'] as String?,
      state: SyncOperationState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => SyncOperationState.pending,
      ),
    );
  }
}

class SyncDomainManifest {
  const SyncDomainManifest({
    required this.manifestVersion,
    required this.generatedAtUtc,
    required this.domains,
  });

  final int manifestVersion;
  final DateTime generatedAtUtc;
  final Map<String, DomainSnapshotHeader> domains;

  Map<String, dynamic> toJson() {
    return {
      'manifestVersion': manifestVersion,
      'generatedAtUtc': generatedAtUtc.toIso8601String(),
      'domains': domains.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  factory SyncDomainManifest.fromJson(Map<String, dynamic> json) {
    final rawDomains = json['domains'] as Map<String, dynamic>? ?? {};
    return SyncDomainManifest(
      manifestVersion: (json['manifestVersion'] as num?)?.toInt() ?? 1,
      generatedAtUtc: json['generatedAtUtc'] != null
          ? DateTime.parse(json['generatedAtUtc'] as String)
          : DateTime.now().toUtc(),
      domains: rawDomains.map(
        (k, v) => MapEntry(
          k,
          DomainSnapshotHeader.fromJson(v as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class DomainSnapshotHeader {
  const DomainSnapshotHeader({
    required this.revision,
    required this.checksum,
    required this.shardCount,
    required this.payloadSizeBytes,
  });

  final int revision;
  final String checksum;
  final int shardCount;
  final int payloadSizeBytes;

  Map<String, dynamic> toJson() {
    return {
      'revision': revision,
      'checksum': checksum,
      'shardCount': shardCount,
      'payloadSizeBytes': payloadSizeBytes,
    };
  }

  factory DomainSnapshotHeader.fromJson(Map<String, dynamic> json) {
    return DomainSnapshotHeader(
      revision: (json['revision'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String? ?? '',
      shardCount: (json['shardCount'] as num?)?.toInt() ?? 1,
      payloadSizeBytes: (json['payloadSizeBytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class SyncSummary {
  const SyncSummary({
    required this.status,
    required this.pendingCount,
    required this.lastSyncedAtUtc,
    this.lastErrorMessage,
  });

  final SyncState status;
  final int pendingCount;
  final DateTime? lastSyncedAtUtc;
  final String? lastErrorMessage;
}

class SyncBudget {
  const SyncBudget({
    this.writesToday = 0,
    this.readsToday = 0,
    this.estimatedPayloadBytesToday = 0,
    required this.dayStartedUtc,
  });

  final int writesToday;
  final int readsToday;
  final int estimatedPayloadBytesToday;
  final DateTime dayStartedUtc;

  bool get isWithinDailyLimits => writesToday < 1000 && readsToday < 2000;
}
