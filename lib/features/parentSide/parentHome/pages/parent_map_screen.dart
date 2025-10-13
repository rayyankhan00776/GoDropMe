// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:godropme/features/parentSide/parentHome/widgets/map_screen_drawer.dart';
import 'package:godropme/features/parentSide/parentHome/widgets/drawer_button.dart';

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({super.key});

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  final ZoomDrawerController _zoomController = ZoomDrawerController();

  static const LatLng _target = LatLng(32.462074, 74.529802);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _target,
    zoom: 14.5,
  );

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _zoomController,
      menuScreen: const MapScreenDrawer(),
      mainScreen: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (c) => _controller = c,
          ),
          // Overlay the glassy button at top-left
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
                child: GlassDrawerButton(
                  onPressed: () => _zoomController.toggle?.call(),
                ),
              ),
            ),
          ),
        ],
      ),
      // Visual tuning for smooth animation
      borderRadius: 24,
      showShadow: true,
      angle: 0.0,
      slideWidth: MediaQuery.of(context).size.width * 0.80,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.easeInOut,
      drawerShadowsBackgroundColor: Colors.black.withOpacity(0.2),
      menuBackgroundColor: Colors.transparent,
    );
  }
}
