import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/garage/domain/motorcycle_profile.dart';
import 'package:apexflow/harmony_engine/harmony_engine.dart';
import 'package:apexflow/rituals/application/ride_readiness_model.dart';
import 'package:apexflow/rituals/application/rituals_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardState {
  const DashboardState({
    required this.bike,
    required this.latestRide,
    required this.hasLatestRide,
    required this.harmony,
    required this.readiness,
    required this.weather,
    required this.hasTodayCheck,
    required this.maintenanceSignals,
    required this.activeMaintenanceSignalCount,
  });

  final MotorcycleProfile bike;
  final RideSession latestRide;
  final bool hasLatestRide;
  final HarmonySnapshot harmony;
  final RideReadinessSnapshot readiness;
  final WeatherSnapshot weather;
  final bool hasTodayCheck;
  final List<DashboardMaintenanceSignal> maintenanceSignals;
  final int activeMaintenanceSignalCount;
}

class DashboardMaintenanceSignal {
  const DashboardMaintenanceSignal({
    required this.kind,
    required this.value,
    required this.severity,
    required this.priority,
  });

  final DashboardMaintenanceSignalKind kind;
  final String value;
  final DashboardSignalSeverity severity;
  final int priority;
}

enum DashboardMaintenanceSignalKind {
  clear,
  serviceOverdue,
  serviceDueSoon,
  chainWear,
  tireWear,
  brakeWear,
  oilHealth,
  batteryHealth,
}

enum DashboardSignalSeverity { stable, watch, caution, critical }

final dashboardStateProvider = Provider<DashboardState>((ref) {
  final garage = ref.watch(garageStateProvider);
  final rides = ref.watch(rideStateProvider);
  final rituals = ref.watch(ritualsStateProvider);
  final bike = garage.activeBike;
  final latestRide = rides.latestRide;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final todayCheck = rituals.dailyChecks.cast<DailyCheckEntry?>().firstWhere(
    (entry) => entry?.isoDate == today,
    orElse: () => null,
  );

  final harmony = const HarmonyEngine().evaluate(bike, latestRide);
  final readiness = evaluateRideReadiness(
    harmonyScore: harmony.score,
    weather: rituals.weather,
    todayCheck: todayCheck,
  );
  final maintenanceSignals = buildDashboardMaintenanceSignals(bike);
  return DashboardState(
    bike: bike,
    latestRide: latestRide,
    hasLatestRide: rides.sessions.isNotEmpty,
    harmony: harmony,
    readiness: readiness,
    weather: rituals.weather,
    hasTodayCheck: todayCheck != null,
    maintenanceSignals: maintenanceSignals,
    activeMaintenanceSignalCount: maintenanceSignals
        .where((signal) => signal.kind != DashboardMaintenanceSignalKind.clear)
        .length,
  );
});

List<DashboardMaintenanceSignal> buildDashboardMaintenanceSignals(
  MotorcycleProfile bike,
) {
  final signals = <DashboardMaintenanceSignal>[];

  switch (bike.serviceWindowState) {
    case ServiceWindowState.overdue:
      signals.add(
        DashboardMaintenanceSignal(
          kind: DashboardMaintenanceSignalKind.serviceOverdue,
          value: '${bike.kmUntilService.abs()} km',
          severity: DashboardSignalSeverity.critical,
          priority: 0,
        ),
      );
      break;
    case ServiceWindowState.dueSoon:
      signals.add(
        DashboardMaintenanceSignal(
          kind: DashboardMaintenanceSignalKind.serviceDueSoon,
          value: '${bike.kmUntilService} km',
          severity: DashboardSignalSeverity.caution,
          priority: 1,
        ),
      );
      break;
    case ServiceWindowState.stable:
      break;
  }

  _addWearSignal(
    signals,
    kind: DashboardMaintenanceSignalKind.chainWear,
    value: bike.chainWearPercent,
    priority: 2,
  );
  _addWearSignal(
    signals,
    kind: DashboardMaintenanceSignalKind.tireWear,
    value: bike.tireWearPercent,
    priority: 3,
  );
  _addWearSignal(
    signals,
    kind: DashboardMaintenanceSignalKind.brakeWear,
    value: bike.brakeWearPercent,
    priority: 4,
  );
  _addHealthSignal(
    signals,
    kind: DashboardMaintenanceSignalKind.oilHealth,
    value: bike.oilHealthPercent,
    priority: 5,
  );
  _addHealthSignal(
    signals,
    kind: DashboardMaintenanceSignalKind.batteryHealth,
    value: bike.batteryHealthPercent,
    priority: 6,
  );

  signals.sort((a, b) => a.priority.compareTo(b.priority));
  if (signals.isEmpty) {
    return const [
      DashboardMaintenanceSignal(
        kind: DashboardMaintenanceSignalKind.clear,
        value: 'Ready',
        severity: DashboardSignalSeverity.stable,
        priority: 99,
      ),
    ];
  }
  return signals.take(3).toList(growable: false);
}

void _addWearSignal(
  List<DashboardMaintenanceSignal> signals, {
  required DashboardMaintenanceSignalKind kind,
  required int value,
  required int priority,
}) {
  if (value == -1 || value < 55) {
    return;
  }
  signals.add(
    DashboardMaintenanceSignal(
      kind: kind,
      value: '$value%',
      severity: value >= 80
          ? DashboardSignalSeverity.critical
          : value >= 70
          ? DashboardSignalSeverity.caution
          : DashboardSignalSeverity.watch,
      priority: priority,
    ),
  );
}

void _addHealthSignal(
  List<DashboardMaintenanceSignal> signals, {
  required DashboardMaintenanceSignalKind kind,
  required int value,
  required int priority,
}) {
  if (value == -1 || value > 60) {
    return;
  }
  signals.add(
    DashboardMaintenanceSignal(
      kind: kind,
      value: '$value%',
      severity: value <= 35
          ? DashboardSignalSeverity.critical
          : value <= 45
          ? DashboardSignalSeverity.caution
          : DashboardSignalSeverity.watch,
      priority: priority,
    ),
  );
}
