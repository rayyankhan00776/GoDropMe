import 'package:flutter/services.dart';

class PakistanPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Digits only from user input.
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Normalize: strip leading country code or 0, keep national part.
    String national = rawDigits;
    if (national.startsWith('92')) national = national.substring(2);
    if (national.startsWith('0')) national = national.substring(1);

    // Clamp to 10 digits (Pakistani mobile national significant number).
    if (national.length > 10) national = national.substring(0, 10);

    // If user cleared everything, keep field truly empty (fixes stray '9').
    if (national.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Display just the national part; UI elsewhere shows +92 context.
    return TextEditingValue(
      text: national,
      selection: TextSelection.collapsed(offset: national.length),
    );
  }
}
