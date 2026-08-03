import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';

import 'package:apexflow/profile/domain/friend_profile.dart';

abstract class DbService {
  Future<void> init();

  Future<List<MotorcycleProfile>> getMotorcycles();
  Future<void> saveMotorcycle(MotorcycleProfile bike);
  Future<void> deleteMotorcycle(String bikeStableId);

  Future<List<ServiceRecord>> getServiceRecords();
  Future<void> saveServiceRecord(ServiceRecord record, String bikeStableId);
  Future<void> deleteServiceRecord(String recordId, String bikeStableId);

  Future<List<RideSession>> getRideSessions({String? userId});
  Future<void> saveRideSession(RideSession session, String bikeStableId, {String? userId});

  Future<List<DailyCheckEntry>> getDailyChecks();
  Future<void> saveDailyCheck(DailyCheckEntry entry);

  Future<List<MotorcycleDocument>> getDocuments();
  Future<void> saveDocument(MotorcycleDocument doc);
  Future<void> deleteDocument(String stableId);

  Future<List<TaxRecord>> getTaxRecords();
  Future<void> saveTaxRecord(TaxRecord record);
  Future<void> deleteTaxRecord(String stableId);

  Future<List<FriendProfile>> getFriends();
  Future<void> saveFriend(FriendProfile friend);
  Future<void> deleteFriend(String stableId);

  Future<void> clearAll();
}
