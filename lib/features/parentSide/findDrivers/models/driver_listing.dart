class DriverListing {
  final String name;
  final String vehicle; // e.g., "Suzuki Alto"
  final String vehicleColor; // e.g., "White"
  final String type; // e.g., "Car" or "Rikshaw"
  final int seatsAvailable;
  final String serving; // e.g., school name or area
  final String pickupRange; // e.g., "3 km"
  final String fare; // e.g., "Rs. 2500/month"
  final String operatingDays; // e.g., "Mon–Fri"
  final String dutyType; // e.g., "Morning"
  final String extraNotes;
  final String photoAsset; // asset path for photo/svg

  const DriverListing({
    required this.name,
    required this.vehicle,
    required this.vehicleColor,
    required this.type,
    required this.seatsAvailable,
    required this.serving,
    required this.pickupRange,
    required this.fare,
    required this.operatingDays,
    required this.dutyType,
    required this.extraNotes,
    required this.photoAsset,
  });

  // Single dummy entry requested for now.
  static DriverListing demo() => const DriverListing(
    name: 'Muhammad Ali',
    vehicle: 'Suzuki Alto',
    vehicleColor: 'White',
    type: 'Car',
    seatsAvailable: 2,
    serving: 'Allied School (Town Campus)',
    pickupRange: '3 km',
    fare: 'Rs. 2500/month',
    operatingDays: 'Mon–Fri',
    dutyType: 'Morning',
    extraNotes: 'Punctual driver with 3 years of experience',
    photoAsset: 'assets/images/svg/person.svg',
  );
}
