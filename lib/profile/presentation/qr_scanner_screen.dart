import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/presentation/smart_park_alert_handler_screen.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _initializingCamera = true;
  String? _scanError;
  bool _processingImage = false;
  DateTime? _lastProcessedTime;

  @override
  void initState() {
    super.initState();
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      unawaited(_cameraController?.stopImageStream());
    }
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          setState(() {
            _initializingCamera = false;
            _scanError = tInline(
              widget.strings.languageCode,
              'Kamera izni verilmedi.',
              'Camera permission denied.',
              'Kameraberechtigung verweigert.',
            );
          });
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializingCamera = false;
          _scanError = tInline(
            widget.strings.languageCode,
            'Kamera bulunamadı.',
            'No cameras found.',
            'Keine Kameras gefunden.',
          );
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _cameraReady = true;
        _initializingCamera = false;
      });

      await controller.startImageStream((CameraImage image) {
        _onLatestFrame(image);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializingCamera = false;
        _scanError = tInline(
          widget.strings.languageCode,
          'Kamera hatası: $e',
          'Camera error: $e',
          'Kamerafehler: $e',
        );
      });
    }
  }

  void _onLatestFrame(CameraImage image) {
    final now = DateTime.now();
    if (_lastProcessedTime != null &&
        now.difference(_lastProcessedTime!) <
            const Duration(milliseconds: 1200)) {
      return; // Throttle processing to at most once per 1.2 seconds
    }
    _lastProcessedTime = now;
    _scanCameraImage(image);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation rotation = InputImageRotation.rotation0deg;
    if (Platform.isIOS) {
      rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    } else if (Platform.isAndroid) {
      rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _scanCameraImage(CameraImage image) async {
    if (_processingImage || !mounted || _cameraController == null) return;

    try {
      _processingImage = true;
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      try {
        final barcodes = await barcodeScanner.processImage(inputImage);

        for (final barcode in barcodes) {
          final String text = barcode.rawValue ?? '';

          if (text.isEmpty) continue;

          // Check if it is a Smart Park Alert QR code (URL)
          if (text.contains('apex-flow-7baea.web.app') ||
              text.contains('?id=')) {
            final tagRegex = RegExp(r'@?[a-zA-Z0-9_]+#[0-9]{4}');
            final match = tagRegex.firstMatch(Uri.decodeComponent(text));
            final riderTag = match?.group(0) ?? 'Rider';

            if (mounted) {
              unawaited(_cameraController?.stopImageStream());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SmartParkAlertHandlerScreen(
                    riderTag: riderTag.startsWith('@')
                        ? riderTag
                        : '@$riderTag',
                    strings: widget.strings,
                  ),
                ),
              );
            }
            return;
          }

          // Regular Rider Tag scan for adding friends (Fallback if they just printed the tag directly in the QR)
          final tagRegex = RegExp(r'@?[a-zA-Z0-9_]+#[0-9]{4}');
          final match = tagRegex.firstMatch(text);
          if (match != null) {
            final riderTag = match.group(0)!;
            if (mounted) {
              unawaited(_cameraController?.stopImageStream());
              Navigator.pop(
                context,
                riderTag.startsWith('@') ? riderTag : '@$riderTag',
              );
            }
            return;
          }
        }
      } finally {
        barcodeScanner.close();
      }
    } catch (_) {
      // Quietly ignore frame failures
    } finally {
      _processingImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.strings.locale.languageCode == 'tr';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tInline(
            widget.strings.languageCode,
            'QR Kod Tara (Kamera)',
            'Scan QR Code (Camera)',
            'QR-Code scannen (Kamera)',
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          if (_cameraReady && _cameraController != null)
            Center(child: CameraPreview(_cameraController!))
          else
            Center(
              child: _initializingCamera
                  ? CircularProgressIndicator(color: context.colors.cyan)
                  : Text(
                      _scanError ??
                          (tInline(
                            widget.strings.languageCode,
                            'Kamera başlatılamadı.',
                            'Camera initialization failed.',
                            'Die Initialisierung der Kamera ist fehlgeschlagen.',
                          )),
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          // QR Scanner Overlay
          IgnorePointer(
            child: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: context.colors.cyan,
                  borderRadius: 16,
                  borderLength: 30,
                  borderWidth: 6,
                  cutOutSize: 250,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                tInline(
                  widget.strings.languageCode,
                  'Arkadaşınızın profil veya park QR kodunu\ntarama alanına getirin',
                  'Place your friend\'s profile or park QR\ncode inside the scan area',
                  'Platzieren Sie das Profil oder den Park-QR-Code Ihres Freundes im Scanbereich',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color(0x99000000),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addOval(Rect.fromCircle(center: rect.center, radius: cutOutSize / 2));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final borderOffset = borderWidth / 2;
    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;

    final left = (width - cutOutWidth) / 2;
    final top = (height - cutOutHeight) / 2;
    final right = left + cutOutWidth;
    final bottom = top + cutOutHeight;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, cutOutWidth, cutOutHeight),
            Radius.circular(borderRadius),
          ),
        ),
      ),
      backgroundPaint,
    );

    final path = Path()
      ..moveTo(left - borderOffset, top + borderLength)
      ..lineTo(left - borderOffset, top - borderOffset)
      ..lineTo(left + borderLength, top - borderOffset)
      ..moveTo(right + borderOffset - borderLength, top - borderOffset)
      ..lineTo(right + borderOffset, top - borderOffset)
      ..lineTo(right + borderOffset, top + borderLength)
      ..moveTo(left - borderOffset, bottom - borderLength)
      ..lineTo(left - borderOffset, bottom + borderOffset)
      ..lineTo(left + borderLength, bottom + borderOffset)
      ..moveTo(right + borderOffset - borderLength, bottom + borderOffset)
      ..lineTo(right + borderOffset, bottom + borderOffset)
      ..lineTo(right + borderOffset, bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
    borderColor: borderColor,
    borderWidth: borderWidth,
    overlayColor: overlayColor,
    borderRadius: borderRadius,
    borderLength: borderLength,
    cutOutSize: cutOutSize,
  );
}
