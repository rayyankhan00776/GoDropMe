import 'package:godropme/constants/app_strings.dart';

/// Centralized validators used across forms. Return null when valid; otherwise
/// return an error message from AppStrings.
class Validators {
  Validators._();

  static String? notEmpty(String? v, {required String message}) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return message;
    return null;
  }

  static String? cnic(String? v) {
    final digitsOnly = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length != 13) return AppStrings.errorCnicDigits;
    if (int.tryParse(digitsOnly) == null) return AppStrings.errorCnicNumeric;
    return null;
  }

  /// Validates a date in DD-MM-YYYY format. Accepts only hyphen separators.
  static String? dateDMY(String? v) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return AppStrings.errorExpiryRequired;
    if (val.length != 10) return AppStrings.errorExpiryFormat;
    final parts = val.split('-');
    if (parts.length != 3) return AppStrings.errorExpiryFormat;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return AppStrings.errorExpiryFormat;
    }
    if (parts[0].length != 2 || parts[1].length != 2 || parts[2].length != 4) {
      return AppStrings.errorExpiryFormat;
    }
    if (month < 1 || month > 12) return AppStrings.errorExpiryMonth;
    if (day < 1 || day > 31) return AppStrings.errorExpiryDay;
    return null;
  }

  static String? seatCapacity(String? v, {required int max}) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return AppStrings.errorSeatCapacityRequired;
    final n = int.tryParse(val);
    if (n == null || n <= 0) return AppStrings.errorSeatCapacityInvalid;
    if (n > max) return '${AppStrings.seatCapacityMaxLabelPrefix} $max';
    return null;
  }

  static String? productionYear(String? v) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return AppStrings.errorYearRequired;
    if (val.length != 4) return AppStrings.errorYearLength;
    final year = int.tryParse(val);
    final now = DateTime.now().year;
    if (year == null || year < 1960 || year > now) {
      return AppStrings.errorYearInvalid;
    }
    return null;
  }

  static String? plateNotEmpty(String? v) {
    return notEmpty(v, message: AppStrings.errorPlateRequired);
  }
}
