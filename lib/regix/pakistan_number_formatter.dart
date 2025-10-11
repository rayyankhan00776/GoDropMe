import 'package:flutter/services.dart';

class PakistanPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits from the raw input
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Normalize to national part (without country code)
    String national = rawDigits;
    if (national.startsWith('92')) {
      national = national.substring(2);
    } else if (national.startsWith('0')) {
      national = national.substring(1);
    }

    // Enforce maximum of 10 digits for the national part
    if (national.length > 10) {
      national = national.substring(0, 10);
    }

    // Build the displayed value: always show +92 prefix when there is any input,
    // otherwise keep just '+92' as the starter for clarity.
    final newText = '+92$national';

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }
}
