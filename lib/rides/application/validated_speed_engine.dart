import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../domain/speed_telemetry_models.dart';
import 'speed_kalman_filter.dart';
import 'motion_state_machine.dart';

class ValidatedSpeedEngine {
  ValidatedSpeedEngine({this.config = const TelemetryConfig()}) {
    _kalmanFilter = SpeedKalmanFilter(config: config);
    _motionMachine = MotionStateMachine(config: config);
  }

  final TelemetryConfig config;
  late final SpeedKalmanFilter _kalmanFilter;
  late final MotionStateMachine _motionMachine;

  final List<RawTelemetrySample> _rawSamples = [];
  final List<SpeedEstimate> _estimates = [];

  /// The Kalman-filtered, NIS-gated speed estimate for every processed
  /// sample (accepted or rejected) — the same series distance/max-speed are
  /// computed from. Consumers that want per-sample speed (e.g. hard-braking
  /// detection) should read this instead of raw `Position.speed`, so their
  /// numbers agree with what the rest of the ride's telemetry is built on.
  List<SpeedEstimate> get estimates => List.unmodifiable(_estimates);

  DateTime? _rideStartTime;
  DateTime? _lastAcceptedTimestamp;
  double _lastAcceptedSpeedMps = 0.0;

  double _totalDistanceMeters = 0.0;
  double _movingDistanceMeters = 0.0;
  double _coordinateDistanceMeters = 0.0;

  double? _lastAcceptedLatitude;
  double? _lastAcceptedLongitude;

  int _acceptedSampleCount = 0;
  int _rejectedSampleCount = 0;
  bool _containsMockedLocations = false;
  bool _hasTelemetryGaps = false;

  void startRide({required DateTime startTime}) {
    _rideStartTime = startTime;
    _rawSamples.clear();
    _estimates.clear();
    _kalmanFilter.reset();
    _motionMachine.reset();
    _lastAcceptedTimestamp = null;
    _lastAcceptedSpeedMps = 0.0;
    _totalDistanceMeters = 0.0;
    _movingDistanceMeters = 0.0;
    _coordinateDistanceMeters = 0.0;
    _lastAcceptedLatitude = null;
    _lastAcceptedLongitude = null;
    _acceptedSampleCount = 0;
    _rejectedSampleCount = 0;
    _containsMockedLocations = false;
    _hasTelemetryGaps = false;
  }

  /// Processes a single incoming raw position sample.
  SpeedEstimate processPosition(
    Position position, {
    required String rideId,
    required int sequence,
  }) {
    final now = DateTime.now().toUtc();
    final measurementTime = position.timestamp.toUtc();

    if (position.isMocked) {
      _containsMockedLocations = true;
    }

    final rawSample = RawTelemetrySample(
      rideId: rideId,
      sequence: sequence,
      measurementTimeUtc: measurementTime,
      receivedTimeUtc: now,
      latitude: position.latitude,
      longitude: position.longitude,
      altitudeM: position.altitude,
      horizontalAccuracyM: position.accuracy,
      verticalAccuracyM: position.altitudeAccuracy,
      hasPlatformSpeed: position.speed >= 0.0,
      platformSpeedMps: position.speed >= 0.0 ? position.speed : null,
      speedAccuracyMps: position.speedAccuracy >= 0.0
          ? position.speedAccuracy
          : null,
      courseDeg: position.heading >= 0.0 ? position.heading : null,
      courseAccuracyDeg: position.headingAccuracy >= 0.0
          ? position.headingAccuracy
          : null,
      isMockedOrSimulated: position.isMocked,
    );

    _rawSamples.add(rawSample);

    // 1. Validation Checks
    final rejectionReasons = <String>[];

    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      rejectionReasons.add('INVALID_COORDINATES');
    }
    if (position.accuracy < 0 || !position.accuracy.isFinite) {
      rejectionReasons.add('INVALID_ACCURACY');
    }
    if (position.accuracy > config.absolutePositionRejectAccuracyM) {
      rejectionReasons.add('HIGH_POSITION_ACCURACY_ERROR');
    }

    if (_lastAcceptedTimestamp != null) {
      final dt =
          measurementTime.difference(_lastAcceptedTimestamp!).inMilliseconds /
          1000.0;
      if (dt <= 0) {
        rejectionReasons.add('NON_POSITIVE_TIME_DELTA');
      }
      if (dt > config.continuousDataGapSeconds) {
        _hasTelemetryGaps = true;
      }
    }

    if (rejectionReasons.isNotEmpty) {
      _rejectedSampleCount++;
      return SpeedEstimate(
        speedMps: _kalmanFilter.currentSpeedMps,
        uncertaintyMps: _kalmanFilter.speedUncertaintyMps,
        source: SpeedSource.unavailable,
        qualityScore: 0,
        confidence: TelemetryConfidence.unavailable,
        acceptedForDistance: false,
        acceptedForMaximumSpeed: false,
        rejectionReasons: rejectionReasons,
        timestamp: measurementTime,
      );
    }

    // 2. Speed Source Selection & Measurement Variance Calculation
    double measurementMps = 0.0;
    double varianceR = 6.25; // default sigma^2 = 2.5^2
    SpeedSource source = SpeedSource.unavailable;

    if (position.speed >= 0.0) {
      measurementMps = position.speed;
      source = SpeedSource.platform;
      if (position.speedAccuracy > 0.0) {
        varianceR = math.pow(position.speedAccuracy, 2).toDouble();
      } else {
        varianceR = math.pow(config.defaultPlatformSpeedSigmaMps, 2).toDouble();
      }
    } else if (_rawSamples.length >= 2) {
      // Fallback to Coordinate-derived speed if platform speed unavailable
      final prevSample = _rawSamples[_rawSamples.length - 2];
      final dt =
          measurementTime
              .difference(prevSample.measurementTimeUtc)
              .inMilliseconds /
          1000.0;

      if (dt > 0 &&
          dt <= config.maxCoordinateDtSeconds &&
          prevSample.horizontalAccuracyM <=
              config.maxCoordinateHorizontalAccuracyM) {
        final distMeters = Geolocator.distanceBetween(
          prevSample.latitude,
          prevSample.longitude,
          position.latitude,
          position.longitude,
        );
        measurementMps = distMeters / dt;
        source = SpeedSource.coordinateDerived;

        final combinedAccuracy = math.sqrt(
          math.pow(position.accuracy, 2) +
              math.pow(prevSample.horizontalAccuracyM, 2),
        );
        final coordSigma = math.max(
          config.minimumCoordinateSpeedSigmaMps,
          combinedAccuracy / dt,
        );
        varianceR = coordSigma * coordSigma;
      }
    }

    if (source == SpeedSource.unavailable) {
      _rejectedSampleCount++;
      return SpeedEstimate(
        speedMps: _kalmanFilter.currentSpeedMps,
        uncertaintyMps: _kalmanFilter.speedUncertaintyMps,
        source: SpeedSource.unavailable,
        qualityScore: 10,
        confidence: TelemetryConfidence.low,
        acceptedForDistance: false,
        acceptedForMaximumSpeed: false,
        rejectionReasons: ['NO_VALID_SPEED_SOURCE'],
        timestamp: measurementTime,
      );
    }

    // 3. Kalman Filter Update
    final filterResult = _kalmanFilter.update(
      measurementMps: measurementMps,
      varianceR: varianceR,
      timestamp: measurementTime,
    );

    // 4. Motion State Machine Update
    _motionMachine.update(
      filteredSpeedMps: filterResult.speedMps,
      uncertaintyMps: filterResult.uncertaintyMps,
      timestamp: measurementTime,
    );

    if (filterResult.accepted) {
      if (_lastAcceptedTimestamp != null) {
        final dt =
            measurementTime.difference(_lastAcceptedTimestamp!).inMilliseconds /
            1000.0;
        // Integrate over the real sampling cadence, not the (much stricter)
        // gap-diagnostic threshold: Android streams positions no faster than
        // AndroidSettings.intervalDuration, so gating on
        // `continuousDataGapSeconds` dropped every single segment of a real
        // ride and finalized it with zero distance.
        if (dt > 0 && dt <= config.maxDistanceIntegrationDtSeconds) {
          final segDist =
              ((_lastAcceptedSpeedMps + filterResult.speedMps) / 2.0) * dt;
          _totalDistanceMeters += segDist;

          if (_motionMachine.currentState == MotionState.moving) {
            _movingDistanceMeters += segDist;
          }
        }
      }

      // Independent great-circle accumulation, used only as a fallback if the
      // speed integration above yields nothing. Segments implying more than
      // 90 m/s (324 km/h) are treated as GPS jumps and skipped.
      final previousLat = _lastAcceptedLatitude;
      final previousLon = _lastAcceptedLongitude;
      final previousTime = _lastAcceptedTimestamp;
      if (previousLat != null && previousLon != null && previousTime != null) {
        final dt =
            measurementTime.difference(previousTime).inMilliseconds / 1000.0;
        final coordMeters = Geolocator.distanceBetween(
          previousLat,
          previousLon,
          position.latitude,
          position.longitude,
        );
        if (dt > 0 &&
            dt <= config.maxDistanceIntegrationDtSeconds &&
            coordMeters / dt <= 90.0) {
          _coordinateDistanceMeters += coordMeters;
        }
      }

      _lastAcceptedTimestamp = measurementTime;
      _lastAcceptedLatitude = position.latitude;
      _lastAcceptedLongitude = position.longitude;
      _lastAcceptedSpeedMps = filterResult.speedMps;
      _acceptedSampleCount++;
    }

    // Calculate Quality Score (0 to 100)
    int quality = 100;
    if (position.accuracy > 15.0) quality -= 20;
    if (position.accuracy > 30.0) quality -= 30;
    if (source == SpeedSource.coordinateDerived) quality -= 25;
    if (!filterResult.accepted) quality -= 40;
    quality = quality.clamp(0, 100);

    TelemetryConfidence confidence;
    if (quality >= config.highConfidenceThreshold) {
      confidence = TelemetryConfidence.high;
    } else if (quality >= config.mediumConfidenceThreshold) {
      confidence = TelemetryConfidence.medium;
    } else {
      confidence = TelemetryConfidence.low;
    }

    final estimate = SpeedEstimate(
      speedMps: filterResult.speedMps,
      uncertaintyMps: filterResult.uncertaintyMps,
      source: source,
      qualityScore: quality,
      confidence: confidence,
      acceptedForDistance: filterResult.accepted,
      acceptedForMaximumSpeed: filterResult.accepted && quality >= 40,
      rejectionReasons: filterResult.accepted
          ? []
          : ['NIS_OUTLIER_GATE_REJECTED'],
      timestamp: measurementTime,
    );

    _estimates.add(estimate);
    return estimate;
  }

  /// Median spacing between consecutive processed samples, in seconds.
  /// Returns 0 when there are not enough samples to measure a cadence.
  double _medianSampleGapSeconds() {
    if (_estimates.length < 2) return 0.0;
    final gaps = <double>[];
    for (int i = 1; i < _estimates.length; i++) {
      final dt =
          _estimates[i].timestamp
              .difference(_estimates[i - 1].timestamp)
              .inMilliseconds /
          1000.0;
      if (dt > 0) gaps.add(dt);
    }
    if (gaps.isEmpty) return 0.0;
    gaps.sort();
    return gaps[gaps.length ~/ 2];
  }

  /// Finalizes the ride session, performing backward smoothing for verified max speed.
  RideTelemetrySummary finalizeRide({required DateTime endTime}) {
    final rideStart =
        _rideStartTime ??
        (_rawSamples.isNotEmpty
            ? _rawSamples.first.measurementTimeUtc
            : endTime);
    final elapsedDuration = endTime.difference(rideStart);
    final movingDuration = _motionMachine.movingDuration;

    final totalDistanceKm = _totalDistanceMeters / 1000.0;
    final movingDistanceKm = _movingDistanceMeters / 1000.0;

    double tripAvgKmh = 0.0;
    if (elapsedDuration.inSeconds > 0) {
      tripAvgKmh = totalDistanceKm / (elapsedDuration.inSeconds / 3600.0);
    }

    double movingAvgKmh = 0.0;
    if (movingDuration.inSeconds > 0) {
      movingAvgKmh = movingDistanceKm / (movingDuration.inSeconds / 3600.0);
    }

    // 1. Compute Raw Max Speed (Developer Diagnosis)
    double rawMaxMps = 0.0;
    for (final s in _estimates) {
      if (s.speedMps > rawMaxMps) {
        rawMaxMps = s.speedMps;
      }
    }
    final rawMaxKmh = rawMaxMps * 3.6;

    // 2. Compute Verified/Validated Max Speed via Neighbor Supporting Verification
    // A peak candidate must be supported by neighboring samples (at least 2 consecutive samples)
    double validatedMaxMps = 0.0;
    SpeedEstimate? maxEstimate;
    int maxSupportingCount = 0;

    // Neighbours only count as supporting if they are close in time. A fixed
    // 3.5 s window silently disqualified every sample on platforms that
    // deliver positions more slowly than that (Android honours
    // AndroidSettings.intervalDuration), leaving a real ride with no
    // validated max speed at all. Scale the window to the ride's own cadence.
    final supportWindowSeconds = math.min(
      config.maxDistanceIntegrationDtSeconds,
      math.max(3.5, _medianSampleGapSeconds() * 2.0),
    );

    for (int i = 0; i < _estimates.length; i++) {
      final curr = _estimates[i];
      if (!curr.acceptedForMaximumSpeed) continue;

      // Count supporting neighbor samples within 3 seconds and +/- 15% speed range
      int supportingCount = 1;
      for (
        int j = math.max(0, i - 3);
        j <= math.min(_estimates.length - 1, i + 3);
        j++
      ) {
        if (i == j) continue;
        final neighbor = _estimates[j];
        if (!neighbor.acceptedForMaximumSpeed) continue;

        final dt =
            (neighbor.timestamp
                .difference(curr.timestamp)
                .inMilliseconds
                .abs()) /
            1000.0;
        if (dt <= supportWindowSeconds &&
            (neighbor.speedMps - curr.speedMps).abs() <=
                math.max(3.0, curr.speedMps * 0.15)) {
          supportingCount++;
        }
      }

      if (supportingCount >= 2 && curr.speedMps > validatedMaxMps) {
        validatedMaxMps = curr.speedMps;
        maxEstimate = curr;
        maxSupportingCount = supportingCount;
      }
    }

    final validatedMaxKmh = validatedMaxMps * 3.6;

    // Telemetry Coverage Ratio
    final totalSamples = _acceptedSampleCount + _rejectedSampleCount;
    final coverageRatio = totalSamples > 0
        ? (_acceptedSampleCount / totalSamples)
        : 0.0;

    return RideTelemetrySummary(
      validatedMaxSpeedKmh: validatedMaxKmh > 0 ? validatedMaxKmh : null,
      rawMaxSpeedKmh: rawMaxKmh > 0 ? rawMaxKmh : null,
      maxSpeedConfidence:
          maxEstimate?.confidence ?? TelemetryConfidence.unavailable,
      maxSpeedUncertaintyKmh: maxEstimate != null
          ? (maxEstimate.uncertaintyMps * 3.6)
          : null,
      maxSpeedTimestampUtc: maxEstimate?.timestamp,
      maxSpeedLatitude: null,
      maxSpeedLongitude: null,
      maxSpeedSource: maxEstimate?.source ?? SpeedSource.unavailable,
      maxSpeedSupportingSampleCount: maxSupportingCount,
      totalDistanceKm: totalDistanceKm,
      movingDistanceKm: movingDistanceKm,
      coordinateDistanceKm: _coordinateDistanceMeters / 1000.0,
      elapsedDuration: elapsedDuration,
      movingDuration: movingDuration,
      tripAverageSpeedKmh: tripAvgKmh,
      movingAverageSpeedKmh: movingAvgKmh,
      telemetryCoverageRatio: coverageRatio,
      acceptedSampleCount: _acceptedSampleCount,
      rejectedSampleCount: _rejectedSampleCount,
      containsMockedLocations: _containsMockedLocations,
      hasTelemetryGaps: _hasTelemetryGaps,
    );
  }
}
