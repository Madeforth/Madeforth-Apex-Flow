import 'package:apexflow/core/design/apex_breakpoints.dart';
import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/fuel/application/fuel_state.dart';
import 'package:apexflow/fuel/presentation/receipt_scan_screen.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/rides/application/ride_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';
import 'package:apexflow/shared/widgets/apex_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'widgets/fuel_history_list.dart';

class FuelScreen extends ConsumerStatefulWidget {
  const FuelScreen({
    super.key,
    required this.strings,
    this.topPadding = 0.0,
  });

  final AppStrings strings;
  final double topPadding;

  @override
  ConsumerState<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends ConsumerState<FuelScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _litresController;
  late final TextEditingController _totalController;
  late final TextEditingController _odometerController;
  late final TextEditingController _noteController;
  late final TextEditingController _brandController;
  DateTime _selectedDate = DateTime.now();
  String? _error;
  String? _scanNotice;
  bool _scanNoticeIsWarning = false;
  String? _scannedImagePath;
  String _activeCurrency = 'TRY';
  bool _odometerTouched = false;
  bool _brandTouched = false;
  int? _lastSeenOdometer;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _litresController = TextEditingController();
    _totalController = TextEditingController();
    _odometerController = TextEditingController();
    _noteController = TextEditingController();
    _brandController = TextEditingController();
    _syncDateLabel();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _litresController.dispose();
    _totalController.dispose();
    _odometerController.dispose();
    _noteController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fuelStateProvider);
    final garage = ref.watch(garageStateProvider);
    final tr = widget.strings.locale.languageCode == 'tr';

    final latestBrand = _latestBrandSuggestion(state);
    final shouldSeedOdometer =
        !garage.isHydrating &&
        !_odometerTouched &&
        garage.motorcycles.isNotEmpty &&
        _odometerController.text.trim().isEmpty;
    final shouldSeedBrand =
        !state.isHydrating &&
        !_brandTouched &&
        latestBrand != null &&
        _brandController.text.trim().isEmpty;

    if (shouldSeedOdometer || shouldSeedBrand) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _applySmartDefaults(state: state, garage: garage, force: false);
      });
    }

    if (!garage.isHydrating &&
        garage.activeBike.odometerKm != _lastSeenOdometer) {
      _lastSeenOdometer = garage.activeBike.odometerKm;
      if (!_odometerTouched) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            _applySmartDefaults(state: state, garage: garage, force: true);
        });
      }
    }

    final isReadyToSave =
        _litresController.text.isNotEmpty && _totalController.text.isNotEmpty;
    final odometerText = _odometerController.text.isNotEmpty
        ? _odometerController.text
        : '0';

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            top: widget.topPadding + 16,
            left: 16,
            right: 16,
          ),
          children: [
            // Top Navigation & Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tInline(
                        widget.strings.languageCode,
                        'Yakıt',
                        'Fuel',
                        'Kraftstoff',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tInline(
                        widget.strings.languageCode,
                        'Yeni Yakıt Girişi',
                        'New Fuel Entry',
                        'Neuer Kraftstoffeintrag',
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _scanReceipt,
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: context.colors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Fiş Tara',
                          'Scan Receipt',
                          'Beleg scannen',
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Summary Row
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _dateController.text.isNotEmpty
                      ? _dateController.text
                      : 'Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.speed,
                  size: 14,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$odometerText km',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tInline(
                    widget.strings.languageCode,
                    'Garajdan',
                    'From garage',
                    'Aus der Garage',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fuel Details
            Text(
              tInline(
                widget.strings.languageCode,
                'Yakıt Detayları',
                'Fuel Details',
                'Kraftstoffdetails',
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Litre',
                          'Litres',
                          'Liter',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTextField(
                        _litresController,
                        suffix: 'L',
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Tutar',
                          'Amount',
                          'Betrag',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTextField(
                        _totalController,
                        suffix: _activeCurrency,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Purchase Info
            Row(
              children: [
                Text(
                  tInline(
                    widget.strings.languageCode,
                    'Satın Alma Bilgisi',
                    'Purchase Info',
                    'Kaufinfo',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tInline(
                    widget.strings.languageCode,
                    '(isteğe bağlı)',
                    '(optional)',
                    '(optional)',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tInline(
                    widget.strings.languageCode,
                    'Yakıt İstasyonu',
                    'Fuel Station',
                    'Tankstelle',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildTextField(
                  _brandController,
                  prefixIcon: Icons.location_on_outlined,
                  hint: tInline(
                    widget.strings.languageCode,
                    'Yakıt istasyonu girin',
                    'Enter fuel station',
                    'Tankstelle eingeben',
                  ),
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Tarih',
                          'Date',
                          'Datum',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: _buildTextField(
                            _dateController,
                            prefixIcon: Icons.calendar_today_outlined,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tInline(
                          widget.strings.languageCode,
                          'Kilometre',
                          'Odometer',
                          'Kilometerzähler',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildTextField(
                        _odometerController,
                        prefixIcon: Icons.speed,
                        suffix: 'km',
                        context: context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Note
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tInline(widget.strings.languageCode, 'Not', 'Note', 'Notiz'),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                _buildTextField(
                  _noteController,
                  prefixIcon: Icons.notes,
                  hint: tInline(
                    widget.strings.languageCode,
                    'Not ekle',
                    'Add a note',
                    'Notiz hinzufügen',
                  ),
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: 24),

            // Ready to Save Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: isReadyToSave
                        ? context.colors.cyan
                        : context.colors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReadyToSave
                            ? tInline(
                                widget.strings.languageCode,
                                'Kaydetmeye hazır',
                                'Ready to save',
                                'Bereit zum Speichern',
                              )
                            : tInline(
                                widget.strings.languageCode,
                                'Bilgileri doldurun',
                                'Fill details to save',
                                'Details ausfüllen',
                              ),
                        style: TextStyle(
                          fontSize: 14,
                          color: isReadyToSave
                              ? Colors.white
                              : context.colors.textSecondary,
                        ),
                      ),
                      if (isReadyToSave) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_dateController.text} • $odometerText km',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isReadyToSave ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.cyan,
                  disabledBackgroundColor: context.colors.cyan.withValues(
                    alpha: 0.3,
                  ),
                  foregroundColor: Colors.black,
                  disabledForegroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.local_gas_station, size: 20),
                label: Text(
                  tInline(
                    widget.strings.languageCode,
                    'YAKIT GİRİŞİNİ KAYDET',
                    'SAVE FUEL ENTRY',
                    'KRAFTSTOFFEINTRAG SPEICHERN',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FuelHistoryList(strings: widget.strings),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? suffix,
    IconData? prefixIcon,
    String? hint,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.textSecondary, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: context.colors.textSecondary)
            : null,
        suffixText: suffix,
        suffixStyle: TextStyle(
          fontSize: 14,
          color: context.colors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: context.colors.border.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: context.colors.border.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.colors.cyan, width: 1.2),
        ),
      ),
      onChanged: (val) {
        setState(() {}); // Rebuild to update "Ready to save"
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = picked;
      _syncDateLabel();
    });
  }

  void _syncDateLabel() {
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  void _submit() {
    final tr = widget.strings.locale.languageCode == 'tr';
    final settings = ref.read(appSettingsProvider);
    final isGallons = settings.volumeUnit == 'gallons';
    final garageController = ref.read(garageStateProvider.notifier);

    final enteredVolume = double.tryParse(
      _litresController.text.trim().replaceAll(',', '.'),
    );
    final total = double.tryParse(
      _totalController.text.trim().replaceAll(',', '.'),
    );

    if (enteredVolume == null || total == null) return;

    // Convert to native litres if user has selected gallons
    final litres = isGallons ? (enteredVolume * 3.78541178) : enteredVolume;

    final displayOdometer = _parseOdometer(_odometerController.text);
    // Convert odometer to native km if entered in miles
    final odometer = (displayOdometer != null && settings.distanceUnit == 'mi')
        ? (displayOdometer * 1.609344).round()
        : displayOdometer;

    HapticFeedback.selectionClick();

    ref
        .read(fuelStateProvider.notifier)
        .addEntry(
          date: _selectedDate,
          litres: litres,
          totalTry: total,
          odometerKm: odometer,
          note: _noteController.text,
          brand: _brandController.text,
          imagePath: _scannedImagePath,
        );
    if (odometer != null) {
      garageController.syncOdometer(odometer);
    }
    setState(() {
      _error = null;
      _litresController.clear();
      _totalController.clear();
      _noteController.clear();
      _scannedImagePath = null;
      _activeCurrency = 'TRY';
      _scanNotice = null;
      _scanNoticeIsWarning = false;
      _odometerTouched = false;
      _brandTouched = false;
      _selectedDate = DateTime.now();
      _syncDateLabel();
    });
    _applySmartDefaults(
      state: ref.read(fuelStateProvider),
      garage: ref.read(garageStateProvider),
      force: true,
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            tInline(
              widget.strings.languageCode,
              'Yakıt kaydı eklendi.',
              'Fuel entry added.',
              'Kraftstoffeintrag hinzugefügt.',
            ),
          ),
        ),
      );
  }

  Future<void> _scanReceipt() async {
    final tr = widget.strings.locale.languageCode == 'tr';
    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (_) => ReceiptScanScreen(tr: tr)),
    );
    if (result == null) return;
    setState(() {
      final appliedFields = <String>[];
      if (result['litres'] != null) {
        _litresController.text = _formatDecimal(result['litres'], 3);
        appliedFields.add(
          tInline(widget.strings.languageCode, 'litre', 'litres', 'Liter'),
        );
      }
      if (result['price'] != null) {
        _totalController.text = _formatDecimal(result['price'], 2);
        appliedFields.add(
          tInline(widget.strings.languageCode, 'tutar', 'total', 'gesamt'),
        );
      }
      final brand = result['brand'];
      if (brand is String && brand.trim().isNotEmpty) {
        _brandController.text = brand.trim();
        _brandTouched = true;
        appliedFields.add(
          tInline(
            widget.strings.languageCode,
            'istasyon',
            'station',
            'Station',
          ),
        );
      }
      if (result['currency'] != null) {
        _activeCurrency = result['currency'] as String;
      }
      if (result['date'] != null) {
        try {
          _selectedDate = DateTime.parse(result['date'] as String);
          _syncDateLabel();
        } catch (_) {}
      }
      if (result['imagePath'] != null) {
        _scannedImagePath = result['imagePath'] as String?;
      }
      _error = null;
      _scanNoticeIsWarning = appliedFields.isEmpty;
      _scanNotice = appliedFields.isEmpty
          ? (tInline(
              widget.strings.languageCode,
              'Fiş okundu, ancak güvenilir alan bulunamadı. Değerleri elle gir.',
              'Receipt was read, but no reliable values were found. Enter the values manually.',
              'Der Beleg wurde gelesen, es wurden jedoch keine verlässlichen Werte gefunden. Geben Sie die Werte manuell ein.',
            ))
          : (tr
                ? 'Fişten ${appliedFields.join(', ')} dolduruldu. Kaydetmeden önce kontrol et.'
                : 'Filled ${appliedFields.join(', ')} from the receipt. Check before saving.');
    });
  }

  int? _parseOdometer(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? null : int.tryParse(cleaned);
  }

  void _applySmartDefaults({
    required FuelState state,
    required GarageState garage,
    required bool force,
  }) {
    int? suggestedOdometer;
    if (garage.motorcycles.isNotEmpty) {
      FuelEntry? lastRefuel;
      for (final entry in state.entries) {
        if (entry.odometerKm != null) {
          lastRefuel = entry;
          break;
        }
      }

      if (lastRefuel != null) {
        final lastRefuelDate = lastRefuel.date;
        final rides = ref.read(rideStateProvider).sessions;
        var accumulatedDistance = 0.0;
        for (final ride in rides) {
          final rideDate = DateTime.parse(ride.loggedAtIso);
          if (rideDate.isAfter(lastRefuelDate)) {
            accumulatedDistance += ride.distanceKm;
          }
        }
        final estimate = lastRefuel.odometerKm! + accumulatedDistance.round();
        suggestedOdometer = estimate >= garage.activeBike.odometerKm
            ? estimate
            : garage.activeBike.odometerKm;
      } else {
        suggestedOdometer = garage.activeBike.odometerKm;
      }
    }

    final suggestedBrand = _latestBrandSuggestion(state);

    final shouldApplyOdometer =
        suggestedOdometer != null &&
        (force ||
            (!_odometerTouched && _odometerController.text.trim().isEmpty));
    final shouldApplyBrand =
        suggestedBrand != null &&
        (force || (!_brandTouched && _brandController.text.trim().isEmpty));

    if (!shouldApplyOdometer && !shouldApplyBrand) {
      return;
    }

    setState(() {
      if (shouldApplyOdometer) {
        _odometerController.text = suggestedOdometer.toString();
      }
      if (shouldApplyBrand) {
        _brandController.text = suggestedBrand;
      }
    });
  }

  String? _latestBrandSuggestion(FuelState state) {
    for (final entry in state.entries) {
      final brand = entry.brand.trim();
      if (brand.isNotEmpty) {
        return brand;
      }
    }
    return null;
  }

  String? _smartDefaultsLine({
    required bool tr,
    required bool hasGarageBike,
    required String? latestBrand,
  }) {
    final parts = <String>[];
    if (hasGarageBike) {
      parts.add(
        tInline(
          widget.strings.languageCode,
          'garaj kilometresi hazır',
          'garage odometer ready',
          'Werkstatt-Kilometerzähler bereit',
        ),
      );
    }
    if (latestBrand != null) {
      parts.add(
        tInline(
          widget.strings.languageCode,
          'son istasyon önerisi: $latestBrand',
          'last station suggestion: $latestBrand',
          'letzter Sendervorschlag: $latestBrand',
        ),
      );
    }
    if (parts.isEmpty) {
      return null;
    }
    return tr
        ? 'Hızlı Doldurma İpuçları: ${parts.join(' • ')}.'
        : 'Quick Fill Tips: ${parts.join(' • ')}.';
  }

  String _formatDecimal(Object? value, int fractionDigits) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null) {
      return '';
    }
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
