import 'dart:convert';
import 'sync_models.dart';

class SyncConflictResolver {
  const SyncConflictResolver();

  /// Resolves conflicts between a local payload and a remote payload based on domain policy.
  ({String mergedPayloadJson, int newRevision, SyncState state})
  resolveConflict({
    required String domainName,
    required String localPayloadJson,
    required int localRevision,
    required String remotePayloadJson,
    required int remoteRevision,
  }) {
    if (localPayloadJson == remotePayloadJson) {
      return (
        mergedPayloadJson: localPayloadJson,
        newRevision: localRevision > remoteRevision
            ? localRevision
            : remoteRevision,
        state: SyncState.synced,
      );
    }

    try {
      final localMap = jsonDecode(localPayloadJson) as Map<String, dynamic>;
      final remoteMap = jsonDecode(remotePayloadJson) as Map<String, dynamic>;

      if (domainName == 'maintenance' ||
          domainName == 'fuel' ||
          domainName == 'rides') {
        // Section 9.1: Append-Only Union Merge Strategy
        final merged = _resolveUnionMerge(localMap, remoteMap);
        final newRev =
            (localRevision > remoteRevision ? localRevision : remoteRevision) +
            1;
        return (
          mergedPayloadJson: jsonEncode(merged),
          newRevision: newRev,
          state: SyncState.synced,
        );
      } else if (domainName == 'profile') {
        // Section 9.2: Field-Level Resolution
        final merged = _resolveProfileFields(localMap, remoteMap);
        final newRev =
            (localRevision > remoteRevision ? localRevision : remoteRevision) +
            1;
        return (
          mergedPayloadJson: jsonEncode(merged),
          newRevision: newRev,
          state: SyncState.synced,
        );
      } else if (domainName == 'garage') {
        // Section 9.3: Garage & Odometer Protection Strategy
        final merged = _resolveGarage(localMap, remoteMap);
        final newRev =
            (localRevision > remoteRevision ? localRevision : remoteRevision) +
            1;
        return (
          mergedPayloadJson: jsonEncode(merged),
          newRevision: newRev,
          state: SyncState.synced,
        );
      }
    } catch (_) {
      // Fallback: Remote server accepted state wins if parsing fails
    }

    return (
      mergedPayloadJson: remotePayloadJson,
      newRevision: remoteRevision,
      state: SyncState.synced,
    );
  }

  Map<String, dynamic> _resolveUnionMerge(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = Map<String, dynamic>.from(remote);
    local.forEach((key, value) {
      if (!merged.containsKey(key)) {
        merged[key] = value;
      } else if (value is List && merged[key] is List) {
        final existingList = (merged[key] as List).toSet();
        existingList.addAll(value);
        merged[key] = existingList.toList();
      }
    });
    return merged;
  }

  Map<String, dynamic> _resolveProfileFields(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = Map<String, dynamic>.from(remote);
    // Local changes overwrite remote if local has newer non-null values
    local.forEach((key, value) {
      if (value != null && (value is! String || value.isNotEmpty)) {
        merged[key] = value;
      }
    });
    return merged;
  }

  Map<String, dynamic> _resolveGarage(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final merged = Map<String, dynamic>.from(remote);

    // Section 9.3: Odometer protection: Odometer can NEVER decrease via sync
    final localOdo = (local['odometerKm'] as num?)?.toDouble() ?? 0.0;
    final remoteOdo = (remote['odometerKm'] as num?)?.toDouble() ?? 0.0;
    merged['odometerKm'] = localOdo > remoteOdo ? localOdo : remoteOdo;

    return merged;
  }
}
