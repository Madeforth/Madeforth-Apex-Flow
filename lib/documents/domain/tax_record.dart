class TaxRecord {
  const TaxRecord({
    required this.id,
    required this.bikeStableId,
    required this.type, // 'mtv_1', 'mtv_2', 'insurance', 'inspection', 'road_tax', 'other'
    required this.dueDateIso,
    required this.amount,
    required this.currency,
    required this.isPaid,
  });

  final String id;
  final String bikeStableId;
  final String type;
  final String dueDateIso;
  final double amount;
  final String currency;
  final bool isPaid;

  DateTime get dueDate => DateTime.parse(dueDateIso);

  TaxRecord copyWith({
    String? id,
    String? bikeStableId,
    String? type,
    String? dueDateIso,
    double? amount,
    String? currency,
    bool? isPaid,
  }) {
    return TaxRecord(
      id: id ?? this.id,
      bikeStableId: bikeStableId ?? this.bikeStableId,
      type: type ?? this.type,
      dueDateIso: dueDateIso ?? this.dueDateIso,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
