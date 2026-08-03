import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexflow/core/storage/db_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';

class MigrationService {
  static const _migrationKey = 'app.migration_completed.v1';

  static Future<void> checkAndMigrate(DbService db) async {
    final migrationCompleted =
        await ApexKvStore.getBool(_migrationKey) ?? false;
    if (migrationCompleted) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('app.onboarding_done.v1') ?? false;
    if (!onboardingDone) {
      // Nothing to migrate
      await ApexKvStore.setBool(_migrationKey, true);
      return;
    }

    try {
      // 1. Migrate App Settings
      final localeCode = prefs.getString('app.locale_code');
      if (localeCode != null) {
        await ApexKvStore.setString('app.locale_code', localeCode);
      }
      await ApexKvStore.setBool('app.onboarding_done.v1', true);

      // 2. Migrate Garage State
      final garageRaw = prefs.getString('garage.state.v1');
      String activeBikeStableId = '';
      if (garageRaw != null && garageRaw.isNotEmpty) {
        final data = jsonDecode(garageRaw) as Map<String, dynamic>;

        // Active Bike
        if (data['activeBike'] != null) {
          final activeBike = MotorcycleProfile.fromJson(
            Map<String, dynamic>.from(data['activeBike'] as Map),
          );
          activeBikeStableId = activeBike.id;
        }

        // Motorcycles
        final motorcycles = (data['motorcycles'] as List<dynamic>? ?? [])
            .map(
              (item) => MotorcycleProfile.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        for (final bike in motorcycles) {
          await db.saveMotorcycle(bike);
          if (activeBikeStableId.isEmpty) {
            activeBikeStableId = bike.id;
          }
        }

        // Service Records
        final records = (data['serviceRecords'] as List<dynamic>? ?? [])
            .map(
              (item) => ServiceRecord.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        for (final r in records) {
          await db.saveServiceRecord(r, activeBikeStableId);
        }
      }

      // 3. Migrate Rides State
      final ridesRaw = prefs.getString('rides.state.v1');
      if (ridesRaw != null &&
          ridesRaw.isNotEmpty &&
          activeBikeStableId.isNotEmpty) {
        final data = jsonDecode(ridesRaw) as Map<String, dynamic>;

        final sessions = (data['sessions'] as List<dynamic>? ?? [])
            .map(
              (item) =>
                  RideSession.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();

        for (final s in sessions) {
          await db.saveRideSession(s, activeBikeStableId);
        }

        // Save active ride state to Hive
        final isRideActive = data['isRideActive'] as bool? ?? false;
        final activeMood = data['activeMood'] as String? ?? 'Focused';
        final rideStartedAtIso = data['rideStartedAtIso'] as String?;

        await ApexKvStore.setBool('rides.is_active', isRideActive);
        await ApexKvStore.setString('rides.active_mood', activeMood);
        if (rideStartedAtIso != null) {
          await ApexKvStore.setString('rides.started_at_iso', rideStartedAtIso);
        }
      }

      // 4. Migrate Rituals State
      final ritualsRaw = prefs.getString('rituals.state.v1');
      if (ritualsRaw != null && ritualsRaw.isNotEmpty) {
        final data = jsonDecode(ritualsRaw) as Map<String, dynamic>;

        final checks = (data['dailyChecks'] as List<dynamic>? ?? [])
            .map((e) => DailyCheckEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        for (final check in checks) {
          await db.saveDailyCheck(check);
        }

        // Weather snapshot
        if (data['weather'] != null) {
          final weather = WeatherSnapshot.fromJson(
            Map<String, dynamic>.from(data['weather'] as Map),
          );
          await ApexKvStore.setString(
            'rituals.weather_json',
            jsonEncode(weather.toJson()),
          );
        }
      }

      // 5. Clean up old SharedPreferences keys
      await prefs.remove('garage.state.v1');
      await prefs.remove('rides.state.v1');
      await prefs.remove('rituals.state.v1');

      await ApexKvStore.setBool(_migrationKey, true);
    } catch (_) {
      // If migration fails, do not mark completed so it can retry
    }
  }
}
