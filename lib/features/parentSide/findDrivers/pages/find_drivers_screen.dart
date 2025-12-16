import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/findDrivers/models/driver_listing.dart';
import 'package:godropme/features/parentSide/findDrivers/widgets/driver_listing_tile.dart';
import 'package:godropme/features/parentSide/findDrivers/widgets/active_service_tile.dart';
import 'package:godropme/features/parentSide/findDrivers/models/active_service.dart';
import 'package:godropme/features/parentSide/findDrivers/controllers/find_drivers_controller.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';

class FindDriversScreen extends StatefulWidget {
  const FindDriversScreen({super.key});

  @override
  State<FindDriversScreen> createState() => _FindDriversScreenState();
}

class _FindDriversScreenState extends State<FindDriversScreen> {
  late final FindDriversController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(FindDriversController());
  }

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Responsive.scaleClamped(context, 60, 48, 72),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                    child: Text(
                      'Find Drivers',
                      style: AppTypography.optionHeading,
                    ),
                  ),
                  _buildChildSelector(),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grayLight, width: 1),
                    ),
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      dividerHeight: 0,
                      tabs: const [
                        Tab(text: 'Find'),
                        Tab(text: 'Requested'),
                        Tab(text: 'Active'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildFindTab(),
                        _buildRequestedTab(),
                        _buildActiveTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildChildSelector() {
    return Obx(() {
      final children = _controller.children;
      final selectedChildId = _controller.selectedChildId.value;

      if (_controller.isLoadingChildren.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight, width: 1.5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading children...',
                style: AppTypography.optionLineSecondary,
              ),
            ],
          ),
        );
      }

      if (children.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.darkGray),
              const SizedBox(width: 12),
              Text(
                'No children registered',
                style: AppTypography.optionLineSecondary,
              ),
            ],
          ),
        );
      }

      final selectedChild =
          children.firstWhereOrNull((c) => c.id == selectedChildId) ??
          children.first;

      return GestureDetector(
        onTap: () => _showChildPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight, width: 1.5),
          ),
          child: Row(
            children: [
              selectedChild.photoUrl != null
                  ? ClipOval(
                      child: AppwriteImage(
                        imageUrl: selectedChild.photoUrl!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            selectedChild.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        selectedChild.name[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedChild.name,
                      style: AppTypography.optionLineSecondary.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    FutureBuilder<String>(
                      future: _controller.getSchoolName(selectedChild.schoolId),
                      builder: (context, snapshot) {
                        final schoolName = snapshot.data ?? 'School';
                        return Text(
                          'School: $schoolName',
                          style: AppTypography.helperSmall.copyWith(
                            color: AppColors.darkGray,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGray,
                size: 24,
              ),
              const SizedBox(width: 8),
              // Refresh button
              GestureDetector(
                onTap: _controller.isLoadingChildren.value
                    ? null
                    : () => _controller.refreshChildren(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _controller.isLoadingChildren.value
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showChildPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.white,
      builder: (ctx) => SafeArea(
        child: Obx(() {
          final children = _controller.children;
          final selectedChildId = _controller.selectedChildId.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Child',
                style: AppTypography.optionLineSecondary.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...children.map(
                (child) => ListTile(
                  leading: child.photoUrl != null
                      ? ClipOval(
                          child: AppwriteImage(
                            imageUrl: child.photoUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                child.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                  title: Text(child.name),
                  subtitle: Text('Age: ${child.age} • ${child.gender}'),
                  trailing: selectedChildId == child.id
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _controller.selectChild(child.id!);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFindTab() {
    return Obx(() {
      if (_controller.isLoadingDrivers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.availableDrivers.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.loadAvailableDrivers,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.grayLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No drivers found',
                      style: AppTypography.optionLineSecondary.copyWith(
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh',
                      style: AppTypography.helperSmall.copyWith(
                        color: AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      final selectedChild = _controller.selectedChild;
      return RefreshIndicator(
        onRefresh: _controller.loadAvailableDrivers,
        child: ListView.separated(
          itemCount: _controller.availableDrivers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final driver = _controller.availableDrivers[index];
            return DriverListingTile(
              data: driver,
              selectedChildId: _controller.selectedChildId.value,
              selectedChildName: selectedChild?.name ?? '',
              onSendRequest: () => _handleSendRequest(driver),
            );
          },
        ),
      );
    });
  }

  Widget _buildRequestedTab() {
    return Obx(() {
      if (_controller.isLoadingRequests.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 64, color: AppColors.grayLight),
              const SizedBox(height: 16),
              Text(
                'No pending requests',
                style: AppTypography.optionLineSecondary.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your sent requests will appear here',
                style: AppTypography.helperSmall.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _controller.loadPendingRequests,
        child: ListView.separated(
          itemCount: _controller.pendingRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final request = _controller.pendingRequests[index];
            final listing = _requestToListing(request);
            return DriverListingTile(
              data: listing,
              isRequested: true,
              selectedChildId: request['childId'],
              selectedChildName: request['childRef']?['name'] ?? 'Child',
              onCancelRequest: () => _handleCancelRequest(request['id']),
            );
          },
        ),
      );
    });
  }

  Widget _buildActiveTab() {
    return Obx(() {
      if (_controller.isLoadingActiveServices.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_controller.activeServices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: AppColors.grayLight,
              ),
              const SizedBox(height: 16),
              Text(
                'No active services',
                style: AppTypography.optionLineSecondary.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find a driver to get started',
                style: AppTypography.helperSmall.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: _controller.loadActiveServices,
        child: ListView.separated(
          itemCount: _controller.activeServices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final service = _controller.activeServices[index];
            return ActiveServiceTile(
              data: service,
              onEndService: () => _showEndServiceDialog(service),
            );
          },
        ),
      );
    });
  }

  Future<void> _handleSendRequest(DriverListing driver) async {
    await _controller.sendRequest(
      driverId: driver.driverId,
      proposedPrice: driver.monthlyPricePkr.toDouble(),
    );
  }

  Future<void> _handleCancelRequest(String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: TextStyle(color: AppColors.darkGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:  AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _controller.cancelRequest(requestId);
    }
  }

  void _showEndServiceDialog(ActiveService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Service'),
        content: Text(
          'Are you sure you want to end the service with ${service.driverName}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkGray)),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: _controller.isEndingService.value
                  ? null
                  : () async {
                      final success = await _controller.endService(service.id);
                      if (success && ctx.mounted) Navigator.pop(ctx);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _controller.isEndingService.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('End Service'),
            ),
          ),
        ],
      ),
    );
  }

  DriverListing _requestToListing(Map<String, dynamic> request) {
    final driverRef = request['driverRef'] as Map<String, dynamic>?;
    final serviceRef = request['serviceRef'] as Map<String, dynamic>?;
    final vehicleRef = driverRef?['vehicle'] as Map<String, dynamic>?;

    // Build vehicle name from brand + model
    String vehicleName = 'Vehicle';
    if (vehicleRef != null) {
      final brand = vehicleRef['brand']?.toString() ?? '';
      final model = vehicleRef['model']?.toString() ?? '';
      vehicleName = '$brand $model'.trim();
      if (vehicleName.isEmpty) vehicleName = 'Vehicle';
    }

    // Capitalize vehicle type
    String vehicleType = vehicleRef?['vehicleType']?.toString() ?? 'car';
    vehicleType = vehicleType.isEmpty 
        ? 'Car' 
        : vehicleType[0].toUpperCase() + vehicleType.substring(1).toLowerCase();

    return DriverListing(
      driverId: request['driverId'] ?? '',
      name: driverRef?['fullName'] ?? 'Driver',
      vehicle: vehicleName,
      vehicleColor: vehicleRef?['color']?.toString() ?? '',
      type: vehicleType,
      seatsAvailable: (vehicleRef?['seatCapacity'] as num?)?.toInt() ?? 0,
      serving: serviceRef?['schoolNames']?.toString() ?? '',
      serviceArea: serviceRef?['serviceAreaAddress']?.toString() ?? '',
      serviceCategory: serviceRef?['serviceCategory']?.toString() ?? 'Both',
      monthlyPricePkr: (request['proposedPrice'] as num?)?.toInt() ?? 0,
      extraNotes: serviceRef?['extraNotes']?.toString() ?? '',
      photoAsset: '',
      profilePhotoFileId: driverRef?['profilePhotoUrl'],
      rating: (driverRef?['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (driverRef?['totalTrips'] as num?)?.toInt() ?? 0,
    );
  }
}
