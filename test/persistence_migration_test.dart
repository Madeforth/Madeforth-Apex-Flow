import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexflow/core/storage/migration_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/in_memory_db_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MigrationService Tests', () {
    late InMemoryDbService db;

    setUp(() async {
      db = InMemoryDbService();
      // Initialize ApexKvStore with fallback so it writes directly to SharedPreferences mock
      await ApexKvStore.init(useFallback: true);
    });

    test('no migration occurs if onboarding not done', () async {
      SharedPreferences.setMockInitialValues({'app.onboarding_done.v1': false});

      await MigrationService.checkAndMigrate(db);

      // Verify that migration was marked completed
      final migrationDone = await ApexKvStore.getBool(
        'app.migration_completed.v1',
      );
      expect(migrationDone, isTrue);

      // Verify no data was migrated to database
      final bikes = await db.getMotorcycles();
      expect(bikes, isEmpty);
    });

    test('migrates full legacy shared preferences data successfully', () async {
      final legacyGarageState = {
        'activeBike': {
          'id': 'bike_1',
          'name': 'Night Vector',
          'model': 'Yamaha MT-07',
          'odometerKm': 12000,
          'lastServiceKm': 10000,
          'chainWearPercent': 30,
          'tireWearPercent': 40,
          'brakeWearPercent': 25,
          'oilHealthPercent': 80,
          'batteryHealthPercent': 95,
          'serviceIntervalKm': 6000,
          'archived': false,
        },
        'motorcycles': [
          {
            'id': 'bike_1',
            'name': 'Night Vector',
            'model': 'Yamaha MT-07',
            'odometerKm': 12000,
            'lastServiceKm': 10000,
            'chainWearPercent': 30,
            'tireWearPercent': 40,
            'brakeWearPercent': 25,
            'oilHealthPercent': 80,
            'batteryHealthPercent': 95,
            'serviceIntervalKm': 6000,
            'archived': false,
          },
        ],
        'serviceRecords': [
          {
            'id': 'record_1',
            'label': 'Oil Change',
            'odometerKm': 10000,
            'note': 'Routine maintenance',
            'loggedAtIso': '2026-05-01T12:00:00Z',
          },
        ],
      };

      final legacyRidesState = {
        'sessions': [
          {
            'distanceKm': 150.0,
            'durationMinutes': 120,
            'averageSpeedKmh': 75.0,
            'mood': 'Thrilled',
            'mechanicalObservation': 'Smooth shift',
            'loggedAtIso': '2026-06-01T10:00:00Z',
          },
        ],
        'isRideActive': true,
        'activeMood': 'Sporty',
        'rideStartedAtIso': '2026-06-02T09:00:00Z',
      };

      final legacyRitualsState = {
        'dailyChecks': [
          {
            'isoDate': '2026-06-10',
            'chainOk': true,
            'tiresOk': true,
            'brakesOk': true,
            'lightsOk': true,
            'oilOk': true,
            'note': 'Good condition',
            'loggedAtIso': '2026-06-10T08:00:00Z',
          },
        ],
        'weather': {
          'locationLabel': 'Izmir',
          'condition': 'Sunny',
          'tempC': 28,
          'windKph': 15,
          'precipChancePercent': 0,
          'observedAtIso': '2026-06-10T08:00:00Z',
        },
      };

      SharedPreferences.setMockInitialValues({
        'app.onboarding_done.v1': true,
        'app.locale_code': 'tr',
        'garage.state.v1': jsonEncode(legacyGarageState),
        'rides.state.v1': jsonEncode(legacyRidesState),
        'rituals.state.v1': jsonEncode(legacyRitualsState),
      });

      await MigrationService.checkAndMigrate(db);

      // Verify database migration contents
      final motorcycles = await db.getMotorcycles();
      expect(motorcycles, hasLength(1));
      expect(motorcycles.first.name, equals('Night Vector'));
      expect(motorcycles.first.odometerKm, equals(12000));

      final serviceRecords = await db.getServiceRecords();
      expect(serviceRecords, hasLength(1));
      expect(serviceRecords.first.label, equals('Oil Change'));

      final rideSessions = await db.getRideSessions();
      expect(rideSessions, hasLength(1));
      expect(rideSessions.first.distanceKm, equals(150.0));
      expect(rideSessions.first.mood, equals('Thrilled'));

      final dailyChecks = await db.getDailyChecks();
      expect(dailyChecks, hasLength(1));
      expect(dailyChecks.first.isoDate, equals('2026-06-10'));
      expect(dailyChecks.first.chainOk, isTrue);

      // Verify Hive/KeyValue configurations
      final onboardingDone = await ApexKvStore.getBool(
        'app.onboarding_done.v1',
      );
      expect(onboardingDone, isTrue);

      final localeCode = await ApexKvStore.getString('app.locale_code');
      expect(localeCode, equals('tr'));

      final isRideActive = await ApexKvStore.getBool('rides.is_active');
      expect(isRideActive, isTrue);

      final activeMood = await ApexKvStore.getString('rides.active_mood');
      expect(activeMood, equals('Sporty'));

      final rideStartedAtIso = await ApexKvStore.getString(
        'rides.started_at_iso',
      );
      expect(rideStartedAtIso, equals('2026-06-02T09:00:00Z'));

      final weatherJson = await ApexKvStore.getString('rituals.weather_json');
      expect(weatherJson, isNotNull);
      final weather = jsonDecode(weatherJson!) as Map<String, dynamic>;
      expect(weather['locationLabel'], equals('Izmir'));

      // Verify old keys were deleted
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('app.locale_code'), isTrue);
      expect(prefs.containsKey('app.onboarding_done.v1'), isTrue);
      expect(prefs.containsKey('garage.state.v1'), isFalse);
      expect(prefs.containsKey('rides.state.v1'), isFalse);
      expect(prefs.containsKey('rituals.state.v1'), isFalse);

      // Verify migration flag is set
      final migrationDone = await ApexKvStore.getBool(
        'app.migration_completed.v1',
      );
      expect(migrationDone, isTrue);
    });
  });
}
