class RideSession {
  const RideSession({
    required this.distanceKm,
    required this.durationMinutes,
    required this.averageSpeedKmh,
    required this.mood,
    required this.mechanicalObservation,
    this.maxSpeedKmh = 0,
    this.maxLeanAngle = 0,
    this.hardAccelerations = 0,
    this.hardBrakes = 0,
    this.harmonyScore = 0,
    this.loggedAtIso = '1970-01-01T00:00:00.000Z',
  });

  final double distanceKm;
  final int durationMinutes;
  final double averageSpeedKmh;
  final String mood;
  final String mechanicalObservation;
  final double maxSpeedKmh;
  final double maxLeanAngle;
  final int hardAccelerations;
  final int hardBrakes;
  final int harmonyScore;
  final String loggedAtIso;

  Map<String, dynamic> toJson() {
    return {
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'averageSpeedKmh': averageSpeedKmh,
      'mood': mood,
      'mechanicalObservation': mechanicalObservation,
      'maxSpeedKmh': maxSpeedKmh,
      'maxLeanAngle': maxLeanAngle,
      'hardAccelerations': hardAccelerations,
      'hardBrakes': hardBrakes,
      'harmonyScore': harmonyScore,
      'loggedAtIso': loggedAtIso,
    };
  }

  factory RideSession.fromJson(Map<String, dynamic> json) {
    return RideSession(
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      averageSpeedKmh: (json['averageSpeedKmh'] as num?)?.toDouble() ?? 0,
      mood: json['mood'] as String? ?? 'Focused',
      mechanicalObservation: json['mechanicalObservation'] as String? ?? '',
      maxSpeedKmh: (json['maxSpeedKmh'] as num?)?.toDouble() ?? 0,
      maxLeanAngle: (json['maxLeanAngle'] as num?)?.toDouble() ?? 0,
      hardAccelerations: json['hardAccelerations'] as int? ?? 0,
      hardBrakes: json['hardBrakes'] as int? ?? 0,
      harmonyScore: json['harmonyScore'] as int? ?? 0,
      loggedAtIso: json['loggedAtIso'] as String? ?? '1970-01-01T00:00:00.000Z',
    );
  }
}
