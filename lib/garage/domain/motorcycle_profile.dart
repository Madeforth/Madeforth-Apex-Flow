class MotorcycleProfile {
  const MotorcycleProfile({
    required this.id,
    required this.name,
    required this.model,
    required this.odometerKm,
    required this.lastServiceKm,
    required this.chainWearPercent,
    required this.tireWearPercent,
    required this.brakeWearPercent,
    required this.oilHealthPercent,
    required this.batteryHealthPercent,
    this.serviceIntervalKm = 6000,
    this.archived = false,
  });

  final String id;
  final String name;
  final String model;
  final int odometerKm;
  final int lastServiceKm;
  final int chainWearPercent;
  final int tireWearPercent;
  final int brakeWearPercent;
  final int oilHealthPercent;
  final int batteryHealthPercent;
  final int serviceIntervalKm;
  final bool archived;

  int get kmSinceService {
    final delta = odometerKm - lastServiceKm;
    return delta < 0 ? 0 : delta;
  }

  int get kmUntilService {
    if (serviceIntervalKm <= 0) return 0;
    return serviceIntervalKm - kmSinceService;
  }

  double get serviceProgress {
    if (serviceIntervalKm <= 0) {
      return 1;
    }
    return (kmSinceService / serviceIntervalKm).clamp(0, 1).toDouble();
  }

  ServiceWindowState get serviceWindowState {
    if (serviceIntervalKm <= 0) return ServiceWindowState.stable;
    if (kmUntilService < 0) {
      return ServiceWindowState.overdue;
    }
    if (kmUntilService <= 500) {
      return ServiceWindowState.dueSoon;
    }
    return ServiceWindowState.stable;
  }

  MotorcycleProfile copyWith({
    String? id,
    String? name,
    String? model,
    int? odometerKm,
    int? lastServiceKm,
    int? chainWearPercent,
    int? tireWearPercent,
    int? brakeWearPercent,
    int? oilHealthPercent,
    int? batteryHealthPercent,
    int? serviceIntervalKm,
    bool? archived,
  }) {
    return MotorcycleProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      odometerKm: odometerKm ?? this.odometerKm,
      lastServiceKm: lastServiceKm ?? this.lastServiceKm,
      chainWearPercent: chainWearPercent ?? this.chainWearPercent,
      tireWearPercent: tireWearPercent ?? this.tireWearPercent,
      brakeWearPercent: brakeWearPercent ?? this.brakeWearPercent,
      oilHealthPercent: oilHealthPercent ?? this.oilHealthPercent,
      batteryHealthPercent: batteryHealthPercent ?? this.batteryHealthPercent,
      serviceIntervalKm: serviceIntervalKm ?? this.serviceIntervalKm,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'odometerKm': odometerKm,
      'lastServiceKm': lastServiceKm,
      'chainWearPercent': chainWearPercent,
      'tireWearPercent': tireWearPercent,
      'brakeWearPercent': brakeWearPercent,
      'oilHealthPercent': oilHealthPercent,
      'batteryHealthPercent': batteryHealthPercent,
      'serviceIntervalKm': serviceIntervalKm,
      'archived': archived,
    };
  }

  factory MotorcycleProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Unnamed';
    final model = json['model'] as String? ?? 'Unknown model';
    final odometerKm = json['odometerKm'] as int? ?? 0;
    return MotorcycleProfile(
      id: json['id'] as String? ?? _legacyId(name, model, odometerKm),
      name: name,
      model: model,
      odometerKm: odometerKm,
      lastServiceKm: json['lastServiceKm'] as int? ?? 0,
      chainWearPercent: json['chainWearPercent'] as int? ?? 0,
      tireWearPercent: json['tireWearPercent'] as int? ?? 0,
      brakeWearPercent: json['brakeWearPercent'] as int? ?? 0,
      oilHealthPercent: json['oilHealthPercent'] as int? ?? 0,
      batteryHealthPercent: json['batteryHealthPercent'] as int? ?? 0,
      serviceIntervalKm: json['serviceIntervalKm'] as int? ?? 6000,
      archived: json['archived'] as bool? ?? false,
    );
  }
}

enum ServiceWindowState { stable, dueSoon, overdue }

String _legacyId(String name, String model, int odometerKm) {
  final normalizedName = name.trim().toLowerCase();
  final normalizedModel = model.trim().toLowerCase();
  return 'legacy-$normalizedName-$normalizedModel-$odometerKm';
}
