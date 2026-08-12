import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/rides/application/ride_telemetry_analyzer.dart';
import 'package:apexflow/core/i18n/app_strings.dart';

import 'package:apexflow/rides/domain/speed_telemetry_models.dart';
import 'package:apexflow/rides/application/validated_speed_engine.dart';

/// Result of a completed ride's location tracking.
class RideLocationResult {
  const RideLocationResult({
    required this.distanceKm,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.hasGpsData,
    required this.statusMessage,
    required this.activeDurationMinutes,
    this.telemetry,
    this.summary,
  });

  final double distanceKm;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final bool hasGpsData;
  final String statusMessage;
  final int activeDurationMinutes;
  final TelemetryAnalysis? telemetry;
  final RideTelemetrySummary? summary;
}

/// Service that tracks ride location using the device's GPS sensor.
///
/// Filters out coordinates with poor accuracy and suppresses GPS drift
/// when the vehicle is stationary. Automatically pauses timer when stopped.
class RideLocationService {
  static final RideLocationService _instance = RideLocationService._internal();

  factory RideLocationService() {
    return _instance;
  }

  RideLocationService._internal();

  /// Single source of truth for both the platform's location request and the
  /// engine's tolerances. They were previously independent — the config asked
  /// for a 1 s cadence while the Android request hardcoded 4 s — and nothing
  /// tied them together, which is how a sampling interval slower than the
  /// distance-integration window shipped unnoticed.
  static const TelemetryConfig _config = TelemetryConfig();

  final ValidatedSpeedEngine _speedEngine = ValidatedSpeedEngine(
    config: _config,
  );
  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _positions = [];
  bool _isTracking = false;
  String _statusMessage = '';

  /// Persisted key holding the in-progress ride's aggregates, so a ride
  /// survives the app process being killed mid-ride (common on aggressive
  /// Android battery managers). Without this, resuming tracking restarted the
  /// speed engine from zero and the whole commute was reported as "no
  /// movement detected".
  static const String _snapshotKey = 'rides.telemetry_snapshot';

  /// Aggregates carried over from earlier segments of the same ride.
  double _carriedDistanceKm = 0.0;
  double _carriedMovingDistanceKm = 0.0;
  double _carriedCoordinateDistanceKm = 0.0;
  int _carriedMovingSeconds = 0;
  double _carriedMaxSpeedKmh = 0.0;
  DateTime? _lastSnapshotWallClock;
  DateTime? _lastSnapshotSampleTime;

  bool get isTracking => _isTracking;

  /// Loads the aggregates of a ride that was interrupted by a process kill,
  /// so the rider can end it from any screen — not only from the one that
  /// happens to resume GPS tracking. No-op while tracking is live, otherwise
  /// the already-carried totals would be counted twice.
  Future<void> restoreInterruptedRide() async {
    if (_isTracking) return;
    await _loadSnapshot();
  }

  /// Start listening to GPS position updates with background support.
  Future<String> startTracking({required bool isTurkish}) async {
    _positions.clear();
    _speedEngine.startRide(startTime: DateTime.now());
    _statusMessage = '';
    _lastSnapshotWallClock = null;
    _lastSnapshotSampleTime = null;
    await _loadSnapshot();

    if (kIsWeb) {
      _statusMessage = tInline(
        AppStrings.currentLanguageCode,
        'Web tarayıcıda GPS konum izleme desteklenmiyor. Mesafe ve hız verisi alınamadı.',
        'GPS location tracking is not supported in web browsers. Distance and speed data unavailable.',
        'Die GPS-Standortverfolgung wird in Webbrowsern nicht unterstützt. Entfernungs- und Geschwindigkeitsdaten nicht verfügbar.',
      );
      _isTracking = false;
      return _statusMessage;
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusMessage = tInline(
          AppStrings.currentLanguageCode,
          'Konum servisleri kapalı. Mesafe ve hız verisi alınamadı. Lütfen cihaz ayarlarından GPS\'i açın.',
          'Location services are disabled. Distance and speed data unavailable. Please enable GPS in device settings.',
          'Ortungsdienste sind deaktiviert. Entfernungs- und Geschwindigkeitsdaten nicht verfügbar. Bitte aktivieren Sie GPS in den Geräteeinstellungen.',
        );
        _isTracking = false;
        return _statusMessage;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _statusMessage = tInline(
            AppStrings.currentLanguageCode,
            'Konum izni reddedildi. Mesafe ve hız verisi alınamadı.',
            'Location permission denied. Distance and speed data unavailable.',
            'Standortberechtigung verweigert. Entfernungs- und Geschwindigkeitsdaten nicht verfügbar.',
          );
          _isTracking = false;
          return _statusMessage;
        }
      }

      // Pil optimizasyonu arka planda GPS'i öldürüyor (Özellikle LG/Samsung cihazlarda).
      // Bu yüzden ignoreBatteryOptimizations izni istiyoruz.
      if (defaultTargetPlatform == TargetPlatform.android) {
        final batteryStatus =
            await Permission.ignoreBatteryOptimizations.status;
        if (!batteryStatus.isGranted) {
          await Permission.ignoreBatteryOptimizations.request();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _statusMessage = tInline(
          AppStrings.currentLanguageCode,
          'Konum izni kalıcı olarak reddedildi. Uygulama ayarlarından konum iznini açın.',
          'Location permission permanently denied. Enable location permission from app settings.',
          'Standortberechtigung dauerhaft verweigert. Aktivieren Sie die Standortberechtigung in den App-Einstellungen.',
        );
        _isTracking = false;
        return _statusMessage;
      }

      // Professional-grade foreground service background tracking settings
      late final LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          // distanceFilter must stay 0: geolocator maps it to
          // setMinUpdateDistanceMeters, which suppresses updates while the
          // bike crawls or waits at lights, starving speed integration.
          distanceFilter: 0,
          // Also mapped to setMinUpdateIntervalMillis, i.e. a hard floor on
          // the sample spacing. Driven by the engine's own desired cadence so
          // the two can never drift apart again.
          intervalDuration: Duration(milliseconds: _config.desiredIntervalMs),
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: tInline(
              AppStrings.currentLanguageCode,
              'Sürüş Devam Ediyor',
              'Ride in Progress',
              'Fahrt läuft',
            ),
            notificationText: tInline(
              AppStrings.currentLanguageCode,
              'Apex Flow motosiklet sürüşünüzü kaydediyor. Sürüş bitmeden kapatmayın.',
              'Apex Flow is recording your ride. Keep the app open until you end the ride.',
              'Apex Flow zeichnet Ihre Fahrt auf. Lassen Sie die App geöffnet, bis Sie die Fahrt beenden.',
            ),
            enableWakeLock: true,
            notificationIcon: const AndroidResource(
              name: 'ic_notification',
              defType: 'drawable',
            ),
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          activityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        );
      }

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            _onPositionUpdate,
            onError: (Object error) {
              debugPrint('RideLocationService: Position stream error: $error');
            },
          );

      _isTracking = true;
      _statusMessage = tInline(
        AppStrings.currentLanguageCode,
        'Sürüş başarıyla başlatıldı.',
        'Ride tracking started.',
        'Fahrtaufzeichnung gestartet.',
      );

      return _statusMessage;
    } catch (e) {
      _statusMessage = tInline(
        AppStrings.currentLanguageCode,
        'GPS donanımı bulunamadı veya konum verisi alınamadı.',
        'GPS hardware not found or location data unavailable.',
        'GPS-Hardware nicht gefunden oder Standortdaten nicht verfügbar.',
      );
      _isTracking = false;
      return _statusMessage;
    }
  }

  /// Restores aggregates written by an earlier segment of the *same* ride.
  /// The snapshot is keyed on `rides.started_at_iso`, so a freshly started
  /// ride (whose start marker is still empty or different) never inherits a
  /// previous ride's distance.
  Future<void> _loadSnapshot() async {
    _carriedDistanceKm = 0.0;
    _carriedMovingDistanceKm = 0.0;
    _carriedCoordinateDistanceKm = 0.0;
    _carriedMovingSeconds = 0;
    _carriedMaxSpeedKmh = 0.0;

    try {
      final startedAtIso = await ApexKvStore.getString('rides.started_at_iso');
      if (startedAtIso == null || startedAtIso.isEmpty) return;

      final isActive = await ApexKvStore.getBool('rides.is_active') ?? false;
      if (!isActive) return;

      final raw = await ApexKvStore.getString(_snapshotKey);
      if (raw == null || raw.isEmpty) return;

      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['startedAtIso'] != startedAtIso) return;

      _carriedDistanceKm = (data['distanceKm'] as num?)?.toDouble() ?? 0.0;
      _carriedMovingDistanceKm =
          (data['movingDistanceKm'] as num?)?.toDouble() ?? 0.0;
      _carriedCoordinateDistanceKm =
          (data['coordinateDistanceKm'] as num?)?.toDouble() ?? 0.0;
      _carriedMovingSeconds = (data['movingSeconds'] as num?)?.toInt() ?? 0;
      _carriedMaxSpeedKmh = (data['maxSpeedKmh'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('RideLocationService: snapshot restore failed: $e');
    }
  }

  /// Writes the ride's running totals so they survive a process kill.
  /// `finalizeRide` only reads engine state, so calling it mid-ride is safe.
  Future<void> _writeSnapshot() async {
    try {
      final startedAtIso = await ApexKvStore.getString('rides.started_at_iso');
      if (startedAtIso == null || startedAtIso.isEmpty) return;

      final summary = _speedEngine.finalizeRide(endTime: DateTime.now());
      final maxSpeedKmh =
          summary.validatedMaxSpeedKmh ?? summary.rawMaxSpeedKmh;

      await ApexKvStore.setString(
        _snapshotKey,
        jsonEncode({
          'startedAtIso': startedAtIso,
          'distanceKm': _carriedDistanceKm + summary.totalDistanceKm,
          'movingDistanceKm':
              _carriedMovingDistanceKm + summary.movingDistanceKm,
          'coordinateDistanceKm':
              _carriedCoordinateDistanceKm + summary.coordinateDistanceKm,
          'movingSeconds':
              _carriedMovingSeconds + summary.movingDuration.inSeconds,
          'maxSpeedKmh': math.max(_carriedMaxSpeedKmh, maxSpeedKmh ?? 0.0),
        }),
      );
    } catch (e) {
      debugPrint('RideLocationService: snapshot write failed: $e');
    }
  }

  Future<void> _clearSnapshot() async {
    try {
      await ApexKvStore.remove(_snapshotKey);
    } catch (e) {
      debugPrint('RideLocationService: snapshot clear failed: $e');
    }
  }

  void _onPositionUpdate(Position position) {
    // Process position through V2 Validated Speed Engine (Kalman Filter + NIS Outlier Gate + Motion State Machine)
    _speedEngine.processPosition(
      position,
      rideId: 'active_ride',
      sequence: _positions.length,
    );

    if (position.accuracy <= 45.0) {
      _positions.add(position);
    }

    // Checkpoint the running totals every 10 s. Both clocks are considered:
    // sample time is what actually advances the ride, wall time is the
    // backstop if a device reports odd fix timestamps.
    final now = DateTime.now();
    final sampleTime = position.timestamp;
    final wallDue =
        _lastSnapshotWallClock == null ||
        now.difference(_lastSnapshotWallClock!).inSeconds >= 10;
    final sampleDue =
        _lastSnapshotSampleTime == null ||
        sampleTime.difference(_lastSnapshotSampleTime!).inSeconds.abs() >= 10;

    if (wallDue || sampleDue) {
      _lastSnapshotWallClock = now;
      _lastSnapshotSampleTime = sampleTime;
      unawaited(_writeSnapshot());
    }
  }

  /// Stop tracking and compute final ride metrics.
  RideLocationResult stopTracking({required bool isTurkish}) {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    _isTracking = false;

    // Finalize V2 Validated Speed Engine Summary first — it tracks its own
    // accepted-sample count using ValidatedSpeedEngine/Kalman-filter
    // validation (config.absolutePositionRejectAccuracyM = 50m). `_positions`
    // below uses a separate, stricter 45m cutoff kept only for the
    // lean-angle/braking telemetry analyzer's input quality; gating the
    // whole ride on `_positions.length` here — as this used to do — meant a
    // ride with real, valid distance/speed accepted by the engine could
    // still get silently zeroed and reported as "no movement detected" if
    // GPS accuracy spent most of the ride between 45m and 50m. Gating on
    // the engine's own accepted-sample count instead removes that mismatch.
    final summary = _speedEngine.finalizeRide(endTime: DateTime.now());

    final hasCarriedRide = _carriedDistanceKm > 0.05;

    if (summary.acceptedSampleCount < 2 && !hasCarriedRide) {
      final msg = _statusMessage.isNotEmpty
          ? _statusMessage
          : (tInline(
              AppStrings.currentLanguageCode,
              'Yeterli konum verisi alınamadı. Sürüş mesafesi kaydedilemedi.',
              'Insufficient location data. Distance could not be recorded.',
              'Unzureichende Standortdaten. Entfernung konnte nicht erfasst werden.',
            ));
      unawaited(_clearSnapshot());
      return RideLocationResult(
        distanceKm: 0,
        averageSpeedKmh: 0,
        maxSpeedKmh: 0,
        hasGpsData: false,
        statusMessage: msg,
        activeDurationMinutes: 0,
        telemetry: null,
        summary: null,
      );
    }

    // Last-resort guard against losing a real ride: if the filtered-speed
    // integration produced (near) nothing but the accepted GPS fixes clearly
    // moved across the map, trust the plain great-circle distance rather than
    // discarding the ride as "no movement detected".
    final segmentDistanceKm = summary.totalDistanceKm < 0.05
        ? summary.coordinateDistanceKm
        : summary.totalDistanceKm;

    // Add whatever earlier segments of this same ride already covered before
    // the process was killed and tracking had to be resumed.
    final distanceKm = _carriedDistanceKm + segmentDistanceKm;
    final movingSeconds =
        _carriedMovingSeconds + summary.movingDuration.inSeconds;
    final maxSpeedKmh = math.max(
      _carriedMaxSpeedKmh,
      summary.validatedMaxSpeedKmh ?? (summary.rawMaxSpeedKmh ?? 0.0),
    );

    // Calculate active duration minutes (minimum 1 minute if distance > 0)
    final activeMinutes = (movingSeconds / 60.0).round();
    final finalActiveDuration = activeMinutes > 0 ? activeMinutes : 1;

    // Only distance the motion state machine actually classified as moving may
    // be divided by moving time. Substituting the whole segment's distance
    // here would inflate the average of a resumed ride, whose carried moving
    // seconds cover a period this segment's distance does not.
    final movingDistanceKm =
        _carriedMovingDistanceKm + summary.movingDistanceKm;

    var averageSpeedKmh = 0.0;
    if (movingSeconds > 0 && movingDistanceKm > 0) {
      averageSpeedKmh = movingDistanceKm / (movingSeconds / 3600.0);
    }
    if (averageSpeedKmh <= 0) {
      averageSpeedKmh = summary.movingAverageSpeedKmh > 0
          ? summary.movingAverageSpeedKmh
          : summary.tripAverageSpeedKmh;
    }
    if (averageSpeedKmh <= 0 && distanceKm > 0) {
      final elapsedHours = summary.elapsedDuration.inSeconds / 3600.0;
      if (elapsedHours > 0) {
        averageSpeedKmh = distanceKm / elapsedHours;
      }
    }

    unawaited(_clearSnapshot());
    _carriedDistanceKm = 0.0;
    _carriedMovingDistanceKm = 0.0;
    _carriedCoordinateDistanceKm = 0.0;
    _carriedMovingSeconds = 0;
    _carriedMaxSpeedKmh = 0.0;

    // Analyze telemetry to infer riding style
    final analyzer = const RideTelemetryAnalyzer();
    final telemetry = analyzer.analyze(
      _positions,
      maxSpeedKmh,
      speedEstimates: _speedEngine.estimates,
    );

    return RideLocationResult(
      distanceKm: distanceKm,
      averageSpeedKmh: averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      hasGpsData: true,
      statusMessage: tInline(
        AppStrings.currentLanguageCode,
        'Sürüş başarıyla kaydedildi.',
        'Ride logged successfully.',
        'Fahrt erfolgreich protokolliert.',
      ),
      activeDurationMinutes: finalActiveDuration,
      telemetry: telemetry,
      summary: summary,
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _positions.clear();
  }
}
