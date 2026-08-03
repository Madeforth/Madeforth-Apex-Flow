import 'package:flutter/services.dart';

class TurkeyPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digit characters
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 1) buffer.write(' ');
      if (i == 4) buffer.write(' ');
      if (i == 7) buffer.write(' ');

      // Limit to 11 digits maximum (e.g. 0 544 643 2066)
      if (i < 11) {
        buffer.write(text[i]);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneCountryCode {
  const PhoneCountryCode({required this.code, required this.flag});
  final String code;
  final String flag;
}

const List<PhoneCountryCode> availableCountryCodes = [
  PhoneCountryCode(code: '+90', flag: '🇹🇷'),
  PhoneCountryCode(code: '+1', flag: '🇺🇸'),
  PhoneCountryCode(code: '+44', flag: '🇬🇧'),
  PhoneCountryCode(code: '+49', flag: '🇩🇪'),
  PhoneCountryCode(code: '+33', flag: '🇫🇷'),
  PhoneCountryCode(code: '+39', flag: '🇮🇹'),
  PhoneCountryCode(code: '+34', flag: '🇪🇸'),
];
