// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({super.key});

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  static const LatLng _target = LatLng(32.462074, 74.529802);
  // static const CameraPosition _initialCameraPosition = CameraPosition(
  // target: _target,
  // zoom: 14.5,
  // );

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(34.0000, 71.57849),
                zoom: 15,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (c) => _controller = c,
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
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('target'),
                  position: _target,
                  infoWindow: const InfoWindow(title: 'Target Location'),
                ),
              },
            ),

            // Rounded chat button at bottom-left
            Positioned(
              right: 16,
              bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.offNamed(AppRoutes.parentChat);
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      border: Border.all(
                        color: AppColors.primaryDark.withOpacity(0.8),
                        width: 0.6,
                      ),
                      shape: BoxShape.circle,
                      // boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 8)],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_sharp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
