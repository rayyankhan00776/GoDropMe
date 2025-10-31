import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_avatar.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_caption.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_section.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_tile.dart';
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
  Map<String, dynamic>? _licence;
  Map<String, dynamic>? _identification;
  Map<String, dynamic>? _vehicle;
  Map<String, dynamic>? _service;
  bool _loading = true;

  String _fullName(Map<String, dynamic>? personalInfo, String? fallback) {
    final f = (personalInfo?['firstName'] ?? '').toString().trim();
    final s = (personalInfo?['surName'] ?? '').toString().trim();
    final l = (personalInfo?['lastName'] ?? '').toString().trim();
    final combined = [f, s, l].where((e) => e.isNotEmpty).join(' ');
    if (combined.isNotEmpty) return combined;
    return (fallback ?? '').trim();
  }

  String _maskCnic(String? cnic) {
    if (cnic == null || cnic.trim().isEmpty) return 'Not set';
    final digits = cnic.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 5) return '*****$digits';
    return '*****${digits.substring(digits.length - 5)}';
  }

  String _joinSchools(dynamic schools) {
    if (schools is List) {
      final list = schools
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isEmpty) return 'Not set';
      return list.join(', ');
    }
    return 'Not set';
  }

  Future<void> _loadAll() async {
    final results = await Future.wait<dynamic>([
      LocalStorage.getJson(StorageKeys.personalInfo),
      LocalStorage.getString(StorageKeys.driverName),
      LocalStorage.getJson(StorageKeys.driverLicence),
      LocalStorage.getJson(StorageKeys.driverIdentification),
      LocalStorage.getJson(StorageKeys.vehicleRegistration),
      LocalStorage.getJson(StorageKeys.driverServiceDetails),
    ]);
    if (!mounted) return;
    setState(() {
      _personalInfo = results[0] as Map<String, dynamic>?;
      _driverName = results[1] as String?;
      _licence = results[2] as Map<String, dynamic>?;
      _identification = results[3] as Map<String, dynamic>?;
      _vehicle = results[4] as Map<String, dynamic>?;
      _service = results[5] as Map<String, dynamic>?;
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Avatar + Name
                      Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: DriverProfileAvatar(
                                size: Responsive.scaleClamped(
                                  context,
                                  108,
                                  96,
                                  128,
                                ),
                                imagePath:
                                    _personalInfo?['imagePath'] as String?,
                              ),
                            ),
                            Text(
                              (() {
                                final name = _fullName(
                                  _personalInfo,
                                  _driverName,
                                );
                                return name.isEmpty ? 'Driver' : name;
                              })(),
                              style: AppTypography.optionLineSecondary.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const DriverProfileCaption('Verification'),
                      DriverProfileSection(
                        children: [
                          () {
                            final number = (_licence?['licenceNumber'] ?? '')
                                .toString()
                                .trim();
                            final expiry = (_licence?['expiryDate'] ?? '')
                                .toString()
                                .trim();
                            final sub = [
                              if (number.isNotEmpty) 'Number: $number',
                              if (expiry.isNotEmpty) 'Expiry: $expiry',
                            ].join(' • ');
                            return DriverProfileTile(
                              title: 'Driver Licence',
                              subtitle: sub.isEmpty ? 'Not set' : sub,
                              showIosChevron: true,
                            );
                          }(),
                          DriverProfileTile(
                            title: 'CNIC',
                            subtitle: _maskCnic(
                              (_identification?['cnicNumber'] ?? '').toString(),
                            ),
                            showIosChevron: true,
                          ),
                        ],
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
                                subtitle: _joinSchools(
                                  _service?['schoolNames'],
                                ),
                                showIosChevron: true,
                              ),
                              const Divider(height: 1),
                              DriverProfileTile(
                                title: 'Duty Type',
                                subtitle: (() {
                                  final duty = (_service?['dutyType'] ?? '')
                                      .toString()
                                      .trim();
                                  return duty.isEmpty ? 'Not set' : duty;
                                })(),
                                showIosChevron: true,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const DriverProfileCaption('Account'),
                      DriverProfileSection(
                        children: const [
                          // Terms opens external link
                          // Using non-const onTap wrapper below
                        ],
                      ),
                      // Use a separate section to keep onTap non-const
                      DriverProfileSection(
                        children: [
                          DriverProfileTile(
                            title: AppStrings.drawerTerms,
                            onTap: () async => termsUriOpener(),
                          ),
                          const Divider(height: 1),
                          const DriverProfileTile(
                            title: AppStrings.drawerLogout,
                          ),
                          const Divider(height: 1),
                          const DriverProfileTile(
                            title: 'Delete Account',
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
