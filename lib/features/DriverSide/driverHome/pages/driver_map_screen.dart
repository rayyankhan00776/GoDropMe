import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/DriverSide/driverHome/controllers/driver_home_controller.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  static const LatLng _peshawar = LatLng(34.0151, 71.5249);
  
  // Use controller for data management
  late final DriverHomeController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize or find controller
    _controller = Get.put(DriverHomeController());
    // Location will be fetched once map is ready in onMapCreated
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final c = _mapController;
    if (c == null) return;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showMessage('Location permission denied.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission permanently denied. Please enable it in Settings.',
        );
        return;
      }

      // Prefer a fresh high-accuracy fix first to avoid stale defaults (e.g., Googleplex).
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } on TimeoutException {
        pos = await Geolocator.getLastKnownPosition();
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        _showMessage('Unable to get current location.');
        return;
      }

      final me = LatLng(pos.latitude, pos.longitude);
      await c.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: me, zoom: 16)),
      );

      // Update driver location marker via controller
      _controller.updateDriverLocation(me);
    } catch (e) {
      _showMessage('Unable to get current location.');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DriverDrawerShell(
        showNotificationButton: true,
        body: Stack(
          children: [
            Obx(() => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _peshawar,
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              padding: const EdgeInsets.only(right: 12, bottom: 80),
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              // Improve gesture responsiveness inside scrollable/drawer shells
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              onMapCreated: (c) {
                _mapController = c;
                // Move to current location once map is ready
                _goToCurrentLocation();
              },
              markers: _controller.markers.value,
            )),
            Positioned(
              left: 16,
              bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
              child: _RoundFab(
                icon: Icons.my_location,
                onTap: () async {
                  await _goToCurrentLocation();
                },
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
  const _RoundFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }
}
