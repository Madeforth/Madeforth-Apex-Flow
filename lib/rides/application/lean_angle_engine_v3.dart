import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

enum LeanInvalidReason {
  none,
  insufficientPoints,
  poorAccuracy,
  lowSpeed,
  outsidePhysicalDomain, // e.g. >= 90 deg
  highFitResidual,
  unconfirmedTurn,
  gapOrPauseBoundary,
}

enum LeanConfidenceLevel { high, medium, low, invalid }

enum LeanSource { gnssTrajectory, fixedMountFusion, legacyUnverified }

class LeanEngineProfile {
  const LeanEngineProfile({
    this.version = '3.0.0-V3',
    this.maxAllowedAccuracyM = 20.0,
    this.minSpeedMps = 4.5, // ~16 km/h
    this.g = 9.80665,
    this.minTurnDurationSeconds = 1.0,
    this.minHighConfidenceWindows = 2,
  });

  final String version;
  final double maxAllowedAccuracyM;
  final double minSpeedMps;
  final double g;
  final double minTurnDurationSeconds;
  final int minHighConfidenceWindows;
}

class LeanGnssSample {
  const LeanGnssSample({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.timestampUtc,
    required this.horizontalAccuracyM,
    this.dopplerSpeedMps,
    this.courseDeg,
  });

  final double latitudeDeg;
  final double longitudeDeg;
  final DateTime timestampUtc;
  final double horizontalAccuracyM;
  final double? dopplerSpeedMps;
  final double? courseDeg;

  factory LeanGnssSample.fromPosition(Position p) {
    return LeanGnssSample(
      latitudeDeg: p.latitude,
      longitudeDeg: p.longitude,
      timestampUtc: p.timestamp,
      horizontalAccuracyM: p.accuracy,
      dopplerSpeedMps: p.speed >= 0 ? p.speed : null,
      courseDeg: p.heading >= 0 ? p.heading : null,
    );
  }
}

class LeanWindowResult {
  const LeanWindowResult({
    required this.leanDeg,
    required this.confidence,
    required this.confidenceLevel,
    required this.speedMps,
    required this.curvature,
    required this.fitResidualRms,
    required this.invalidReason,
  });

  final double? leanDeg;
  final double confidence;
  final LeanConfidenceLevel confidenceLevel;
  final double speedMps;
  final double curvature;
  final double fitResidualRms;
  final LeanInvalidReason invalidReason;

  bool get isValid =>
      invalidReason == LeanInvalidReason.none &&
      leanDeg != null &&
      leanDeg! >= 0.0 &&
      leanDeg! < 90.0;
}

class ConfirmedTurnEvent {
  const ConfirmedTurnEvent({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.peakLeanDeg,
    required this.robustMedianLeanDeg,
    required this.confidence,
    required this.supportingWindowCount,
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double peakLeanDeg;
  final double robustMedianLeanDeg;
  final double confidence;
  final int supportingWindowCount;
}

class LeanEstimate {
  const LeanEstimate({
    this.maxLeanDeg,
    required this.confidence,
    required this.confidenceLevel,
    required this.source,
    required this.algorithmVersion,
    required this.confirmedTurnCount,
    required this.invalidReason,
  });

  final double? maxLeanDeg;
  final double confidence;
  final LeanConfidenceLevel confidenceLevel;
  final LeanSource source;
  final String algorithmVersion;
  final int confirmedTurnCount;
  final LeanInvalidReason invalidReason;

  factory LeanEstimate.invalid(
    LeanInvalidReason reason, {
    String version = '3.0.0-V3',
  }) {
    return LeanEstimate(
      maxLeanDeg: null,
      confidence: 0.0,
      confidenceLevel: LeanConfidenceLevel.invalid,
      source: LeanSource.gnssTrajectory,
      algorithmVersion: version,
      confirmedTurnCount: 0,
      invalidReason: reason,
    );
  }
}

/// High-Precision 5-Point Trajectory Curvature Engine (V3)
class FivePointTrajectoryFit {
  const FivePointTrajectoryFit({this.profile = const LeanEngineProfile()});

  final LeanEngineProfile profile;

  LeanWindowResult fitWindow(List<LeanGnssSample> window) {
    if (window.length < 5) {
      return const LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: 0.0,
        curvature: 0.0,
        fitResidualRms: 999.0,
        invalidReason: LeanInvalidReason.insufficientPoints,
      );
    }

    // Check accuracy bounds for all 5 points
    for (final s in window) {
      if (s.horizontalAccuracyM > profile.maxAllowedAccuracyM ||
          s.horizontalAccuracyM <= 0.0) {
        return const LeanWindowResult(
          leanDeg: null,
          confidence: 0.0,
          confidenceLevel: LeanConfidenceLevel.invalid,
          speedMps: 0.0,
          curvature: 0.0,
          fitResidualRms: 999.0,
          invalidReason: LeanInvalidReason.poorAccuracy,
        );
      }
    }

    final center = window[2];
    final lat0 = center.latitudeDeg;
    final lon0 = center.longitudeDeg;
    const metersPerDegreeLat = 111320.0;
    final metersPerDegreeLon =
        math.cos(lat0 * math.pi / 180.0) * metersPerDegreeLat;

    // Convert to local metric coordinates centered at center (i=2)
    final x = <double>[];
    final y = <double>[];
    final t = <double>[];
    final w = <double>[];

    for (int j = 0; j < 5; j++) {
      final s = window[j];
      final dt =
          s.timestampUtc.difference(center.timestampUtc).inMilliseconds /
          1000.0;
      if (j > 0 &&
          dt <=
              window[j - 1].timestampUtc
                      .difference(center.timestampUtc)
                      .inMilliseconds /
                  1000.0) {
        // Non-monotonic timestamps
        return const LeanWindowResult(
          leanDeg: null,
          confidence: 0.0,
          confidenceLevel: LeanConfidenceLevel.invalid,
          speedMps: 0.0,
          curvature: 0.0,
          fitResidualRms: 999.0,
          invalidReason: LeanInvalidReason.gapOrPauseBoundary,
        );
      }
      x.add((s.longitudeDeg - lon0) * metersPerDegreeLon);
      y.add((s.latitudeDeg - lat0) * metersPerDegreeLat);
      t.add(dt);
      w.add(
        1.0 / math.max(s.horizontalAccuracyM * s.horizontalAccuracyM, 0.01),
      );
    }

    // Solve weighted quadratic fit for x(t) = b0 + b1*t + b2*t^2
    final bx = _solveWeightedQuadratic(t, x, w);
    final by = _solveWeightedQuadratic(t, y, w);

    if (bx == null || by == null) {
      return const LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: 0.0,
        curvature: 0.0,
        fitResidualRms: 999.0,
        invalidReason: LeanInvalidReason.highFitResidual,
      );
    }

    // Derivatives at t=0 (center point): xDot = bx1, xDDot = 2*bx2
    final xDot = bx[1];
    final yDot = by[1];
    final xDDot = 2.0 * bx[2];
    final yDDot = 2.0 * by[2];

    final fitSpeedMps = math.sqrt(xDot * xDot + yDot * yDot);
    final selectedSpeedMps =
        (center.dopplerSpeedMps != null && center.dopplerSpeedMps! > 0)
        ? center.dopplerSpeedMps!
        : fitSpeedMps;

    if (selectedSpeedMps < profile.minSpeedMps) {
      return LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: selectedSpeedMps,
        curvature: 0.0,
        fitResidualRms: 0.0,
        invalidReason: LeanInvalidReason.lowSpeed,
      );
    }

    // Compute residual RMS
    var residualSum = 0.0;
    var weightSum = 0.0;
    for (int j = 0; j < 5; j++) {
      final px = bx[0] + bx[1] * t[j] + bx[2] * t[j] * t[j];
      final py = by[0] + by[1] * t[j] + by[2] * t[j] * t[j];
      final errSq = (x[j] - px) * (x[j] - px) + (y[j] - py) * (y[j] - py);
      residualSum += w[j] * errSq;
      weightSum += w[j];
    }
    final residualRms = math.sqrt(residualSum / math.max(weightSum, 0.001));

    if (residualRms > 5.0) {
      return LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: selectedSpeedMps,
        curvature: 0.0,
        fitResidualRms: residualRms,
        invalidReason: LeanInvalidReason.highFitResidual,
      );
    }

    // Signed curvature kappa = (xDot*yDDot - yDot*xDDot) / (xDot^2 + yDot^2)^(1.5)
    final num = (xDot * yDDot - yDot * xDDot);
    final den = math.pow(xDot * xDot + yDot * yDot, 1.5).toDouble();

    if (den <= 0.0001) {
      return LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: selectedSpeedMps,
        curvature: 0.0,
        fitResidualRms: residualRms,
        invalidReason: LeanInvalidReason.highFitResidual,
      );
    }

    final kappa = num / den;
    final absKappa = kappa.abs();
    final ac = selectedSpeedMps * selectedSpeedMps * absKappa;
    final leanRad = math.atan(ac / profile.g);
    final leanDeg = leanRad * (180.0 / math.pi);

    // CRITICAL CORRECTION: Reject non-physical domain values (>= 90 deg) instead of clamping!
    if (leanDeg.isNaN ||
        leanDeg.isInfinite ||
        leanDeg >= 90.0 ||
        leanDeg < 0.0) {
      return LeanWindowResult(
        leanDeg: null,
        confidence: 0.0,
        confidenceLevel: LeanConfidenceLevel.invalid,
        speedMps: selectedSpeedMps,
        curvature: kappa,
        fitResidualRms: residualRms,
        invalidReason: LeanInvalidReason.outsidePhysicalDomain,
      );
    }

    // Explainable Confidence Score (0.0 to 1.0)
    final qAccuracy =
        (1.0 - (center.horizontalAccuracyM / profile.maxAllowedAccuracyM))
            .clamp(0.0, 1.0);
    final qResidual = (1.0 - (residualRms / 5.0)).clamp(0.0, 1.0);
    final qSpeed = (selectedSpeedMps / 30.0).clamp(0.2, 1.0);
    final confidence = (0.4 * qAccuracy + 0.4 * qResidual + 0.2 * qSpeed).clamp(
      0.0,
      1.0,
    );

    final confidenceLevel = confidence >= 0.80
        ? LeanConfidenceLevel.high
        : (confidence >= 0.60
              ? LeanConfidenceLevel.medium
              : LeanConfidenceLevel.low);

    return LeanWindowResult(
      leanDeg: leanDeg,
      confidence: confidence,
      confidenceLevel: confidenceLevel,
      speedMps: selectedSpeedMps,
      curvature: kappa,
      fitResidualRms: residualRms,
      invalidReason: LeanInvalidReason.none,
    );
  }

  /// Solves 3x3 normal equations A^T W A b = A^T W v for quadratic fit
  List<double>? _solveWeightedQuadratic(
    List<double> t,
    List<double> values,
    List<double> w,
  ) {
    double s0 = 0, s1 = 0, s2 = 0, s3 = 0, s4 = 0;
    double v0 = 0, v1 = 0, v2 = 0;

    for (int i = 0; i < 5; i++) {
      final ti = t[i];
      final ti2 = ti * ti;
      final wi = w[i];

      s0 += wi;
      s1 += wi * ti;
      s2 += wi * ti2;
      s3 += wi * ti2 * ti;
      s4 += wi * ti2 * ti2;

      v0 += wi * values[i];
      v1 += wi * ti * values[i];
      v2 += wi * ti2 * values[i];
    }

    // Matrix elements
    final a00 = s0, a01 = s1, a02 = s2;
    final a10 = s1, a11 = s2, a12 = s3;
    final a20 = s2, a21 = s3, a22 = s4;

    final det =
        a00 * (a11 * a22 - a12 * a21) -
        a01 * (a10 * a22 - a12 * a20) +
        a02 * (a10 * a21 - a11 * a20);
    if (det.abs() < 1e-9) return null;

    final b0 =
        ((v0 * (a11 * a22 - a12 * a21) -
            a01 * (v1 * a22 - a12 * v2) +
            a02 * (v1 * a21 - a11 * v2)) /
        det);
    final b1 =
        ((a00 * (v1 * a22 - a12 * v2) -
            v0 * (a10 * a22 - a12 * a20) +
            a02 * (a10 * v2 - v1 * a20)) /
        det);
    final b2 =
        ((a00 * (a11 * v2 - v1 * a21) -
            a01 * (a10 * v2 - v1 * a20) +
            v0 * (a10 * a21 - a11 * a20)) /
        det);

    return [b0, b1, b2];
  }
}

/// Confirmed Turn Event Detector and Peak Selector
class TurnEventDetector {
  const TurnEventDetector({this.profile = const LeanEngineProfile()});

  final LeanEngineProfile profile;

  List<ConfirmedTurnEvent> detectTurnEvents(
    List<LeanWindowResult> windowResults,
    List<LeanGnssSample> samples,
  ) {
    final confirmedEvents = <ConfirmedTurnEvent>[];
    final candidateWindows = <LeanWindowResult>[];
    DateTime? eventStart;

    for (int i = 0; i < windowResults.length; i++) {
      final res = windowResults[i];
      final sample = samples[i + 2]; // Center point of 5-point window

      if (res.isValid &&
          res.confidenceLevel != LeanConfidenceLevel.low &&
          res.curvature.abs() > 0.005) {
        if (candidateWindows.isEmpty) {
          eventStart = sample.timestampUtc;
        }
        candidateWindows.add(res);
      } else {
        if (candidateWindows.isNotEmpty && eventStart != null) {
          final eventEnd = samples[i + 1].timestampUtc;
          final durationSec =
              eventEnd.difference(eventStart).inMilliseconds / 1000.0;

          final highConfCount = candidateWindows
              .where((w) => w.confidenceLevel == LeanConfidenceLevel.high)
              .length;

          if (durationSec >= profile.minTurnDurationSeconds &&
              highConfCount >= profile.minHighConfidenceWindows) {
            // Robust Peak Selection: Median of top 3 high-confidence lean values
            final leanValues =
                candidateWindows
                    .where((w) => w.leanDeg != null)
                    .map((w) => w.leanDeg!)
                    .toList()
                  ..sort();

            final rawPeak = leanValues.last;
            final top3 = leanValues.length >= 3
                ? leanValues.sublist(leanValues.length - 3)
                : leanValues;
            final robustMedian = top3[top3.length ~/ 2];

            final avgConfidence =
                candidateWindows
                    .map((w) => w.confidence)
                    .reduce((a, b) => a + b) /
                candidateWindows.length;

            confirmedEvents.add(
              ConfirmedTurnEvent(
                id: 'turn_${eventStart.millisecondsSinceEpoch}',
                startTime: eventStart,
                endTime: eventEnd,
                peakLeanDeg: rawPeak,
                robustMedianLeanDeg: robustMedian,
                confidence: avgConfidence,
                supportingWindowCount: candidateWindows.length,
              ),
            );
          }
          candidateWindows.clear();
          eventStart = null;
        }
      }
    }

    return confirmedEvents;
  }
}

/// Main V3 Lean Angle Telemetry Engine Coordinator
class LeanAngleEngineV3 {
  const LeanAngleEngineV3({this.profile = const LeanEngineProfile()});

  final LeanEngineProfile profile;

  LeanEstimate evaluateRideTrajectory(List<Position> rawPositions) {
    if (rawPositions.length < 5) {
      return LeanEstimate.invalid(
        LeanInvalidReason.insufficientPoints,
        version: profile.version,
      );
    }

    final samples = rawPositions.map(LeanGnssSample.fromPosition).toList();
    final fitter = FivePointTrajectoryFit(profile: profile);
    final windowResults = <LeanWindowResult>[];

    for (int i = 2; i < samples.length - 2; i++) {
      final window = samples.sublist(i - 2, i + 3);
      final res = fitter.fitWindow(window);
      windowResults.add(res);
    }

    final detector = TurnEventDetector(profile: profile);
    final confirmedEvents = detector.detectTurnEvents(windowResults, samples);

    if (confirmedEvents.isEmpty) {
      return LeanEstimate.invalid(
        LeanInvalidReason.unconfirmedTurn,
        version: profile.version,
      );
    }

    // Ride max lean angle is the maximum of robust medians among confirmed turn events
    double rideMaxLean = 0.0;
    double maxConfidence = 0.0;

    for (final ev in confirmedEvents) {
      if (ev.robustMedianLeanDeg > rideMaxLean) {
        rideMaxLean = ev.robustMedianLeanDeg;
        maxConfidence = ev.confidence;
      }
    }

    final overallConfidenceLevel = maxConfidence >= 0.80
        ? LeanConfidenceLevel.high
        : (maxConfidence >= 0.60
              ? LeanConfidenceLevel.medium
              : LeanConfidenceLevel.low);

    return LeanEstimate(
      maxLeanDeg: rideMaxLean,
      confidence: maxConfidence,
      confidenceLevel: overallConfidenceLevel,
      source: LeanSource.gnssTrajectory,
      algorithmVersion: profile.version,
      confirmedTurnCount: confirmedEvents.length,
      invalidReason: LeanInvalidReason.none,
    );
  }
}

/// Persistence & Legacy Database Migration Sanitizer
class LeanPersistenceSanitizer {
  /// Sanitizes legacy raw max lean angle values (e.g. 168 degrees or invalid values).
  /// If value >= 90 or unverified legacy, returns null for UI record highlight while preserving audit metadata.
  static double? sanitizeForUiDisplay(
    double? rawMaxLeanDeg, {
    bool isLegacy = false,
  }) {
    if (rawMaxLeanDeg == null ||
        rawMaxLeanDeg.isNaN ||
        rawMaxLeanDeg.isInfinite)
      return null;
    if (rawMaxLeanDeg >= 90.0 || rawMaxLeanDeg < 0.0)
      return null; // Reject 168 deg!
    if (isLegacy && rawMaxLeanDeg > 45.0)
      return null; // Unverified legacy extreme values
    return rawMaxLeanDeg;
  }
}
