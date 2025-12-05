import 'package:flutter/material.dart';
import 'driver_profile_section.dart';
import 'driver_profile_tile.dart';
import '../utils/profile_utils.dart';

class ProfileDocumentsSection extends StatelessWidget {
  final Map<String, dynamic>? licence;
  final Map<String, dynamic>? identification;
  const ProfileDocumentsSection({
    super.key,
    required this.licence,
    required this.identification,
  });

  @override
  Widget build(BuildContext context) {
    final number = (licence?['licenceNumber'] ?? '').toString().trim();
    // Support both new 'licenseExpiry' and old 'expiryDate' keys
    final expiry = (licence?['licenseExpiry'] ?? licence?['expiryDate'] ?? '').toString().trim();
    final sub = [
      if (number.isNotEmpty) 'Number: $number',
      if (expiry.isNotEmpty) 'Expiry: $expiry',
    ].join(' • ');

    return DriverProfileSection(
      children: [
        DriverProfileTile(
          title: 'Driver Licence',
          subtitle: sub.isEmpty ? 'Not set' : sub,
          showIosChevron: true,
        ),
        DriverProfileTile(
          title: 'CNIC',
          subtitle: maskCnic((identification?['cnicNumber'] ?? '').toString()),
          showIosChevron: true,
        ),
      ],
    );
  }
}
