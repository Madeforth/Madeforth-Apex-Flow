import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:printing/printing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/domain/accident_report_model.dart';
import 'package:apexflow/garage/application/accident_pdf_generator.dart';

class TrAccidentWizardScreen extends StatefulWidget {
  const TrAccidentWizardScreen({super.key, required this.strings});
  final AppStrings strings;

  @override
  State<TrAccidentWizardScreen> createState() => _TrAccidentWizardScreenState();
}

class _TrAccidentWizardScreenState extends State<TrAccidentWizardScreen> {
  int _currentStep = 0;
  final _locationController = TextEditingController();
  final _witnessesController = TextEditingController();

  // Driver A
  final _driverANameController = TextEditingController();
  final _driverATcController = TextEditingController();
  final _driverALicenseController = TextEditingController();
  final _driverALicensePlaceController = TextEditingController();
  final _driverAAddressController = TextEditingController();
  final _driverAPhoneController = TextEditingController();
  final _driverAVehicleMakeController = TextEditingController();
  final _driverAVehiclePlateController = TextEditingController();
  final _driverAVehicleChassisController = TextEditingController();
  final _driverAVehicleUsageController = TextEditingController();
  final _driverAInsuranceCompanyController = TextEditingController();
  final _driverAInsurancePolicyController = TextEditingController();
  final _driverAAgentController = TextEditingController();
  final _driverATramerController = TextEditingController();
  final _driverAPolicyPeriodController = TextEditingController();
  final _driverASpeedController = TextEditingController();
  final _driverABrakeTrackController = TextEditingController();
  final _impactAController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
  );
  final _impactKeyA = GlobalKey();
  final _impactKeyB = GlobalKey();
  Uint8List _cachedImpactA = Uint8List(0);
  Uint8List _cachedImpactB = Uint8List(0);
  List<int> _trChecksA = [];

  Future<Uint8List?> _captureKey(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // Driver B
  final _driverBNameController = TextEditingController();
  final _driverBTcController = TextEditingController();
  final _driverBLicenseController = TextEditingController();
  final _driverBLicensePlaceController = TextEditingController();
  final _driverBAddressController = TextEditingController();
  final _driverBPhoneController = TextEditingController();
  final _driverBVehicleMakeController = TextEditingController();
  final _driverBVehiclePlateController = TextEditingController();
  final _driverBVehicleChassisController = TextEditingController();
  final _driverBVehicleUsageController = TextEditingController();
  final _driverBInsuranceCompanyController = TextEditingController();
  final _driverBInsurancePolicyController = TextEditingController();
  final _driverBAgentController = TextEditingController();
  final _driverBTramerController = TextEditingController();
  final _driverBPolicyPeriodController = TextEditingController();
  final _driverBSpeedController = TextEditingController();
  final _driverBBrakeTrackController = TextEditingController();
  final _impactBController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
  );
  List<int> _trChecksB = [];

  // Common
  final _remarksAController = TextEditingController();
  final _remarksBController = TextEditingController();

  final _sketchController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  final _signatureAController = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF000080),
    exportBackgroundColor: Colors.transparent,
  );
  final _signatureBController = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF000080),
    exportBackgroundColor: Colors.transparent,
  );

  final List<String> _trCheckboxLabels = [
    'Kırmızı ışıkta geçmek',
    'Taşıt giremez işaretine girmek',
    'Karşı yöne girmek',
    'Geçme yasağı olan yerde geçmek',
    'Dönüş manevralarını yanlış yapmak',
    'Şeride tecavüz etmek',
    'Kavşakta geçiş önceliğine uymamak',
    'Arkadan çarpmak',
    'Sağa dönüş kurallarına uymamak',
    'Sola dönüş kurallarına uymamak',
    'Park etme yasaklarına uymamak',
    'Hız kurallarına uymamak',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _witnessesController.dispose();

    _driverANameController.dispose();
    _driverATcController.dispose();
    _driverALicenseController.dispose();
    _driverALicensePlaceController.dispose();
    _driverAAddressController.dispose();
    _driverAPhoneController.dispose();
    _driverAVehicleMakeController.dispose();
    _driverAVehiclePlateController.dispose();
    _driverAVehicleChassisController.dispose();
    _driverAVehicleUsageController.dispose();
    _driverAInsuranceCompanyController.dispose();
    _driverAInsurancePolicyController.dispose();
    _driverAAgentController.dispose();
    _driverATramerController.dispose();
    _driverAPolicyPeriodController.dispose();
    _driverASpeedController.dispose();
    _driverABrakeTrackController.dispose();
    _impactAController.dispose();

    _driverBNameController.dispose();
    _driverBTcController.dispose();
    _driverBLicenseController.dispose();
    _driverBLicensePlaceController.dispose();
    _driverBAddressController.dispose();
    _driverBPhoneController.dispose();
    _driverBVehicleMakeController.dispose();
    _driverBVehiclePlateController.dispose();
    _driverBVehicleChassisController.dispose();
    _driverBVehicleUsageController.dispose();
    _driverBInsuranceCompanyController.dispose();
    _driverBInsurancePolicyController.dispose();
    _driverBAgentController.dispose();
    _driverBTramerController.dispose();
    _driverBPolicyPeriodController.dispose();
    _driverBSpeedController.dispose();
    _driverBBrakeTrackController.dispose();
    _impactBController.dispose();

    _remarksAController.dispose();
    _remarksBController.dispose();
    _sketchController.dispose();
    _signatureAController.dispose();
    _signatureBController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSharePdf() async {
    final sketchBytes = await _sketchController.toPngBytes() ?? Uint8List(0);
    final sigABytes = await _signatureAController.toPngBytes() ?? Uint8List(0);
    final sigBBytes = await _signatureBController.toPngBytes() ?? Uint8List(0);
    final impactABytes = _cachedImpactA;
    final impactBBytes = _cachedImpactB;

    final report = AccidentReport(
      date: DateTime.now(),
      location: _locationController.text.isEmpty
          ? 'Bilinmiyor'
          : _locationController.text,
      witnesses: _witnessesController.text,
      driverA: DriverInfo(
        name: _driverANameController.text,
        identityNumber: _driverATcController.text,
        licenseNumber: _driverALicenseController.text,
        licenseIssuingPlace: _driverALicensePlaceController.text,
        address: _driverAAddressController.text,
        phone: _driverAPhoneController.text,
        vehicleChassis: _driverAVehicleChassisController.text,
        vehicleMake: _driverAVehicleMakeController.text,
        vehiclePlate: _driverAVehiclePlateController.text,
        vehicleUsage: _driverAVehicleUsageController.text,
        insuranceCompany: _driverAInsuranceCompanyController.text,
        insurancePolicyNumber: _driverAInsurancePolicyController.text,
        insuranceAgentNumber: _driverAAgentController.text,
        tramerNumber: _driverATramerController.text,
        policyPeriod: _driverAPolicyPeriodController.text,
      ),
      driverB: DriverInfo(
        name: _driverBNameController.text,
        identityNumber: _driverBTcController.text,
        licenseNumber: _driverBLicenseController.text,
        licenseIssuingPlace: _driverBLicensePlaceController.text,
        address: _driverBAddressController.text,
        phone: _driverBPhoneController.text,
        vehicleChassis: _driverBVehicleChassisController.text,
        vehicleMake: _driverBVehicleMakeController.text,
        vehiclePlate: _driverBVehiclePlateController.text,
        vehicleUsage: _driverBVehicleUsageController.text,
        insuranceCompany: _driverBInsuranceCompanyController.text,
        insurancePolicyNumber: _driverBInsurancePolicyController.text,
        insuranceAgentNumber: _driverBAgentController.text,
        tramerNumber: _driverBTramerController.text,
        policyPeriod: _driverBPolicyPeriodController.text,
      ),
      circumstancesA: AccidentCircumstances(trSelectedBoxes: _trChecksA),
      circumstancesB: AccidentCircumstances(trSelectedBoxes: _trChecksB),
      remarksA: _remarksAController.text,
      remarksB: _remarksBController.text,
      sketchBytes: sketchBytes.toList(),
      signatureBytesA: sigABytes.toList(),
      signatureBytesB: sigBBytes.toList(),
      speedA: _driverASpeedController.text,
      speedB: _driverBSpeedController.text,
      brakeTrackA: _driverABrakeTrackController.text,
      brakeTrackB: _driverBBrakeTrackController.text,
      impactPointBytesA: impactABytes.toList(),
      impactPointBytesB: impactBBytes.toList(),
    );

    final pdfBytes = await AccidentPdfGenerator.generatePdf(
      report,
      isEurope: false,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'TR_Kaza_Tespit_Tutanagi.pdf',
    );
  }

  Widget _buildCheckboxes(bool isDriverA) {
    final checks = isDriverA ? _trChecksA : _trChecksB;
    return Column(
      children: List.generate(_trCheckboxLabels.length, (index) {
        return CheckboxListTile(
          title: Text(
            _trCheckboxLabels[index],
            style: const TextStyle(fontSize: 12),
          ),
          value: checks.contains(index),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                checks.add(index);
              } else {
                checks.remove(index);
              }
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawingBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.grey.shade200;

    return Scaffold(
      appBar: AppBar(title: const Text('Türkiye KTT Sihirbazı')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () async {
          // Capture impact bytes before leaving the step that contains the canvas
          if (_currentStep == 1) {
            _cachedImpactA = await _captureKey(_impactKeyA) ?? Uint8List(0);
          } else if (_currentStep == 2) {
            _cachedImpactB = await _captureKey(_impactKeyB) ?? Uint8List(0);
          }
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            _generateAndSharePdf();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        steps: [
          Step(
            title: const Text('Tarih & Yer'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Kaza Yeri (İl, İlçe, Mahalle, Cadde)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _witnessesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Görgü Tanıkları (Adı Soyadı, Adres, Tel)',
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('ARAÇ A Sürücüsü'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Sürücü Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverANameController,
                  decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverATcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'T.C. Kimlik / Pasaport No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverALicenseController,
                  decoration: const InputDecoration(
                    labelText: 'Sürücü Belge No ve Sınıfı',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverALicensePlaceController,
                  decoration: const InputDecoration(
                    labelText: 'Belgenin Alındığı Yer (İl/İlçe)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAAddressController,
                  decoration: const InputDecoration(labelText: 'Adres'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Cep Tel No'),
                ),

                const SizedBox(height: 16),
                const Text(
                  '2. Araç Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverAVehiclePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Plaka'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleMakeController,
                  decoration: const InputDecoration(
                    labelText: 'Marka ve Modeli',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleChassisController,
                  decoration: const InputDecoration(labelText: 'Şasi No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleUsageController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanım Şekli (Örn: Hususi)',
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  '3. Trafik Sigortası Poliçe Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverAInsuranceCompanyController,
                  decoration: const InputDecoration(
                    labelText: 'Sigorta Şirketi',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAInsurancePolicyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Poliçe No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAAgentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Acente No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverATramerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TRAMER Belge No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAPolicyPeriodController,
                  decoration: const InputDecoration(
                    labelText: 'Poliçe Başlangıç - Bitiş Tarihi',
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  '4. Kaza Detayları',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverASpeedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Çarpışma Anındaki Hız (km/s)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverABrakeTrackController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fren İzi Uzunluğu (m)',
                  ),
                ),
                const SizedBox(height: 12),
                _buildImpactCanvas(
                  _impactAController,
                  273,
                  200,
                  drawingBg,
                  _impactKeyA,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Kusur Durumu (Sadece uygun olanları seçin)'),
                const SizedBox(height: 8),
                _buildCheckboxes(true),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('ARAÇ B Sürücüsü'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Sürücü Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBNameController,
                  decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBTcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'T.C. Kimlik / Pasaport No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBLicenseController,
                  decoration: const InputDecoration(
                    labelText: 'Sürücü Belge No ve Sınıfı',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBLicensePlaceController,
                  decoration: const InputDecoration(
                    labelText: 'Belgenin Alındığı Yer (İl/İlçe)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBAddressController,
                  decoration: const InputDecoration(labelText: 'Adres'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Cep Tel No'),
                ),

                const SizedBox(height: 16),
                const Text(
                  '2. Araç Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBVehiclePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Plaka'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleMakeController,
                  decoration: const InputDecoration(
                    labelText: 'Marka ve Modeli',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleChassisController,
                  decoration: const InputDecoration(labelText: 'Şasi No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleUsageController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanım Şekli (Örn: Hususi)',
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  '3. Trafik Sigortası Poliçe Bilgileri',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBInsuranceCompanyController,
                  decoration: const InputDecoration(
                    labelText: 'Sigorta Şirketi',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBInsurancePolicyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Poliçe No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBAgentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Acente No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBTramerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TRAMER Belge No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBPolicyPeriodController,
                  decoration: const InputDecoration(
                    labelText: 'Poliçe Başlangıç - Bitiş Tarihi',
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  '4. Kaza Detayları',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBSpeedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Çarpışma Anındaki Hız (km/s)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBBrakeTrackController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fren İzi Uzunluğu (m)',
                  ),
                ),
                const SizedBox(height: 12),
                _buildImpactCanvas(
                  _impactBController,
                  273,
                  200,
                  drawingBg,
                  _impactKeyB,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const Text('Kusur Durumu (Sadece uygun olanları seçin)'),
                const SizedBox(height: 8),
                _buildCheckboxes(false),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Kaza Krokisi'),
            content: Column(
              children: [
                const Text('Lütfen kaza anını aşağıya çizin'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: drawingBg,
                  ),
                  child: Signature(
                    controller: _sketchController,
                    height: 350,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                TextButton(
                  onPressed: () => _sketchController.clear(),
                  child: const Text('Krokiyi Temizle'),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Sürücü Görüşleri'),
            content: Column(
              children: [
                TextField(
                  controller: _remarksAController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Araç A Görüşleri',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _remarksBController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Araç B Görüşleri',
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: const Text('İmzalar'),
            content: Column(
              children: [
                const Text('Araç A Sürücüsü İmzası:'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: drawingBg,
                  ),
                  child: Signature(
                    controller: _signatureAController,
                    height: 100,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                TextButton(
                  onPressed: () => _signatureAController.clear(),
                  child: const Text('Temizle'),
                ),
                const SizedBox(height: 20),
                const Text('Araç B Sürücüsü İmzası:'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: drawingBg,
                  ),
                  child: Signature(
                    controller: _signatureBController,
                    height: 100,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                TextButton(
                  onPressed: () => _signatureBController.clear(),
                  child: const Text('Temizle'),
                ),
              ],
            ),
            isActive: _currentStep >= 5,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCanvas(
    SignatureController controller,
    double width,
    double height,
    Color bg,
    Key repaintKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İlk Darbe Noktası (Aşağıdaki görsel üzerinde ok çizerek işaretleyiniz):',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: SilhouettePainter()),
                ),
                Positioned.fill(
                  child: Signature(
                    controller: controller,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => controller.clear(),
          child: const Text('Çizimi Temizle'),
        ),
      ],
    );
  }
}

class SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.grey.shade300.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 1. Scooter/Motorcycle (Left)
    final cx1 = size.width * 0.18;
    final cy1 = size.height * 0.5;

    // Front wheel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx1, cy1 - 35), width: 6, height: 14),
        const Radius.circular(2),
      ),
      paint,
    );
    // Rear wheel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx1, cy1 + 35), width: 8, height: 16),
        const Radius.circular(2),
      ),
      paint,
    );
    // Handlebars
    canvas.drawLine(
      Offset(cx1 - 18, cy1 - 22),
      Offset(cx1 + 18, cy1 - 22),
      paint,
    );
    // Mirrors
    canvas.drawCircle(Offset(cx1 - 18, cy1 - 26), 3, paint);
    canvas.drawCircle(Offset(cx1 + 18, cy1 - 26), 3, paint);
    // Main Body
    final bodyPath = Path()
      ..moveTo(cx1, cy1 - 25)
      ..quadraticBezierTo(cx1 - 10, cy1 - 10, cx1 - 8, cy1 + 20)
      ..lineTo(cx1 + 8, cy1 + 20)
      ..quadraticBezierTo(cx1 + 10, cy1 - 10, cx1, cy1 - 25)
      ..close();
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, paint);
    // Seat details
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx1, cy1), width: 10, height: 26),
      paint,
    );

    // 2. Sedan / Car (Center)
    final cx2 = size.width * 0.5;
    final cy2 = size.height * 0.5;

    // Main outline
    final carRect = Rect.fromCenter(
      center: Offset(cx2, cy2),
      width: size.width * 0.22,
      height: size.height * 0.8,
    );
    final carRRect = RRect.fromRectAndRadius(carRect, const Radius.circular(8));
    canvas.drawRRect(carRRect, fillPaint);
    canvas.drawRRect(carRRect, paint);

    // Hood line
    canvas.drawLine(
      Offset(cx2 - size.width * 0.11, cy2 - size.height * 0.2),
      Offset(cx2 + size.width * 0.11, cy2 - size.height * 0.2),
      paint,
    );
    // Windshield
    final windshieldPath = Path()
      ..moveTo(cx2 - size.width * 0.09, cy2 - size.height * 0.18)
      ..quadraticBezierTo(
        cx2,
        cy2 - size.height * 0.22,
        cx2 + size.width * 0.09,
        cy2 - size.height * 0.18,
      )
      ..quadraticBezierTo(
        cx2 + size.width * 0.08,
        cy2 - size.height * 0.10,
        cx2 + size.width * 0.09,
        cy2 - size.height * 0.08,
      )
      ..quadraticBezierTo(
        cx2,
        cy2 - size.height * 0.06,
        cx2 - size.width * 0.09,
        cy2 - size.height * 0.08,
      )
      ..quadraticBezierTo(
        cx2 - size.width * 0.08,
        cy2 - size.height * 0.10,
        cx2 - size.width * 0.09,
        cy2 - size.height * 0.18,
      )
      ..close();
    canvas.drawPath(windshieldPath, paint);

    // Roof
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx2, cy2 + size.height * 0.04),
        width: size.width * 0.16,
        height: size.height * 0.25,
      ),
      paint,
    );

    // Rear Window
    final rearWindowPath = Path()
      ..moveTo(cx2 - size.width * 0.08, cy2 + size.height * 0.18)
      ..quadraticBezierTo(
        cx2,
        cy2 + size.height * 0.22,
        cx2 + size.width * 0.08,
        cy2 + size.height * 0.18,
      )
      ..lineTo(cx2 + size.width * 0.07, cy2 + size.height * 0.14)
      ..quadraticBezierTo(
        cx2,
        cy2 + size.height * 0.16,
        cx2 - size.width * 0.07,
        cy2 + size.height * 0.14,
      )
      ..close();
    canvas.drawPath(rearWindowPath, paint);

    // Side Mirrors
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx2 - size.width * 0.13, cy2 - size.height * 0.16, 4, 10),
        const Radius.circular(1),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx2 + size.width * 0.11, cy2 - size.height * 0.16, 4, 10),
        const Radius.circular(1),
      ),
      paint,
    );

    // 3. Truck / Kamyonet (Right)
    final cx3 = size.width * 0.82;
    final cy3 = size.height * 0.5;

    // Main cargo bed
    final cargoRect = Rect.fromCenter(
      center: Offset(cx3, cy3 + size.height * 0.1),
      width: size.width * 0.24,
      height: size.height * 0.55,
    );
    canvas.drawRect(cargoRect, fillPaint);
    canvas.drawRect(cargoRect, paint);
    // Draw details inside cargo bed
    canvas.drawLine(
      Offset(cx3 - size.width * 0.12, cy3 - size.height * 0.1),
      Offset(cx3 + size.width * 0.12, cy3 + size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(cx3 + size.width * 0.12, cy3 - size.height * 0.1),
      Offset(cx3 - size.width * 0.12, cy3 + size.height * 0.3),
      paint,
    );

    // Front Cabin
    final cabinRect = Rect.fromCenter(
      center: Offset(cx3, cy3 - size.height * 0.28),
      width: size.width * 0.24,
      height: size.height * 0.24,
    );
    canvas.drawRect(cabinRect, fillPaint);
    canvas.drawRect(cabinRect, paint);

    // Windshield
    final truckWindshield = Rect.fromCenter(
      center: Offset(cx3, cy3 - size.height * 0.3),
      width: size.width * 0.20,
      height: size.height * 0.08,
    );
    canvas.drawRect(truckWindshield, paint);

    // Mirrors
    canvas.drawRect(
      Rect.fromLTWH(cx3 - size.width * 0.16, cy3 - size.height * 0.34, 6, 12),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(cx3 + size.width * 0.12, cy3 - size.height * 0.34, 6, 12),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
