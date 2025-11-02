// Shared small value objects and enums used across models.
// These are pure Dart types with simple parsing helpers.

class PhoneNumber {
  /// National significant number without country code, e.g., 3XXXXXXXXX for PK.
  final String national;

  /// Country code without plus, e.g., '92'.
  final String countryCode;

  const PhoneNumber({required this.national, this.countryCode = '92'});

  String get e164 => '+$countryCode$national';

  Map<String, dynamic> toJson() => {
    'national': national,
    'countryCode': countryCode,
  };

  factory PhoneNumber.fromJson(Map<String, dynamic> json) => PhoneNumber(
    national: (json['national'] ?? '').toString(),
    countryCode: (json['countryCode'] ?? '92').toString(),
  );
}

class Cnic {
  /// 13 digit CNIC number as digits only.
  final String digits;
  const Cnic(this.digits);

  Map<String, dynamic> toJson() => {'digits': digits};
  factory Cnic.fromJson(Map<String, dynamic> json) =>
      Cnic((json['digits'] ?? '').toString());
}

/// Minimal location value object for storing a single point.
class LatLngLite {
  final double lat;
  final double lng;
  const LatLngLite({required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  factory LatLngLite.fromJson(Map<String, dynamic> json) => LatLngLite(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );
}

enum DayOfWeek { mon, tue, wed, thu, fri, sat, sun }

extension DayOfWeekCodec on DayOfWeek {
  String get code => switch (this) {
    DayOfWeek.mon => 'Mon',
    DayOfWeek.tue => 'Tue',
    DayOfWeek.wed => 'Wed',
    DayOfWeek.thu => 'Thu',
    DayOfWeek.fri => 'Fri',
    DayOfWeek.sat => 'Sat',
    DayOfWeek.sun => 'Sun',
  };

  static DayOfWeek? parse(String s) {
    final v = s.toLowerCase();
    if (v.startsWith('mon')) return DayOfWeek.mon;
    if (v.startsWith('tue')) return DayOfWeek.tue;
    if (v.startsWith('wed')) return DayOfWeek.wed;
    if (v.startsWith('thu')) return DayOfWeek.thu;
    if (v.startsWith('fri')) return DayOfWeek.fri;
    if (v.startsWith('sat')) return DayOfWeek.sat;
    if (v.startsWith('sun')) return DayOfWeek.sun;
    return null;
  }
}
