import 'dart:async';
import 'dart:math';

import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/services/firebase_service.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/garage/domain/garage_passport.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/garage/domain/maintenance_engine_v2.dart';
import 'package:apexflow/garage/domain/service_record.dart';
import 'package:apexflow/harmony_engine/harmony_engine.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/notifications/notification_scheduler.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GarageComponentStatus {
  const GarageComponentStatus({
    required this.label,
    required this.value,
    required this.signal,
  });

  final String label;
  final String value;
  final String signal;
}

class GarageState {
  const GarageState({
    required this.isHydrating,
    required this.activeBike,
    required this.motorcycles,
    required this.latestRide,
    required this.serviceRecords,
    required this.componentStatuses,
  });

  final bool isHydrating;
  final MotorcycleProfile activeBike;
  final List<MotorcycleProfile> motorcycles;
  final RideSession latestRide;
  final List<ServiceRecord> serviceRecords;
  final List<GarageComponentStatus> componentStatuses;

  GarageState copyWith({
    bool? isHydrating,
    MotorcycleProfile? activeBike,
    List<MotorcycleProfile>? motorcycles,
    RideSession? latestRide,
    List<ServiceRecord>? serviceRecords,
    List<GarageComponentStatus>? componentStatuses,
  }) {
    return GarageState(
      isHydrating: isHydrating ?? this.isHydrating,
      activeBike: activeBike ?? this.activeBike,
      motorcycles: motorcycles ?? this.motorcycles,
      latestRide: latestRide ?? this.latestRide,
      serviceRecords: serviceRecords ?? this.serviceRecords,
      componentStatuses: componentStatuses ?? this.componentStatuses,
    );
  }
}

final garageStateProvider = NotifierProvider<GarageController, GarageState>(
  GarageController.new,
);

class GarageController extends Notifier<GarageState> {
  bool _mounted = true;
  // Local-storage owner id: Firebase UID once signed in, otherwise a
  // persisted per-install id. Cached from _hydrate() so the many
  // synchronous mutation methods below don't each need to await it.
  String _ownerId = '';

  @override
  GarageState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    const emptyBike = MotorcycleProfile(
      id: 'empty',
      name: '—',
      model: '—',
      odometerKm: 0,
      lastServiceKm: 0,
      chainWearPercent: -1,
      tireWearPercent: -1,
      brakeWearPercent: -1,
      oilHealthPercent: -1,
      batteryHealthPercent: -1,
      serviceIntervalKm: 6000,
    );

    const latestRide = RideSession(
      distanceKm: 0,
      durationMinutes: 0,
      averageSpeedKmh: 0,
      mood: '—',
      mechanicalObservation: '—',
    );

    return GarageState(
      isHydrating: true,
      activeBike: emptyBike,
      motorcycles: const [],
      latestRide: latestRide,
      serviceRecords: const [],
      componentStatuses: const [],
    );
  }

  void setActiveMotorcycle(MotorcycleProfile bike) {
    final active = _bikeById(bike.id) ?? bike;
    state = state.copyWith(
      activeBike: active,
      componentStatuses: _componentStatuses(active),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        active,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );
    unawaited(ApexKvStore.setString('garage.active_bike_id', active.id));
  }

  void updateMotorcycle({
    required MotorcycleProfile bike,
    required String name,
    required String model,
    required int odometerKm,
  }) {
    final next = bike.copyWith(
      name: name.trim().isEmpty ? bike.name : name.trim(),
      model: model.trim().isEmpty ? bike.model : model.trim(),
      odometerKm: odometerKm < 0 ? 0 : odometerKm,
    );
    final updated = _replaceMotorcycle(next);
    final active = state.activeBike.id == bike.id ? next : state.activeBike;
    state = state.copyWith(
      activeBike: active,
      motorcycles: updated,
      componentStatuses: _componentStatuses(active),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        active,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(next, userId: _ownerId));
    if (state.activeBike.id == next.id) {
      unawaited(ApexKvStore.setString('garage.active_bike_id', next.id));
    }
  }

  void updateServiceInterval(MotorcycleProfile bike, int serviceIntervalKm) {
    final next = bike.copyWith(
      serviceIntervalKm: serviceIntervalKm < 100 ? 100 : serviceIntervalKm,
    );
    final updated = _replaceMotorcycle(next);
    final active = state.activeBike.id == bike.id ? next : state.activeBike;
    state = state.copyWith(
      activeBike: active,
      motorcycles: updated,
      componentStatuses: _componentStatuses(active),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        active,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(next, userId: _ownerId));
    if (state.activeBike.id == next.id) {
      unawaited(ApexKvStore.setString('garage.active_bike_id', next.id));
    }
  }

  void toggleArchive(MotorcycleProfile bike) {
    final current = _bikeById(bike.id) ?? bike;
    final next = current.copyWith(archived: !current.archived);
    final updated = _replaceMotorcycle(next);
    // If active bike is archived, switch to first non-archived if possible.
    MotorcycleProfile active = state.activeBike;
    if (state.activeBike.id == bike.id && next.archived) {
      final fallback = updated.where((m) => !m.archived).toList();
      if (fallback.isNotEmpty) {
        active = fallback.first;
      } else {
        active = next;
      }
    } else if (state.activeBike.id == bike.id) {
      active = next;
    }
    state = state.copyWith(
      activeBike: active,
      motorcycles: updated,
      componentStatuses: _componentStatuses(active),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        active,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(next, userId: _ownerId));
    unawaited(ApexKvStore.setString('garage.active_bike_id', active.id));
  }

  void addServiceRecord({
    required String type,
    required String label,
    required int odometerKm,
    required String note,
  }) {
    final normalizedLabel = label.trim().isEmpty
        ? 'Manual service entry'
        : label.trim();
    final normalizedNote = note.trim().isEmpty
        ? 'No additional mechanical note.'
        : note.trim();
    final nextBike = state.activeBike.copyWith(
      odometerKm: odometerKm > state.activeBike.odometerKm
          ? odometerKm
          : state.activeBike.odometerKm,
      lastServiceKm: odometerKm > state.activeBike.lastServiceKm
          ? odometerKm
          : state.activeBike.lastServiceKm,
    );
    final nextMotorcycles = _replaceMotorcycle(nextBike);

    final record = ServiceRecord(
      id: const Uuid().v4(),
      type: type,
      label: normalizedLabel,
      odometerKm: odometerKm,
      status: 'New log',
      note: normalizedNote,
      loggedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      serviceRecords: [record, ...state.serviceRecords],
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
    unawaited(db.saveServiceRecord(record, nextBike.id, userId: _ownerId));
  }

  int _recalculateLastServiceKm(
    List<ServiceRecord> records,
    MotorcycleProfile bike,
  ) {
    if (records.isEmpty) {
      if (bike.serviceIntervalKm > 0) {
        return (bike.odometerKm ~/ bike.serviceIntervalKm) *
            bike.serviceIntervalKm;
      }
      return 0;
    }
    return records.map((r) => r.odometerKm).reduce((a, b) => a > b ? a : b);
  }

  void updateServiceRecord(ServiceRecord record) {
    final updatedRecords = state.serviceRecords
        .map((r) => r.id == record.id ? record : r)
        .toList();

    final newLastServiceKm = _recalculateLastServiceKm(
      updatedRecords,
      state.activeBike,
    );
    final nextBike = state.activeBike.copyWith(lastServiceKm: newLastServiceKm);
    final nextMotorcycles = _replaceMotorcycle(nextBike);

    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      serviceRecords: updatedRecords,
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
    unawaited(db.saveServiceRecord(record, nextBike.id, userId: _ownerId));
  }

  void deleteServiceRecord(String recordId) {
    final updatedRecords = state.serviceRecords
        .where((r) => r.id != recordId)
        .toList();

    final newLastServiceKm = _recalculateLastServiceKm(
      updatedRecords,
      state.activeBike,
    );

    final nextBike = state.activeBike.copyWith(lastServiceKm: newLastServiceKm);
    final nextMotorcycles = _replaceMotorcycle(nextBike);

    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      serviceRecords: updatedRecords,
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
    unawaited(db.deleteServiceRecord(recordId, state.activeBike.id));
  }

  void updateComponentHealth({
    required int chainWearPercent,
    required int tireWearPercent,
    required int brakeWearPercent,
    required int oilHealthPercent,
    required int batteryHealthPercent,
  }) {
    final nextBike = state.activeBike.copyWith(
      chainWearPercent: _clampPercent(chainWearPercent),
      tireWearPercent: _clampPercent(tireWearPercent),
      brakeWearPercent: _clampPercent(brakeWearPercent),
      oilHealthPercent: _clampPercent(oilHealthPercent),
      batteryHealthPercent: _clampPercent(batteryHealthPercent),
      wearUpdatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    final nextMotorcycles = _replaceMotorcycle(nextBike);

    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
  }

  /// Ride-to-Maintenance Intelligence: apply ride impact to active bike.
  ///
  /// Called automatically when a ride ends. Calculates wear degradation
  /// based on distance and mood (aggressive/sporty triggers 1.5x multiplier).
  void applyRideImpact({
    required double distanceKm,
    required String mood,
    required double averageSpeedKmh,
    double maxSpeedKmh = 0,
    double maxLeanAngle = 0,
    int hardBrakes = 0,
  }) {
    if (state.motorcycles.isEmpty || distanceKm <= 0) {
      return;
    }

    final bike = state.activeBike;

    final moodLower = mood.toLowerCase();
    final isAggressive =
        moodLower.contains('aggressive') ||
        moodLower.contains('sporty') ||
        moodLower.contains('fast') ||
        moodLower.contains('agresif') ||
        moodLower.contains('hızlı') ||
        moodLower.contains('sportif') ||
        maxSpeedKmh > 130.0 ||
        averageSpeedKmh > 95.0 ||
        maxLeanAngle > 45.0 ||
        hardBrakes > 3;
    final wearMultiplier = isAggressive ? 2.0 : 1.0;

    // Traffic (low average speed on non-trivial trip) or hard braking accelerates brake wear.
    final isTraffic =
        (averageSpeedKmh > 0 && averageSpeedKmh < 28.0 && distanceKm > 1.0) ||
        (averageSpeedKmh > 0 && averageSpeedKmh < 30.0 && !isAggressive);
    final isHardBraking = hardBrakes > 3;
    final brakeMultiplier = (isTraffic || isHardBraking) ? 2.0 : 1.0;

    // Odometer always increases.
    final nextOdometer = bike.odometerKm + distanceKm.round();

    // Component wear degrades with distance. Each ride's fractional wear is
    // added to a persisted carry and only the whole-number part is applied
    // to the integer *Percent fields — otherwise a ride under ~10-25 km
    // (a typical daily commute) rounds its own delta down to zero and the
    // rider's most common trips never register any wear at all.
    final chainCarry = bike.chainWearCarry + 0.05 * distanceKm * wearMultiplier;
    final tireCarry = bike.tireWearCarry + 0.03 * distanceKm * wearMultiplier;
    final brakeCarry =
        bike.brakeWearCarry + 0.02 * distanceKm * brakeMultiplier;
    final oilCarry = bike.oilWearCarry + 0.02 * distanceKm;

    final chainDelta = chainCarry.floor();
    final tireDelta = tireCarry.floor();
    final brakeDelta = brakeCarry.floor();
    final oilDelta = oilCarry.floor();

    // Battery charges on rides > 10 km when under 95%.
    final batteryCharge = (distanceKm > 10 && bike.batteryHealthPercent < 95)
        ? 2
        : 0;

    final nextBike = bike.copyWith(
      odometerKm: nextOdometer,
      chainWearPercent: _clampPercent(bike.chainWearPercent + chainDelta),
      tireWearPercent: _clampPercent(bike.tireWearPercent + tireDelta),
      brakeWearPercent: _clampPercent(bike.brakeWearPercent + brakeDelta),
      oilHealthPercent: _clampPercent(bike.oilHealthPercent - oilDelta),
      batteryHealthPercent: _clampPercent(
        bike.batteryHealthPercent + batteryCharge,
      ),
      chainWearCarry: chainCarry - chainDelta,
      tireWearCarry: tireCarry - tireDelta,
      brakeWearCarry: brakeCarry - brakeDelta,
      oilWearCarry: oilCarry - oilDelta,
      wearUpdatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    final nextMotorcycles = _replaceMotorcycle(nextBike);

    // Save latest ride info for insights
    final latestSession = RideSession(
      distanceKm: distanceKm,
      durationMinutes: 0,
      averageSpeedKmh: averageSpeedKmh,
      mood: mood,
      mechanicalObservation: '',
      loggedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      latestRide: latestSession,
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );
    unawaited(
      NotificationScheduler.scheduleDailyCheckReminder(
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
  }

  void syncOdometer(int odometerKm) {
    if (state.motorcycles.isEmpty ||
        odometerKm <= state.activeBike.odometerKm) {
      return;
    }
    final nextBike = state.activeBike.copyWith(odometerKm: odometerKm);
    final nextMotorcycles = _replaceMotorcycle(nextBike);
    state = state.copyWith(
      activeBike: nextBike,
      motorcycles: nextMotorcycles,
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
  }

  /// Build a [GaragePassport] snapshot for the active motorcycle.
  GaragePassport buildPassport() {
    final bike = state.activeBike;
    final rides = ref.read(rideStateProvider).sessions;
    final totalRides = rides.length;
    final totalDistance = rides.fold<double>(0, (sum, r) => sum + r.distanceKm);
    final avgDistance = totalRides > 0 ? totalDistance / totalRides : 0.0;

    final harmony = const HarmonyEngine().evaluate(bike, state.latestRide);

    return GaragePassport(
      bike: bike,
      serviceRecords: state.serviceRecords,
      totalRides: totalRides,
      totalDistanceKm: totalDistance,
      averageRideDistanceKm: avgDistance,
      harmonyScore: harmony.score,
      harmonyLevel: harmony.level.label,
      harmonyInsight: harmony.insight,
      generatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  }

  void addMotorcycle({
    required String name,
    required String model,
    required int odometerKm,
    int? lastServiceKm,
    int? serviceIntervalKm,
    int? chainWearPercent,
    int? tireWearPercent,
    int? brakeWearPercent,
    int? oilHealthPercent,
    int? batteryHealthPercent,
  }) {
    final safeOdometer = odometerKm < 0 ? 0 : odometerKm;
    final fallbackName = tInline(
      AppStrings.currentLanguageCode,
      'Yeni Motosiklet',
      'New Motorcycle',
      'Neues Motorrad',
    );
    final nextBike = MotorcycleProfile(
      id: _newBikeId(),
      name: name.trim().isEmpty ? fallbackName : name.trim(),
      model: model.trim().isEmpty
          ? tInline(
              AppStrings.currentLanguageCode,
              'Bilinmeyen model',
              'Unknown model',
              'Unbekanntes Modell',
            )
          : model.trim(),
      odometerKm: safeOdometer,
      lastServiceKm: lastServiceKm ?? safeOdometer,
      chainWearPercent: chainWearPercent ?? -1,
      tireWearPercent: tireWearPercent ?? -1,
      brakeWearPercent: brakeWearPercent ?? -1,
      oilHealthPercent: oilHealthPercent ?? -1,
      batteryHealthPercent: batteryHealthPercent ?? -1,
      serviceIntervalKm: serviceIntervalKm ?? 6000,
    );
    state = state.copyWith(
      isHydrating: false,
      activeBike: nextBike,
      motorcycles: [nextBike, ...state.motorcycles],
      componentStatuses: _componentStatuses(nextBike),
    );
    unawaited(
      NotificationScheduler.syncNotifications(
        nextBike,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.saveMotorcycle(nextBike, userId: _ownerId));
    unawaited(ApexKvStore.setString('garage.active_bike_id', nextBike.id));
  }

  void deleteMotorcycle(String bikeId) {
    final updatedMotorcycles = state.motorcycles
        .where((m) => m.id != bikeId)
        .toList();

    const emptyBike = MotorcycleProfile(
      id: 'empty',
      name: '—',
      model: '—',
      odometerKm: 0,
      lastServiceKm: 0,
      chainWearPercent: -1,
      tireWearPercent: -1,
      brakeWearPercent: -1,
      oilHealthPercent: -1,
      batteryHealthPercent: -1,
      serviceIntervalKm: 6000,
    );

    MotorcycleProfile nextActive = emptyBike;
    if (updatedMotorcycles.isNotEmpty) {
      if (state.activeBike.id == bikeId) {
        nextActive = updatedMotorcycles.firstWhere(
          (m) => !m.archived,
          orElse: () => updatedMotorcycles.first,
        );
      } else {
        nextActive = state.activeBike;
      }
    }

    state = state.copyWith(
      activeBike: nextActive,
      motorcycles: updatedMotorcycles,
      componentStatuses: _componentStatuses(nextActive),
    );

    unawaited(
      NotificationScheduler.syncNotifications(
        nextActive,
        AppStrings(ref.read(appSettingsProvider).locale),
      ),
    );

    final db = ref.read(dbServiceProvider);
    unawaited(db.deleteMotorcycle(bikeId));
    if (nextActive.id != 'empty') {
      unawaited(ApexKvStore.setString('garage.active_bike_id', nextActive.id));
    } else {
      unawaited(ApexKvStore.setString('garage.active_bike_id', ''));
    }
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    await db.init();
    try {
      _ownerId = await FirebaseService.instance.getOrCreateInstallationId();
    } catch (_) {}
    final motorcycles = await db.getMotorcycles(userId: _ownerId);
    final serviceRecords = await db.getServiceRecords(userId: _ownerId);

    final activeStableId = await ApexKvStore.getString('garage.active_bike_id');

    if (!_mounted) return;

    if (motorcycles.isEmpty) {
      state = state.copyWith(isHydrating: false);
      return;
    }

    final active = motorcycles.firstWhere(
      (bike) => bike.id == activeStableId,
      orElse: () => motorcycles.firstWhere(
        (bike) => !bike.archived,
        orElse: () => motorcycles.first,
      ),
    );

    state = state.copyWith(
      isHydrating: false,
      activeBike: active,
      motorcycles: motorcycles,
      serviceRecords: serviceRecords,
      componentStatuses: _componentStatuses(active),
    );
  }

  MotorcycleProfile? _bikeById(String id) {
    for (final bike in state.motorcycles) {
      if (bike.id == id) {
        return bike;
      }
    }
    return null;
  }

  List<MotorcycleProfile> _replaceMotorcycle(MotorcycleProfile nextBike) {
    if (state.motorcycles.isEmpty) {
      return [nextBike];
    }

    final updated = [
      for (final bike in state.motorcycles)
        if (bike.id == nextBike.id) nextBike else bike,
    ];

    if (state.motorcycles.any((bike) => bike.id == nextBike.id)) {
      return updated;
    }
    return [nextBike, ...state.motorcycles];
  }
}

int _clampPercent(int value) => value.clamp(0, 100);

final _bikeIdRandom = Random();

String _newBikeId() {
  final now = DateTime.now().microsecondsSinceEpoch;
  final salt = _bikeIdRandom.nextInt(1000000).toRadixString(36);
  return 'bike-$now-$salt';
}

List<GarageComponentStatus> _componentStatuses(MotorcycleProfile bike) {
  final rules = MaintenanceEngineV2.getDefaultRules();
  final now = DateTime.now().toUtc();

  // Derive installed odometer from lastServiceKm (best available proxy)
  final installedOdo = bike.lastServiceKm.toDouble();
  // Use the real last wear/service update when available; only fall back
  // to "90 days ago" for a bike that has never had a wear update recorded
  // (e.g. freshly added), rather than treating every bike as permanently
  // 90 days old regardless of its actual service history.
  final installedAt =
      DateTime.tryParse(bike.wearUpdatedAtIso ?? '') ??
      now.subtract(const Duration(days: 90));

  String _signal(ComponentType type, ServiceRule rule, int wearPercent) {
    if (wearPercent == -1) return 'Seçilmedi';
    final assessment = MaintenanceEngineV2.assess(
      type: type,
      rule: rule,
      currentOdometerKm: bike.odometerKm.toDouble(),
      installedOdometerKm: installedOdo,
      installedAtUtc: installedAt,
    );
    return assessment.nextAction;
  }

  return [
    GarageComponentStatus(
      label: 'Chain',
      value: bike.chainWearPercent == -1 ? '—' : '${bike.chainWearPercent}%',
      signal: _signal(
        ComponentType.chainSprocket,
        rules[ComponentType.chainSprocket]!,
        bike.chainWearPercent,
      ),
    ),
    GarageComponentStatus(
      label: 'Tires',
      value: bike.tireWearPercent == -1 ? '—' : '${bike.tireWearPercent}%',
      signal: _signal(
        ComponentType.tiresRear,
        rules[ComponentType.tiresRear]!,
        bike.tireWearPercent,
      ),
    ),
    GarageComponentStatus(
      label: 'Brakes',
      value: bike.brakeWearPercent == -1 ? '—' : '${bike.brakeWearPercent}%',
      signal: _signal(
        ComponentType.brakePadsRear,
        rules[ComponentType.brakePadsRear]!,
        bike.brakeWearPercent,
      ),
    ),
    GarageComponentStatus(
      label: 'Oil',
      value: bike.oilHealthPercent == -1 ? '—' : '${bike.oilHealthPercent}%',
      signal: _signal(
        ComponentType.engineOil,
        rules[ComponentType.engineOil]!,
        bike.oilHealthPercent,
      ),
    ),
    GarageComponentStatus(
      label: 'Battery',
      value: bike.batteryHealthPercent == -1
          ? '—'
          : '${bike.batteryHealthPercent}%',
      signal: bike.batteryHealthPercent == -1 ? 'Seçilmedi' : 'Voltaj stabil',
    ),
    GarageComponentStatus(
      label: 'Service',
      value: '${bike.kmSinceService} km',
      signal: _signal(
        ComponentType.engineOil,
        rules[ComponentType.engineOil]!,
        0,
      ),
    ),
  ];
}
