import 'package:isar/isar.dart';
import 'package:apexflow/rides/domain/ride_session.dart';

part 'ride_session_entity.g.dart';

@collection
class RideSessionEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String bikeStableId;

  @Index()
  String userId = '';

  late double distanceKm;
  late int durationMinutes;
  late double averageSpeedKmh;
  late String mood;
  late String mechanicalObservation;
  late String loggedAtIso;

  double maxSpeedKmh = 0;
  int hardAccelerations = 0;
  int hardBrakes = 0;
  int harmonyScore = 0;

  RideSession toDomain() {
    return RideSession(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      averageSpeedKmh: averageSpeedKmh,
      mood: mood,
      mechanicalObservation: mechanicalObservation,
      maxSpeedKmh: maxSpeedKmh,
      hardAccelerations: hardAccelerations,
      hardBrakes: hardBrakes,
      harmonyScore: harmonyScore,
      loggedAtIso: loggedAtIso,
    );
  }

  static RideSessionEntity fromDomain(
    RideSession domain,
    String bikeStableId, {
    String userId = '',
  }) {
    return RideSessionEntity()
      ..bikeStableId = bikeStableId
      ..userId = userId
      ..distanceKm = domain.distanceKm
      ..durationMinutes = domain.durationMinutes
      ..averageSpeedKmh = domain.averageSpeedKmh
      ..mood = domain.mood
      ..mechanicalObservation = domain.mechanicalObservation
      ..maxSpeedKmh = domain.maxSpeedKmh
      ..hardAccelerations = domain.hardAccelerations
      ..hardBrakes = domain.hardBrakes
      ..harmonyScore = domain.harmonyScore
      ..loggedAtIso = domain.loggedAtIso;
  }
}
