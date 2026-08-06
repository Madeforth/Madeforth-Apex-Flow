import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';

import 'package:apexflow/profile/domain/friend_profile.dart';

abstract class DbService {
  Future<void> init();

  Future<List<MotorcycleProfile>> getMotorcycles({String? userId});
  Future<void> saveMotorcycle(MotorcycleProfile bike, {String? userId});
  Future<void> deleteMotorcycle(String bikeStableId);

  Future<List<ServiceRecord>> getServiceRecords({String? userId});
  Future<void> saveServiceRecord(
    ServiceRecord record,
    String bikeStableId, {
    String? userId,
  });
  Future<void> deleteServiceRecord(String recordId, String bikeStableId);

  Future<List<RideSession>> getRideSessions({String? userId});
  Future<void> saveRideSession(
    RideSession session,
    String bikeStableId, {
    String? userId,
  });

  Future<List<DailyCheckEntry>> getDailyChecks({String? userId});
  Future<void> saveDailyCheck(DailyCheckEntry entry, {String? userId});

  Future<List<MotorcycleDocument>> getDocuments({String? userId});
  Future<void> saveDocument(MotorcycleDocument doc, {String? userId});
  Future<void> deleteDocument(String stableId);

  Future<List<TaxRecord>> getTaxRecords({String? userId});
  Future<void> saveTaxRecord(TaxRecord record, {String? userId});
  Future<void> deleteTaxRecord(String stableId);

  Future<List<FriendProfile>> getFriends({String? userId});
  Future<void> saveFriend(FriendProfile friend, {String? userId});
  Future<void> deleteFriend(String stableId);

  /// One-time backfill: assigns `ownerId` to any locally stored record of the
  /// six user-scoped entities that predates the userId field (userId == '').
  /// Never deletes data — see migration_service.dart.
  Future<void> backfillOwnerId(String ownerId);

  /// Deletes every locally stored record owned by [userId] (bikes, service
  /// records, rides, daily checks, documents, tax records, friends) — used
  /// by account deletion so device-local data doesn't outlive the account.
  Future<void> deleteAllForUser(String userId);

  Future<void> clearAll();
}
