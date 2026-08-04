import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sync_models.dart';
import 'sync_conflict_resolver.dart';

abstract interface class SyncCoordinator {
  Stream<SyncSummary> watchSummary();
  SyncSummary get currentSummary;
  Future<void> requestSync(SyncReason reason);
  Future<void> enqueueOperation(SyncOperation operation);
  Future<void> retryFailed();
}

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final coordinator = ApexSyncCoordinator();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

class ApexSyncCoordinator implements SyncCoordinator {
  ApexSyncCoordinator() {
    _init();
  }

  final _summaryController = StreamController<SyncSummary>.broadcast();
  final _outbox = <SyncOperation>[];
  final _conflictResolver = const SyncConflictResolver();
  final _random = math.Random();

  SyncState _status = SyncState.synced;
  DateTime? _lastSyncedAt;
  String? _lastError;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  void _init() {
    _loadOutboxFromStorage();
  }

  void _loadOutboxFromStorage() {
    try {
      final rawList = ApexKvStore.getStringList('sync.outbox_queue') ?? [];
      _outbox.clear();
      for (final jsonStr in rawList) {
        try {
          _outbox.add(
            SyncOperation.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
          );
        } catch (_) {}
      }
      _updateStatus();
    } catch (_) {}
  }

  Future<void> _persistOutbox() async {
    final list = _outbox.map((op) => jsonEncode(op.toJson())).toList();
    await ApexKvStore.setStringList('sync.outbox_queue', list);
    _updateStatus();
  }

  void _updateStatus() {
    final pendingCount = _outbox
        .where((op) => op.state != SyncOperationState.completed)
        .length;
    if (pendingCount == 0 && _status != SyncState.syncing) {
      _status = SyncState.synced;
    } else if (pendingCount > 0 && _status != SyncState.syncing) {
      _status = SyncState.pending;
    }

    final summary = SyncSummary(
      status: _status,
      pendingCount: pendingCount,
      lastSyncedAtUtc: _lastSyncedAt,
      lastErrorMessage: _lastError,
    );

    _summaryController.add(summary);
  }

  @override
  Stream<SyncSummary> watchSummary() => _summaryController.stream;

  @override
  SyncSummary get currentSummary => SyncSummary(
    status: _status,
    pendingCount: _outbox
        .where((op) => op.state != SyncOperationState.completed)
        .length,
    lastSyncedAtUtc: _lastSyncedAt,
    lastErrorMessage: _lastError,
  );

  @override
  Future<void> enqueueOperation(SyncOperation operation) async {
    // Section 13.2: Coalesce multiple updates for same entity
    _outbox.removeWhere(
      (op) =>
          op.entityType == operation.entityType &&
          op.entityId == operation.entityId &&
          op.state == SyncOperationState.pending,
    );
    _outbox.add(operation);
    await _persistOutbox();
    await requestSync(SyncReason.localMutation);
  }

  @override
  Future<void> requestSync(SyncReason reason) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      unawaited(_processQueue());
    });
  }

  @override
  Future<void> retryFailed() async {
    for (int i = 0; i < _outbox.length; i++) {
      if (_outbox[i].state == SyncOperationState.failedTransient ||
          _outbox[i].state == SyncOperationState.failedPermanent) {
        _outbox[i] = _outbox[i].copyWith(
          state: SyncOperationState.pending,
          attemptCount: 0,
          nextAttemptAtUtc: null,
        );
      }
    }
    await _persistOutbox();
    await requestSync(SyncReason.userRequested);
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    _status = SyncState.syncing;
    _updateStatus();

    try {
      final now = DateTime.now().toUtc();
      final pendingOps = _outbox.where((op) {
        if (op.state == SyncOperationState.completed ||
            op.state == SyncOperationState.failedPermanent) {
          return false;
        }
        if (op.nextAttemptAtUtc != null && op.nextAttemptAtUtc!.isAfter(now)) {
          return false;
        }
        return true;
      }).toList();

      for (final op in pendingOps) {
        // Section 13.3 Payload Byte Guard (650 KiB warning / 750 KiB hard threshold)
        final payloadBytes = utf8.encode(op.payloadJson).length;
        if (payloadBytes > 750 * 1024) {
          debugPrint(
            'SyncCoordinator: Payload byte guard limit exceeded ($payloadBytes bytes). Domain sharding required.',
          );
        }

        final success = await _executeRemoteSync(op);
        if (success) {
          final idx = _outbox.indexWhere(
            (o) => o.operationId == op.operationId,
          );
          if (idx != -1) {
            _outbox[idx] = _outbox[idx].copyWith(
              state: SyncOperationState.completed,
            );
          }
          _lastSyncedAt = DateTime.now().toUtc();
          _lastError = null;
        } else {
          // Exponential Backoff with Jitter: baseDelay = 2s, maxDelay = 6h
          final attempt = op.attemptCount + 1;
          if (attempt >= 5) {
            final idx = _outbox.indexWhere(
              (o) => o.operationId == op.operationId,
            );
            if (idx != -1) {
              _outbox[idx] = _outbox[idx].copyWith(
                state: SyncOperationState.failedPermanent,
                lastErrorCode: 'MAX_ATTEMPTS_EXCEEDED',
              );
            }
          } else {
            final baseSeconds =
                math.pow(2, attempt).toDouble() * 2.0; // 4s, 8s, 16s, 32s
            final maxJitter = math.min(21600.0, baseSeconds);
            final delaySeconds = _random.nextDouble() * maxJitter;
            final nextAttempt = now.add(
              Duration(seconds: delaySeconds.toInt() + 2),
            );

            final idx = _outbox.indexWhere(
              (o) => o.operationId == op.operationId,
            );
            if (idx != -1) {
              _outbox[idx] = _outbox[idx].copyWith(
                attemptCount: attempt,
                state: SyncOperationState.failedTransient,
                nextAttemptAtUtc: nextAttempt,
                lastErrorCode: 'TRANSIENT_NETWORK_ERROR',
              );
            }
          }
        }
      }

      // Clean up completed operations
      _outbox.removeWhere((op) => op.state == SyncOperationState.completed);
      await _persistOutbox();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isProcessing = false;
      _updateStatus();
    }
  }

  Future<bool> _executeRemoteSync(SyncOperation op) async {
    try {
      final user = FirebaseService().currentUser;
      if (user == null) {
        return false;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(op.entityType)
          .doc(op.entityId);

      if (op.type == SyncOperationType.delete) {
        await docRef.delete();
        return true;
      }

      // Upsert with conflict detection
      final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
      final remoteDoc = await docRef.get();

      if (remoteDoc.exists && op.baseRemoteRevision > 0) {
        final remoteData = remoteDoc.data() ?? {};
        final remoteRevision =
            (remoteData['_syncRevision'] as num?)?.toInt() ?? 0;

        if (remoteRevision > op.baseRemoteRevision) {
          // Conflict detected — resolve using domain-aware conflict resolver
          final resolution = _conflictResolver.resolveConflict(
            domainName: op.entityType,
            localPayloadJson: op.payloadJson,
            localRevision: op.targetLocalRevision,
            remotePayloadJson: jsonEncode(remoteData),
            remoteRevision: remoteRevision,
          );
          final mergedPayload =
              jsonDecode(resolution.mergedPayloadJson) as Map<String, dynamic>;
          mergedPayload['_syncRevision'] = resolution.newRevision;
          mergedPayload['_syncedAtUtc'] = DateTime.now().toUtc().toIso8601String();
          await docRef.set(mergedPayload, SetOptions(merge: true));
          return true;
        }
      }

      // No conflict — write directly
      payload['_syncRevision'] = op.targetLocalRevision;
      payload['_syncedAtUtc'] = DateTime.now().toUtc().toIso8601String();
      await docRef.set(payload, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('SyncCoordinator: Remote sync failed — $e');
      return false;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _summaryController.close();
  }
}
