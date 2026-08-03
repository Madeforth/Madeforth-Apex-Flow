import 'package:isar/isar.dart';
import 'package:apexflow/garage/domain/service_record.dart';

part 'service_record_entity.g.dart';

@collection
class ServiceRecordEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String bikeStableId;

  @Index(unique: true)
  late String stableId;

  late String type;
  late String label;
  late int odometerKm;
  late String status;
  late String note;
  late String loggedAtIso;

  ServiceRecord toDomain() {
    return ServiceRecord(
      id: stableId,
      type: type,
      label: label,
      odometerKm: odometerKm,
      status: status,
      note: note,
      loggedAtIso: loggedAtIso,
    );
  }

  static ServiceRecordEntity fromDomain(
    ServiceRecord domain,
    String bikeStableId,
  ) {
    return ServiceRecordEntity()
      ..bikeStableId = bikeStableId
      ..stableId = domain.id
      ..type = domain.type
      ..label = domain.label
      ..odometerKm = domain.odometerKm
      ..status = domain.status
      ..note = domain.note
      ..loggedAtIso = domain.loggedAtIso;
  }
}
