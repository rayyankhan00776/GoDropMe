import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_caption.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_section.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_tile.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/profile_header.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/profile_documents_section.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/profile_actions_section.dart';
import 'package:godropme/features/driverSide/driverProfile/utils/profile_utils.dart';
import 'package:godropme/services/Terms_uri_opener.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  Map<String, dynamic>? _personalInfo;
  String? _driverName;
  String? _driverPhone;
  Map<String, dynamic>? _licence;
  Map<String, dynamic>? _identification;
  Map<String, dynamic>? _vehicle;
  Map<String, dynamic>? _service;
  bool _loading = true;

  // Helpers moved to profile_utils.dart

  Future<void> _loadAll() async {
    final results = await Future.wait<dynamic>([
      LocalStorage.getJson(StorageKeys.personalInfo),
      LocalStorage.getString(StorageKeys.driverName),
      LocalStorage.getString(StorageKeys.driverPhone),
      LocalStorage.getJson(StorageKeys.driverLicence),
      LocalStorage.getJson(StorageKeys.driverIdentification),
      LocalStorage.getJson(StorageKeys.vehicleRegistration),
      LocalStorage.getJson(StorageKeys.driverServiceDetails),
    ]);
    if (!mounted) return;
    setState(() {
      _personalInfo = results[0] as Map<String, dynamic>?;
      _driverName = results[1] as String?;
      _driverPhone = results[2] as String?;
      _licence = results[3] as Map<String, dynamic>?;
      _identification = results[4] as Map<String, dynamic>?;
      _vehicle = results[5] as Map<String, dynamic>?;
      _service = results[6] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return DriverDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    // Leave space beneath the overlaid drawer button
                    SizedBox(
                      height: Responsive.scaleClamped(context, 60, 48, 72),
                    ),

                    // Title centered
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          AppStrings.profileTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.optionHeading,
                        ),
                      ),
                    ),

                    // Avatar + Name (refactored)
                    ProfileHeader(
                      personalInfo: _personalInfo,
                      displayName: fullNameFromPersonalInfo(
                        _personalInfo,
                        _driverName,
                      ),
                    ),

                    const DriverProfileCaption('Verification'),
                    ProfileDocumentsSection(
                      licence: _licence,
                      identification: _identification,
                    ),

                    const DriverProfileCaption('Vehicle'),
                    DriverProfileSection(
                      children: [
                        Column(
                          children: [
                            DriverProfileTile(
                              title: 'Vehicle',
                              subtitle: [
                                (_vehicle?['brand'] ?? '').toString().trim(),
                                (_vehicle?['model'] ?? '').toString().trim(),
                              ].where((e) => e.isNotEmpty).join(' '),
                              showIosChevron: true,
                            ),
                            const Divider(height: 1),
                            DriverProfileTile(
                              title: 'Seat Capacity',
                              subtitle: _vehicle?['seatCapacity'] == null
                                  ? 'Not set'
                                  : _vehicle!['seatCapacity'].toString(),
                              showIosChevron: true,
                            ),
                            const Divider(height: 1),
                            DriverProfileTile(
                              title: 'Number Plate',
                              subtitle: (() {
                                final p = (_vehicle?['plate'] ?? '')
                                    .toString()
                                    .trim();
                                return p.isEmpty ? 'Not set' : p;
                              })(),
                              showIosChevron: true,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const DriverProfileCaption('Service details'),
                    DriverProfileSection(
                      children: [
                        Column(
                          children: [
                            DriverProfileTile(
                              title: 'School(s)',
                              subtitle: joinSchools(_service?['schoolNames']),
                              showIosChevron: true,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const DriverProfileCaption('Account'),
                    ProfileActionsSection(
                      phoneNumber: _driverPhone,
                      onOpenTerms: () async => termsUriOpener(),
                      // Keep logout and delete as no-ops here to preserve behavior
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
