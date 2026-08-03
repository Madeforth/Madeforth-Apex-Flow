import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:printing/printing.dart';
import 'package:apexflow/core/i18n/app_strings.dart';
import 'package:apexflow/garage/domain/accident_report_model.dart';
import 'package:apexflow/garage/application/accident_pdf_generator.dart';

class EuAccidentWizardScreen extends StatefulWidget {
  const EuAccidentWizardScreen({super.key, required this.strings});
  final AppStrings strings;

  @override
  State<EuAccidentWizardScreen> createState() => _EuAccidentWizardScreenState();
}

class _EuAccidentWizardScreenState extends State<EuAccidentWizardScreen> {
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
  final _driverAGreenCardController = TextEditingController();
  List<int> _euChecksA = [];

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
  final _driverBGreenCardController = TextEditingController();
  List<int> _euChecksB = [];

  // Common
  final _remarksAController = TextEditingController();
  final _remarksBController = TextEditingController();

  bool _hasInjuries = false;
  bool _hasOtherPropertyDamage = false;
  bool _driverACanRecoverVat = false;
  bool _driverBCanRecoverVat = false;
  bool _driverAIsDamageInsured = true;
  bool _driverBIsDamageInsured = true;
  final _driverAVisibleDamageController = TextEditingController();
  final _driverBVisibleDamageController = TextEditingController();

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

  final List<String> _euCheckboxLabels = [
    'Parked / Stopped',
    'Leaving a parking place',
    'Entering a parking place',
    'Emerging from a car park / private grounds',
    'Entering a car park / private grounds',
    'Entering a roundabout',
    'Circulating a roundabout',
    'Striking the rear of the other vehicle',
    'Going in the same direction and in the same lane',
    'Changing lanes',
    'Overtaking',
    'Turning to the right',
    'Turning to the left',
    'Reversing',
    'Encroaching on a lane reserved for opposite traffic',
    'Coming from the right (at road junctions)',
    'Had not observed a right of way sign or a red light',
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
    _driverAGreenCardController.dispose();

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
    _driverBGreenCardController.dispose();

    _remarksAController.dispose();
    _remarksBController.dispose();
    _driverAVisibleDamageController.dispose();
    _driverBVisibleDamageController.dispose();
    _sketchController.dispose();
    _signatureAController.dispose();
    _signatureBController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSharePdf() async {
    final sketchBytes = await _sketchController.toPngBytes() ?? Uint8List(0);
    final sigABytes = await _signatureAController.toPngBytes() ?? Uint8List(0);
    final sigBBytes = await _signatureBController.toPngBytes() ?? Uint8List(0);
    final impactABytes = await _captureKey(_impactKeyA) ?? Uint8List(0);
    final impactBBytes = await _captureKey(_impactKeyB) ?? Uint8List(0);

    final report = AccidentReport(
      date: DateTime.now(),
      location: _locationController.text.isEmpty
          ? 'Unknown'
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
        greenCardNumber: _driverAGreenCardController.text,
        canRecoverVat: _driverACanRecoverVat,
        isDamageInsured: _driverAIsDamageInsured,
        visibleDamage: _driverAVisibleDamageController.text,
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
        greenCardNumber: _driverBGreenCardController.text,
        canRecoverVat: _driverBCanRecoverVat,
        isDamageInsured: _driverBIsDamageInsured,
        visibleDamage: _driverBVisibleDamageController.text,
      ),
      circumstancesA: AccidentCircumstances(euSelectedBoxes: _euChecksA),
      circumstancesB: AccidentCircumstances(euSelectedBoxes: _euChecksB),
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
      hasInjuries: _hasInjuries,
      hasOtherPropertyDamage: _hasOtherPropertyDamage,
    );

    final pdfBytes = await AccidentPdfGenerator.generatePdf(
      report,
      isEurope: true,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'EU_Accident_Statement.pdf',
    );
  }

  Widget _buildCheckboxes(bool isDriverA) {
    final checks = isDriverA ? _euChecksA : _euChecksB;
    return Column(
      children: List.generate(_euCheckboxLabels.length, (index) {
        return CheckboxListTile(
          title: Text(
            _euCheckboxLabels[index],
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
      appBar: AppBar(title: const Text('EU Accident Statement')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 5)
            setState(() => _currentStep += 1);
          else
            _generateAndSharePdf();
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        steps: [
          Step(
            title: const Text('Date & Location'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Place (exact location)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _witnessesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Witnesses (Name, Address, Tel)',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Injuries even if slight?'),
                  value: _hasInjuries,
                  onChanged: (val) => setState(() => _hasInjuries = val),
                ),
                SwitchListTile(
                  title: const Text(
                    'Other property damage than to vehicles A and B?',
                  ),
                  value: _hasOtherPropertyDamage,
                  onChanged: (val) =>
                      setState(() => _hasOtherPropertyDamage = val),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Vehicle A (You)'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Driver Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverANameController,
                  decoration: const InputDecoration(labelText: 'Name Surname'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverATcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Identity / Passport No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverALicenseController,
                  decoration: const InputDecoration(
                    labelText: 'Driving License No & Class',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverALicensePlaceController,
                  decoration: const InputDecoration(
                    labelText: 'License Issuing Place',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAAddressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),

                const SizedBox(height: 16),
                const Text(
                  '2. Vehicle Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverAVehiclePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Registration Plate',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleMakeController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Make & Model',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleChassisController,
                  decoration: const InputDecoration(labelText: 'Chassis No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVehicleUsageController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Usage (e.g. Private)',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Can recover VAT?'),
                  value: _driverACanRecoverVat,
                  onChanged: (val) =>
                      setState(() => _driverACanRecoverVat = val),
                ),
                const SizedBox(height: 16),
                const Text(
                  '3. Insurance Policy Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverAInsuranceCompanyController,
                  decoration: const InputDecoration(
                    labelText: 'Insurance Company',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAInsurancePolicyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Policy No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAAgentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Agent No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverATramerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TRAMER Document No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAPolicyPeriodController,
                  decoration: const InputDecoration(
                    labelText: 'Policy Period (Start - End Dates)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAGreenCardController,
                  decoration: const InputDecoration(labelText: 'Green Card No'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Is vehicle damage insured?'),
                  value: _driverAIsDamageInsured,
                  onChanged: (val) =>
                      setState(() => _driverAIsDamageInsured = val),
                ),

                const SizedBox(height: 16),
                const Text(
                  '4. Collision Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverASpeedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Speed at Impact (km/h)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverABrakeTrackController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Brake Track Length (m)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverAVisibleDamageController,
                  decoration: const InputDecoration(
                    labelText: 'Visible Damage Description',
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
                const Text('Circumstances (Check valid ones)'),
                const SizedBox(height: 8),
                _buildCheckboxes(true),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Vehicle B (Other)'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. Driver Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBNameController,
                  decoration: const InputDecoration(labelText: 'Name Surname'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBTcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Identity / Passport No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBLicenseController,
                  decoration: const InputDecoration(
                    labelText: 'Driving License No & Class',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBLicensePlaceController,
                  decoration: const InputDecoration(
                    labelText: 'License Issuing Place',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBAddressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),

                const SizedBox(height: 16),
                const Text(
                  '2. Vehicle Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBVehiclePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Registration Plate',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleMakeController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Make & Model',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleChassisController,
                  decoration: const InputDecoration(labelText: 'Chassis No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVehicleUsageController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Usage (e.g. Private)',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Can recover VAT?'),
                  value: _driverBCanRecoverVat,
                  onChanged: (val) =>
                      setState(() => _driverBCanRecoverVat = val),
                ),
                const SizedBox(height: 16),
                const Text(
                  '3. Insurance Policy Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBInsuranceCompanyController,
                  decoration: const InputDecoration(
                    labelText: 'Insurance Company',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBInsurancePolicyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Policy No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBAgentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Agent No'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBTramerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TRAMER Document No',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBPolicyPeriodController,
                  decoration: const InputDecoration(
                    labelText: 'Policy Period (Start - End Dates)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBGreenCardController,
                  decoration: const InputDecoration(labelText: 'Green Card No'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Is vehicle damage insured?'),
                  value: _driverBIsDamageInsured,
                  onChanged: (val) =>
                      setState(() => _driverBIsDamageInsured = val),
                ),

                const SizedBox(height: 16),
                const Text(
                  '4. Collision Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _driverBSpeedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Speed at Impact (km/h)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBBrakeTrackController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Brake Track Length (m)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _driverBVisibleDamageController,
                  decoration: const InputDecoration(
                    labelText: 'Visible Damage Description',
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
                const Text('Circumstances (Check valid ones)'),
                const SizedBox(height: 8),
                _buildCheckboxes(false),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Accident Sketch'),
            content: Column(
              children: [
                const Text('Draw the sketch of accident'),
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
                  child: const Text('Clear Sketch'),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Remarks'),
            content: Column(
              children: [
                TextField(
                  controller: _remarksAController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle A Remarks',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _remarksBController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle B Remarks',
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: const Text('Signatures'),
            content: Column(
              children: [
                const Text('Driver A Signature:'),
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
                  child: const Text('Clear'),
                ),
                const SizedBox(height: 20),
                const Text('Driver B Signature:'),
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
                  child: const Text('Clear'),
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
          'Point of Impact (Draw an arrow on the vehicle silhouettes below):',
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
          child: const Text('Clear Drawing'),
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
