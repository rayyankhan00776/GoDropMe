// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/parentHome/controllers/parent_map_controller.dart';

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({super.key});

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  GoogleMapController? _controller;
  final _mapController = Get.put(ParentMapController());

  @override
  void initState() {
    super.initState();
    // Location will be fetched once map is ready in onMapCreated
  }

  Future<void> _initializeLocation() async {
    final position = await _mapController.getCurrentLocation();
    if (position != null && _controller != null) {
      final currentLatLng = LatLng(position.latitude, position.longitude);
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 15),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      showNotificationButton: true,
      body: Scaffold(
        body: Stack(
          children: [
            Obx(() => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(34.0000, 71.57849),
                zoom: 15,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              markers: _mapController.markers.value,
              onMapCreated: (c) {
                _controller = c;
                // Move to current location once map is ready
                _initializeLocation();
              },
              mapType: MapType.normal,
              // Improve interaction responsiveness inside drawer shell
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
            )),

            // Chat button bottom-right
            Positioned(
              right: 16,
              bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
              child: _RoundFab(
                icon: Icons.chat_bubble_outline_sharp,
                onTap: () => Get.toNamed(AppRoutes.parentChat),
              ),
            ),
            // Relocated custom "locate me" button bottom-left (avoid overlap)
            Positioned(
              left: 16,
              bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
              child: Obx(
                () => _RoundFab(
                  icon: Icons.my_location,
                  isLoading: _mapController.isLoadingLocation.value,
                  onTap: () async {
                    final c = _controller;
                    if (c != null) {
                      // Get the actual current location
                      final position = await _mapController.getCurrentLocation();
                      if (position != null) {
                        final currentLatLng = LatLng(
                          position.latitude,
                          position.longitude,
                        );
                        await c.animateCamera(
                          CameraUpdate.newLatLngZoom(currentLatLng, 15),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  
  const _RoundFab({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.9),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.8),
              width: 0.6,
            ),
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }
}
