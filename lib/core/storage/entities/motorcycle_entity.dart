import 'package:isar/isar.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';

part 'motorcycle_entity.g.dart';

@collection
class MotorcycleEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String stableId;

  @Index()
  String userId = '';

  late String name;
  late String model;
  late int odometerKm;
  late int lastServiceKm;
  late int chainWearPercent;
  late int tireWearPercent;
  late int brakeWearPercent;
  late int oilHealthPercent;
  late int batteryHealthPercent;
  late int serviceIntervalKm;
  late bool archived;

  MotorcycleProfile toDomain() {
    return MotorcycleProfile(
      id: stableId,
      name: name,
      model: model,
      odometerKm: odometerKm,
      lastServiceKm: lastServiceKm,
      chainWearPercent: chainWearPercent,
      tireWearPercent: tireWearPercent,
      brakeWearPercent: brakeWearPercent,
      oilHealthPercent: oilHealthPercent,
      batteryHealthPercent: batteryHealthPercent,
      serviceIntervalKm: serviceIntervalKm,
      archived: archived,
    );
  }

  static MotorcycleEntity fromDomain(
    MotorcycleProfile domain, {
    String userId = '',
  }) {
    return MotorcycleEntity()
      ..stableId = domain.id
      ..userId = userId
      ..name = domain.name
      ..model = domain.model
      ..odometerKm = domain.odometerKm
      ..lastServiceKm = domain.lastServiceKm
      ..chainWearPercent = domain.chainWearPercent
      ..tireWearPercent = domain.tireWearPercent
      ..brakeWearPercent = domain.brakeWearPercent
      ..oilHealthPercent = domain.oilHealthPercent
      ..batteryHealthPercent = domain.batteryHealthPercent
      ..serviceIntervalKm = domain.serviceIntervalKm
      ..archived = domain.archived;
  }
}
