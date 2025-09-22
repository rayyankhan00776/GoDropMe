import 'package:flutter/services.dart';

class PakistanPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ensure the phone number starts with +92 and contains only digits
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      newText = '+92';
    } else if (newText.startsWith('92')) {
      newText = '+$newText';
    } else if (newText.startsWith('0')) {
      newText = '+92${newText.substring(1)}';
    } else {
      newText = '+92$newText';
    }

    // Handle backspace correctly
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset &&
        newText.length > 3) {
      newText = newText.substring(0, newText.length - 1);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
