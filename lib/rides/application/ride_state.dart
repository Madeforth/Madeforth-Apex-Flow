import 'dart:async';

import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/rides/domain/ride_session.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

class RideState {
  const RideState({
    required this.isHydrating,
    required this.isRideActive,
    required this.activeMood,
    required this.sessions,
    this.rideStartedAtIso,
  });

  final bool isHydrating;
  final bool isRideActive;
  final String activeMood;
  final List<RideSession> sessions;
  final String? rideStartedAtIso;

  RideSession get latestRide => sessions.isEmpty
      ? const RideSession(
          distanceKm: 0,
          durationMinutes: 0,
          averageSpeedKmh: 0,
          mood: '—',
          mechanicalObservation: '—',
        )
      : sessions.first;

  RideState copyWith({
    bool? isHydrating,
    bool? isRideActive,
    String? activeMood,
    List<RideSession>? sessions,
    String? rideStartedAtIso,
    bool clearRideStartedAt = false,
  }) {
    return RideState(
      isHydrating: isHydrating ?? this.isHydrating,
      isRideActive: isRideActive ?? this.isRideActive,
      activeMood: activeMood ?? this.activeMood,
      sessions: sessions ?? this.sessions,
      rideStartedAtIso: clearRideStartedAt
          ? null
          : (rideStartedAtIso ?? this.rideStartedAtIso),
    );
  }
}

final rideStateProvider = NotifierProvider<RideController, RideState>(
  RideController.new,
);

class RideController extends Notifier<RideState> {
  bool _mounted = true;

  @override
  RideState build() {
    ref.onDispose(() => _mounted = false);
    unawaited(_hydrate());
    return RideState(
      isHydrating: true,
      isRideActive: false,
      activeMood: 'Focused',
      sessions: const [],
    );
  }

  void startRide({required String mood}) {
    final activeMood = mood.trim().isEmpty
        ? tInline(
            AppStrings.currentLanguageCode,
            'Odaklı',
            'Focused',
            'Konzentriert',
          )
        : mood.trim();
    final startedAtIso = DateTime.now().toUtc().toIso8601String();

    state = state.copyWith(
      isRideActive: true,
      activeMood: activeMood,
      rideStartedAtIso: startedAtIso,
    );

    unawaited(ApexKvStore.setBool('rides.is_active', true));
    unawaited(ApexKvStore.setString('rides.active_mood', activeMood));
    unawaited(ApexKvStore.setString('rides.started_at_iso', startedAtIso));
  }

  void cancelRide() {
    state = state.copyWith(isRideActive: false, clearRideStartedAt: true);
    unawaited(ApexKvStore.setBool('rides.is_active', false));
    unawaited(ApexKvStore.setString('rides.started_at_iso', ''));
  }

  /// Returns `true` if the ride was saved, `false` if it was discarded as
  /// too short/slow to be a real ride (callers should inform the user).
  bool endRide({
    required double distanceKm,
    required int durationMinutes,
    required double averageSpeedKmh,
    required String mood,
    required String mechanicalObservation,
    double maxSpeedKmh = 0,
    double maxLeanAngle = 0,
    int hardAccelerations = 0,
    int hardBrakes = 0,
    int harmonyScore = 0,
  }) {
    // If no real movement is detected (less than 0.1 km and avg speed < 1.0 km/h),
    // DO NOT save to history or last ride panel!
    if ((distanceKm < 0.1 && averageSpeedKmh < 1.0) ||
        (distanceKm <= 0.05 && durationMinutes == 0)) {
      cancelRide();
      return false;
    }

    // DOC 24 SECTION 37: Do not generate fake maxSpeed (average * 1.5) or fake maxLeanAngle when unmeasured!
    final maxSpeed = maxSpeedKmh > 0 ? maxSpeedKmh : 0.0;
    final maxLean = maxLeanAngle > 0 ? maxLeanAngle : 0.0;
    final hardAcc = hardAccelerations;
    final hardBrk = hardBrakes;
    final harmony = harmonyScore > 0
        ? harmonyScore
        : (mood == 'Aggressive' ? 65 : (mood == 'Sporty' ? 82 : 94));

    final session = RideSession(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      averageSpeedKmh: averageSpeedKmh,
      mood: mood.trim().isEmpty ? state.activeMood : mood.trim(),
      mechanicalObservation: mechanicalObservation.trim().isEmpty
          ? tInline(
              AppStrings.currentLanguageCode,
              'Mekanik gözlem kaydı yok.',
              'No mechanical observation recorded.',
              'Keine mechanische Beobachtung aufgezeichnet.',
            )
          : mechanicalObservation.trim(),
      maxSpeedKmh: maxSpeed,
      maxLeanAngle: maxLean,
      hardAccelerations: hardAcc,
      hardBrakes: hardBrk,
      harmonyScore: harmony,
      loggedAtIso: DateTime.now().toUtc().toIso8601String(),
    );

    // Ride-to-Maintenance Intelligence: propagate ride impact to garage.
    ref
        .read(garageStateProvider.notifier)
        .applyRideImpact(
          distanceKm: distanceKm,
          mood: session.mood,
          averageSpeedKmh: averageSpeedKmh,
          maxSpeedKmh: maxSpeed,
          maxLeanAngle: maxLean,
          hardBrakes: hardBrk,
        );

    state = state.copyWith(
      isRideActive: false,
      activeMood: session.mood,
      sessions: [session, ...state.sessions],
      clearRideStartedAt: true,
    );

    unawaited(ApexKvStore.setBool('rides.is_active', false));
    unawaited(ApexKvStore.setString('rides.active_mood', session.mood));
    unawaited(ApexKvStore.setString('rides.started_at_iso', ''));

    final db = ref.read(dbServiceProvider);
    final activeBike = ref.read(garageStateProvider).activeBike;
    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {}
    unawaited(db.saveRideSession(session, activeBike.id, userId: uid));

    // Check and unlock achievements
    ref.read(userProfileProvider.notifier).checkAndUnlockAchievements();
    return true;
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    String? uid;
    try {
      uid = FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {}
    final sessions = await db.getRideSessions(userId: uid);

    final isRideActive = await ApexKvStore.getBool('rides.is_active') ?? false;
    final activeMood =
        await ApexKvStore.getString('rides.active_mood') ?? 'Focused';
    final rideStartedAtIso = await ApexKvStore.getString(
      'rides.started_at_iso',
    );

    if (!_mounted) return;

    final sortedSessions = List<RideSession>.from(sessions)
      ..sort((a, b) => b.loggedAtIso.compareTo(a.loggedAtIso));

    state = state.copyWith(
      isHydrating: false,
      isRideActive: isRideActive,
      activeMood: activeMood,
      sessions: sortedSessions,
      rideStartedAtIso:
          (rideStartedAtIso != null && rideStartedAtIso.isNotEmpty)
          ? rideStartedAtIso
          : null,
    );
  }
}
