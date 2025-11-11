import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  static const LatLng _peshawar = LatLng(34.0151, 71.5249);

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

      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final me = LatLng(pos.latitude, pos.longitude);
      await c.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: me, zoom: 16)),
      );

      if (!mounted) return;
      setState(() {
        _markers.removeWhere((m) => m.markerId == const MarkerId('me'));
        _markers.add(
          Marker(
            markerId: const MarkerId('me'),
            position: me,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
      });
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
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _peshawar,
                zoom: 14,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              padding: const EdgeInsets.only(right: 12, bottom: 80),
              zoomControlsEnabled: false,
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
              onMapCreated: (c) => _mapController = c,
              markers: _markers,
            ),
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
