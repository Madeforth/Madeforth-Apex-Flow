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
  @override
  Future<List<MotorcycleProfile>> getMotorcycles() async {
    final raw = await ApexKvStore.getString('db.bikes');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => MotorcycleProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveMotorcycle(MotorcycleProfile bike) async {
    final list = await getMotorcycles();
    list.removeWhere((e) => e.id == bike.id);
    list.add(bike);
    await ApexKvStore.setString(
      'db.bikes',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteMotorcycle(String bikeStableId) async {
    final list = await getMotorcycles();
    list.removeWhere((e) => e.id == bikeStableId);
    await ApexKvStore.setString(
      'db.bikes',
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  // --- Service Records ---
  @override
  Future<List<ServiceRecord>> getServiceRecords() async {
    final raw = await ApexKvStore.getString('db.service_records');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => ServiceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveServiceRecord(
    ServiceRecord record,
    String bikeStableId,
  ) async {
    final list = await getServiceRecords();
    list.removeWhere((e) => e.id == record.id);
    list.add(record);
    await ApexKvStore.setString(
      'db.service_records',
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
  Future<void> saveRideSession(RideSession session, String bikeStableId, {String? userId}) async {
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
  @override
  Future<List<DailyCheckEntry>> getDailyChecks() async {
    final raw = await ApexKvStore.getString('db.daily_checks');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => DailyCheckEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveDailyCheck(DailyCheckEntry entry) async {
    final list = await getDailyChecks();
    list.removeWhere((e) => e.isoDate == entry.isoDate);
    list.add(entry);
    await ApexKvStore.setString(
      'db.daily_checks',
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

  @override
  Future<List<MotorcycleDocument>> getDocuments() async {
    final raw = await ApexKvStore.getString('db.documents');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => _docFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveDocument(MotorcycleDocument doc) async {
    final list = await getDocuments();
    list.removeWhere((e) => e.id == doc.id);
    list.add(doc);
    await ApexKvStore.setString(
      'db.documents',
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

  @override
  Future<List<TaxRecord>> getTaxRecords() async {
    final raw = await ApexKvStore.getString('db.tax_records');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => _taxFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveTaxRecord(TaxRecord record) async {
    final list = await getTaxRecords();
    list.removeWhere((e) => e.id == record.id);
    list.add(record);
    await ApexKvStore.setString(
      'db.tax_records',
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
  @override
  Future<List<FriendProfile>> getFriends() async {
    final raw = await ApexKvStore.getString('db.friends');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded
        .map((e) => FriendProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveFriend(FriendProfile friend) async {
    final list = await getFriends();
    list.removeWhere((e) => e.stableId == friend.stableId);
    list.add(friend);
    await ApexKvStore.setString(
      'db.friends',
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
