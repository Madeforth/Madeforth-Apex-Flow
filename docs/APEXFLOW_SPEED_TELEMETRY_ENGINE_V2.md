# ApexFlow Speed Telemetry Engine V2 — Technical Documentation

## 1. Purpose of the Engine
The ApexFlow Speed Telemetry Engine V2 is an offline-first, high-precision telemetry engine designed to process raw GNSS and device sensor streams to compute validated maximum speed (`validatedMaxSpeedKmh`), moving/trip distances, active moving duration, and average speeds without relying on paid external APIs or hardware clamps.

## 2. Platform Speed Definition
Platform speed (`RawTelemetrySample.platformSpeedMps` / `Position.speed`) is defined as the velocity estimation reported by the underlying platform (Android Location API / iOS CoreLocation). The platform may utilize GNSS Doppler shift hardware measurements when available, but the value is not guaranteed to be a pure raw Doppler measurement across all devices and environmental conditions.

## 3. Data Flow Architecture
```
Raw GNSS Measurement (Position)
    |
    v
Source & Timestamp Validation (RawTelemetrySample)
    |
    +--> Valid Platform Speed (with R = speedAccuracyMps^2)
    |
    +--> Multi-Point Geodesic Coordinate Fallback
    |
    v
SpeedKalmanFilter (1D/2D Kinematic Kalman Filter)
    |
    v
Normalized Innovation Squared (NIS > 16.0) Outlier Gate & Recovery
    |
    v
Filtered Speed Estimate (SpeedEstimate)
    |
    +--> MotionStateMachine (Hysteresis & Retroactive Correction)
    |       |
    |       +--> Moving Duration & Active Riding Time
    |       +--> Trapezoidal Integrated Distance
    |       +--> Moving & Trip Average Speeds
    |
    +--> ValidatedSpeedEngine Peak Verification
            |
            v
      Neighboring Sample Validation (>= 2 Supporting Samples)
            |
            v
      Offline Backward Smoothing Pass
            |
            v
      Validated Max Speed (validatedMaxSpeedKmh)
```

## 4. Sample Validity & Outlier Rejection System
Before any measurement is fed into the estimation pipeline, it must pass explicit validation rules:
- **Coordinates**: Latitude and Longitude must be finite and within valid geographic bounds (`-90 <= lat <= 90`, `-180 <= lon <= 180`).
- **Position Accuracy**: Horizontal accuracy must be finite, non-negative, and `<= 50.0m` (`config.absolutePositionRejectAccuracyM`).
- **Timestamps**: Measurements must arrive with valid UTC timestamps and strictly positive time deltas ($\Delta t > 0$).
- **NIS Innovation Gate**: Single 4-sigma outliers ($NIS > 16.0$) are rejected. If 3 consecutive readings are consistent at a new level, the filter recalibrates to accept true rapid acceleration while discarding GPS spikes.

## 5. Distance & Average Speed Calculations
- **Trapezoidal Integration**: Distance between accepted speed estimates is computed via $d = \frac{v_1 + v_2}{2} \cdot \Delta t$. The old 10m noise threshold has been removed to preserve urban low-speed distances.
- **Trip Average Speed**: $v_{\text{trip\_avg}} = \frac{\text{Total Distance (km)}}{\text{Total Elapsed Time (Hours)}}$
- **Moving Average Speed**: $v_{\text{moving\_avg}} = \frac{\text{Moving Distance (km)}}{\text{Moving Duration (Hours)}}$

## 6. Validated Maximum Speed
- **No Artificial Upper Clamp**: The engine does NOT apply artificial hard clamps (e.g. 250 km/h or 300 km/h caps).
- **Neighbor Verification**: A peak speed candidate is accepted as `validatedMaxSpeedKmh` only if supported by at least 2 neighboring samples within a 3-second window and $\pm 15\%$ speed tolerance.
- **Raw Max Speed**: Stored as `rawMaxSpeedKmh` for developer diagnostic logging only and excluded from standard user interfaces.

## 7. Android vs iOS Differences & Sensor Limitations
- **Android**: Supports `elapsedRealtimeNanos` for monotonic timestamping. Uses `bestForNavigation` location settings.
- **iOS**: Uses `AppleSettings` with `automotiveNavigation` and background location indicator. Platform speed accuracy metadata is processed when available.
- **Limitations**: Smartphone GNSS chips are subject to satellite geometry (DOP), urban canyon reflections, and multipath interference. The engine does NOT claim to exceed motorcycle CAN-bus or multi-frequency RTK external hardware telemetry systems.

## 8. Approved Marketing Statements
- **Allowed**:
  - "Discover your validated maximum speed."
  - "Advanced offline GNSS speed and trajectory telemetry."
  - "Relive your ride metrics with high confidence."
- **Prohibited**:
  - "100% exact speed guarantee"
  - "Better than motorcycle CAN-bus or optical track computers"
  - "Artificial top speed record breaking claims"
