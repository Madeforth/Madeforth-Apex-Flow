import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:apexflow/rides/application/ride_telemetry_analyzer.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/rides/application/telemetry_isolate.dart';
import 'package:apexflow/rides/application/sensor_fusion_engine.dart';

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

  final ValidatedSpeedEngine _speedEngine = ValidatedSpeedEngine();
  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _positions = [];
  bool _isTracking = false;
  String _statusMessage = '';

  final TelemetryIsolate _telemetryIsolate = TelemetryIsolate();
  StreamSubscription<TelemetryIsolateMessage>? _telemetrySub;
  double _maxFusedLeanAngle = 0.0;
  bool _isPhoneMounted = false;

  bool get isTracking => _isTracking;
  bool get hasGpsData => _positions.length >= 2;

  /// Calibrates the gyroscope zero-offset for the lean angle telemetry.
  void calibrateMount() {
    if (_telemetryIsolate.isRunning) {
      _telemetryIsolate.calibrateZeroOffset();
    }
  }

  /// Start listening to GPS position updates with background support.
  Future<String> startTracking({
    required bool isTurkish,
    required bool isMounted,
  }) async {
    _positions.clear();
    _speedEngine.startRide(startTime: DateTime.now());
    _statusMessage = '';
    _maxFusedLeanAngle = 0.0;
    _isPhoneMounted = isMounted;

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
          distanceFilter: 10, // Battery optimized distance filter
          intervalDuration: const Duration(seconds: 4),
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
          distanceFilter: 10,
          activityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
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

      // Start High-Frequency Sensor Fusion (Now supports Pocket Mode via AHRS)
      await _telemetryIsolate.start();
      _telemetryIsolate.setMountMode(_isPhoneMounted);

      _telemetrySub = _telemetryIsolate.telemetryStream.listen((msg) {
        final absLean = msg.fusedLeanAngle.abs();
        if (absLean > _maxFusedLeanAngle &&
            !absLean.isNaN &&
            !absLean.isInfinite) {
          _maxFusedLeanAngle = absLean;
        }
      });

      if (!_isPhoneMounted) {
        _statusMessage += tInline(
          AppStrings.currentLanguageCode,
          ' (Akıllı Telemetri: Cep)',
          ' (Smart Telemetry: Pocket)',
          ' (Smart-Telemetrie: Tasche)',
        );
      }

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

  void _onPositionUpdate(Position position) {
    // Process position through V2 Validated Speed Engine (Kalman Filter + NIS Outlier Gate + Motion State Machine)
    _speedEngine.processPosition(
      position,
      rideId: 'active_ride',
      sequence: _positions.length,
    );

    // Feed GPS kinematic lean angle to the sensor fusion isolate to correct gyro drift
    if (_positions.isNotEmpty) {
      final prev = _positions.last;
      final dt = position.timestamp
          .difference(prev.timestamp)
          .inSeconds
          .toDouble();
      if (dt > 0) {
        double headingDiff = position.heading - prev.heading;
        if (headingDiff > 180) headingDiff -= 360;
        if (headingDiff < -180) headingDiff += 360;
        final omega = (headingDiff / dt) * (math.pi / 180.0);
        final gpsLean = SensorFusionEngine.calculateGpsKinematicAngle(
          position.speed,
          omega,
        );

        // Pass speed and headingRate for AHRS gravity vectoring
        _telemetryIsolate.updateWithGpsKinematic(
          gpsLean,
          speed: position.speed,
          headingRate: omega,
        );
      }
    }

    if (position.accuracy <= 45.0) {
      _positions.add(position);
    }
  }

  /// Stop tracking and compute final ride metrics.
  RideLocationResult stopTracking({required bool isTurkish}) {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    _telemetrySub?.cancel();
    _telemetryIsolate.stop();

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

    if (summary.acceptedSampleCount < 2) {
      final msg = _statusMessage.isNotEmpty
          ? _statusMessage
          : (tInline(
              AppStrings.currentLanguageCode,
              'Yeterli konum verisi alınamadı. Sürüş mesafesi kaydedilemedi.',
              'Insufficient location data. Distance could not be recorded.',
              'Unzureichende Standortdaten. Entfernung konnte nicht erfasst werden.',
            ));
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

    final distanceKm = summary.totalDistanceKm;
    final maxSpeedKmh =
        summary.validatedMaxSpeedKmh ?? (summary.rawMaxSpeedKmh ?? 0.0);

    // Calculate active duration minutes (minimum 1 minute if distance > 0)
    final activeMinutes = (summary.movingDuration.inSeconds / 60.0).round();
    final finalActiveDuration = activeMinutes > 0 ? activeMinutes : 1;

    final averageSpeedKmh = summary.movingAverageSpeedKmh > 0
        ? summary.movingAverageSpeedKmh
        : summary.tripAverageSpeedKmh;

    // Analyze telemetry to infer riding style
    final analyzer = const RideTelemetryAnalyzer();
    final telemetry = analyzer.analyze(
      _positions,
      maxSpeedKmh,
      fusedMaxLeanAngle: _maxFusedLeanAngle,
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
