import 'package:flutter/services.dart';

/// InputFormatters & lightweight helpers extracted for reuse without altering
/// existing validation logic elsewhere. These are pure transform/guard pieces
/// that previous inline implementations duplicated.
class ExtraInputFormatters {
  ExtraInputFormatters._();

  /// Forces uppercase (e.g., number plates) while keeping cursor at end.
  static final TextInputFormatter toUpperCase = _UpperCaseTextFormatter();

  /// Formats incremental numeric input into DD-MM-YYYY while typing. Accepts
  /// only digits; inserts '-' after day & month. (Used for licence expiry.)
  static final TextInputFormatter dateDmy = _DateInputFormatter();
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buf = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buf.write(limited[i]);
      if (i == 1 || i == 3) buf.write('-');
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
