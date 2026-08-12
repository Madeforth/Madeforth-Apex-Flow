import 'package:flutter_test/flutter_test.dart';

import 'package:apexflow/core/storage/entities/ride_session_entity.dart';
import 'package:apexflow/rides/domain/ride_session.dart';

void main() {
  group('Ride records written before lean angle was removed', () {
    test('legacy JSON carrying maxLeanAngle still parses', () {
      final legacy = <String, dynamic>{
        'distanceKm': 18.4,
        'durationMinutes': 22,
        'averageSpeedKmh': 50.2,
        'mood': 'Focused',
        'mechanicalObservation': 'Fine',
        'maxSpeedKmh': 131.5,
        'maxLeanAngle': 42.0, // removed field, must be ignored
        'hardAccelerations': 2,
        'hardBrakes': 1,
        'harmonyScore': 88,
        'loggedAtIso': '2026-08-01T09:00:00.000Z',
      };

      final session = RideSession.fromJson(legacy);

      expect(session.distanceKm, 18.4);
      expect(session.maxSpeedKmh, 131.5);
      expect(session.harmonyScore, 88);
      expect(session.hardBrakes, 1);
      expect(session.loggedAtIso, '2026-08-01T09:00:00.000Z');
    });

    test('serialization no longer emits a lean angle', () {
      const session = RideSession(
        distanceKm: 5.0,
        durationMinutes: 10,
        averageSpeedKmh: 30.0,
        mood: 'Focused',
        mechanicalObservation: 'Fine',
      );

      expect(session.toJson().containsKey('maxLeanAngle'), isFalse);
    });

    test('entity round-trip preserves the remaining ride metrics', () {
      const session = RideSession(
        distanceKm: 12.3,
        durationMinutes: 15,
        averageSpeedKmh: 49.2,
        mood: 'Focused',
        mechanicalObservation: 'Fine',
        maxSpeedKmh: 128.0,
        hardAccelerations: 3,
        hardBrakes: 2,
        harmonyScore: 91,
        loggedAtIso: '2026-08-12T07:30:00.000Z',
      );

      final restored = RideSessionEntity.fromDomain(
        session,
        'bike-1',
        userId: 'user-1',
      ).toDomain();

      expect(restored.distanceKm, session.distanceKm);
      expect(restored.maxSpeedKmh, session.maxSpeedKmh);
      expect(restored.harmonyScore, session.harmonyScore);
      expect(restored.hardBrakes, session.hardBrakes);
      expect(restored.loggedAtIso, session.loggedAtIso);
    });
  });
}
