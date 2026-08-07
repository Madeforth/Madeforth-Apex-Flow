import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/theme_extensions.dart';
import 'package:apexflow/core/i18n/app_settings_state.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/core/utils/phone_formatter.dart';
import 'package:apexflow/features/shell/apex_app_shell.dart';
import 'package:apexflow/garage/application/garage_state.dart';
import 'package:apexflow/settings/application/user_profile_state.dart';
import 'package:apexflow/shared/widgets/apex_panel.dart';

class ProfileSetupWizardScreen extends ConsumerStatefulWidget {
  const ProfileSetupWizardScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  ConsumerState<ProfileSetupWizardScreen> createState() =>
      _ProfileSetupWizardScreenState();
}

class _ProfileSetupWizardScreenState
    extends ConsumerState<ProfileSetupWizardScreen> {
  int _currentStep = 0; // 0: Rider Profile, 1: Motorcycle Details
  bool _isSubmitting = false;
  String? _error;

  // Step 1: Rider Profile Controllers
  late final TextEditingController _riderName;
  late final TextEditingController _riderPhone;
  late final TextEditingController _riderBlood;
  late final TextEditingController _emergencyName;
  late final TextEditingController _emergencyPhone;
  bool _sharePhone = false;
  bool _shareEmergency = false;
  String _riderCountryCode = '+90';
  String _emergencyCountryCode = '+90';

  // Step 2: Motorcycle Controllers
  late final TextEditingController _bikeName;
  late final TextEditingController _bikeModel;
  late final TextEditingController _odometer;
  late final TextEditingController _lastServiceOdometer;
  late final TextEditingController _serviceInterval;
  String _distanceUnit = 'km';

  @override
  void initState() {
    super.initState();
    _riderName = TextEditingController();
    _riderPhone = TextEditingController();
    _riderBlood = TextEditingController();
    _emergencyName = TextEditingController();
    _emergencyPhone = TextEditingController();

    _bikeName = TextEditingController();
    _bikeModel = TextEditingController();
    _odometer = TextEditingController();
    _lastServiceOdometer = TextEditingController();
    _serviceInterval = TextEditingController(text: '6000');
  }

  @override
  void dispose() {
    _riderName.dispose();
    _riderPhone.dispose();
    _riderBlood.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();

    _bikeName.dispose();
    _bikeModel.dispose();
    _odometer.dispose();
    _lastServiceOdometer.dispose();
    _serviceInterval.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.selectionClick();
    setState(() => _error = null);

    if (_currentStep == 0) {
      final nameVal = _riderName.text.trim();
      if (nameVal.isEmpty) {
        setState(() {
          _error = tInline(
            widget.strings.languageCode,
            'Lütfen sürücü isim soyisim alanını doldurun.',
            'Please fill in the rider full name.',
            'Bitte geben Sie den Namen des Fahrers ein.',
          );
        });
        return;
      }
      setState(() => _currentStep = 1);
    } else {
      _completeSetup();
    }
  }

  void _prevStep() {
    HapticFeedback.selectionClick();
    if (_currentStep > 0) {
      setState(() {
        _error = null;
        _currentStep--;
      });
    }
  }

  Future<void> _completeSetup() async {
    final bikeNameVal = _bikeName.text.trim();
    final modelVal = _bikeModel.text.trim();
    final odoVal = double.tryParse(_odometer.text.trim());
    final lastServiceVal = double.tryParse(_lastServiceOdometer.text.trim());
    final intervalVal = double.tryParse(_serviceInterval.text.trim());

    if (bikeNameVal.isEmpty ||
        modelVal.isEmpty ||
        odoVal == null ||
        odoVal < 0 ||
        lastServiceVal == null ||
        lastServiceVal < 0 ||
        intervalVal == null ||
        intervalVal <= 0) {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'Lütfen motosiklet bilgilerini tam ve doğru doldurun.',
          'Please fill in motorcycle details correctly.',
          'Bitte füllen Sie die Motorraddetails korrekt aus.',
        );
      });
      return;
    }

    if (lastServiceVal > odoVal) {
      setState(() {
        _error = tInline(
          widget.strings.languageCode,
          'Son servis KM değeri güncel KM değerinden büyük olamaz.',
          'Last service odometer cannot exceed current odometer.',
          'Der Kilometerstand der letzten Wartung darf den aktuellen nicht überschreiten.',
        );
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // 1. Distance & Volume Preferences
      final settingsNotifier = ref.read(appSettingsProvider.notifier);
      settingsNotifier.setDistanceUnit(_distanceUnit);
      if (_distanceUnit == 'mi') {
        settingsNotifier.setVolumeUnit('gallons');
      } else {
        settingsNotifier.setVolumeUnit('liters');
      }

      // Convert to Km if needed
      final odometerKm = _distanceUnit == 'mi'
          ? (odoVal * 1.609344).round()
          : odoVal.round();
      final lastServiceKm = _distanceUnit == 'mi'
          ? (lastServiceVal * 1.609344).round()
          : lastServiceVal.round();
      final serviceIntervalKm = _distanceUnit == 'mi'
          ? (intervalVal * 1.609344).round()
          : intervalVal.round();

      // 2. Add Motorcycle to Garage first (so updateProfile can sync it)
      ref
          .read(garageStateProvider.notifier)
          .addMotorcycle(
            name: bikeNameVal,
            model: modelVal,
            odometerKm: odometerKm,
            lastServiceKm: lastServiceKm,
            serviceIntervalKm: serviceIntervalKm,
          );

      // 3. Save Rider Profile
      final riderNameVal = _riderName.text.trim();
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            name: riderNameVal,
            riderTag: riderNameVal,
            phoneNumber: _riderPhone.text.trim().isNotEmpty
                ? '$_riderCountryCode ${_riderPhone.text.trim()}'
                : '',
            bloodType: _riderBlood.text.trim(),
            emergencyContactName: _emergencyName.text.trim(),
            emergencyContactPhone: _emergencyPhone.text.trim().isNotEmpty
                ? '$_emergencyCountryCode ${_emergencyPhone.text.trim()}'
                : '',
            sharePhone: _sharePhone,
            shareEmergency: _shareEmergency,
          );

      // 4. Mark Onboarding Completed
      settingsNotifier.completeOnboarding();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ApexAppShell()),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = tInline(
          widget.strings.languageCode,
          'Profil kaydedilirken bir hata oluştu.',
          'An error occurred while saving profile.',
          'Beim Speichern des Profils ist ein Fehler aufgetreten.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Progress
            Padding(
              padding: const EdgeInsets.all(ApexSpacing.x2),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.white),
                      onPressed: _prevStep,
                      tooltip: 'Back',
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          tInline(
                            widget.strings.languageCode,
                            'HAYDİ PROFİLİNİ OLUŞTURALIM',
                            'LET\'S BUILD YOUR PROFILE',
                            'LASS UNS DEIN PROFIL ERSTELLEN',
                          ),
                          style: TextStyle(
                            color: colors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepDot(0),
                            Container(
                              width: 30,
                              height: 2,
                              color: _currentStep >= 1
                                  ? colors.cyan
                                  : colors.border,
                            ),
                            _buildStepDot(1),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            if (_error != null)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: ApexSpacing.x2,
                  vertical: ApexSpacing.x1,
                ),
                padding: const EdgeInsets.all(ApexSpacing.x1),
                decoration: BoxDecoration(
                  color: colors.caution.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ApexSpacing.radius),
                  border: Border.all(color: colors.caution),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colors.caution,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: colors.caution, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ApexSpacing.x2),
                child: _currentStep == 0
                    ? _buildRiderStep(colors)
                    : _buildMotorcycleStep(colors),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(ApexSpacing.x2),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onAccent,
                    backgroundColor: colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ApexSpacing.radius),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _nextStep,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onAccent,
                          ),
                        )
                      : Text(
                          _currentStep == 0
                              ? tInline(
                                  widget.strings.languageCode,
                                  'SONRAKİ: MOTOSİKLET DETAYLARI →',
                                  'NEXT: MOTORCYCLE DETAILS →',
                                  'WEITER: MOTORRAD-DETAILS →',
                                )
                              : tInline(
                                  widget.strings.languageCode,
                                  'PROFİLİ TAMAMLA VE BAŞLA',
                                  'COMPLETE PROFILE & START',
                                  'PROFIL ABSCHLIESSEN & STARTEN',
                                ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(int stepIndex) {
    final active = _currentStep == stepIndex;
    final completed = _currentStep > stepIndex;
    final colors = context.colors;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? colors.cyan
            : (active ? colors.cyan.withValues(alpha: 0.2) : colors.surface),
        border: Border.all(
          color: active || completed ? colors.cyan : colors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: completed
            ? Icon(Icons.check, size: 14, color: colors.onAccent)
            : Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  color: active ? colors.cyan : colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRiderStep(ApexColorsExtension colors) {
    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: colors.cyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                tInline(
                  widget.strings.languageCode,
                  '1. Sürücü Profili',
                  '1. Rider Profile',
                  '1. Fahrerprofil',
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.white,
                ),
              ),
            ],
          ),
          Divider(color: colors.border, height: 24),

          Text(
            tInline(
              widget.strings.languageCode,
              'Sana daha özel bir sürüş deneyimi ve acil durumlarda güvenlik sağlamak için sürücü detaylarını gir.',
              'Enter your rider details for a personalized ride experience and emergency safety.',
              'Geben Sie Ihre Fahrerdetails für ein personalisiertes Fahrerlebnis ein.',
            ),
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: ApexSpacing.x2),

          // Sürücü Adı
          TextField(
            controller: _riderName,
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'İsim Soyisim *',
                'Full Name *',
                'Vollständiger Name *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Örn: Ahmet Yılmaz',
                'E.g., John Doe',
                'Z. B. John Doe',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Telefon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 95,
                margin: const EdgeInsets.only(right: 8),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tInline(
                      widget.strings.languageCode,
                      'Kod',
                      'Code',
                      'Code',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _riderCountryCode,
                  items: availableCountryCodes.map((cc) {
                    return DropdownMenuItem<String>(
                      value: cc.code,
                      child: Text(
                        '${cc.flag} ${cc.code}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _riderCountryCode = val ?? '+90';
                    });
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _riderPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: _riderCountryCode == '+90'
                      ? [TurkeyPhoneInputFormatter()]
                      : null,
                  decoration: InputDecoration(
                    labelText: tInline(
                      widget.strings.languageCode,
                      'Telefon Numarası',
                      'Phone Number',
                      'Telefonnummer',
                    ),
                    hintText: _riderCountryCode == '+90'
                        ? '0 555 555 5555'
                        : '555 555 5555',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kan Grubu (Dropdown)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Kan Grubu',
                'Blood Type',
                'Blutgruppe',
              ),
            ),
            initialValue: _riderBlood.text.isEmpty ? null : _riderBlood.text,
            items: const [
              DropdownMenuItem(value: 'A Rh(+)', child: Text('A Rh(+)')),
              DropdownMenuItem(value: 'A Rh(-)', child: Text('A Rh(-)')),
              DropdownMenuItem(value: 'B Rh(+)', child: Text('B Rh(+)')),
              DropdownMenuItem(value: 'B Rh(-)', child: Text('B Rh(-)')),
              DropdownMenuItem(value: 'AB Rh(+)', child: Text('AB Rh(+)')),
              DropdownMenuItem(value: 'AB Rh(-)', child: Text('AB Rh(-)')),
              DropdownMenuItem(value: '0 Rh(+)', child: Text('0 Rh(+)')),
              DropdownMenuItem(value: '0 Rh(-)', child: Text('0 Rh(-)')),
            ],
            onChanged: (value) {
              setState(() {
                _riderBlood.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: ApexSpacing.x2),

          // Emergency contact header
          Text(
            tInline(
              widget.strings.languageCode,
              'Acil Durum İletişim Bilgileri (İsteğe Bağlı)',
              'Emergency Contact (Optional)',
              'Notfallkontakt (optional)',
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ApexSpacing.x1),

          // Acil Durum Adı
          TextField(
            controller: _emergencyName,
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Acil Durum Yakını Adı',
                'Emergency Contact Name',
                'Name des Notfallkontakts',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Örn: Ayşe Yılmaz',
                'E.g., Jane Doe',
                'Z. B. Jane Doe',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Acil Durum Telefon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 95,
                margin: const EdgeInsets.only(right: 8),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tInline(
                      widget.strings.languageCode,
                      'Kod',
                      'Code',
                      'Code',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _emergencyCountryCode,
                  items: availableCountryCodes.map((cc) {
                    return DropdownMenuItem<String>(
                      value: cc.code,
                      child: Text(
                        '${cc.flag} ${cc.code}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _emergencyCountryCode = val ?? '+90';
                    });
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _emergencyPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: _emergencyCountryCode == '+90'
                      ? [TurkeyPhoneInputFormatter()]
                      : null,
                  decoration: InputDecoration(
                    labelText: tInline(
                      widget.strings.languageCode,
                      'Acil Durum Yakını Telefonu',
                      'Emergency Contact Phone',
                      'Notfall-Kontakttelefon',
                    ),
                    hintText: _emergencyCountryCode == '+90'
                        ? '0 555 555 5556'
                        : '555 555 5556',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotorcycleStep(ApexColorsExtension colors) {
    final unitSuffix = _distanceUnit;

    return ApexPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.two_wheeler_outlined,
                color: colors.cyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                tInline(
                  widget.strings.languageCode,
                  '2. Motosiklet Detayları',
                  '2. Motorcycle Details',
                  '2. Motorrad-Details',
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colors.white,
                ),
              ),
            ],
          ),
          Divider(color: colors.border, height: 24),

          Text(
            tInline(
              widget.strings.languageCode,
              'Garajına eklenecek ilk motosikletinin teknik ve bakım bilgilerini gir.',
              'Enter technical and maintenance info for your main bike.',
              'Geben Sie technische und Wartungsinformationen ein.',
            ),
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: ApexSpacing.x2),

          // Birim Seçimi (Km / Mi)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tInline(
                  widget.strings.languageCode,
                  'Mesafe Birimi:',
                  'Distance Unit:',
                  'Entfernungseinheit:',
                ),
                style: TextStyle(
                  color: colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'km', label: Text('KM')),
                  ButtonSegment(value: 'mi', label: Text('MI')),
                ],
                selected: {_distanceUnit},
                onSelectionChanged: (set) {
                  setState(() => _distanceUnit = set.first);
                },
              ),
            ],
          ),
          const SizedBox(height: ApexSpacing.x2),

          // Motosiklet Marka / Model
          TextField(
            controller: _bikeModel,
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Motosiklet Marka / Model *',
                'Motorcycle Brand / Model *',
                'Motorradmarke/-modell *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Örn: Yamaha Tenere 700',
                'E.g., Yamaha Tenere 700',
                'Z. B. Yamaha Tenere 700',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Motosiklet İsmi / Takma Adı
          TextField(
            controller: _bikeName,
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Motosiklet İsmi *',
                'Motorcycle Name *',
                'Motorradname *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Örn: Siyah İnci',
                'E.g., Black Pearl',
                'Zum Beispiel Black Pearl',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Güncel Odometer
          TextField(
            controller: _odometer,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Güncel Kilometre ($unitSuffix) *',
                'Current Odometer ($unitSuffix) *',
                'Aktueller Kilometerzähler ($unitSuffix) *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Mevcut odometre değeri',
                'Current odometer reading',
                'Aktueller Kilometerstand',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Son Servis Kilometresi
          TextField(
            controller: _lastServiceOdometer,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Son Servis Kilometresi ($unitSuffix) *',
                'Last Service Odometer ($unitSuffix) *',
                'Kilometerzähler der letzten Wartung ($unitSuffix) *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Son bakım yapıldığındaki değer',
                'Value at last service',
                'Wert beim letzten Service',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Servis Aralığı
          TextField(
            controller: _serviceInterval,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: tInline(
                widget.strings.languageCode,
                'Servis Aralığı ($unitSuffix) *',
                'Service Interval ($unitSuffix) *',
                'Serviceintervall ($unitSuffix) *',
              ),
              hintText: tInline(
                widget.strings.languageCode,
                'Örn: 6000',
                'E.g., 6000',
                'Z. B. 6000',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
