import 'package:isar/isar.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';

part 'document_entity.g.dart';

@collection
class DocumentEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String stableId;

  late String bikeStableId;
  late String title;
  late String description;
  String? imagePath;
  String? expirationDateIso;

  MotorcycleDocument toDomain() {
    return MotorcycleDocument(
      id: stableId,
      bikeStableId: bikeStableId,
      title: title,
      description: description,
      imagePath: imagePath,
      expirationDateIso: expirationDateIso,
    );
  }

  static DocumentEntity fromDomain(MotorcycleDocument domain) {
    return DocumentEntity()
      ..stableId = domain.id
      ..bikeStableId = domain.bikeStableId
      ..title = domain.title
      ..description = domain.description
      ..imagePath = domain.imagePath
      ..expirationDateIso = domain.expirationDateIso;
  }
}
