class MotorcycleDocument {
  const MotorcycleDocument({
    required this.id,
    required this.bikeStableId,
    required this.title,
    required this.description,
    this.imagePath,
    this.expirationDateIso,
  });

  final String id;
  final String bikeStableId;
  final String title;
  final String description;
  final String? imagePath;
  final String? expirationDateIso;

  DateTime? get expirationDate =>
      expirationDateIso != null ? DateTime.tryParse(expirationDateIso!) : null;

  MotorcycleDocument copyWith({
    String? id,
    String? bikeStableId,
    String? title,
    String? description,
    String? imagePath,
    String? expirationDateIso,
  }) {
    return MotorcycleDocument(
      id: id ?? this.id,
      bikeStableId: bikeStableId ?? this.bikeStableId,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      expirationDateIso: expirationDateIso ?? this.expirationDateIso,
    );
  }
}
