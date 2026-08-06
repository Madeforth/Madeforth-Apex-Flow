import 'dart:convert';
import 'package:apexflow/core/storage/db_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';
import 'package:apexflow/profile/domain/friend_profile.dart';

class IsarDbService implements DbService {
  @override
  Future<void> init() async {
    // Already initialized via ApexKvStore in main
  }

  // --- Motorcycles ---
  String _bikesKey(String? userId) =>
      userId != null && userId.isNotEmpty ? 'db.bikes.$userId' : 'db.bikes';

  @override
  Future<List<MotorcycleProfile>> getMotorcycles({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_bikesKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => MotorcycleProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveMotorcycle(MotorcycleProfile bike, {String? userId}) async {
    final list = await getMotorcycles(userId: userId);
    list.removeWhere((e) => e.id == bike.id);
    list.add(bike);
    await ApexKvStore.setString(
      _bikesKey(userId),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteMotorcycle(String bikeStableId) async {
    // NOTE: DbService.deleteMotorcycle takes no userId, so this stub (used
    // only when dart.library.io is unavailable AND kIsWeb is false — not
    // reachable via the current dbServiceProvider wiring, see db_provider.dart)
    // cannot target a specific owner's keyed storage here.
    final list = await getMotorcycles();
    list.removeWhere((e) => e.id == bikeStableId);
    await ApexKvStore.setString(
      'db.bikes',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // --- Service Records ---
  String _serviceRecordsKey(String? userId) =>
      userId != null && userId.isNotEmpty
      ? 'db.service_records.$userId'
      : 'db.service_records';

  @override
  Future<List<ServiceRecord>> getServiceRecords({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_serviceRecordsKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => ServiceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveServiceRecord(
    ServiceRecord record,
    String bikeStableId, {
    String? userId,
  }) async {
    final list = await getServiceRecords(userId: userId);
    list.removeWhere((e) => e.id == record.id);
    list.add(record);
    await ApexKvStore.setString(
      _serviceRecordsKey(userId),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteServiceRecord(String recordId, String bikeStableId) async {
    final list = await getServiceRecords();
    list.removeWhere((e) => e.id == recordId);
    await ApexKvStore.setString(
      'db.service_records',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // --- Ride Sessions ---
  @override
  Future<List<RideSession>> getRideSessions({String? userId}) async {
    final key = userId != null && userId.isNotEmpty
        ? 'db.ride_sessions.$userId'
        : 'db.ride_sessions';
    final raw = await ApexKvStore.getString(key);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => RideSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRideSession(
    RideSession session,
    String bikeStableId, {
    String? userId,
  }) async {
    final key = userId != null && userId.isNotEmpty
        ? 'db.ride_sessions.$userId'
        : 'db.ride_sessions';
    final list = await getRideSessions(userId: userId);
    list.add(session);
    await ApexKvStore.setString(
      key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // --- Daily Checks ---
  String _dailyChecksKey(String? userId) => userId != null && userId.isNotEmpty
      ? 'db.daily_checks.$userId'
      : 'db.daily_checks';

  @override
  Future<List<DailyCheckEntry>> getDailyChecks({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_dailyChecksKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => DailyCheckEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveDailyCheck(DailyCheckEntry entry, {String? userId}) async {
    final list = await getDailyChecks(userId: userId);
    list.removeWhere((e) => e.isoDate == entry.isoDate);
    list.add(entry);
    await ApexKvStore.setString(
      _dailyChecksKey(userId),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // --- Documents ---
  Map<String, dynamic> _docToJson(MotorcycleDocument doc) {
    return {
      'id': doc.id,
      'bikeStableId': doc.bikeStableId,
      'title': doc.title,
      'description': doc.description,
      'imagePath': doc.imagePath,
      'expirationDateIso': doc.expirationDateIso,
    };
  }

  MotorcycleDocument _docFromJson(Map<String, dynamic> map) {
    return MotorcycleDocument(
      id: map['id'] as String,
      bikeStableId: map['bikeStableId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imagePath: map['imagePath'] as String?,
      expirationDateIso: map['expirationDateIso'] as String?,
    );
  }

  String _documentsKey(String? userId) => userId != null && userId.isNotEmpty
      ? 'db.documents.$userId'
      : 'db.documents';

  @override
  Future<List<MotorcycleDocument>> getDocuments({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_documentsKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => _docFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveDocument(MotorcycleDocument doc, {String? userId}) async {
    final list = await getDocuments(userId: userId);
    list.removeWhere((e) => e.id == doc.id);
    list.add(doc);
    await ApexKvStore.setString(
      _documentsKey(userId),
      jsonEncode(list.map((e) => _docToJson(e)).toList()),
    );
  }

  @override
  Future<void> deleteDocument(String stableId) async {
    final list = await getDocuments();
    list.removeWhere((e) => e.id == stableId);
    await ApexKvStore.setString(
      'db.documents',
      jsonEncode(list.map((e) => _docToJson(e)).toList()),
    );
  }

  // --- Tax Records ---
  Map<String, dynamic> _taxToJson(TaxRecord record) {
    return {
      'id': record.id,
      'bikeStableId': record.bikeStableId,
      'type': record.type,
      'dueDateIso': record.dueDateIso,
      'amount': record.amount,
      'currency': record.currency,
      'isPaid': record.isPaid,
    };
  }

  TaxRecord _taxFromJson(Map<String, dynamic> map) {
    return TaxRecord(
      id: map['id'] as String,
      bikeStableId: map['bikeStableId'] as String,
      type: map['type'] as String,
      dueDateIso: map['dueDateIso'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      isPaid: map['isPaid'] as bool,
    );
  }

  String _taxRecordsKey(String? userId) => userId != null && userId.isNotEmpty
      ? 'db.tax_records.$userId'
      : 'db.tax_records';

  @override
  Future<List<TaxRecord>> getTaxRecords({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_taxRecordsKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => _taxFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveTaxRecord(TaxRecord record, {String? userId}) async {
    final list = await getTaxRecords(userId: userId);
    list.removeWhere((e) => e.id == record.id);
    list.add(record);
    await ApexKvStore.setString(
      _taxRecordsKey(userId),
      jsonEncode(list.map((e) => _taxToJson(e)).toList()),
    );
  }

  @override
  Future<void> deleteTaxRecord(String stableId) async {
    final list = await getTaxRecords();
    list.removeWhere((e) => e.id == stableId);
    await ApexKvStore.setString(
      'db.tax_records',
      jsonEncode(list.map((e) => _taxToJson(e)).toList()),
    );
  }

  // --- Friends ---
  String _friendsKey(String? userId) =>
      userId != null && userId.isNotEmpty ? 'db.friends.$userId' : 'db.friends';

  @override
  Future<List<FriendProfile>> getFriends({String? userId}) async {
    if (userId == null || userId.isEmpty) return [];
    final raw = await ApexKvStore.getString(_friendsKey(userId));
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => FriendProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveFriend(FriendProfile friend, {String? userId}) async {
    final list = await getFriends(userId: userId);
    list.removeWhere((e) => e.stableId == friend.stableId);
    list.add(friend);
    await ApexKvStore.setString(
      _friendsKey(userId),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteFriend(String stableId) async {
    final list = await getFriends();
    list.removeWhere((e) => e.stableId == stableId);
    await ApexKvStore.setString(
      'db.friends',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> backfillOwnerId(String ownerId) async {
    // No-op: this stub is not reachable via the current dbServiceProvider
    // wiring (kIsWeb is always caught by InMemoryDbService first — see
    // db_provider.dart), so there is no real device data to migrate here.
  }

  @override
  Future<void> deleteAllForUser(String userId) async {
    if (userId.isEmpty) return;
    await ApexKvStore.remove(_bikesKey(userId));
    await ApexKvStore.remove(_serviceRecordsKey(userId));
    await ApexKvStore.remove('db.ride_sessions.$userId');
    await ApexKvStore.remove(_dailyChecksKey(userId));
    await ApexKvStore.remove(_documentsKey(userId));
    await ApexKvStore.remove(_taxRecordsKey(userId));
    await ApexKvStore.remove(_friendsKey(userId));
  }

  @override
  Future<void> clearAll() async {
    await ApexKvStore.remove('db.bikes');
    await ApexKvStore.remove('db.service_records');
    await ApexKvStore.remove('db.ride_sessions');
    await ApexKvStore.remove('db.daily_checks');
    await ApexKvStore.remove('db.documents');
    await ApexKvStore.remove('db.tax_records');
    await ApexKvStore.remove('db.friends');
  }
}
