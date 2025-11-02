import 'driver_identification.dart';
import 'driver_licence.dart';
import 'driver_name.dart';
import 'personal_info.dart';
import 'service_details.dart';
import 'vehicle_registration.dart';
import 'vehicle_selection.dart';

/// Aggregated draft representing the in-progress driver onboarding.
/// This mirrors the current SharedPreferences keys so it can be serialized
/// or reconstructed easily without changing existing flows.
class DriverOnboardingDraft {
  final DriverName? driverName;
  final VehicleSelection? vehicleSelection;
  final PersonalInfo? personalInfo;
  final DriverLicence? driverLicence;
  final DriverIdentification? driverIdentification;
  final VehicleRegistration? vehicleRegistration;
  final ServiceDetails? serviceDetails;

  const DriverOnboardingDraft({
    this.driverName,
    this.vehicleSelection,
    this.personalInfo,
    this.driverLicence,
    this.driverIdentification,
    this.vehicleRegistration,
    this.serviceDetails,
  });

  DriverOnboardingDraft copyWith({
    DriverName? driverName,
    VehicleSelection? vehicleSelection,
    PersonalInfo? personalInfo,
    DriverLicence? driverLicence,
    DriverIdentification? driverIdentification,
    VehicleRegistration? vehicleRegistration,
    ServiceDetails? serviceDetails,
  }) {
    return DriverOnboardingDraft(
      driverName: driverName ?? this.driverName,
      vehicleSelection: vehicleSelection ?? this.vehicleSelection,
      personalInfo: personalInfo ?? this.personalInfo,
      driverLicence: driverLicence ?? this.driverLicence,
      driverIdentification: driverIdentification ?? this.driverIdentification,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      serviceDetails: serviceDetails ?? this.serviceDetails,
    );
  }

  Map<String, dynamic> toJson() => {
    'driverName': driverName?.toJson(),
    'vehicleSelection': vehicleSelection?.toJson(),
    'personalInfo': personalInfo?.toJson(),
    'driverLicence': driverLicence?.toJson(),
    'driverIdentification': driverIdentification?.toJson(),
    'vehicleRegistration': vehicleRegistration?.toJson(),
    'serviceDetails': serviceDetails?.toJson(),
  };

  factory DriverOnboardingDraft.fromJson(Map<String, dynamic> json) {
    T? _map<T>(String key, T Function(Map<String, dynamic>) f) {
      final v = json[key];
      if (v is Map<String, dynamic>) return f(v);
      return null;
    }

    return DriverOnboardingDraft(
      driverName: _map('driverName', (j) => DriverName.fromJson(j)),
      vehicleSelection: _map(
        'vehicleSelection',
        (j) => VehicleSelection.fromJson(j),
      ),
      personalInfo: _map('personalInfo', (j) => PersonalInfo.fromJson(j)),
      driverLicence: _map('driverLicence', (j) => DriverLicence.fromJson(j)),
      driverIdentification: _map(
        'driverIdentification',
        (j) => DriverIdentification.fromJson(j),
      ),
      vehicleRegistration: _map(
        'vehicleRegistration',
        (j) => VehicleRegistration.fromJson(j),
      ),
      serviceDetails: _map('serviceDetails', (j) => ServiceDetails.fromJson(j)),
    );
  }
}
