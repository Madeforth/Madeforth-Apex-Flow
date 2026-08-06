import 'dart:async';
import 'dart:typed_data';

import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/fuel/presentation/receipt_parser.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key, required this.tr});

  final bool tr;

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  String? _imagePath;
  Uint8List? _imageBytes;
  Map<String, dynamic> _parsed = {};
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _initializingCamera = true;
  bool _processingImage = false;
  bool _isFlashOn = false;
  String? _scanError;

  bool get _hasPhoto => _imageBytes != null;

  bool get _hasUsableParsedValues {
    return _parsed['litres'] != null ||
        _parsed['price'] != null ||
        ((_parsed['brand'] as String?)?.trim().isNotEmpty ?? false) ||
        _parsed['date'] != null;
  }

  int get _overallConfidence {
    return (_parsed['overall_confidence'] as num?)?.round() ?? 0;
  }

  String _t(String tr, String en) => widget.tr ? tr : en;

  @override
  void initState() {
    super.initState();
    unawaited(_initCamera());
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      if (!mounted) return;
      setState(() {
        _initializingCamera = false;
        _scanError = _t(
          'OCR web önizlemede desteklenmiyor. Mobil cihazda kamerayla kullan.',
          'OCR is not supported in web preview. Use it with the camera on mobile.',
        );
      });
      return;
    }

    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (result.isPermanentlyDenied) {
            await openAppSettings();
          }
          if (!mounted) return;
          setState(() {
            _initializingCamera = false;
            _scanError = _t(
              'Kamera izni gerekli.',
              'Camera permission is required.',
            );
          });
          return;
        }
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializingCamera = false;
          _scanError = _t('Kamera bulunamadı.', 'No camera available.');
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
        enableAudio: false,
      );
      await controller.initialize();

      try {
        await controller.setFocusMode(FocusMode.auto);
        await controller.setExposureMode(ExposureMode.auto);
      } catch (_) {
        // Device support varies; the scanner remains usable without this.
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _cameraReady = true;
        _initializingCamera = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializingCamera = false;
        _scanError = _t('Kamera hatası: $e', 'Camera error: $e');
      });
    }
  }

  Future<void> _takePhoto() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _processingImage) {
      return;
    }

    try {
      setState(() {
        _processingImage = true;
        _scanError = null;
        _parsed = {};
      });

      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imagePath = file.path;
        _imageBytes = bytes;
      });

      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final inputImage = InputImage.fromFilePath(file.path);
        final result = await recognizer.processImage(inputImage);
        final lines = _sortedReceiptLines(result);
        if (!mounted) return;

        if (lines.isEmpty) {
          setState(() {
            _scanError = _t(
              'Fiş okunamadı. Daha düz, daha aydınlık bir çekim dene.',
              'Receipt could not be read. Try a flatter, brighter shot.',
            );
          });
          return;
        }

        final extracted = _normalizeOcrText(lines.join('\n'));
        final parsed = parseReceipt(extracted);
        setState(() {
          _parsed = parsed;
          _scanError = _hasUsableParsedValues
              ? null
              : _t(
                  'Güvenilir yakıt alanı bulunamadı.',
                  'No reliable fuel values were found.',
                );
        });
      } finally {
        await recognizer.close();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = _t('OCR hatası: $e', 'OCR error: $e');
      });
    } finally {
      if (mounted) {
        setState(() => _processingImage = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_processingImage) return;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _processingImage = true;
        _scanError = null;
        _parsed = {};
      });

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imagePath = image.path;
        _imageBytes = bytes;
      });

      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final inputImage = InputImage.fromFilePath(image.path);
        final result = await recognizer.processImage(inputImage);
        final lines = _sortedReceiptLines(result);
        if (!mounted) return;

        if (lines.isEmpty) {
          setState(() {
            _scanError = _t(
              'Fiş okunamadı. Daha düz, daha aydınlık bir çekim dene.',
              'Receipt could not be read. Try a flatter, brighter shot.',
            );
          });
          return;
        }

        final extracted = _normalizeOcrText(lines.join('\n'));
        final parsed = parseReceipt(extracted);
        setState(() {
          _parsed = parsed;
          _scanError = _hasUsableParsedValues
              ? null
              : _t(
                  'Güvenilir yakıt alanı bulunamadı.',
                  'No reliable fuel values were found.',
                );
        });
      } finally {
        await recognizer.close();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = _t('Galeri hatası: $e', 'Gallery error: $e');
      });
    } finally {
      if (mounted) {
        setState(() => _processingImage = false);
      }
    }
  }

  List<String> _sortedReceiptLines(RecognizedText result) {
    final lines = <TextLine>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        if (line.text.trim().length >= 2) {
          lines.add(line);
        }
      }
    }
    lines.sort((a, b) {
      final yDiff = (a.boundingBox.top - b.boundingBox.top).abs();
      if (yDiff < 14) {
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      }
      return a.boundingBox.top.compareTo(b.boundingBox.top);
    });
    return lines.map((line) => line.text).toList();
  }

  String _normalizeOcrText(String input) {
    return input
        .replaceAll('’', '\'')
        .replaceAll('₺', ' TL ')
        .replaceAll(RegExp(r'[|¦]'), 'I')
        .split('\n')
        .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((line) => line.length >= 2)
        .join('\n')
        .toUpperCase();
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _setFocusPoint(Offset localPosition, Size size) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (size.width <= 0 || size.height <= 0) return;

    final point = Offset(
      (localPosition.dx / size.width).clamp(0.0, 1.0),
      (localPosition.dy / size.height).clamp(0.0, 1.0),
    );
    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
    } catch (_) {}
  }

  void _retake() {
    setState(() {
      _imagePath = null;
      _imageBytes = null;
      _parsed = {};
      _scanError = null;
    });
  }

  void _useValues() {
    if (!_hasUsableParsedValues) return;
    Navigator.of(context).pop({..._parsed, 'imagePath': _imagePath});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('Fiş Tara', 'Scan receipt'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          child: Column(
            children: [
              Expanded(child: _buildMainSurface()),
              const SizedBox(height: ApexSpacing.x2),
              _buildBottomSurface(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSurface() {
    if (_hasPhoto) {
      return _PhotoPreview(
        bytes: _imageBytes!,
        processing: _processingImage,
        processingLabel: _t('Fiş okunuyor', 'Reading receipt'),
      );
    }

    if (_cameraReady && _cameraController != null) {
      return _CameraSurface(
        controller: _cameraController!,
        isFlashOn: _isFlashOn,
        helperText: _t('Fişi çerçeveye hizala', 'Align receipt in frame'),
        onToggleFlash: _toggleFlash,
        onFocus: (position, size) => unawaited(_setFocusPoint(position, size)),
      );
    }

    return _CameraMessage(
      loading: _initializingCamera,
      message: _scanError ?? _t('Kamera hazırlanıyor.', 'Preparing camera.'),
    );
  }

  Widget _buildBottomSurface() {
    if (!_hasPhoto) {
      if (!_cameraReady) {
        return _BottomMessage(message: _scanError);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: ApexSpacing.x2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 56), // spacer to center the shutter button
            const Spacer(),
            _ShutterButton(
              onTap: _processingImage ? null : _takePhoto,
              isLoading: _processingImage,
            ),
            const Spacer(),
            SizedBox(
              width: 56,
              height: 56,
              child: IconButton(
                tooltip: _t('Galeriden seç', 'Pick from gallery'),
                onPressed: _processingImage ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 24),
                style: IconButton.styleFrom(
                  foregroundColor: context.colors.cyan,
                  backgroundColor: context.colors.elevated,
                  side: BorderSide(color: context.colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _ReceiptResultPanel(
      tr: widget.tr,
      parsed: _parsed,
      scanError: _scanError,
      confidence: _overallConfidence,
      hasUsableValues: _hasUsableParsedValues,
      onUse: _useValues,
      onRetake: _retake,
    );
  }
}

class _CameraSurface extends StatelessWidget {
  const _CameraSurface({
    required this.controller,
    required this.isFlashOn,
    required this.helperText,
    required this.onToggleFlash,
    required this.onFocus,
  });

  final CameraController controller;
  final bool isFlashOn;
  final String helperText;
  final VoidCallback onToggleFlash;
  final void Function(Offset position, Size size) onFocus;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final frameWidth = constraints.maxWidth * 0.76;
          final frameHeight = constraints.maxHeight * 0.82;
          final frame = Rect.fromLTWH(
            (constraints.maxWidth - frameWidth) / 2,
            (constraints.maxHeight - frameHeight) / 2,
            frameWidth,
            frameHeight,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTapDown: (details) => onFocus(details.localPosition, size),
                child: CameraPreview(controller),
              ),
              ApexReceiptOverlay(overlayColor: Colors.black54, rect: frame),
              Positioned.fromRect(
                rect: frame,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.72),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                ),
              ),
              Positioned(
                left: ApexSpacing.x2,
                right: ApexSpacing.x2,
                bottom: ApexSpacing.x2,
                child: Text(
                  helperText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                right: ApexSpacing.x1,
                top: ApexSpacing.x1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  ),
                  child: IconButton(
                    tooltip: isFlashOn ? 'Flash off' : 'Flash on',
                    onPressed: onToggleFlash,
                    icon: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.bytes,
    required this.processing,
    required this.processingLabel,
  });

  final Uint8List bytes;
  final bool processing;
  final String processingLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ApexSpacing.radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
          if (processing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.42),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: ApexSpacing.x2),
                    Text(
                      processingLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.loading, required this.message});

  final bool loading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(ApexSpacing.x2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: ApexSpacing.x2),
              ] else
                Icon(
                  Icons.camera_alt_outlined,
                  size: 28,
                  color: context.colors.textSecondary,
                ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomMessage extends StatelessWidget {
  const _BottomMessage({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox(height: 48);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: ApexSpacing.x2),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.textSecondary, height: 1.35),
      ),
    );
  }
}

class _ReceiptResultPanel extends StatelessWidget {
  const _ReceiptResultPanel({
    required this.tr,
    required this.parsed,
    required this.scanError,
    required this.confidence,
    required this.hasUsableValues,
    required this.onUse,
    required this.onRetake,
  });

  final bool tr;
  final Map<String, dynamic> parsed;
  final String? scanError;
  final int confidence;
  final bool hasUsableValues;
  final VoidCallback onUse;
  final VoidCallback onRetake;

  String _t(String trText, String enText) => tr ? trText : enText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ApexSpacing.x2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _t('Okunan Değerler', 'Detected values'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _ConfidencePill(value: confidence),
              ],
            ),
            const SizedBox(height: ApexSpacing.x1),
            _ReceiptResultTile(
              icon: Icons.local_gas_station_outlined,
              label: _t('Benzinlik', 'Station'),
              value: _textValue(parsed['brand']),
              confidence: parsed['brand_confidence'],
            ),
            _ReceiptResultTile(
              icon: Icons.local_offer_outlined,
              label: _t('Litre', 'Litres'),
              value: _numberValue(parsed['litres'], 3),
              confidence: parsed['litres_confidence'],
            ),
            _ReceiptResultTile(
              icon: Icons.payments_outlined,
              label: _t('Tutar', 'Total'),
              value:
                  '${_numberValue(parsed['price'], 2)} ${_textValue(parsed['currency'])}',
              confidence: parsed['price_confidence'],
            ),
            _ReceiptResultTile(
              icon: Icons.event_outlined,
              label: _t('Tarih', 'Date'),
              value: _textValue(parsed['date']),
              confidence: parsed['date_confidence'],
            ),
            if (scanError != null) ...[
              const SizedBox(height: ApexSpacing.x1),
              Text(
                scanError!,
                style: TextStyle(
                  color: context.colors.caution,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: ApexSpacing.x2),
            _ActionButtons(
              useLabel: _t('Değerleri Kullan', 'Use values'),
              retakeLabel: _t('Tekrar Çek', 'Retake'),
              onUse: hasUsableValues ? onUse : null,
              onRetake: onRetake,
            ),
          ],
        ),
      ),
    );
  }

  String _textValue(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String _numberValue(Object? value, int fractionDigits) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null) return '-';
    var text = number.toStringAsFixed(fractionDigits);
    while (text.contains('.') && text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }
}

class _ReceiptResultTile extends StatelessWidget {
  const _ReceiptResultTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.confidence,
  });

  final IconData icon;
  final String label;
  final String value;
  final Object? confidence;

  @override
  Widget build(BuildContext context) {
    final confidenceValue = (confidence as num?)?.round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.cyan, size: 19),
          const SizedBox(width: ApexSpacing.x1),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: ApexSpacing.x1),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (confidenceValue != null) ...[
            const SizedBox(width: ApexSpacing.x1),
            Text(
              '$confidenceValue%',
              style: TextStyle(
                color: context.colors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 70 ? context.colors.healthy : context.colors.caution;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(ApexSpacing.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          '$value%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({this.onTap, required this.isLoading});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          height: 74,
          width: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.cyan, width: 3),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isLoading ? 30 : 56,
              width: isLoading ? 30 : 56,
              decoration: BoxDecoration(
                color: context.colors.cyan,
                borderRadius: BorderRadius.circular(isLoading ? 6 : 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.useLabel,
    required this.retakeLabel,
    required this.onUse,
    required this.onRetake,
  });

  final String useLabel;
  final String retakeLabel;
  final VoidCallback? onUse;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onUse,
              icon: const Icon(Icons.check, size: 18),
              label: Text(useLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.cyan,
                foregroundColor: context.colors.onAccent,
                disabledBackgroundColor: context.colors.elevated,
                disabledForegroundColor: context.colors.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: ApexSpacing.x1),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onRetake,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(retakeLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.cyan,
                side: BorderSide(color: context.colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ApexReceiptOverlay extends StatelessWidget {
  const ApexReceiptOverlay({
    super.key,
    required this.overlayColor,
    required this.rect,
  });

  final Color overlayColor;
  final Rect rect;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(overlayColor, BlendMode.srcOut),
      child: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned.fromRect(
            rect: rect,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ApexSpacing.radius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
