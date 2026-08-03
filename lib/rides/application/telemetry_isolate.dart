import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A data model to send fused telemetry data back to the main thread.
class TelemetryIsolateMessage {
  const TelemetryIsolateMessage({
    required this.fusedLeanAngle,
    required this.rawRollRate,
    required this.timestamp,
  });

  final double fusedLeanAngle;
  final double rawRollRate; // rad/s or deg/s
  final DateTime timestamp;
}

/// A command message sent from the main thread to the isolate.
class TelemetryCommand {
  const TelemetryCommand({
    required this.type,
    this.gpsLeanAngle,
    this.isMounted,
    this.gpsSpeed,
    this.gpsHeadingRate,
    this.x,
    this.y,
    this.z,
  });

  final String
  type; // e.g. 'CALIBRATE', 'UPDATE_GPS', 'STOP', 'MODE_SWITCH', 'ACCEL', 'GYRO'
  final double? gpsLeanAngle;
  final bool? isMounted;
  final double? gpsSpeed;
  final double? gpsHeadingRate;
  final double? x;
  final double? y;
  final double? z;
}

class TelemetryIsolate {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  final StreamController<TelemetryIsolateMessage> _telemetryStreamController =
      StreamController.broadcast();
  Stream<TelemetryIsolateMessage> get telemetryStream =>
      _telemetryStreamController.stream;

  bool get isRunning => _isolate != null;

  Future<void> start() async {
    if (isRunning) return;

    final token = RootIsolateToken.instance;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntryPoint, [
      _receivePort!.sendPort,
      token,
    ], debugName: 'ApexTelemetryIsolate');

    _receivePort!.listen((message) {
      if (message is SendPort) {
        // The isolate has started and given us its SendPort for commands
        _sendPort = message;
        _startSensors();
      } else if (message is TelemetryIsolateMessage) {
        _telemetryStreamController.add(message);
      }
    });
  }

  void _startSensors() {
    _accelSub =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen((event) {
          _sendPort?.send(
            TelemetryCommand(type: 'ACCEL', x: event.x, y: event.y, z: event.z),
          );
        });
    _gyroSub =
        gyroscopeEventStream(
          samplingPeriod: const Duration(milliseconds: 20),
        ).listen((event) {
          _sendPort?.send(
            TelemetryCommand(type: 'GYRO', x: event.x, y: event.y, z: event.z),
          );
        });
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
    _gyroSub?.cancel();
    _gyroSub = null;
    _sendPort?.send(const TelemetryCommand(type: 'STOP'));
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
  }

  void calibrateZeroOffset() {
    _sendPort?.send(const TelemetryCommand(type: 'CALIBRATE'));
  }

  void updateWithGpsKinematic(
    double gpsAngle, {
    double? speed,
    double? headingRate,
  }) {
    _sendPort?.send(
      TelemetryCommand(
        type: 'UPDATE_GPS',
        gpsLeanAngle: gpsAngle,
        gpsSpeed: speed,
        gpsHeadingRate: headingRate,
      ),
    );
  }

  void setMountMode(bool isMounted) {
    _sendPort?.send(
      TelemetryCommand(type: 'MODE_SWITCH', isMounted: isMounted),
    );
  }

  // --- 3D VECTOR MATH HELPERS ---
  static List<double> _normalize(List<double> v) {
    final mag = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (mag == 0) return [0, 0, 0];
    return [v[0] / mag, v[1] / mag, v[2] / mag];
  }

  static double _dotProduct(List<double> v1, List<double> v2) {
    return v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2];
  }

  // --- ISOLATE ENTRY POINT ---
  static void _isolateEntryPoint(List<dynamic> args) {
    final mainSendPort = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;

    if (token != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    }

    final commandPort = ReceivePort();
    mainSendPort.send(commandPort.sendPort);

    double currentLeanAngle = 0.0;
    double calibrationOffset = 0.0;
    DateTime? lastTime;
    DateTime? lastSentTime;

    // AHRS State
    bool isMountedMode = false;
    List<double> gravityVector = [
      0.0,
      9.81,
      0.0,
    ]; // Default down (Y-axis for portrait phone)
    double lastGpsSpeed = 0.0;
    double lastGpsHeadingRate = 0.0;

    // Listen for commands
    commandPort.listen((message) {
      if (message is TelemetryCommand) {
        switch (message.type) {
          case 'STOP':
            commandPort.close();
            break;
          case 'MODE_SWITCH':
            if (message.isMounted != null) {
              isMountedMode = message.isMounted!;
            }
            break;
          case 'CALIBRATE':
            calibrationOffset = currentLeanAngle;
            break;
          case 'UPDATE_GPS':
            if (message.gpsLeanAngle != null) {
              lastGpsSpeed = message.gpsSpeed ?? 0.0;
              lastGpsHeadingRate = message.gpsHeadingRate ?? 0.0;

              // Complementary filter: pull gyro integration towards absolute GPS truth
              final dynamicAlpha = isMountedMode ? 0.98 : 0.85;

              if (!isMountedMode) {
                final gpsAbs = message.gpsLeanAngle!.abs();
                currentLeanAngle =
                    (dynamicAlpha * currentLeanAngle.abs()) +
                    ((1.0 - dynamicAlpha) * gpsAbs);
              } else {
                currentLeanAngle =
                    (dynamicAlpha * currentLeanAngle) +
                    ((1.0 - dynamicAlpha) * message.gpsLeanAngle!);
              }
            }
            break;
          case 'ACCEL':
            if (isMountedMode) return;
            // Only update gravity vector if we are going straight (not cornering)
            if (lastGpsHeadingRate.abs() < 0.1 && lastGpsSpeed > 4.0) {
              final dtAccel = 0.1; // 100ms
              final tau = 2.0; // 2 second time constant
              final a = dtAccel / (tau + dtAccel);
              gravityVector[0] = (1 - a) * gravityVector[0] + a * message.x!;
              gravityVector[1] = (1 - a) * gravityVector[1] + a * message.y!;
              gravityVector[2] = (1 - a) * gravityVector[2] + a * message.z!;
            }
            break;
          case 'GYRO':
            final now = DateTime.now();
            if (lastTime != null) {
              final dt = now.difference(lastTime!).inMilliseconds / 1000.0;
              if (dt <= 0.0 || dt > 0.5) {
                lastTime = now;
                break;
              }

              double rollRateDegS = 0.0;

              if (isMountedMode) {
                rollRateDegS = message.z! * (180.0 / math.pi);
                if (rollRateDegS.abs() < 1.5) rollRateDegS = 0.0;

                // Continuous time-based exponential decay (tau = 3.0s)
                final decayAlpha = math.exp(-dt / 3.0);
                currentLeanAngle += (rollRateDegS * dt);
                currentLeanAngle *= decayAlpha;
              } else {
                // DOC 24 SECTION 17: Pocket mode IMU does NOT integrate gyro magnitude to produce lean angle!
                rollRateDegS = 0.0;
                currentLeanAngle = 0.0;
              }

              // Throttle output to 5Hz (every 200ms)
              if (lastSentTime == null ||
                  now.difference(lastSentTime!).inMilliseconds >= 200) {
                mainSendPort.send(
                  TelemetryIsolateMessage(
                    fusedLeanAngle: currentLeanAngle - calibrationOffset,
                    rawRollRate: rollRateDegS,
                    timestamp: now,
                  ),
                );
                lastSentTime = now;
              }
            }
            lastTime = now;
            break;
        }
      }
    });
  }
}
