import 'package:apexflow/core/storage/db_service.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';

import 'package:apexflow/profile/domain/friend_profile.dart';

class InMemoryDbService implements DbService {
  final List<MotorcycleProfile> _motorcycles = [];
  final List<MapEntry<ServiceRecord, String>> _serviceRecords = [];
  final List<MapEntry<RideSession, String>> _rideSessions = [];
  final List<DailyCheckEntry> _dailyChecks = [];
  final List<MotorcycleDocument> _documents = [];
  final List<TaxRecord> _taxRecords = [];
  final List<FriendProfile> _friends = [];

  @override
  Future<void> init() async {}

  @override
  Future<List<MotorcycleProfile>> getMotorcycles({String? userId}) async {
    return List.from(_motorcycles);
  }

  @override
  Future<void> saveMotorcycle(MotorcycleProfile bike, {String? userId}) async {
    _motorcycles.removeWhere((element) => element.id == bike.id);
    _motorcycles.add(bike);
  }

  @override
  Future<void> deleteMotorcycle(String bikeStableId) async {
    _motorcycles.removeWhere((element) => element.id == bikeStableId);
    _serviceRecords.removeWhere((element) => element.value == bikeStableId);
    _rideSessions.removeWhere((element) => element.value == bikeStableId);
  }

  @override
  Future<List<ServiceRecord>> getServiceRecords({String? userId}) async {
    return _serviceRecords.map((e) => e.key).toList();
  }

  @override
  Future<void> saveServiceRecord(
    ServiceRecord record,
    String bikeStableId, {
    String? userId,
  }) async {
    _serviceRecords.removeWhere((element) => element.key.id == record.id);
    _serviceRecords.add(MapEntry(record, bikeStableId));
  }

  @override
  Future<void> deleteServiceRecord(String recordId, String bikeStableId) async {
    _serviceRecords.removeWhere((element) => element.key.id == recordId);
  }

  @override
  Future<List<RideSession>> getRideSessions({String? userId}) async {
    return _rideSessions.map((e) => e.key).toList();
  }

  @override
  Future<void> saveRideSession(
    RideSession session,
    String bikeStableId, {
    String? userId,
  }) async {
    _rideSessions.add(MapEntry(session, bikeStableId));
  }

  @override
  Future<List<DailyCheckEntry>> getDailyChecks({String? userId}) async {
    return List.from(_dailyChecks);
  }

  @override
  Future<void> saveDailyCheck(DailyCheckEntry entry, {String? userId}) async {
    _dailyChecks.removeWhere((element) => element.isoDate == entry.isoDate);
    _dailyChecks.add(entry);
  }

  @override
  Future<List<MotorcycleDocument>> getDocuments({String? userId}) async {
    return List.from(_documents);
  }

  @override
  Future<void> saveDocument(MotorcycleDocument doc, {String? userId}) async {
    _documents.removeWhere((element) => element.id == doc.id);
    _documents.add(doc);
  }

  @override
  Future<void> deleteDocument(String stableId) async {
    _documents.removeWhere((element) => element.id == stableId);
  }

  @override
  Future<List<TaxRecord>> getTaxRecords({String? userId}) async {
    return List.from(_taxRecords);
  }

  @override
  Future<void> saveTaxRecord(TaxRecord record, {String? userId}) async {
    _taxRecords.removeWhere((element) => element.id == record.id);
    _taxRecords.add(record);
  }

  @override
  Future<void> deleteTaxRecord(String stableId) async {
    _taxRecords.removeWhere((element) => element.id == stableId);
  }

  @override
  Future<List<FriendProfile>> getFriends({String? userId}) async {
    return List.from(_friends);
  }

  @override
  Future<void> saveFriend(FriendProfile friend, {String? userId}) async {
    _friends.removeWhere((element) => element.stableId == friend.stableId);
    _friends.add(friend);
  }

  @override
  Future<void> deleteFriend(String stableId) async {
    _friends.removeWhere((element) => element.stableId == stableId);
  }

  @override
  Future<void> backfillOwnerId(String ownerId) async {
    // No-op: the in-memory service backs tests and web builds, neither of
    // which carries pre-existing unowned local records to migrate.
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    // Records aren't tagged by userId in this in-memory store (it backs
    // tests and web builds only, neither of which persists real per-user
    // local data) — clearing everything is the correct equivalent here.
    await clearAll();
  }

  @override
  Future<void> clearAll() async {
    _motorcycles.clear();
    _serviceRecords.clear();
    _rideSessions.clear();
    _dailyChecks.clear();
    _documents.clear();
    _taxRecords.clear();
    _friends.clear();
  }
}
