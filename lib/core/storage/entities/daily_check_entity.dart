import 'package:isar/isar.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';

part 'daily_check_entity.g.dart';

@collection
class DailyCheckEntity {
  Id id = Isar.autoIncrement;

  // Composite unique index: one check per (isoDate, userId) pair, not
  // globally unique by date — otherwise two accounts on one device would
  // silently overwrite each other's daily check for the same date.
  @Index(composite: [CompositeIndex('userId')], unique: true)
  late String isoDate;

  String userId = '';

  late bool tiresOk;
  late bool chainOk;
  late bool oilOk;
  late bool brakesOk;
  late bool batteryOk;
  late bool lightsOk;
  late String note;
  String? loggedAtIso;

  DailyCheckEntry toDomain() {
    return DailyCheckEntry(
      isoDate: isoDate,
      tiresOk: tiresOk,
      chainOk: chainOk,
      oilOk: oilOk,
      brakesOk: brakesOk,
      batteryOk: batteryOk,
      lightsOk: lightsOk,
      note: note,
      loggedAtIso: loggedAtIso,
    );
  }

  static DailyCheckEntity fromDomain(
    DailyCheckEntry domain, {
    String userId = '',
  }) {
    return DailyCheckEntity()
      ..isoDate = domain.isoDate
      ..userId = userId
      ..tiresOk = domain.tiresOk
      ..chainOk = domain.chainOk
      ..oilOk = domain.oilOk
      ..brakesOk = domain.brakesOk
      ..batteryOk = domain.batteryOk
      ..lightsOk = domain.lightsOk
      ..note = domain.note
      ..loggedAtIso = domain.loggedAtIso;
  }
}
