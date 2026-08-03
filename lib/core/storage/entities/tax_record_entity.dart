import 'package:isar/isar.dart';
import 'package:apexflow/documents/domain/tax_record.dart';

part 'tax_record_entity.g.dart';

@collection
class TaxRecordEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String stableId;

  late String bikeStableId;
  late String type;
  late String dueDateIso;
  late double amount;
  late String currency;
  late bool isPaid;

  TaxRecord toDomain() {
    return TaxRecord(
      id: stableId,
      bikeStableId: bikeStableId,
      type: type,
      dueDateIso: dueDateIso,
      amount: amount,
      currency: currency,
      isPaid: isPaid,
    );
  }

  static TaxRecordEntity fromDomain(TaxRecord domain) {
    return TaxRecordEntity()
      ..stableId = domain.id
      ..bikeStableId = domain.bikeStableId
      ..type = domain.type
      ..dueDateIso = domain.dueDateIso
      ..amount = domain.amount
      ..currency = domain.currency
      ..isPaid = domain.isPaid;
  }
}
