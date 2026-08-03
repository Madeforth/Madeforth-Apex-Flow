class DriverInfo {
  final String name;
  final String surname;
  final String identityNumber;
  final String licenseNumber;
  final String licenseClass;
  final String address;
  final String phone;
  final String email;
  final String insuranceCompany;
  final String insurancePolicyNumber;
  final String? greenCardNumber;
  final String vehicleMake;
  final String vehiclePlate;
  final String vehicleChassis;
  final String vehicleUsage;
  final String licenseIssuingPlace;
  final String insuranceAgentNumber;
  final String tramerNumber;
  final String policyPeriod;
  final bool? canRecoverVat;
  final bool? isDamageInsured;
  final String visibleDamage;

  DriverInfo({
    this.name = '',
    this.surname = '',
    this.identityNumber = '',
    this.licenseNumber = '',
    this.licenseClass = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.insuranceCompany = '',
    this.insurancePolicyNumber = '',
    this.greenCardNumber,
    this.vehicleMake = '',
    this.vehiclePlate = '',
    this.vehicleChassis = '',
    this.vehicleUsage = '',
    this.licenseIssuingPlace = '',
    this.insuranceAgentNumber = '',
    this.tramerNumber = '',
    this.policyPeriod = '',
    this.canRecoverVat,
    this.isDamageInsured,
    this.visibleDamage = '',
  });
}

class AccidentCircumstances {
  final List<int> trSelectedBoxes;
  final List<int> euSelectedBoxes;

  AccidentCircumstances({
    this.trSelectedBoxes = const [],
    this.euSelectedBoxes = const [],
  });
}

class AccidentReport {
  final DateTime date;
  final String location;
  final DriverInfo driverA;
  final DriverInfo driverB;
  final AccidentCircumstances circumstancesA;
  final AccidentCircumstances circumstancesB;
  final String remarksA;
  final String remarksB;
  final List<int> sketchBytes;
  final List<int> signatureBytesA;
  final List<int> signatureBytesB;
  final String witnesses;
  final String speedA;
  final String speedB;
  final String brakeTrackA;
  final String brakeTrackB;
  final List<int> impactPointBytesA;
  final List<int> impactPointBytesB;
  final bool? hasInjuries;
  final bool? hasOtherPropertyDamage;

  AccidentReport({
    required this.date,
    required this.location,
    required this.driverA,
    required this.driverB,
    required this.circumstancesA,
    required this.circumstancesB,
    this.remarksA = '',
    this.remarksB = '',
    this.sketchBytes = const [],
    this.signatureBytesA = const [],
    this.signatureBytesB = const [],
    this.witnesses = '',
    this.speedA = '',
    this.speedB = '',
    this.brakeTrackA = '',
    this.brakeTrackB = '',
    this.impactPointBytesA = const [],
    this.impactPointBytesB = const [],
    this.hasInjuries,
    this.hasOtherPropertyDamage,
  });
}
