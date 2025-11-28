/// Driver listing model for parent's "Find Drivers" screen.
/// This is a composite model joining data from `drivers`, `vehicles`, and `driver_services` collections.
class DriverListing {
  final String driverId; // drivers.$id
  final String name; // drivers.fullName
  final String vehicle; // e.g., "Suzuki Alto" - vehicles.brand + model
  final String vehicleColor; // vehicles.color
  final String type; // e.g., "Car" or "Rikshaw" - vehicles.vehicleType
  final int seatsAvailable; // vehicles.seatCapacity (or remaining seats)
  final String serving; // e.g., school name or area - from driver_services.schoolNames
  final String serviceArea; // e.g., "F-10, Islamabad" - driver_services.serviceAreaAddress
  final String serviceCategory; // 'Male', 'Female', or 'Both' - driver_services.serviceCategory
  final int monthlyPricePkr; // driver_services.monthlyPricePkr
  final String extraNotes; // driver_services.extraNotes
  final String photoAsset; // For demo - will be profilePhotoFileId from storage
  final String? profilePhotoFileId; // drivers.profilePhotoFileId for Appwrite storage
  final double rating; // drivers.rating
  final int totalTrips; // drivers.totalTrips
  final double? distanceKm; // Calculated distance from parent's location

  const DriverListing({
    required this.driverId,
    required this.name,
    required this.vehicle,
    required this.vehicleColor,
    required this.type,
    required this.seatsAvailable,
    required this.serving,
    required this.serviceArea,
    required this.serviceCategory,
    required this.monthlyPricePkr,
    required this.extraNotes,
    required this.photoAsset,
    this.profilePhotoFileId,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.distanceKm,
  });

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'driverId': driverId,
    'name': name,
    'vehicle': vehicle,
    'vehicleColor': vehicleColor,
    'type': type,
    'seatsAvailable': seatsAvailable,
    'serving': serving,
    'serviceArea': serviceArea,
    'serviceCategory': serviceCategory,
    'monthlyPricePkr': monthlyPricePkr,
    'extraNotes': extraNotes,
    'photoAsset': photoAsset,
    'profilePhotoFileId': profilePhotoFileId,
    'rating': rating,
    'totalTrips': totalTrips,
    'distanceKm': distanceKm,
  };

  /// Create from backend JSON (expected from `match-drivers` function)
  factory DriverListing.fromJson(Map<String, dynamic> json) => DriverListing(
    driverId: json['driverId']?.toString() ?? json['\$id']?.toString() ?? '',
    name: json['name']?.toString() ?? json['driverName']?.toString() ?? '',
    vehicle: json['vehicle']?.toString() ?? json['vehicleModel']?.toString() ?? '',
    vehicleColor: json['vehicleColor']?.toString() ?? '',
    type: json['type']?.toString() ?? json['vehicleType']?.toString() ?? '',
    seatsAvailable: (json['seatsAvailable'] as num?)?.toInt() ?? 
                    (json['seatCapacity'] as num?)?.toInt() ?? 0,
    serving: json['serving']?.toString() ?? '',
    serviceArea: json['serviceArea']?.toString() ?? '',
    serviceCategory: json['serviceCategory']?.toString() ?? 'Both',
    monthlyPricePkr: (json['monthlyPricePkr'] as num?)?.toInt() ?? 
                     (json['pricePerMonth'] as num?)?.toInt() ?? 0,
    extraNotes: json['extraNotes']?.toString() ?? '',
    photoAsset: json['photoAsset']?.toString() ?? 'assets/images/svg/person.svg',
    profilePhotoFileId: json['profilePhotoFileId']?.toString(),
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
    distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  );

  // Single dummy entry requested for now.
  static DriverListing demo() => const DriverListing(
    driverId: 'driver_1',
    name: 'Muhammad Ali',
    vehicle: 'Suzuki Alto',
    vehicleColor: 'White',
    type: 'Car',
    seatsAvailable: 2,
    serving: 'Allied School (Town Campus)',
    serviceArea: 'Hayatabad Phase 6, Peshawar',
    serviceCategory: 'Male',
    monthlyPricePkr: 8000,
    extraNotes: 'Punctual driver with 3 years of experience',
    photoAsset: 'assets/images/svg/person.svg',
    rating: 4.5,
    totalTrips: 156,
    distanceKm: 1.2,
  );
}
