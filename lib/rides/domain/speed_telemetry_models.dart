enum SpeedSource { platform, coordinateDerived, predicted, unavailable }

enum TelemetryConfidence { high, medium, low, unavailable }

enum MotionState { stopped, uncertain, moving }

class TelemetryConfig {
  const TelemetryConfig({
    this.desiredIntervalMs = 1000,
    this.minimumIntervalMs = 500,
    this.maxSampleAgeSeconds = 5.0,
    this.continuousDataGapSeconds = 3.0,
    this.maxDistanceIntegrationDtSeconds = 15.0,
    this.maxCoordinateDtSeconds = 3.0,
    this.maxCoordinateHorizontalAccuracyM = 30.0,
    this.absolutePositionRejectAccuracyM = 50.0,
    this.motionEnterSpeedMps = 1.5,
    this.motionExitSpeedMps = 0.8,
    this.motionEnterHoldSeconds = 2.0,
    this.motionExitHoldSeconds = 4.0,
    this.defaultPlatformSpeedSigmaMps = 2.5,
    this.minimumCoordinateSpeedSigmaMps = 1.5,
    this.normalizedInnovationGateSquared = 16.0,
    this.mediumConfidenceThreshold = 60,
    this.highConfidenceThreshold = 80,
  });

  final int desiredIntervalMs;
  final int minimumIntervalMs;
  final double maxSampleAgeSeconds;

  /// Flags a ride as having telemetry gaps when samples arrive further apart
  /// than this. Diagnostic only — it must never gate distance integration.
  final double continuousDataGapSeconds;

  /// Longest gap between two accepted samples that is still integrated into
  /// ride distance. Must stay comfortably above the platform's real location
  /// update interval, otherwise every segment is dropped and a genuine ride
  /// finalizes with zero distance.
  final double maxDistanceIntegrationDtSeconds;

  final double maxCoordinateDtSeconds;
  final double maxCoordinateHorizontalAccuracyM;
  final double absolutePositionRejectAccuracyM;
  final double motionEnterSpeedMps;
  final double motionExitSpeedMps;
  final double motionEnterHoldSeconds;
  final double motionExitHoldSeconds;
  final double defaultPlatformSpeedSigmaMps;
  final double minimumCoordinateSpeedSigmaMps;
  final double normalizedInnovationGateSquared;
  final int mediumConfidenceThreshold;
  final int highConfidenceThreshold;
}

class RawTelemetrySample {
  const RawTelemetrySample({
    required this.rideId,
    required this.sequence,
    required this.measurementTimeUtc,
    this.monotonicTimeNanos,
    required this.receivedTimeUtc,
    required this.latitude,
    required this.longitude,
    this.altitudeM,
    required this.horizontalAccuracyM,
    this.verticalAccuracyM,
    required this.hasPlatformSpeed,
    this.platformSpeedMps,
    this.speedAccuracyMps,
    this.courseDeg,
    this.courseAccuracyDeg,
    this.isMockedOrSimulated = false,
    this.provider,
  });

  final String rideId;
  final int sequence;
  final DateTime measurementTimeUtc;
  final int? monotonicTimeNanos;
  final DateTime receivedTimeUtc;
  final double latitude;
  final double longitude;
  final double? altitudeM;
  final double horizontalAccuracyM;
  final double? verticalAccuracyM;
  final bool hasPlatformSpeed;
  final double? platformSpeedMps;
  final double? speedAccuracyMps;
  final double? courseDeg;
  final double? courseAccuracyDeg;
  final bool isMockedOrSimulated;
  final String? provider;
}

class SpeedEstimate {
  const SpeedEstimate({
    required this.speedMps,
    required this.uncertaintyMps,
    required this.source,
    required this.qualityScore,
    required this.confidence,
    required this.acceptedForDistance,
    required this.acceptedForMaximumSpeed,
    required this.rejectionReasons,
    required this.timestamp,
  });

  final double speedMps;
  final double uncertaintyMps;
  final SpeedSource source;
  final int qualityScore;
  final TelemetryConfidence confidence;
  final bool acceptedForDistance;
  final bool acceptedForMaximumSpeed;
  final List<String> rejectionReasons;
  final DateTime timestamp;
}

class RideTelemetrySummary {
  const RideTelemetrySummary({
    this.validatedMaxSpeedKmh,
    this.rawMaxSpeedKmh,
    this.maxSpeedConfidence = TelemetryConfidence.unavailable,
    this.maxSpeedUncertaintyKmh,
    this.maxSpeedTimestampUtc,
    this.maxSpeedLatitude,
    this.maxSpeedLongitude,
    this.maxSpeedSource = SpeedSource.unavailable,
    this.maxSpeedSupportingSampleCount = 0,
    this.totalDistanceKm = 0.0,
    this.movingDistanceKm = 0.0,
    this.coordinateDistanceKm = 0.0,
    this.elapsedDuration = Duration.zero,
    this.movingDuration = Duration.zero,
    this.tripAverageSpeedKmh = 0.0,
    this.movingAverageSpeedKmh = 0.0,
    this.telemetryCoverageRatio = 0.0,
    this.acceptedSampleCount = 0,
    this.rejectedSampleCount = 0,
    this.containsMockedLocations = false,
    this.hasTelemetryGaps = false,
  });

  final double? validatedMaxSpeedKmh;
  final double? rawMaxSpeedKmh;
  final TelemetryConfidence maxSpeedConfidence;
  final double? maxSpeedUncertaintyKmh;
  final DateTime? maxSpeedTimestampUtc;
  final double? maxSpeedLatitude;
  final double? maxSpeedLongitude;
  final SpeedSource maxSpeedSource;
  final int maxSpeedSupportingSampleCount;

  final double totalDistanceKm;
  final double movingDistanceKm;

  /// Plain great-circle distance across accepted samples, independent of the
  /// filtered-speed integration. Used only as a last-resort sanity fallback so
  /// a genuine ride is never discarded as "no movement" when the integrator
  /// produces nothing.
  final double coordinateDistanceKm;
  final Duration elapsedDuration;
  final Duration movingDuration;
  final double tripAverageSpeedKmh;
  final double movingAverageSpeedKmh;

  final double telemetryCoverageRatio;
  final int acceptedSampleCount;
  final int rejectedSampleCount;
  final bool containsMockedLocations;
  final bool hasTelemetryGaps;

  Map<String, dynamic> toJson() {
    return {
      'validatedMaxSpeedKmh': validatedMaxSpeedKmh,
      'rawMaxSpeedKmh': rawMaxSpeedKmh,
      'maxSpeedConfidence': maxSpeedConfidence.name,
      'maxSpeedUncertaintyKmh': maxSpeedUncertaintyKmh,
      'maxSpeedTimestampUtc': maxSpeedTimestampUtc?.toIso8601String(),
      'maxSpeedLatitude': maxSpeedLatitude,
      'maxSpeedLongitude': maxSpeedLongitude,
      'maxSpeedSource': maxSpeedSource.name,
      'maxSpeedSupportingSampleCount': maxSpeedSupportingSampleCount,
      'totalDistanceKm': totalDistanceKm,
      'movingDistanceKm': movingDistanceKm,
      'coordinateDistanceKm': coordinateDistanceKm,
      'elapsedDurationMs': elapsedDuration.inMilliseconds,
      'movingDurationMs': movingDuration.inMilliseconds,
      'tripAverageSpeedKmh': tripAverageSpeedKmh,
      'movingAverageSpeedKmh': movingAverageSpeedKmh,
      'telemetryCoverageRatio': telemetryCoverageRatio,
      'acceptedSampleCount': acceptedSampleCount,
      'rejectedSampleCount': rejectedSampleCount,
      'containsMockedLocations': containsMockedLocations,
      'hasTelemetryGaps': hasTelemetryGaps,
    };
  }

  factory RideTelemetrySummary.fromJson(Map<String, dynamic> json) {
    return RideTelemetrySummary(
      validatedMaxSpeedKmh: (json['validatedMaxSpeedKmh'] as num?)?.toDouble(),
      rawMaxSpeedKmh: (json['rawMaxSpeedKmh'] as num?)?.toDouble(),
      maxSpeedConfidence: TelemetryConfidence.values.firstWhere(
        (e) => e.name == json['maxSpeedConfidence'],
        orElse: () => TelemetryConfidence.unavailable,
      ),
      maxSpeedUncertaintyKmh: (json['maxSpeedUncertaintyKmh'] as num?)
          ?.toDouble(),
      maxSpeedTimestampUtc: json['maxSpeedTimestampUtc'] != null
          ? DateTime.tryParse(json['maxSpeedTimestampUtc'] as String)
          : null,
      maxSpeedLatitude: (json['maxSpeedLatitude'] as num?)?.toDouble(),
      maxSpeedLongitude: (json['maxSpeedLongitude'] as num?)?.toDouble(),
      maxSpeedSource: SpeedSource.values.firstWhere(
        (e) => e.name == json['maxSpeedSource'],
        orElse: () => SpeedSource.unavailable,
      ),
      maxSpeedSupportingSampleCount:
          (json['maxSpeedSupportingSampleCount'] as num?)?.toInt() ?? 0,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      movingDistanceKm: (json['movingDistanceKm'] as num?)?.toDouble() ?? 0.0,
      elapsedDuration: Duration(
        milliseconds: json['elapsedDurationMs'] as int? ?? 0,
      ),
      movingDuration: Duration(
        milliseconds: json['movingDurationMs'] as int? ?? 0,
      ),
      tripAverageSpeedKmh:
          (json['tripAverageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      movingAverageSpeedKmh:
          (json['movingAverageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      telemetryCoverageRatio:
          (json['telemetryCoverageRatio'] as num?)?.toDouble() ?? 0.0,
      acceptedSampleCount: (json['acceptedSampleCount'] as num?)?.toInt() ?? 0,
      rejectedSampleCount: (json['rejectedSampleCount'] as num?)?.toInt() ?? 0,
      containsMockedLocations:
          json['containsMockedLocations'] as bool? ?? false,
      hasTelemetryGaps: json['hasTelemetryGaps'] as bool? ?? false,
    );
  }
}
